################################################################################
# Load libraries
################################################################################

library(ggplot2)

################################################################################
# Create plot
################################################################################

ggplot(mtcars, aes(factor(cyl), mpg)) +
  geom_point() +
  stat_summary(fun.data = "mean_cl_normal", color="red", size=1.2)

################################################################################
# Create ANOVA model
################################################################################

model <- lm(mpg ~ factor(cyl), data=mtcars)
summary(model)
# Call:
# lm(formula = mpg ~ factor(cyl), data = mtcars)
#
# Residuals:
#     Min      1Q  Median      3Q     Max
# -5.2636 -1.8357  0.0286  1.3893  7.2364
#
# Coefficients:
#              Estimate Std. Error t value Pr(>|t|)
# (Intercept)   26.6636     0.9718  27.437  < 2e-16 ***
# factor(cyl)6  -6.9208     1.5583  -4.441 0.000119 ***
# factor(cyl)8 -11.5636     1.2986  -8.905 8.57e-10 ***
# ---
# Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
#
# Residual standard error: 3.223 on 29 degrees of freedom
# Multiple R-squared:  0.7325,	Adjusted R-squared:  0.714
# F-statistic:  39.7 on 2 and 29 DF,  p-value: 4.979e-09

################################################################################
# Create Mean Squared Error(MSE)
################################################################################

MSE <- function(y, yhat) {
  mean((y - yhat)^2)
}
mpghat <- predict(model)
MSE(mtcars$mpg, mpghat)
