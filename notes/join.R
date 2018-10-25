################################################################################
# Load libraries
################################################################################

library(ggplot2)
library(dplyr)

################################################################################
# Read data
################################################################################

aqi.df <- read.csv("daily_aqi_by_county_2017.csv")
states <- map_data("state")
counties <- map_data("county")

################################################################################
# Manipulate data
################################################################################

## Fix aqi names
colnames(aqi.df) <- c("region", "subregion", "state.code", "county.code", "date",
                      "aqi", "category", "defining.parameter", "defining.site",
                      "number.of.sites.reporting")
aqi.df$region <- tolower(aqi.df$region)
aqi.df$subregion <- tolower(aqi.df$subregion)

################################################################################
# Generate statistics per state
################################################################################

## Generate mean aqi per state
aqi.states <- aqi.df %>%
  group_by(region) %>%
  summarise(mn_aqi=mean(aqi), md_aqi=median(aqi))

################################################################################
# Join datasets for state
################################################################################

df_plot_state <- aqi.states %>%
  left_join(states, by="region")

################################################################################
# Make plot for US
################################################################################

ggplot() +
  geom_polygon(data=df_plot_state, aes(long, lat, group=group, fill=mn_aqi)) +
  coord_fixed(1.3)

################################################################################
# Generate county data for Montana
################################################################################

aqi.montana <- aqi.df %>% filter(region == "montana")
montana.counties <- counties %>% filter(region == "montana")

## Generate mean aqi per county
aqi.county <- aqi.montana %>%
  group_by(subregion) %>%
  summarise(mn_aqi=mean(aqi), md_aqi=median(aqi))

################################################################################
# Join datasets for Montana counties
################################################################################

df_plot_counties <- aqi.county %>%
  left_join(montana.counties, by="subregion")

################################################################################
# Make plot for Montana                                                        #
################################################################################

ggplot(data=montana.counties, aes(x=long, y=lat, group=group)) +
    coord_fixed(1.3) +
    geom_polygon(color="black", fill="gray") +
    geom_polygon(data=df_plot_counties, aes(fill=mn_aqi), color="black") +
    scale_fill_gradient2(low="#FFFFE0", mid="#FEB24C", high="#CD0000") +
    theme_void()
