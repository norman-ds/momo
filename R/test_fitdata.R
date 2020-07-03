## Testing download and validate data
source("fit_data.R")

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

if(!file.exists(oldfile)) file.copy('~/data/arc_todesfaelle_woche.csv', oldfile)

# check last week of test files
getLastWeek <- function(file) {
  readr::read_delim(file, delim = ';') %>%
    summarise(names = file, max(TIME_PERIOD))
}
sapply(as.list(c(destfile=destfile,oldfile=oldfile)), getLastWeek)


# run function fit_data()
retval <-
  fit_data(
    destfile = destfile,
    oldfile = oldfile,
    logfile = logfile,
    restfile = restfile,
    apifile = apifile,
    difffile = difffile,
    badgefile = badgefile
  )
stopifnot(retval==0)


# check data files
sapply(as.list(c(destfile=destfile,oldfile=oldfile,arcfile=arcfile)), getLastWeek)

# check log file
readr::read_delim(logfile, delim = ';', col_names = F)  %>% View()

# check api file
readr::read_delim(apifile, delim = ';')  %>% View()

# check difference file
readr::read_delim(difffile, delim = ';') %>%
  summarise(min(TIME_PERIOD),max(TIME_PERIOD))

# check badges
read_file(badgefile)

# check restful json
restobj <- restful(restfile)
restobj$init(fromURL = T)
restobj$get()
restobj$get(toHtml = T)



