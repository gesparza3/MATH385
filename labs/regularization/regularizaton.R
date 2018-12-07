################################################################################
# Load libraries
################################################################################

library(glmnet)
library(caret)

################################################################################
# Load libraries
################################################################################

bikes <- read.csv("https://roualdes.us/data/bike.csv")

################################################################################
# Questions to think about
################################################################################

# 1. Penalty term. Look at the parameter alpha under the Arguments section and
#    the objective function under the Details section of the help file for
#    glmnet.

# (a) What piece of the puzzle are they calling the penalty term?

# The penalty term is the expression that is being multiplied by alpha

# (b) What piece of the puzzle are they calling the objective function?
#     Notice that I had one two many λs in my objective function in class
#     yesterday.

#


# 2. Ridge versus Lasso.
# (a) What is the main difference between Ridge regression and Lasso?

# Lasso uses an absolute value of the betas as the penalty term as opposed to
# squaring it.

# (b) When might you be interested in one versus the other? Hint: what is the
#     standard error of a coefficient forced to zero?

#

# 3. cv.glmnet. Notice that the output of cv.glmnet provides two specific values
#    of λ to choose. Explain the difference?


################################################################################
# Prediction
################################################################################

# Create training and testing datasets
train_idx <- createDataPartition(y, p=0.75, list=FALSE)
training <- bikes[train_idx, ]
testing <- bikes[-train_idx, ]

# Calculate predictions for 3 models
X <- model.matrix(~ temp, data=training)
y <- training$cnt
fit <- cv.glmnet(X, y, nfolds=nrow(bikes), grouped=FALSE, alpha=0)
plot(fit)
