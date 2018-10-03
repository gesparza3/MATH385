library(stringr)
library(ggplot2)
library(reshape)
library(dplyr)

x <- "a string variable"

## Concat strings
str_c("x + ", "y") # [1] "x + y"

## Split string
str_split("/data/sibilings.txt", "/") ## Returns a list

################################################################################

## Frequency of letters

scrab_words <- " A-9, B-2, C-2, D-4, E-12, F-2, G-3, H-2, I-9, J-1, K-1, L-4, M-2, N-6, O-8, P-2, Q-1, R-6, S-4, T-6, U-4, V-2, W-2, X-1, Y-2, Z-1"
r_words <- tolower(words)

## Do some splitting
splt_space <- str_remove_all(scrab_words, pattern=" ")
splt_comma <- str_split(splt_space, pattern=",")

## Make a data frame
words.dat <- data.frame(splt_comma)
colnames(words.dat) <- "letters"

## Split the data frame
words.freq <- data.frame(str_split_fixed(words.dat$letters, "-", 2))
colnames(words.freq) <- c("letters", "scrab_freq")

## Grab first letter of each word from r_words
first_letter <- data.frame(letters = str_sub(r_words, 1, 1))

## Group by
first_letter %>%
  group_by(letters) %>%
  summarise(n=n()) -> occurences
occurences <- add_row(occurences, letters="x", n=0, .before=24)
occurences <- add_row(occurences, letters="z", n=0)

## Join datasets
words.freq$real_freq <- occurences$n
words.freq$scrab_freq <- as.character(words.freq$scrab_freq)
words.freq$real_freq <- as.character(words.freq$real_freq)
words.freq$scrab_freq <- as.numeric(words.freq$scrab_freq)
words.freq$real_freq <- as.numeric(words.freq$real_freq)


## Compare freq
final.dat <- mutate(words.freq, scrab_prop = round(scrab_freq/sum(scrab_freq), 2), real_prop = round(real_freq/sum(real_freq), 2))

## Select proportions
plot_dat <- final.dat[,c("letters", "scrab_prop", "real_prop")]

## Convert to wide
wide_dat <- melt(plot_dat, id="letters") 

## Plot
ggplot(wide_dat, aes(letters, value, fill=variable)) + geom_bar(stat="identity", position="dodge") 
