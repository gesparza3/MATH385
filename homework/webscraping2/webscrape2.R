################################################################################
# Load libraries
################################################################################

library(httr)
library(knitr)
library(dplyr)
library(ggplot2)
library(stringr)
library(RSQLite)
library(gridExtra)
library(data.table)


################################################################################
# Match links
################################################################################

## Incomplete web links
get_request <- GET("https://aqs.epa.gov/aqsweb/airdata/download_files.html#AQI")
html <- content(get_request, "text")
incomplete_links <- as.data.frame(
                      str_match_all(
                        html, pattern="<a href=\"daily.*county_[0-9]{4}\\.zip\">"
                      ) ## str_match_all
                    ) ## as.data.frame

## Split
incomp_links <- as.data.frame(str_split_fixed(incomplete_links[,1], pattern="\"", 3))
colnames(incomp_links) <- c("href", "link", "end")

## Add home url
complete_links <- paste("https://aqs.epa.gov/aqsweb/airdata/", incomp_links$link, sep="")

################################################################################
# Add data to folder
################################################################################

## Add data
for (link in complete_links[4:14]) {
  get_request <- GET(link)
  bin_data <- content(get_request, "raw")
  writeBin(bin_data, "daily-county-aqi")
  unzip(zipfile="daily-county-aqi", exdir="aqi")
}

################################################################################
# Manipulate data
################################################################################

files <- list.files(path="aqi", full.names=TRUE)
aqi.df <- rbindlist(lapply(files, fread))

################################################################################
# Read wildfire data
################################################################################

## Extract fire table from database
db <-dbConnect(SQLite(), "fire_database.sqlite")
res <- dbSendQuery(db, "SELECT * FROM Fires WHERE State == 'MT'")
montana_fires <- dbFetch(res)

################################################################################
# Generate statistics
################################################################################

## Get a tibble
montana_fires %>%
    group_by(FIPS_NAME) %>%
    summarise(n=n(), mn_size=mean(FIRE_SIZE), sum_size=sum(FIRE_SIZE)) -> num_fires
  num_fires <- num_fires[1:56,]

################################################################################
# Plot fire data
################################################################################

## Map plot
counties <- map_data("county") %>% filter(region == "montana")

## Fix county names
colnames(num_fires) <- c("subregion", "num_fires", "mn_fire_size", "sum_fire_size")

## Fix subregion names
num_fires$subregion <- tolower(num_fires$subregion)

## Plot
montana_map <- ggplot(data=counties, aes(x=long, y=lat, group=group)) +
    coord_fixed(1.3) +
    geom_polygon(color="black", fill="gray")

## Join datasets
fire_map <- inner_join(counties, num_fires, by="subregion")

## Plot map with data
fire_base_map <- montana_map +
    geom_polygon(data=fire_map, aes(fill=num_fires), color="black") +
    ggtitle("Total Acres Burned by County 1992-2015") +
    scale_fill_gradient2(trans="log10", low="#FFFFE0", mid="#FEB24C", high="#CD0000") +
    labs(fill="Total Acres Burned") +
    theme_void() +
    theme(title = element_text(face="bold"))

################################################################################
# Plot aqi data
################################################################################

counties <- map_data("county")

## Fix aqi names
colnames(aqi.df) <- c("region", "subregion", "state.code", "county.code", "date",
                      "aqi", "category", "defining.parameter", "defining.site",
                      "number.of.sites.reporting")
aqi.df$region <- tolower(aqi.df$region)
aqi.df$subregion <- tolower(aqi.df$subregion)

## Select montana
montana.dat <- aqi.df %>% filter(region == "montana")

## Generate mean aqi per county
aqi.county <- aqi.df %>%
  group_by(subregion) %>%
  summarise(mn_aqi=mean(aqi), md_aqi=median(aqi))

## Join stat data
aqi.map <- inner_join(counties, aqi.county, by="subregion")

ggplot(data=counties[counties$region == "montana",], aes(x=long, y=lat, group=group)) +
    coord_fixed(1.3) +
    geom_polygon(color="black", fill="gray") +
    geom_polygon(data=aqi.county, aes(fill=mn_aqi), color="black") +
    scale_fill_gradient2(low="#FFFFE0", mid="#FEB24C", high="#CD0000") +
    theme_void()
