## test restfull json
library(dplyr)
library(readr)
#library(curl)
library(jsonlite)
source("restful.R")
source("opendata.R")

restobj <- restful('test.json')

myapis <- apimeta('todesfalle-nach-funf-jahres-altersgruppe-geschlecht-woche-und-kanton-csv-datei',
                  'CSV', 'en')  %>%
  mutate(pivot = if_else('2020'>=substr(start_date,0,4) &
                         '2020'<=substr(end_date,0,4),
                         'PIVOT','NOPI')) %>%
  split(.$pivot)
restobj$init(myapis$PIVOT)
restobj$get()
restobj$add(myapis$NOPI)
restobj$get()

restobj$add(tibble(
  display_name = "Difference between downloads",
  created = "jetzt",
  download_url = "https://raw.githubusercontent.com/norman-ds/momo/master/data/diff.csv",
  format = "CSV",
  start_date = "dann",
  end_date = "heute"
))
restobj$get()
restobj$write(F)



################################
restobj2 <- restful('test.json')
restobj2$init(fromURL = T)
restobj$get()

purrr::map_lgl(as.list(restobj$get()$download_url), httr::http_error)

# write a html tables
################################
restobj2$get(toHtml=T)

