## testing functions opendata

library(dplyr)
# library(jsonlite::fromJSON)
source("opendata.R")

#"https://opendata.swiss/de/dataset?q=%22Todesfälle+nach+Fünf-Jahres-Altersgruppe%22+Kanton"

# list of apis
openlist <-plist()
stopifnot(openlist$success)
length(openlist$result) # [1] 7828


# Todesfälle
####################
pivot.slug <- "todesf.*lle.*alter.*kanton.*csv"
pivot.formats <- c('CSV')
pivot.lang <- 'de'
pivot.year <- 2020

# give list of all apis with pivot.slug
openlist$result[grepl(pivot.slug, openlist$result)]
# [1] "todesfalle-nach-funf-jahres-altersgruppe-geschlecht-woche-und-kanton-csv-datei20"
# [2] "todesfalle-nach-funf-jahres-altersgruppe-geschlecht-woche-und-kanton-csv-datei26"
# [3] "todesfalle-nach-funf-jahres-altersgruppe-geschlecht-woche-und-kanton-csv-datei7" 

# give all meta information of one api
pshow('todesfalle-nach-funf-jahres-altersgruppe-geschlecht-woche-und-kanton-csv-datei26') 

# give selected metadata of apis with pivot.slug
ptable('todesfalle-nach-funf-jahres-altersgruppe-geschlecht-woche-und-kanton-csv-datei26') %>%
  filter(language=='de') %>% t

# give selected download urls of apis with pivot.slug
papi('todesfalle-nach-funf-jahres-altersgruppe-geschlecht-woche-und-kanton-csv-datei26') 

# return table of metadata and api
myapis <- apimeta(pivot.slug, pivot.formats, pivot.lang) %>%
  mutate(pivot = if_else(pivot.year>=substr(start_date,0,4) &
           pivot.year<=substr(end_date,0,4),'PIVOT','NOPI')) %>%
  split(.$pivot)

glimpse(myapis)

# select url for the pivot year
myapis$PIVOT %>%
  transmute(id = substring(id,70), download_url)
