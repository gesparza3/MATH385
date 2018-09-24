library(boot)
library(ggplot2)
library(dplyr)

## Read data
email <- read.csv("https://roualdes.us/data/email.csv")
colnames(email)
#  [1] "spam"         "to_multiple"  "from"         "cc"          
#  [5] "sent_email"   "time"         "image"        "attach"      
#  [9] "dollar"       "winner"       "inherit"      "viagra"      
# [13] "password"     "num_char"     "line_breaks"  "format"      
# [17] "re_subj"      "exclaim_subj" "urgent_subj"  "exclaim_mess"
# [21] "number"      

## Make a plot
ggplot(email, aes(num_char, line_breaks)) + geom_point()

## Create simple linear regression model
mod <- lm(line_breaks ~ num_char, data=email)
summary(mod)
str(predict(mod, data.frame(num_char=c(10, 50, 100, 120, 30))))


################################################################################

## Bootstrap stuff
boot_linear_regression <- function(original_data, idx) {
    df <- original_data[idx,]
    fit <- lm(line_breaks ~ num_char, data=df)
    predict(fit, data.frame(num_char=c(10, 50, 100, 120, 30)))
}

b <- boot(email, boot_linear_regression, R=999)

for (i in 1:5) {
  print(boot.ci(b, type="perc", index=i)$t)
}
