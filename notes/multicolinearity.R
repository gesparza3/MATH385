## Fake example from
## from Statistical Rethinking R code 5.29
N <- 100
height <- rnorm(100, 10, 2)
leg_prop <- runif(N, 0.4, 0.5)
leg_left <- leg_prop * height + rnorm(N, 0, 0.02)
leg_right <- leg_prop * height + rnorm(N, 0, 0.02)
## we expect the true slope coefficient to be about 10 / 4.5 = 2.2
df <- data.frame(height, leg_left, leg_right)

fitl <- lm(height ~ leg_left, data=df)
summary(fitl)


fitr <- lm(height ~ leg_right, data=df)
summary(fitr)


## But what happens when we use both legs as predictors (which are highly correlated)
fit <- lm(height ~ leg_right + leg_left, data=df)
summary(fit)


## Real data example
hospital <- read.csv("https://roualdes.us/data/hospital.csv")
names(hospital)

cor(hospital[,-6]) # beds and nurses very highly correlated

modb <- lm(infection_risk ~ beds, data=hospital)
summary(modb)

modn <- lm(infection_risk ~ nurses, data=hospital)
summary(modn)

mod <- lm(infection_risk ~ nurses + beds, data=hospital)
summary(mod)


library(glmnet)
library(boot)

X <- model.matrix(~ -1 + nurses + beds, data=hospital)
y <- hospital$infection_risk

## in practice
model <- cv.glmnet(X, y, alpha=0)
coef(model)
predict(model)
plot(model)

coef(glmnet(X, y, alpha=0, lambda=model$lambda.1se))

## for plot that helps understanding
pfit <- glmnet(X, y, alpha=0)
plot(pfit, xvar="lambda")


## what's going on
simple_reg <- function(beta, X, y) {
    yhat <- cbind(1, X) %*% beta
    sum((y - yhat)^2)  + model$lambda.1se*sum(beta[-1]^2)
}

optim(rexp(3), simple_reg, method="L-BFGS-B", X=X, y=y)
coef(lm.ridge(infection_risk ~ nurses + beds, data=hospital, lambda=model$lambda.1se))




## estimating standard errors
bglmnet <- function(data, index, l) {
    X <- as.matrix(data[, -3][index, ])
    y <- data[, 3][index]
    fit <- glmnet(X, y, alpha=0, lambda=l)
    matrix(coef(fit))
}

b <- boot(data.frame(X=X, y=y), bglmnet, R=1001, l=model$lambda.1se)

apply(b$t, 2, mean)
apply(b$t, 2, sd)
summary(lm(infection_risk ~ nurses + beds, data=hospital))
