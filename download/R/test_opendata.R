# Weekly death data in Switzerland
# Download from opendata.swiss

library(tidyverse)
library(jsonlite)
# library(curl::curl_download)
# library(jsonlite::fromJSON)

source('R/config.R', local = T)
config_all <- build_config()
config <- config_all$data$net
testdir <- '~/testdata'
if(!dir.exists(testdir)) dir.create(testdir)
config$path <- testdir


#"https://opendata.swiss/de/dataset?q=%22Todesfälle+nach+Fünf-Jahres-Altersgruppe%22+Kanton"

# list of all apis
stopifnot(config$format == 'json')
openlist <- jsonlite::fromJSON(config$urlPackagelist)
stopifnot(openlist$success)

# give list of all ids
(idlist <- openlist$result[grepl(config$pattern, openlist$result)])
cat(idlist, sep = '\n')

# download datasets (metadata and urls) by id (slug)
pdown <- function(id) {
  mydown <- FALSE
  myurl <- paste0(config$urlPackage,'?id=', id)
  myfile <- file.path(config$path, id)
  curl::curl_download(myurl, myfile)
  return(id)
}
unlist(lapply(idlist, pdown))

