## Download and validate data
library(dplyr)
library(readr)
#source("download.R")
#source("validator.R")
source("badge.R")
#source("fileread.R")
#source("diffdf.R")

badgefile <- file.path('testlink.testR')

bgoj <- badge(c(    
  "![Run download](https://github.com/norman-ds/momo/workflows/Run%20download/badge.svg)",
  "![Deploy dashboard](https://github.com/norman-ds/momo/workflows/Deploy%20dashboard/badge.svg)"
  #    "![Deploy dashboard](https://github.com/norman-ds/momo/workflows/Deploy%20dashboard/badge.svg)",
  #    "[![Last pull](https://img.shields.io/badge/last%20pull-2020--06--07-success)](#logdatei)",
  #    "![Last update](https://img.shields.io/badge/last%20update-2020--06--07-critical)"
), file = badgefile)
bgoj$get()
bgoj$add('![](jhdsfjk)')
bgoj$get()
bgoj$write()
read_file(badgefile)
