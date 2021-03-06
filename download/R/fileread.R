## a file reader function

# return value is dataframe
fileread <- function(datafile) {
  df <- readr::read_delim(datafile,
                          delim = ';',
                          col_types = cols(.default = col_character())) %>%
    mutate(YEAR=gsub('^(.{4}).*','\\1',TIME_PERIOD), 
           CW=gsub('.*(.{2})$','\\1',TIME_PERIOD))
  
  df$VALUE=parse_integer(df$OBS_VALUE)
  stop_for_problems(df$VALUE)
  
  # reference column names
  refnames <- c('TIME_PERIOD',
                'GEO',
                'AGE',
                'SEX',
                'OBS_STATUS',
                'OBS_VALUE',
                'YEAR',
                'CW',
                'VALUE')
  stopifnot(names(df) == refnames)
  
  return(df)
}
