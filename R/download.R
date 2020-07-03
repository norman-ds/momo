# Download weekly death file from opendata swiss
# library(dplyr)
# library(readr)
# library(jsonlite::fromJSON)
# source("worker.R")
# source("opendata.R")

# Return value is same of curl_download
# Writes data in destcsv file (CSV)
# Needs worker
downloadfile <- function(destcsv = "neu_todesfaelle_woche.csv",
                         worker = NULL) {
  
  # Check directories
  stopifnot(dir.exists(dirname(destcsv)))
  
  # return value path of downloaded file (curl_download)
  return_value <- NULL

  # API vector
  api_meta <- c(NULL)
  tryCatch({
    
    worker$get('logger')$add("Opendata spec lesen ...")
    pivot <- worker$get('opendata')
    api_res <- apimeta(pivot$slug, pivot$formats, pivot$language) %>%
      mutate(pivot = if_else(pivot$year>=substr(start_date,0,4) &
                             pivot$year<=substr(end_date,0,4),
                             'PIVOT','NOPI')) %>%
      split(.$pivot)
    
    # Only 1 CSV file allowed
    stopifnot(NROW(api_res$PIVOT)==1)
    api_meta <- unlist(api_res$PIVOT)
    worker$write_api(api_meta)
    
    # Add other CSV's to restful
    worker$get('restful')$add(api_res$NOPI)
    
  }, warning = function(c) {
    worker$get('logger')$add(paste('Warning',c$message ),'W')
  }, error = function(c) {
    worker$get('logger')$add(paste('Error',c$message ),'E')
  })
  
  # Stop if Error
  if (worker$get('logger')$stop()) return(log)
  
  # Datenfile CSV (ASCII) Datei (ca. 18MB) (tibble)
  tryCatch({
    worker$get('logger')$add("URL download lesen ...")
    if (file.exists(destcsv))
      worker$get('logger')$add(sprintf("..%s wird überschrieben !", basename(destcsv)),"W")
    return_value <- curl::curl_download(api_meta["download_url"], destcsv)
    worker$get('logger')$add(sprintf("..CSV in %s geschrieben !",basename(destcsv)))

  }, warning = function(c) {
    worker$get('logger')$add(paste('Warning',c$message ),'W')
  }, error = function(c) {
    worker$get('logger')$add(paste('Error',c$message ),'E')
  })
  
  
  return(return_value)
}


