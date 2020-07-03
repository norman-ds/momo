## Testing Download function

library(dplyr)
library(readr)
source("download.R")
source("opendata.R")
#source("validator.R")
source("logger.R")
source("badge.R")
source("restful.R")
source("worker.R")
#source("fileread.R")
#source("diffdf.R")

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

# create worker
work <- worker(
  logger("Download", logfile),
  badge(
    c(
      "![Run download](https://github.com/norman-ds/momo/workflows/Run%20download/badge.svg)",
      "![Deploy dashboard](https://github.com/norman-ds/momo/workflows/Deploy%20dashboard/badge.svg)"
    )
  ),
  restful(restfile),
  apifile = apifile
)


retval <- downloadfile(destcsv = destfile, worker = work)
retval
work$get('logger')$get()
readr::read_delim(destfile, delim = ';') %>%
  summarise(max(TIME_PERIOD))
work$get('logger')$stop()
work$get('restful')$get()
work$get('restful')$write(F)
read_csv2(apifile)
read_csv2(destfile)

work$get('urls')
work$get('opendata')
work$write_and_badge('Test_download')
work$get('badge')$get()
readr::read_delim(logfile, delim = ';', col_names = F)
