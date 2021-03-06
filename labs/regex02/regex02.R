## Load libraries
library(httr)
library(ggplot2)
library(stringr)
library(ggplot2)
library(dplyr)

################################################################################

### Incomplete web links
get_request <- GET("https://aqs.epa.gov/aqsweb/airdata/download_files.html#AQI")
html <- content(get_request, "text")
incomplete_links <- as.data.frame(str_match_all(html, pattern="<a href=\"daily.*county_[0-9]{4}\\.zip\">"))

## Split 
incomp_links <- as.data.frame(str_split_fixed(incomplete_links[,1], pattern="\"", 3))
colnames(incomp_links) <- c("href", "link", "end")

## Add home url
complete_links <- paste("https://aqs.epa.gov/aqsweb/airdata/", incomp_links$link, sep="")

################################################################################

## Add urls to directory
folder <- '~/home/gesparza3/MATH385/labs/regex02/aqi_data'
r <- character()
for (i in incomp_links$link) {
  r <- c(r, file.path(folder, i))
}

head(r)

################################################################################

## Using httr
get_request <- GET("https://aqs.epa.gov/aqsweb/airdata/daily_aqi_by_county_2016.zip")
bin_data <- content(get_request, "raw") 
writeBin(bin_data, "daily-county-aqi")
unzip(zipfile="daily-county-aqi")

## Read in data
aqi.df <- read.csv("daily_aqi_by_county_2016.csv")

## Create map of US
counties <- map_data("county")

## Fix aqi names
colnames(aqi.df) <- c("region", "subregion", "state.code", "county.code", "date",
                      "aqi", "category", "defining.parameter", "defining.site",
                      "number.of.sites.reporting")
aqi.df$region <- tolower(aqi.df$region)
aqi.df$subregion <- tolower(aqi.df$subregion)

## Generate mean aqi per county
aqi.county <- aqi.df %>%
  group_by(subregion) %>%
  summarise(mn_aqi=mean(aqi), md_aqi=median(aqi))

## Join stat data
aqi.map <- inner_join(counties, aqi.county, by="subregion")

## Plot US map with data
ggplot(data=counties, aes(x=long, y=lat, group=group)) +
    coord_fixed(1.3) + 
    geom_polygon(color="black", fill="gray") + 
    geom_polygon(data=aqi.map, aes(fill=mn_aqi), color="black") +
    scale_fill_gradient2(low="#FFFFE0", mid="#FEB24C", high="#CD0000") +
    theme_void()

################################################################################

## Look at Montana 
montana.dat <- aqi.map %>% filter(region == "montana")

ggplot(data=counties[counties$region == "montana",], aes(x=long, y=lat, group=group)) +
    coord_fixed(1.3) + 
    geom_polygon(color="black", fill="gray") + 
    geom_polygon(data=montana.dat, aes(fill=mn_aqi), color="black") +
   scale_fill_gradient2(low="#FFFFE0", mid="#FEB24C", high="#CD0000") +
    theme_void()
