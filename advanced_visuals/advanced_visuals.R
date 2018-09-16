## Load libraries
library(ggplot2)
library(RSQLite)
library(dplyr)

##################################SQL CLEANUP###################################

## Extract fire table from database
db <-dbConnect(SQLite(), "fire_database.sqlite") 
fire.dat <- tbl(db, "Fires") %>% collect()

## Grab only the fires from California
cal_fires <- fire.dat %>% filter(STATE == "CA")

## Write table to csv for ease of use
write.csv(cal_fires, "cal_wildfires.csv")

################################################################################

## Read csv into cal_fires
cal_fires <- read.csv("cal_wildfires.csv")
