## Download and validate data
library(dplyr)
library(readr)
#source("download.R")
#source("opendata.R")
source("validator.R")
source("logger.R")
source("badge.R")
source("restful.R")
source("worker.R")
source("fileread.R")
source("diffdf.R")

testdir <- file.path('..', 'testdata')
dir.create(testdir)
#ifelse(!dir.exists(testdir), dir.create(testdir), warning)

destfile <- file.path(testdir, 'new_todesfaelle_woche.csv')
oldfile <- file.path(testdir, 'todesfaelle_woche.csv')
arcfile <- file.path(testdir, 'arc_todesfaelle_woche.csv')
logfile <- file.path(testdir, 'testlog.csv')
restfile <- file.path(testdir, 'testjson.json')
apifile <- file.path(testdir, 'testapi.csv')
difffile <- file.path(testdir, 'testdiff.csv')
badgefile <- file.path(testdir, 'testlink.testR')

# check last week of test files
getLastWeek <- function(file) {
  readr::read_delim(file, delim = ';') %>%
    summarise(names = file, max(TIME_PERIOD))
}
sapply(as.list(c(destfile=destfile,oldfile=oldfile)), getLastWeek)

# restful function
restobj <- restful(restfile)
apivec <- c(
  display_name = "Test load data",
  created = "1999-02-29",
  download_url = "https://raw.githubusercontent.com/norman-ds/momo/master/data/diff.csv",
  format = "CSV",
  start_date = "dann",
  end_date = "heute"
)
restobj$init(apivec)
apivec[1] <- "Test sec. load"
restobj$add(apivec)
restobj$get()



# create worker
work <- worker(
  logger("Validierung", logfile),
  badge(
    c(
      "![Run download](https://github.com/norman-ds/momo/workflows/Run%20download/badge.svg)",
      "![Deploy dashboard](https://github.com/norman-ds/momo/workflows/Deploy%20dashboard/badge.svg)"
    )
  ),
  restobj,
  apifile = apifile
)

# create wrapper for difference file
diffobj <- dff(difffile)
diffobj$file()
is.null(diffobj$get())

# create difference file
retval <- validator(oldfile = oldfile, 
                    newfile = destfile,
                    replace = F,
                    prefix = 'arc_',
                    diffobj = diffobj,
                    worker = work)
retval
work$get('logger')$get()
work$get('logger')$stop()
readr::read_delim(difffile, delim = ';') %>%
  count(TIMESTAMP)

# check restful json
work$get('restful')$get()

# check badges
work$get('badge')$get()

