## Load libaries
library(httr)
library(xml2)
library(stringr)
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

## Add data
for (link in complete_links[1:14]) {
  get_request <- GET(link)
  bin_data <- content(get_request, "raw")
  writeBin(bin_data, "daily-county-aqi")
  unzip(zipfile="daily-county-aqi", exdir="aqi")
}

################################################################################

## Manipulate data
file_path <- "aqi/daily_aqi_by_county_"
aqi.dat <- data.frame(State.Name=factor(),
                      county.Name=factor(),
                      State.Code=factor(),
                      County.Code=integer(),
                      Data=factor(),
                      AQI=integer(),
                      Category=factor(),
                      Defining.Parameter=factor(),
                      Defining.Site=factor(),
                      Number.of.Sites.Reporting=integer())

n <- 0
## Determine size of dataframe
for (year in 2005:2015) {
  file <- str_c("cat ", file_path, year, ".csv", " | wc -l")
  n <- n + as.numeric(system(file, intern=TRUE)) - 1
}

multmerge = function(path){
  filenames=list.files(path=path, full.names=TRUE)
  rbindlist(lapply(filenames, fread))
}

library(data.table)
aqi.dat <- multmerge("aqi")

write.csv(aqi.dat, "aqi_2005-2015.csv")

data <- read.csv("aqi_1980-2015.csv")
