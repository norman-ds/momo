## test function dyfun

library(dplyr)
#library(jsonlite::read_json)
source('berestful.R')

berestful(html = F) %>%
cat()

berestful(html = T) %>%
  cat()
