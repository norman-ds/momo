## a logger function

logger <- function(modul, logfile="log.csv") {
  tsv <- lubridate::now("CET")
  tx <- paste("START", modul)
  st <- 'I'
  addint <- function(text, status) {
    tsv <<- c(tsv,rep(lubridate::now("CET"), length(text)))
    tx <<- c(tx,text)
    st <<- c(st,status)
  }
  add <- function(text, status='I') {
    stopifnot(status %in% c('I','W','E'))
    stopifnot(dim(text)==dim(status))
    addint(text, status)
  }
  get <- function() {
    return(list(time=tsv, messages=tx, status=st))
  }
  stop <- function() {
    return(any(st=='E'))
  }
  write <- function() {
    addint(paste("END", modul),'I')
    # Schreibt Logdatei
    logf <- tibble::tibble(time=tsv, status=st, text=tx)
    readr::write_csv2(logf, logfile, append = T)
    return(get())
  }
  return(list(add=add, get=get, stop=stop, write=write))
}
