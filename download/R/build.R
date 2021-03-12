build_build <- function() {
  # load function data file reader
  source('R/fileread.R', local = T)
  source('R/extract_mrw.R', local = T)
  
  # load datafile
  datafile <- config_all$filepath('datafile') %>% fileread()
  
  ##########################
  # build firstrelease.csv
  releasefile <- config_all$filepath('releasefile')
  releasedata <- read_csv(releasefile) %>% 
    select(TIME_PERIOD, GEO, VALUE) %>%
    distinct() 
  
  
  # dataframe of most recent week
  dfmrw <- datafile %>% 
    extract_mrw(config_all$data$geofilter, config$releaseweeks) 
  
  if (nrow(anti_join(dfmrw, releasedata, by=c('TIME_PERIOD','GEO','VALUE')))>0) {
    dfmrw %>%
      add_column(DOWNLOAD = writedate(), .before = 1) %>%
      write_csv(releasefile, append = file.exists(releasefile))
  }
  
  stopifnot(file.exists(releasefile))
  
  
  message("... build completed ...")
  
}


