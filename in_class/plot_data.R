library(ggplot2)
library(ape)
library(dplyr)
data(carnivora) # Dataframe from package

## Plot for average weaning age
mnWA <- mean(carnivora$WA, na.rm=TRUE)
ggplot(carnivora, aes(WA)) +
    geom_histogram(bins=11) +
    geom_vline(xintercept = mnWA, color="red")

## Box plot for weaning age
ggplot(carnivora, aes(factor(Family), WA)) +
       geom_boxplot() +
       stat_summary(fun.y=mean, geom="point", shape=23, size=4, color="red") + 
       theme(axis.text.x = element_text(hjust = 1, angle = 45))

## Summaries with dplyr
carnivora %>%
    group_by(Family) %>%
    summarise(mnWeaningAge = mean(WA, na.rm=TRUE), mnBirthWeight = mean(BW, na.rm=TRUE))

## Linear Regression
carnivora %>%
    ggplot(aes(BW, WA)) + 
    geom_point() + 
    geom_smooth(method="lm")
