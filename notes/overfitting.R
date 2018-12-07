## data on hominin species
## Statistical Rethinking R cod 6.1
library(ggplot2)
spnames <- c("afarensis", "africanus", "habilis", "boisei",
              "rudolfensis", "ergaster", "sapiens")
brainvolcc <- c(438, 452, 612, 521, 752, 871, 1350)
masskg <- c(37, 35.5, 34.5, 41.5, 55.5, 61, 53.5)
df <- data.frame(species = spnames, brain = brainvolcc, mass = masskg)

ggplot(df, aes(mass, brain)) +
    geom_point() +
    geom_smooth(method="lm", formula="y ~ poly(x, 6)")

## what to do about it
library(glmnet)

X <- model.matrix(~ poly(mass, 6), data=df)
y <- df$brain

fit <- cv.glmnet(X, y, nfolds=nrow(df), grouped=FALSE, alpha=0)
yhat <- predict(fit, newx=X, lambda=fit$lambda.1se)

newdf <- df
newdf$yhat <- yhat

ggplot(newdf, aes(mass, brain)) +
    geom_point() +
    geom_line(aes(mass, yhat)) +
    geom_smooth(method="lm", formula="y ~ poly(x, 6)", se=FALSE)
