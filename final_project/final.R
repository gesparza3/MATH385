## Load libraries
library(ggplot2)
library(dplyr)
library(BAS)

## Read data

cars <- read.csv("https://roualdes.us/data/cars.csv")


## Plot
ggplot(cars, aes(x=weight, y=mpgCity)) + geom_point() + stat_smooth(method="lm")

## Correlation
cor(cars$weight, cars$mpgCity)

qplot(cars$mpgCity, geom="histogram")

qplot(as.factor(cars$type), cars$mpgCity, geom="boxplot")
ggplot(cars, aes(x=price, y=mpgCity)) + geom_point() + stat_smooth(method="lm")
qplot(as.factor(cars$driveTrain), cars$mpgCity, geom="boxplot")
qplot(as.factor(cars$passengers), cars$mpgCity, geom="boxplot")
ggplot(cars, aes(x=weight, y=mpgCity)) + geom_point() + stat_smooth(method="lm")


## build mlr
summary(lm(mpgCity ~ type + price + driveTrain + passengers + weight, data=cars))
summary(lm(mpgCity ~ type + driveTrain + passengers + weight, data=cars))

summary(lm(mpgCity ~ type + passengers + weight, data=cars))

## Bayes stuff
car_bays <- BAS::bas.lm(mpgCity ~., data=cars, method="MCMC", prior="ZS-null", modelprior=uniform())
