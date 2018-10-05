## Load libraries
library(httr)
library(ggplot2)
library(stringr)

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

