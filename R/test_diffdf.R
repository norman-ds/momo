## testing wrapper of diffrenece file
library(dplyr)
library(readr)
library(lubridate)
source("fileread.R")
source("diffdf.R")

difffile <- file.path('..', 'testdata', 'testdiff.csv')
destfile <- file.path('..', 'testdata', 'new_todesfaelle_woche.csv')
oldfile <- file.path('..', 'testdata', 'todesfaelle_woche.csv')

diffobj <- dff(difffile)
stopifnot(is.null(diffobj$get()))

stopifnot(diffobj$file()==difffile)

df <- diffobj$read()
glimpse(df)
stopifnot(all_equal(diffobj$get(),df))

stopifnot(min(df$TIME_PERIOD)==diffobj$start_date())
stopifnot(max(df$TIME_PERIOD)==diffobj$end_date())

# function creat tabele of diffrenece
dfold <- fileread(oldfile)
dfnew <- fileread(destfile)
data <- diffobj$diffdf(dfold, dfnew)
glimpse(data)
sprintf('Differenzen in %i Zeilen mit %i Todesfällen ..', 
        nrow(data), sum(data$diff))
data %>% 
  mutate(y = substr(TIME_PERIOD, 0,4)) %>%
  group_by(y) %>% tally(diff)

# write file to disc
diffobj$write(data)
df <- diffobj$read()
glimpse(df)
stopifnot(all_equal(diffobj$get(),df))
stopifnot(all_equal(data,df, convert = T))

stopifnot(min(df$TIME_PERIOD)==diffobj$start_date())
stopifnot(max(df$TIME_PERIOD)==diffobj$end_date())
