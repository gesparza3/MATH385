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
