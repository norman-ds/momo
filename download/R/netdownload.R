library(tidyverse)
#library(jsonlite)
#library(RCurl)
#library(curl)

# download data of years 2000 to 2019
jfile <-  paste0('https://opendata.swiss/api/3/action/package_show','?id=',
                 'todesfalle-nach-funf-jahres-altersgruppe-geschlecht-woche-und-kanton-csv-datei7') %>%
  jsonlite::fromJSON()
stopifnot(jfile$success)

# get download url
pivotfile <- function(jfile) {
  list(start_date = as.Date(jfile$temporals$start_date, format="%Y-%m-%d"),
       end_date = as.Date(jfile$temporals$end_date, format="%Y-%m-%d"),
       title = jfile$display_name$en,
       urlcsv = jfile$resources$download_url[jfile$resources$media_type=='text/csv'],
       urls = jfile$resources$download_url,
       medias = jfile$resources$media_type)
}

(pivot <- pivotfile(jfile$result))
stopifnot(pivot$start_date=="2000-01-03")
stopifnot(pivot$end_date=="2019-12-29")

# download csv file
newfile <-'static/data2000to2019.csv'
stopifnot(RCurl::url.exists(pivot$urlcsv))
curl::curl_download(pivot$urlcsv, newfile)
stopifnot(file.exists(newfile))

# test dataframe
dfcsv <- readr::read_delim(newfile, delim = ';',
                           col_types = cols(.default = col_character())) %>%
  rename_all(toupper)

# download appendix file
appfile <-'static/appendix2000to2019.xlsx'
appurl <- pivot$urls[grepl('openxml', pivot$medias)]
stopifnot(RCurl::url.exists(appurl))
curl::curl_download(appurl, appfile)
stopifnot(file.exists(appfile))

