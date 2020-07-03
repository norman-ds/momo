## a restful function
library(dplyr)
library(readr)
library(jsonlite)

restful <- function(resturl="json.json") {
  stopifnot(dir.exists(dirname(resturl)))
  
  restnames <- c('display_name', 
                 'created', 
                 'download_url',
                 'format',
                 'start_date',
                 'end_date')
  
  df <- NULL
  
  init <- function(dataframe, fromURL = FALSE) {
    if (!fromURL)
      df <<- dataframe[restnames]
    else
      df <<- fromURL()
  }
  fromURL <- function() {
    read_json(resturl, T)
  }
  add <- function(dataframe) {
    df <<- bind_rows(df, dataframe[restnames])
  }
  get <- function(toHtml = FALSE) {
    # return a dataframe
    if (!toHtml)
     return(df)
    # return html tables
    else {
      list.of.dts <-jsonlite::read_json(resturl, simplifyVector = T) %>%
        mutate(subject = 1:n()) %>% 
        select(-download_url) %>%
        tidyr::pivot_longer(-subject) %>%
        split(.$subject)
      
      for (dti in list.of.dts) {
        print(knitr::kable(paste(dti$name, ' : ', dti$value),
                           caption = dti$value[1], 
                           table.attr = "class=\"striped\"", 
                           format = "html"))
        
        cat('\n\n<!-- -->\n\n')
      }
      
    }
  }
  write <- function(silent=TRUE) {
    write_json(df, resturl, pretty = TRUE)
    if (!silent) print(sprintf('.. %s geschrieben', resturl))
    return(get())
  }
  return(list(init=init, add=add, get=get, write=write))
}
