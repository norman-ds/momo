## function worker reads file worker.yaml
## a wrapper of a list of worker functions
## for logger, badge, restful
## also a buffer for urls
## and writes api data to file

worker <- function(logger, badge, restful, apifile = 'api.csv') {
  
  log <- logger # a logger function
  bad <- badge # a badge function
  res <- restful # a restful function
  
  # read urls and stop when they do not exist
  init <- yaml::read_yaml('worker.yaml')
  urls <- init$url
  lapply(urls, stopifnoturl)
  
  # read opendata filter
  opendata <- init$opendata

  get <- function(type) {
    switch (type,
            logger = log,
            badge = bad,
            urls = urls,
            opendata = opendata,
            restful = res
    )
  }
  put <- function(x, type) {
    switch (type,
            logger = log <<- x,
            badge = bad <<- x,
            restful = res <<- x
    )
  }
  write_api <- function(apivector) {
    log$add(sprintf(". %s vom %s", 
                    apivector["display_name"], 
                    apivector["created"]))
    
    # Schreibt API Infos in Textdatei
    readr::write_csv2(tibble::as_tibble(as.list(apivector)), 
                      apifile, 
                      append = file.exists(apifile))
    log$add(sprintf("..API in %s geschrieben !",basename(apifile)))
    
    # Schreibt restful API
    res$init(apivector)
  }
  write_and_badge <- function(badge='badge') {
    bad$add(badge_auto(badge)) # create badge
    log$add(sprintf('<%s> badge created', badge))
    log$write()
  }
  badge_auto <- function(badge) {
    badge_build(badge, 
                format(last(log$get()$time), '%Y--%m--%d'),
                #                format(last(tsv), '%Y--%m--%d__%H:%M:%S'),
                badge_color(log$get()$status))
  }
  badge_build <- function(lable, message, color) {
    sprintf('![%s](https://img.shields.io/badge/%s-%s-%s)',
            lable, lable, message, color)
  }
  badge_color <- function(status) {
    ifelse(any(status=='E'),'critical',
           ifelse(any(status=='W'),'blue',
                  'success'))
  }
  
  return(list(get=get, put=put, write_api=write_api, write_and_badge=write_and_badge))
}

# check if each url in url_vector reachable
stopifnoturl <- function(url_vector) {
  # check if url exists
  valid_url <- function(url_in,t=2){
    con <- url(url_in)
    check <- suppressWarnings(try(open.connection(con,open="rt",timeout=t),silent=T)[1])
    suppressWarnings(try(close.connection(con),silent=T))
    ifelse(is.null(check),TRUE,FALSE)
  }
  
  # stop if not all url exists
  urltest<-sapply(url_vector,valid_url)
#  try(
    if (!all(urltest))
      stop(paste("url fails ", 
                 paste(names(urltest[!urltest]), collapse = '\n')))
#  )
}
