hospital <- read.csv("https://roualdes.us/data/hospital.csv")
library(ggplot2)

ggplot(hospital, aes(beds, nurses)) +
	geom_point() +
	geom_smooth(method="lm", se=FALSE)

fit <- lm(nurses ~ beds, data = hospital)
summary(fit)
