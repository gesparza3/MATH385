################################################################################

## Loops in R

## for loops in R
for(i in 1:10) {
    print(i)
}

x <- 0
for(i in 1:10) {
    x <- x + i
}

x <- 0
for(i in sample(1:100, 10)) {
    x <- x + i
}

## Indexing vectors with vectors
idx <- sample(1:100, 10)

idx[c(1, 2, 5, 6)] ## Example vector index
idx[sample(1:100, 10)] ## Another example

################################################################################

## Bootstrap stuff
hospitals <- read.csv("https://roualdes.us/data/hospital.csv")
T <- 999
xbars <- rep(NA, T)
for (t in 1:T) {
    data <- hospitals$infection_risk
    N <- length(data)
    idx <- sample(1:N, size=N, replace=TRUE)
    xbars[t] <- mean(data[idx])
}

ste <- sd(xbars) ## Standard error

## Confidence interval
mean(data) - 1.96*ste ## lower bound
mean(data) + 1.96*ste ## upper bound

# We are 95% confident that the true population mean infection_risk is between 4.101 and 4.608.

################################################################################

## Practice on your own
T <- 1500
xbars <- rep(NA, T)
for (t in 1:T) {
    data <- hospitals$beds
    N <- length(data)
    idx <- sample(1:N, size=N, replace=TRUE)
    xbars[t] <- mean(data[idx])
}

ste <- sd(xbars)
# [1] 17.47625

# Confidence interval
mean(data) - 1.96*ste ## lower bound
# [1] 216.7782
mean(data) + 1.96*ste ## upper bound
# [1] 287.5581

# We are 95% confident that the true population mean number of beds is between 216.78 and 287.6 beds.

################################################################################

## Functions in R
square_x <- function(x) {
    x^2
}
square_x(5)

square_x_plus_3 <- function(x) { ## You can create variables in functions
    z <- 3
    z + x^2
}
square_x_plus_3(5)

square_x_plus_z <- function(x, z) { ## You can add parameters
    z + x^2
}
square_x_plus_z(5, 3)

################################################################################

## Advanced Functions
sample_data <- function(data, idx) {
   data[idx] 
}

x <- rnorm(101)
sample_data(x, sample(1:length(x), 10)) ## Passing in a vector 'x' and result of sample

mean_sample_data <- function(data, idx) {
   mean(data[idx]) ## Mean of a vector
}

x <- rnorm(101)
mean_sample_data(x, sample(1:length(x), 10))

################################################################################

## Putting it all together

library(boot) ## Bootstrap library
mean_sample_data <- function(data, idx) {
   mean(data[idx]) ## Mean of a vector
}

## 2nd arg is user defined function with 2 args itself
b <- boot(hospitals$infection_risk, mean_sample_data, R=999) 
boot.ci(b, type="norm")
# BOOTSTRAP CONFIDENCE INTERVAL CALCULATIONS
# Based on 999 bootstrap replicates
# 
# CALL : 
# boot.ci(boot.out = b, type = "norm")
# 
# Intervals : 
# Level      Normal        
# 95%   ( 4.110,  4.595 )  
# Calculations and Intervals on Original Scale

## we are 95% confident that the true population mean infection_risk is between
## 4.11 and 4.6.

################################################################################

## Practice
sd_sample_data <- function(data, idx) {
   sd(data[idx]) ## Mean of a vector
}

## 2nd arg is user defined function with 2 args itself
b <- boot(hospitals$nurses, sd_sample_data, R=999) 
boot.ci(b, type="norm")
# BOOTSTRAP CONFIDENCE INTERVAL CALCULATIONS
# Based on 999 bootstrap replicates
# 
# CALL : 
# boot.ci(boot.out = b, type = "norm")
# 
# Intervals : 
# Level      Normal        
# 95%   (115.3, 164.6 )  
# Calculations and Intervals on Original Scale

## We are 95% confident that the true population standard deviation of nurses is between
## 115.3 and 164.6.

