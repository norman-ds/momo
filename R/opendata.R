# functions to read api opendata.swiss

# library(dplyr)
# library(jsonlite::fromJSON)

# lists all datasets
plist <- function() {
  jsonlite::fromJSON('https://opendata.swiss/api/3/action/package_list')
}

# shows one dataset by id (slug)
pshow <- function(id) {
  ##  "curl 'https://opendata.swiss/api/3/action/package_show?id=studierende-fachhochschule-anz'"
  myurl <- "https://opendata.swiss/api/3/action/package_show"
  
  res <- jsonlite::fromJSON(paste0(myurl,'?id=', id))
  if (!res$success) message(sprintf('not successful id > %s', id))
  return(res)
}

# serach dataset by keys
psearch <- function(q, fq) {
  # "curl https://opendata.swiss/api/3/action/package_search?q=switzerland&fq=+keywords_en:geology'
  
  myurl <- "https://opendata.swiss/api/3/action/package_search"
  
  jsonlite::fromJSON(paste0(myurl,'?q=', q, '&fq=',fq))
}

# shows selected metadata in a table
ptable <- function(id) {
  rest_api <- pshow(id)
  stopifnot(rest_api$success) 
  
  as.na <- function(cell) {
    ifelse(is.null(cell), NA, cell)
  }
  
  r <- rest_api$result
  api_desc <- tibble(id=id,
                     issued=r$issued,
                     author=r$author,
                     language=r$language,
                     spatial=as.na(r$spatial),
                     metadata_created=r$metadata_created,
                     metadata_modified=r$metadata_modified,
                     start_date=as.na(r$temporals$start_date),
                     end_date=as.na(r$temporals$end_date),
                     display_name=r$display_name$de,
                     state=r$state,
                     format=paste(sort(unique(r$resources$format)),collapse = ','))
  
  return(api_desc)
}

# shows selected api data in a table
papi <- function(id, formats=c('CSV'), language='de') {
  rest_api <- pshow(id)
  stopifnot(rest_api$success) 
  
  as.na <- function(cell) {
    ifelse(is.null(cell), NA, cell)
  }
  
  r <- filter(rest_api$result$resources, format %in% formats)
  #return(r)
  api_desc <- tibble(id=id,
                     issued=r$issued,
                     display_name=unlist(r$display_name[language]),
                     language=unlist(r$language),
                     created=r$created,
                     format=r$format,
                     rights=r$rights,
                     state=r$state,
                     url=r$url,
                     download_url=r$download_url,
                     revision_id=r$revision_id)
  
  return(api_desc)
}

# shows selected api and meta data in a table
apimeta <- function(api.pattern, api.formats, api.lang) {
  
  # list of all opendata swiss apis
  mylist <- plist()
  
  # give download urls of api with pivot...
  myids <- mylist$result[grepl(api.pattern, mylist$result)] %>%
    purrr::map_dfr(papi, format=api.formats, language=api.lang) %>%
    filter(language==api.lang)
  
  # merge metadata to urls
  myapis <- unlist(myids$id)  %>%
    purrr::map_dfr(ptable) %>%
    filter(language==api.lang) %>%
    select(-language, -issued, -display_name, -state, -format) %>%
    inner_join(myids, by='id')
  
  myapis
}
