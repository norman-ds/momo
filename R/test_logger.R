## Testing logger function

library(dplyr)
library(readr)
#source("download.R")
#source("validator.R")
source("logger.R")
#source("fileread.R")
#source("diffdf.R")

logfile <- file.path('testlog.csv')

log <- logger('Test', logfile = logfile)
log$add('Hallo Velo')
log$get()
stopifnot(log$stop()==F)
log$add('Otto Sugus','W')
log$get()
stopifnot(log$stop()==F)
log$add('Bad Lands','E')
log$get()
stopifnot(log$stop()==T)
log$write()

read_csv2(logfile)
