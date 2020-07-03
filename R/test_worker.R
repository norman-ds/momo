## testing worker function

library(dplyr)
library(readr)
#source("download.R")
#source("validator.R")
source("logger.R")
source("badge.R")
source("restful.R")
source("worker.R")
#source("fileread.R")
#source("diffdf.R")


# create worker
work <- worker(
  logger("Testing worker", 'testlog.csv'),
  badge(c(    
    "![Run download](https://github.com/norman-ds/momo/workflows/Run%20download/badge.svg)",
    "![Deploy dashboard](https://github.com/norman-ds/momo/workflows/Deploy%20dashboard/badge.svg)"
  )),
  restful('test.json'),
  apifile = 'testapi.csv')

# test logger
work$get('logger')$add('Test 1')
work$get('logger')$get()

testfun <- function(worker, mess) {
  worker$get('logger')$add(mess)
  print(worker$get('logger')$get())
}
a <- testfun(work, 'Function 1')
work$get('logger')$add('Test post function')
work$get('logger')$get()

# test urls
work$get('urls')
work$get('urls')$remote

# test opendata
work$get('opendata')

# test api
apivec <- c(
  display_name.en = "Difference between downloads",
  created = "1999-02-29",
  download_url = "https://raw.githubusercontent.com/norman-ds/momo/master/data/diff.csv",
  format = "CSV",
  start_date = "dann",
  end_date = "heute"
)
work$write_api(apivec)
work$get('logger')$get()

# test badge
work$write_and_badge('Test_badge')
work$get('badge')$get()

# test put new logger
work$put(logger('Checking worker', 'testlog.csv'), 'logger')
work$get('logger')$add('Check 1')
work$get('logger')$get()

b <- testfun(work, 'Check funtion 1')
b <- testfun(work, 'Check funtion 2')
work$get('logger')$add('Test post function', 'E')
work$get('logger')$get()

# test badge
work$write_and_badge('Check_badge')
work$get('badge')$get()

# test restful
apivec[1] <- "Sec. record"
work$get('restful')$add(apivec)
apivec[1] <- "Schon wieder"
work$get('restful')$add(apivec)
work$get('restful')$get()
work$get('logger')$get()
