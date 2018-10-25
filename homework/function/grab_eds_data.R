get_eds_data <- function(target = 'hospital') {
  library(reticulate)
  os <- import("requests")
  os <- import("bs4")
  source_python("grab_data.py")
  read.csv(retrieve(target))
}

email <- get_eds_data("email")
