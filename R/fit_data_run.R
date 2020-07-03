## Run function fit_data()
source("fit_data.R")

destfile <- file.path('..', 'data', 'new_todesfaelle_woche.csv')
oldfile <- file.path('..', 'data', 'todesfaelle_woche.csv')
logfile <- file.path('..', 'data', 'log.csv')
restfile <- file.path('..', 'data', 'json.json')
apifile <- file.path('..', 'data', 'api.csv')
difffile <- file.path('..', 'data', 'diff.csv')
badgefile <- file.path('badgelinks.R')

fit_data(
  destfile = destfile,
  oldfile = oldfile,
  logfile = logfile,
  restfile = restfile,
  apifile = apifile,
  difffile = difffile,
  badgefile = badgefile
)
