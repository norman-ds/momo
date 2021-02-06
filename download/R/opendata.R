# Weekly death data in Switzerland
# Download from opendata.swiss

# library(curl::curl_download)
# library(jsonlite::fromJSON)
# library(yaml::read_yaml)

#"https://opendata.swiss/de/dataset?q=%22Todesfälle+nach+Fünf-Jahres-Altersgruppe%22+Kanton"

# list of all apis
stopifnot(config$format == 'json')
openlist <- jsonlite::fromJSON(config$urlPackagelist)
stopifnot(openlist$success)

# give list of all ids
(idlist <- openlist$result[grepl(config$pattern, openlist$result)])

# download datasets (metadata and urls) by id (slug)
pdown <- function(id) {
  mydown <- FALSE
  myurl <- paste0(config$urlPackage,'?id=', id)
  myfile <- file.path(config$path, id)
  curl::curl_download(myurl, myfile)
  return(id)
}

anybox$add(json=unlist(lapply(idlist, pdown)))

