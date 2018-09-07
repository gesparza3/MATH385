## Load libraries
library(ggplot2)
library(dplyr)

## Read data
comp_dat <- read.csv("lobbyist-data-compensation.csv")
contribute_dat <- read.csv("lobbyist-data-contributions.csv")

## Select variables of interest
comp_dat <- comp_dat %>% select(LOBBYIST_ID, COMPENSATION_AMOUNT)
contribute_dat <- contribute_dat %>% select(LOBBYIST_ID, AMOUNT)

## Join datasets
lobby_dat  <- inner_join(comp_dat, contribute_dat, on = c("LOBBYIST_ID" = "LOBBYIST_ID"))
lobby_dat[, "LOBBYIST_ID"] <- as.factor(lobby_dat[, "LOBBYIST_ID"])

## Group by lobbyist, calculate sum for comp and contriubtion
lobby_summary <- lobby_dat %>% 
  group_by(LOBBYIST_ID) %>% 
  summarise(comp_sum = sum(COMPENSATION_AMOUNT), contrib_sum = sum(AMOUNT))

## Plot linear regression
ggplot(lobby_summary, aes(log(comp_sum), log(contrib_sum))) +
         geom_point() +
         stat_smooth(method="lm")

