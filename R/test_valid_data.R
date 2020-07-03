## Download and validate data
library(dplyr)
library(readr)
#source("download.R")
#source("opendata.R")
source("validator.R")
#source("logger.R")
source("fileread.R")
#source("diffdf.R")

  oldfile <- file.path('..','data','arc_todesfaelle_woche.csv')
  newfile <- file.path('..','data','todesfaelle_woche.csv')

  # create dataframes
  dfold <- fileread(oldfile)
  dfnew <- fileread(newfile)
  
  # create lists of reference tables
  refold <- create_reftab(dfold)
  refnew <- create_reftab(dfnew)

  # Vergleich der Daten
  difflist <- purrr::map2(refnew, refold, valid_data)
  
  difflist[[1]] %>% knitr::kable()
  difflist[[2]] %>% knitr::kable()

  # Logdatei für Kalenderwochen schreiben
  difflist[[2]] %>%
    mutate(st = if_else(between(row_number(), n()-7, n()),'I',NULL)) %>%
    mutate(st = if_else(VALUE.OLD==0 & is.na(st),'W',st))  %>%
    mutate(st = if_else(!between(DIFF,0,1500), 'W',st)) %>%
    mutate(st = if_else(row_number()==n() & DIFF<500, 'E',st)) %>%
    filter(!is.na(st)) %>%
    knitr::kable()
  


