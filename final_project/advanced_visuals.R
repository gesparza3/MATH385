## Load libraries
library(ggplot2)
library(RSQLite)
library(dplyr)
library(ggrepel)
library(boot)

##################################SQL CLEANUP###################################

## Extract fire table from database
db <-dbConnect(SQLite(), "fire_database.sqlite")
res <- dbSendQuery(db, "SELECT * FROM Fires WHERE State == 'CA'")
cal_fires <- dbFetch(res)
dbDisconnect(db)

################################################################################

## USE DISCOVERY_DOY AND DISCOVER_YEAR

## Column names
colnames(cal_fires)
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

################################################################################

## Get a tibble
cal_fires %>%
  filter(STAT_CAUSE_DESCR == "Arson") %>%
  group_by(FIPS_NAME) %>%
  summarise(n=n(), mn_size=mean(FIRE_SIZE), sum_size=sum(FIRE_SIZE)) -> num_fires
num_fires <- num_fires[1:57,]

################################################################################

## Histogram of fire_size caused by arson
ggplot(num_fires, aes(sum_size)) +
  geom_histogram(bins=40) +
  ggtitle("Total Acres Burned 1992-2015") +
  xlab("Total Acres Burned per County") + ylab("Count") +
  scale_x_continuous(labels = scales::comma) +
  theme_minimal() +
  theme(axis.title.x = element_text(face = "italic"),
        axis.title.y = element_text(face = "italic"),
        title = element_text(face = "bold"))

  ################################################################################

  ## Make plot of num_fires to average fire size
  ggplot(num_fires, aes(log(n), log(sum_size))) + geom_point()

  ## Linear Regression
  fire_mod <- lm(data=num_fires, sum_size ~ n)
  summary(fire_mod)

  ################################################################################

  ## Summary Stats
  summarise(num_fires, Mean = mean(sum_size), Median = median(sum_size),
            Std_dev = sd(sum_size), IQR = IQR(sum_size))

  ################################################################################

  ## Bootstrap CIs
  mean_sample_data <- function(data, idx) {
    mean(data[idx]) ## Mean of a vector
  }

  b <- boot(num_fires$sum_size, mean_sample_data, R=999)
  boot.ci(b, type="perc")

  median_sample_data <- function(data, idx) {
    median(data[idx]) ## Mean of a vector
  }

  b <- boot(num_fires$sum_size, median_sample_data, R=999)
  boot.ci(b, type="perc")

  sd_sample_data <- function(data, idx) {
    sd(data[idx]) ## Mean of a vector
  }

  b <- boot(num_fires$sum_size, sd_sample_data, R=999)
  boot.ci(b, type="perc")


  ################################################################################

  ## Map plot
  counties <- map_data("county") %>% filter(region == "california")

  ## Fix county names
  colnames(num_fires) <- c("subregion", "num_fires", "mn_fire_size", "sum_fire_size")

  ## Fix subregion names
  num_fires$subregion <- tolower(num_fires$subregion)

  ## Plot
  cal_map <- ggplot(data=counties, aes(x=long, y=lat, group=group)) +
    coord_fixed(1.3) +
    geom_polygon(color="black", fill="gray")

  ## Join datasets
  fire_map <- inner_join(counties, num_fires, by="subregion")

  ## Plot map with data
  fire_base_map <- cal_map +
    geom_polygon(data=fire_map, aes(fill=sum_fire_size), color="black") +
    geom_point(data=biggest_fire, aes(x=long, y=lat), inherit.aes=FALSE, size=3) +
    geom_label_repel(data=biggest_fire, aes(x=long, y=lat, label = FIRE_YEAR),
                     box.padding   = 0.35,
                     point.padding = 0.5,
                     segment.color = 'grey50', inherit.aes=FALSE) +
scale_fill_gradient2(trans="log10", low="#FFFFE0", mid="#FEB24C", high="#CD0000") +
ggtitle("Total Acres Burned by County 1992-2015") +
labs(fill="Total Acres Burned") +
theme_void() +
theme(title = element_text(face="bold"))

################################################################################

## Create tibble of biggest fire per year
cal_fires %>%
  group_by(FIRE_YEAR) %>%
  summarise(max=which.max(FIRE_SIZE),
            subregion=cal_fires[which.max(FIRE_SIZE),]$FIPS_NAME,
            long=cal_fires[which.max(FIRE_SIZE),]$LONGITUDE,
            lat=cal_fires[which.max(FIRE_SIZE),]$LATITUDE) -> biggest_fire


  ## Plot with points
  fire_base_map +
    geom_point(data=biggest_fire, aes(x=long, y=lat))
