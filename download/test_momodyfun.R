## test function dyfun

library(dplyr)
library(readr)
library(dygraphs)
source('momodyfun.R')

# select sorted timeseries by canton
ktlist <- c('CH','ZH','BE','VD','TI')

# read data with dyfun and convert to timeseries
dft1 <- dyfun(quos(kanton %in% ktlist))
dft2 <- dft1 %>%
  count(kt,date, wt=value, name='value') %>%
  split(.$kt)
dft2 <- dft2[ktlist] # sorted list
tslist <- lapply(dft2, function(x) {
  xts::xts(x$value, order.by = x$date)
  })
tss <- do.call(cbind,tslist)
dygraph(tss, main = "Todesfälle Schweiz") %>% 
  dyOptions(stepPlot = T) %>%
  dyHighlight(highlightCircleSize = 5, 
              highlightSeriesBackgroundAlpha = 0.2,
              hideOnMouseOut = FALSE) %>% 
  dyRangeSelector(dateWindow = c("2013-07-01", as.character(last(dft1$date)))) %>%
  dyEvent("2020-3-17", "Lockdown", labelLoc = "bottom")


dft1 %>%
  filter(value==min(value))

dft2 %>% purrr::map_df(~filter(.,value==min(value)))

# read data with filereader
source('../R/fileread.R')
fileread('../data/todesfaelle_woche.csv')

# read the diff.csv
ddf <- read_csv2('../data/diff.csv')


