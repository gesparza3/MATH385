## Load libraries
library(ggplot2)
library(RSQLite)
library(dplyr)
library(stringr)
library(httr)
library(data.table)
library(lubridate)
library(purrr)

################################################################################

## USE DISCOVERY_DOY AND DISCOVER_YEAR

## Column names
colnames(wc_fires)
#  [1] "OBJECTID"                   "FOD_ID"
#  [3] "FPA_ID"                     "SOURCE_SYSTEM_TYPE"
#  [5] "SOURCE_SYSTEM"              "NWCG_REPORTING_AGENCY"
#  [7] "NWCG_REPORTING_UNIT_ID"     "NWCG_REPORTING_UNIT_NAME"
#  [9] "SOURCE_REPORTING_UNIT"      "SOURCE_REPORTING_UNIT_NAME"
# [11] "LOCAL_FIRE_REPORT_ID"       "LOCAL_INCIDENT_ID"
# [13] "FIRE_CODE"                  "FIRE_NAME"
# [15] "ICS_209_INCIDENT_NUMBER"    "ICS_209_NAME"
# [17] "MTBS_ID"                    "MTBS_FIRE_NAME"
# [19] "COMPLEX_NAME"               "FIRE_YEAR"
# [21] "DISCOVERY_DATE"             "DISCOVERY_DOY"
# [23] "DISCOVERY_TIME"             "STAT_CAUSE_CODE"
# [25] "STAT_CAUSE_DESCR"           "CONT_DATE"
# [27] "CONT_DOY"                   "CONT_TIME"
# [29] "FIRE_SIZE"                  "FIRE_SIZE_CLASS"
# [31] "LATITUDE"                   "LONGITUDE"
# [33] "OWNER_CODE"                 "OWNER_DESCR"
# [35] "STATE"                      "COUNTY"
# [37] "FIPS_CODE"                  "FIPS_NAME"
# [39] "Shape"

##################################SQL CLEANUP###################################

## Extract fire table from database
db <-dbConnect(SQLite(), "fire_db.sqlite")
res <- dbSendQuery(db, "SELECT * FROM Fires WHERE State == 'CA' OR State == 'OR' OR State == 'WA'")
wc_fires <- dbFetch(res)

################################################################################

## Get a tibble of west coast fires
wc_fires %>%
  select(DISCOVERY_DATE, DISCOVERY_DOY, FIRE_YEAR, CONT_DOY, FIRE_SIZE,
         STATE, FIPS_CODE, FIPS_NAME, STATE, STAT_CAUSE_CODE) %>%
filter(FIRE_SIZE > 300.0) -> wc_fires

## Clear result and disconnect from database
dbClearResult(res)
dbDisconnect(db)

## Tidy data
colnames(wc_fires) <- tolower(colnames(wc_fires))

wc_fires$discovery_date <- wc_fires$discovery_date %>%
  as.Date(origin = structure(-2440588, class="Date"))

wc_fires$state <- tolower(state.name[match(wc_fires$state, state.abb)])
wc_fires$fips_name <- tolower(wc_fires$fips_name)

wc_fires$fire_length <- wc_fires$cont_doy - wc_fires$discovery_doy
wc_fires$psudeo_length <- ifelse(wc_fires$fire_length < 0, wc_fires$fire_length + 365, wc_fires$fire_length)
wc_fires$cont_date <- wc_fires$discovery_date + days(wc_fires$fire_length)
wc_fires$fire_length <- interval(wc_fires$discovery_date, wc_fires$cont_date)

################################################################################
# Load AQI data
################################################################################

## Grab html
get_request <- GET("https://aqs.epa.gov/aqsweb/airdata/download_files.html#AQI")
html <- content(get_request, "text")

## Find links
incomplete_links <- as.data.frame(str_match_all(html, pattern="<a href=\"daily.*county_[0-9]{4}\\.zip\">"))

## Split
incomp_links <- as.data.frame(str_split_fixed(incomplete_links[,1], pattern="\"", 3))
colnames(incomp_links) <- c("href", "link", "end")

## Add home url
complete_links <- paste("https://aqs.epa.gov/aqsweb/airdata/", incomp_links$link, sep="")

#Add data to folder
for (link in complete_links[4:14]) {
  get_request <- GET(link)
  bin_data <- content(get_request, "raw")
  writeBin(bin_data, "daily-county-aqi")
  unzip(zipfile="daily-county-aqi", exdir="aqi")
}

## Read csvs
files <- list.files(path="aqi", full.names=TRUE)

## Stack datasets
aqi.df <- rbindlist(lapply(files, fread))

## Tidy the data
colnames(aqi.df) <- c("region", "subregion", "state.code", "county.code", "date",
                      "aqi", "category", "defining.parameter", "defining.site",
                      "number.of.sites.reporting")
aqi.df %>% filter(region %in% c("California", "Washington", "Oregon")) -> aqi.df
aqi.df$subregion <- tolower(aqi.df$subregion)
aqi.df$region <- tolower(aqi.df$region)
################################################################################

wc.fires <- wc_fires %>%
    group_by(fire_year, fips_name, state) %>%
    summarise(num_fires=n(), mn_fire_size=mean(fire_size),
              sum_fire_size=sum(fire_size))
