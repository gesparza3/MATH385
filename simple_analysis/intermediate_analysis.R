## Load libraries
library(ggplot2)
library(dplyr)

## Read data
comp_dat <- read.csv("lobbyist-data-compensation.csv")
contribute_dat <- read.csv("lobbyist-data-contributions.csv")

## Join datasets
lobby_dat  <- 
    inner_join(comp_dat, contribute_dat, on = "LOBBYIST_ID") %>%
    select(LOBBYIST_ID, COMPENSATION_AMOUNT, 'RECIPIENT AMOUNT')
