#library(dplyr)
#library(readr)
#library(purrr)

dyfun <- function(regiofilter) {
  # regiofilter must be a quosure
  
  # Kantonsliste mit KZ und Namen
  dfkanton <- readr::read_delim(
    config_all$filepath('refdatageo'), 
    delim = ';',
    col_types = cols(.default = col_character())) %>%
    filter(!!!regiofilter)
    
  
  ##############
  # dataframe nach Kanton und drei Altersgruppen
  dfdeath <-   purrr::map_dfr(
    list(config_all$filepath('earlydata'), config_all$filepath('datafile')), 
    ~ readr::read_delim(., delim = ';',
                        col_types = cols(.default = col_character()))
    ) %>%
    # delete total in class age, delete the column sex
    filter(AGE != '_T', SEX=='T') %>%
    # build two columns year and calendarweek cw
    mutate(year=gsub('^(.{4}).*','\\1',TIME_PERIOD), 
           cw=gsub('.*(.{2})$','\\1',TIME_PERIOD)) %>%
    mutate(cw = as.integer(cw)) %>%
    # bilde new age classes
    mutate(AC0=gsub('(.+[ET])([0-9]?)([049])$','\\2\\3',AGE)) %>%
    mutate(AC1=as.integer(AC0)) %>%
    mutate(age=as.character(cut(AC1, breaks = c(0,64,80,100), 
                                labels = c("0-64", "65-79", "80+")))) %>%
    # aggregate observations
    group_by(geo=GEO, year, cw, age) %>%
      summarise(value=sum(as.double(Obs_value))) %>%
    # build a yearly cummulativ sum 
    group_by(geo, year, age) %>%
     mutate(value_cum = cumsum(value)) %>%
    ungroup() %>%
    # join geographic names
    mutate(ggeo=gsub('^(CH0[1-7]).$','\\1',geo)) %>%
    inner_join( dfkanton, by='geo' ) %>%
    # build a time series
    mutate(date = paste0(year,'-W',cw,'-',1),
           ldoy = paste0(year,'-12-31')) 
 dfdeath$date = lubridate::as_date(dfdeath$date, format='%Y-W%U-%u') 
# dfdeath$date <- ifelse(dfdeath$cw == 53,
#                        lubridate::as_date(dfdeath$ldoy, '%F'),
#                        lubridate::as_date(dfdeath$date, format='%Y-W%U-%u'))
 dfdeath$date[dfdeath$cw==53] <- dfdeath$ldoy[dfdeath$cw==53]

  
  return(dfdeath %>%
           # select columns
           select(date, age, kt=kanton, kanton=kanton2, value, value_cum) 
         )
}