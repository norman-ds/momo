build_restapi <- function() {

  source('R/opendatajsonwrapper.R', local = T)
  source('R/restful.R', local = T)
#  source('R/createrest.R', local = T)
  
  
  # ouput file ist restfile
  restnames <- c('display_name', 
                 'created', 
                 'download_url',
                 'format',
                 'start_date',
                 'end_date')
  rfile <- config_all$filepath('restfile') 
  robject <- restful(rfile, restnames)
  
  # function of selected fieldes out of json file
  pivotfile <- function(jfile) {
    list(display_name = jfile$display_name$de,
         created = jfile$issued,
         format = 'CSV',
         start_date = as.Date(jfile$temporals$start_date, format="%Y-%m-%d"),
         end_date = as.Date(jfile$temporals$end_date, format="%Y-%m-%d"),
         download_url = jfile$resources$download_url[jfile$resources$format=='CSV'])
  }
  
  # create a dataframe of file, url and dates
  anybox$get()$validate$file %>%
    purrr::map(~ jwrapper(.x)) %>% 
    purrr::map_df(~ pivotfile(.x)) %>%
    arrange(desc(end_date)) %>% 
    robject$init()
  
  robject$write()
  stopifnot(file.exists(rfile))
  
  
  message("... restapi completed ...")
  
}


