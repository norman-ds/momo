## Download and validate data
library(dplyr)
library(readr)
source("download.R")
source("opendata.R")
source("validator.R")
source("logger.R")
source("badge.R")
source("restful.R")
source("worker.R")
source("fileread.R")
source("diffdf.R")

fit_data <- function(destfile = '../data/neu_todesfaelle_woche.csv',
                     oldfile = '../data/todesfaelle_woche.csv',
                     logfile = '../data/log.csv',
                     restfile = '../data/json.json',
                     apifile = '../data/api.csv',
                     difffile = '../data/diff.csv',
                     badgefile = 'badgelinks.R') {
  
  return_value = 0  # 1:error, 0:ok
  
  # create worker
  work <- worker(
    logger = logger("Download", logfile),
    badge = badge(c(    
      "![Run download](https://github.com/norman-ds/momo/workflows/Run%20download/badge.svg)",
      "![Deploy dashboard](https://github.com/norman-ds/momo/workflows/Deploy%20dashboard/badge.svg)"
    ), badgefile),
    restful = restful(restfile),
    apifile = apifile)

  
  tryCatch({
    # download data from OGD resources (Open Government Data)
    # return a log-object and append it on 'log.csv'
    # api info is appended on 'api.csv'
    
    downloadfile(destcsv = destfile, worker = work)
    work$write_and_badge('Last_pull')
    
    # Stop if Error
    stopifnot(!work$get('logger')$stop())
    
    # Validate data with previous data
    # return a log-object and append it on 'log.csv'
    # difference is appended on 'diff.csv'
    # replace=TRUE
    #   the oldfile is archieved on 'arc_*.*' file
    #   the newfile is renamed to oldfile
    
    work$put(logger('Validierung', logfile), 'logger')
    diffobj <- dff(difffile)
    
    validator(oldfile = oldfile, 
              newfile = destfile,
              replace = T,
              prefix = 'arc_',
              diffobj = diffobj,
              worker = work)
    work$write_and_badge('Valdidate')
    
    # Stop if Error
    stopifnot(!work$get('logger')$stop())
    
    work$put(logger('API', logfile), 'logger')
    
    # add  difference file to restful object
    diffobj$read(put=TRUE) # read file 
    
    work$get('restful')$add(c(
      display_name = "Difference between downloads",
      created = as.character(Sys.time()),
      download_url = "https://raw.githubusercontent.com/norman-ds/momo/master/data/diff.csv",
      format = "CSV",
      start_date = diffobj$start_date(),
      end_date = diffobj$end_date()
    ))
    
    work$get('restful')$write()
    work$get('logger')$add(sprintf('restful auf disc'))
    
    # Write badge
    work$get('badge')$write()
    work$get('logger')$add(sprintf('badge auf disc'))
    
  }, error = function(c) {
    return_value = 1  # 1:error, 0:ok
  }, finally = work$get('logger')$write())
  
  return(return_value) # 1:error, 0:ok
}

