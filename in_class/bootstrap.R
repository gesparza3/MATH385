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

###############################################################################

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

#################################################################################

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

