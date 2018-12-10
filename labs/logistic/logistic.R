df <- read.csv("https://web.stanford.edu/~hastie/ElemStatLearn/datasets/SAheart.data")

lnfit <- lm(ldl ~ sbp, data=df)

range(df$sbp)
mean(df$sbp)
newdf <- data.frame(sbp = c(101, 102, 138, 139, 217, 218))

## linear derivatives
yhat <- predict(lnfit, newdata=newdf)
(yhat[2] - yhat[1]) / (102 - 101)
(yhat[4] - yhat[3]) / (139 - 138)
(yhat[6] - yhat[5]) / (218 - 217)

## logistic derivatives
unique(df$chd) # heart disease: yes == 1, no == 0
lgfit <- glm(chd ~ sbp, data=df, family='binomial')
phat <- predict(lgfit, type='response', newdata=newdf)
(phat[2] - phat[1]) / (102 - 101)
(phat[4] - phat[3]) / (139 - 138)
(phat[6] - phat[5]) / (218 - 217)

## predictive (in)accuracy
library(caret)
y <- as.factor(df$chd)
yphat <- as.factor(rbinom(length(y),
                          size=1,
                          predict(lgfit, type='response')))
confusionMatrix(yphat, y)
## https://en.wikipedia.org/wiki/Sensitivity_and_specificity
