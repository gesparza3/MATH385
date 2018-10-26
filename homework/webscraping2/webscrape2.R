################################################################################
# Load libraries
################################################################################

library(httr)
library(knitr)
library(dplyr)
library(ggplot2)
library(ggExtra)
library(stringr)
library(RSQLite)
library(lubridate)
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
colnames(aqi.df) <- c("region", "subregion", "state.code", "county.code", "date",
                      "aqi", "category", "defining.parameter", "defining.site",
                      "number.of.sites.reporting")
aqi.df$date <- year(aqi.df$date)

################################################################################
# Generate AQI statistics
################################################################################

## Get a tibble
montana.aqi <- aqi.df %>%
  filter(region == "Montana") %>%
  group_by(date, subregion) %>%
  summarise(mn_aqi=mean(aqi), md_aqi=median(aqi))

################################################################################
# Read wildfire data
################################################################################

## Extract fire table from database
db <-dbConnect(SQLite(), "fire_database.sqlite")
res <- dbSendQuery(db, "SELECT * FROM Fires WHERE State == 'MT'")
fires <- dbFetch(res)

################################################################################
# Generate fire statistics
################################################################################

## Get a tibble
montana.fires <- fires %>%
    group_by(FIRE_YEAR, FIPS_NAME) %>%
    summarise(num_fires=n(), mn_fire_size=mean(FIRE_SIZE),
              sum_fire_size=sum(FIRE_SIZE))

################################################################################
# Join data
################################################################################

## Rename columns for join
colnames(montana.fires)[colnames(montana.fires) == "FIRE_YEAR"] <- "date"
colnames(montana.fires)[colnames(montana.fires) == "FIPS_NAME"] <- "subregion"

## Join
montana.comp <- montana.aqi %>%
  inner_join(montana.fires, by=c("subregion", "date"))

## Switch case
montana.comp$subregion <- tolower(montana.comp$subregion)

################################################################################
# Plot map of AQI
################################################################################

## Get county data
counties <- map_data("county") %>%
  filter(region == "montana")

## Join with montana data
geo.dat <- montana.comp %>% inner_join(counties, by="subregion")

## Plot US map with data
ggplot(data=counties, aes(x=long, y=lat, group=group)) +
    coord_fixed(1.3) +
    geom_polygon(color="black", fill="gray") +
    geom_polygon(data=geo.dat, aes(fill=mn_aqi), color="black") +
    scale_fill_gradient2(low="#FFFFE0", mid="#FEB24C", high="#CD0000") +
    theme_void()

################################################################################
# Plot the data
################################################################################

## Select western counties
montana.western <- montana.comp %>%
  filter(subregion %in% c("Lincoln", "Flathead", "Sanders", "Lake", "Missoula",
                        "Ravalli", "Powell"))

## Number of fires explains mean_aqi
p <- ggplot(montana.western, aes(log(num_fires), log(mn_aqi))) +
  geom_point(aes(color=subregion)) +
  stat_smooth(method="lm", se=FALSE)

## Add margin plots
ggMarginal(p, type="boxplot")

################################################################################
# Create a model
################################################################################

summary(lm(log(mn_aqi)~log(num_fires), data=montana.western))


