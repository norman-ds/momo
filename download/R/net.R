build_net <- function() {
  # load wrapper for json files
  source('R/opendatajsonwrapper.R', local = T)
  
  # download matadata (json)
  source('R/opendata.R', local = T)
  
  # download data file with most recent week
  source('R/weeklydeath.R', local = T)
  
  message("... net completed ...")
}