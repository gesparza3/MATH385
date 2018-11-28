################################################################################
# Load libraries
################################################################################

library(caret)

################################################################################
# Read in data
################################################################################

bikes <- read.csv("https://roualdes.us/data/bike.csv")

################################################################################
# Defin Mean Squared Error
################################################################################

MSE <- function(y, yhat) {
  mean((y - yhat)^2)
}

################################################################################
# Create folds
################################################################################

folds <- createFolds(bikes$cnt)

################################################################################
# Create MSE vectors
################################################################################

mse_mr01 <- rep(NA, 10)
mse_mr02 <- rep(NA, 10)

################################################################################
# Test some models
################################################################################

# temp

summary(lm(cnt ~ as.factor(season) + temp + as.factor(season):temp, data = bikes))
summary(lm(cnt ~ workingday + as.factor(season) + as.factor(season):workingday, data = bikes))

################################################################################
# Calculate MSE using K-folds
################################################################################

for(fold in 1:length(folds)) {
  training <- bikes[-folds[[fold]],]
  testing <- bikes[folds[[fold]],]
  mod01 <- lm(cnt ~ as.factor(season) + temp + as.factor(season):temp, data = bikes)
  mod02 <- lm(cnt ~ workingday + as.factor(season) + as.factor(season):workingday, data = bikes)
  mse_mr01[fold] <- MSE(testing$cnt, predict(mod01, newdata=testing))
  mse_mr02[fold] <- MSE(testing$cnt, predict(mod02, newdata=testing))
}

################################################################################
# Mean of the MSE's
################################################################################

mean(mse_mr01)
mean(mse_mr02)
