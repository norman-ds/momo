## a wrapper of difference file
#library(dplyr)
#library(readr)
#library(lubridate)

dff <- function(difffile) {
  
  # test if file path exists
  stopifnot(dir.exists(dirname(difffile)))
  
  # difffile as dataframe
  difftab <- NULL
  
  file <- function() {
    return(difffile)
  }
  get <- function() {
    return(difftab)
  }
  read <- function(put=TRUE) {
    ddf <- readr::read_delim(difffile, delim = ';')
    if(put) difftab <<- ddf
    return(invisible(ddf))
  }
  write <- function(dataframe, put=FALSE) {
    if (put) difftab <<-dataframe
    readr::write_csv2(dataframe, 
                      difffile, 
                      append = file.exists(difffile))
  }
  start <- function() {
    min(difftab$TIME_PERIOD)
  }
  end <- function(variables) {
    max(difftab$TIME_PERIOD)
  }
  # return value is dataframe
  diffdf <- function(dfold, dfnew) {
    stopifnot(names(dfnew)==names(dfold))
    tsv <- lubridate::now("CET")
    
    
    dfcols <- c("TIME_PERIOD", "GEO", "AGE", "SEX", "VALUE")
    stopifnot(dfcols %in% names(dfnew))
    
    dfnew <- dfnew %>% select(dfcols[1:4], neu=VALUE) %>%
      filter(GEO != 'CH', AGE != '_T', SEX != 'T')
    dfold <- dfold %>% select(dfcols[1:4], old=VALUE) %>%
      filter(GEO != 'CH', AGE != '_T', SEX != 'T')
    
    dfdiff <- left_join(dfnew, dfold, 
                        by = c("TIME_PERIOD", "GEO", "AGE", "SEX")) %>% 
      mutate(neu = if_else(is.na(neu),0L,neu),
             old = if_else(is.na(old),0L,old),
             edge = sprintf("%sto%s",max(dfnew$TIME_PERIOD),max(dfold$TIME_PERIOD))) 
    dfdiff <- dfdiff %>%
      mutate(diff = neu - old) %>%
      mutate(TIMESTAMP = tsv) %>%
      filter(diff != 0) 
    
    return(dfdiff)
  }
  
  return(list(file=file, get=get, read=read, write=write, diffdf=diffdf, start_date=start, end_date=end))
}
