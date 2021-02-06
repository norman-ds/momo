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
  
  ##########################
  # build timeserie
  
  # config_all$filepath('earlydata') %>%
  #   fileread() %>%
  #   bind_rows(datafile, .id = 'file') %>%
  #   filter(AGE == '_T' & SEX == 'T') %>%
  #   filter(GEO %in% config_all$data$geofilter) %>%
  #   group_by(file) %>%
  #   summarise(min = min(TIME_PERIOD), max = max(TIME_PERIOD))
 

  message("... build completed ...")
  
}


