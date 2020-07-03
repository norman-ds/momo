## Erstellt aus bestehenden Daten Referenztabellen, die 
## mit den neuen Daten verglichen werden. Schreibt in 
## Logdatei zu Datenwachstum und erstellt ein Differenzdatei (CSV).
## Ersetzt alte Datei durch neu (default=FALSE).
## The worker handels logfile, badge and restful api

#library(dplyr)
#library(readr)
#source("logger.R")
#source("fileread.R")
#source("diffdf.R")

# Return value is difference table (invesible)
# Writes difference in file (CSV)
# If replace=true rename oldfile with prefix and newfile to oldfile
validator <- function(oldfile, 
                      newfile, 
                      replace=FALSE, 
                      prefix="arc_",
                      diffobj = NULL,
                      worker = NULL) {
  
  # Check directories
  stopifnot(dir.exists(dirname(oldfile)))
  stopifnot(dir.exists(dirname(newfile)))

  # return value difference table (invesible)
  return_value <- NULL
  
  # create dataframe of old and new file
  # stop if they equal
  dfold <- NULL
  dfnew <- NULL
  tryCatch({
    dfold <- fileread(oldfile)
    worker$get('logger')$add(
      sprintf('%s gelesen %i Zeilen und %i Spalten', 
              basename(oldfile), nrow(dfold), ncol(dfold)))

    dfnew <- fileread(newfile)
    worker$get('logger')$add(
      sprintf('%s gelesen %i Zeilen und %i Spalten', 
              basename(newfile), nrow(dfnew), ncol(dfnew)))
    
    # Stop if both tabels equal
    if (isTRUE(all_equal(dfold, dfnew))) 
      worker$get('logger')$add("Daten identisch","E")
  }, warning = function(c) {
    worker$get('logger')$add(paste('Warning',c$message ),'W')
  }, error = function(c) {
    worker$get('logger')$add(paste('Error',c$message ),'E')
  })

  # Stop if Error
  stopifnot(!worker$get('logger')$stop())
  
  # create list of reference tables
  refold <- NULL
  refnew <- NULL
  tryCatch({
    refold <- create_reftab(dfold)
    worker$get('logger')$add("Referenztabellen erstellt ...")
    
    refnew <- create_reftab(dfnew)
    worker$get('logger')$add("Validatortabellen erstellt ...")
  }, warning = function(c) {
    worker$get('logger')$add(paste('Warning',c$message ),'W')
  }, error = function(c) {
    worker$get('logger')$add(paste('Error',c$message ),'E')
  })
  
  # Stop if Error
  stopifnot(!worker$get('logger')$stop())
  
  # create list of tables with difference
  difflist <- purrr::map2(refnew, refold, valid_data)
  
  # Write differences per year to the log file
  worker$get('logger')$add(
    sprintf("..%s mit %i Todesfälle", 
            difflist[[1]]$YEAR, difflist[[1]]$DIFF),
    ifelse(difflist[[1]]$DIFF>=0, 'I', 'W')
  )
  
  # Write differences per calendar week to the log file
  dfkw <- difflist[[2]] %>%
    mutate(st = if_else(between(row_number(), n()-7, n()),'I',NULL)) %>%
    mutate(st = if_else(VALUE.OLD==0 & is.na(st),'W',st))  %>%
    mutate(st = if_else(!between(DIFF,0,1500), 'W',st)) %>%
    mutate(st = if_else(row_number()==n() & DIFF<500, 'E',st)) %>%
    filter(!is.na(st))
  worker$get('logger')$add(
    sprintf("..%s mit %i Todesfälle", dfkw$TIME_PERIOD, dfkw$DIFF),
    dfkw$st
  )

  # Stop if Error
  stopifnot(!worker$get('logger')$stop())
  
  # Write differences to difference file (CSV)
  tryCatch({
    difftable <- diffobj$diffdf(dfold, dfnew)
    worker$get('logger')$add(sprintf('Differenzen in %i Zeilen mit %i Todesfällen ..', 
                    nrow(difftable), sum(difftable$diff)))
    
    diffobj$write(difftable)
    worker$get('logger')$add(sprintf("..in %s geschrieben !",diffobj$file()))
    
    # return value 
    return_value <- difftable
    
  }, warning = function(c) {
    worker$get('logger')$add(paste('Warning',c$message ),'W')
  }, error = function(c) {
    worker$get('logger')$add(paste('Error',c$message ),'E')
  })
  

  # Stop if Error
  stopifnot(!worker$get('logger')$stop())
  
  # Ersetze alte Datei durch neu
  if (replace) {
    arcfile <- file.path(dirname(oldfile),paste0(prefix, basename(oldfile)))
    tmpfile <- paste0(arcfile,".tmp")
    tryCatch({
      
      # save archive file to temp file
      if (file.exists(arcfile)) 
        stopifnot(file.rename(arcfile, tmpfile))
      
      # rename files
      stopifnot(file.rename(oldfile, arcfile))
      worker$get('logger')$add(sprintf("%s umbenannt in %s",oldfile, arcfile))
      stopifnot(file.rename(newfile, oldfile))
      worker$get('logger')$add(sprintf("%s umbenannt in %s",newfile, oldfile))
      
      # delete temp file
      if (file.exists(tmpfile)) 
        stopifnot(file.remove(tmpfile))
      
    }, warning = function(c) {
      worker$get('logger')$add(paste('Warning',c$message ),'W')
    }, error = function(c) {
      worker$get('logger')$add(paste('Error',c$message ),'E')
    })
    
  }
  
  # Stop if Error
  stopifnot(!worker$get('logger')$stop())

  return(invisible(return_value))
}



# function to create reference tables
create_reftab <- function(data) {
  ref1 <- data %>%
    filter(SEX == 'T', AGE == '_T', GEO == 'CH') %>%
    group_by(YEAR) %>%
    summarise(VALUE = sum(VALUE)) %>%
    ungroup()
  ref2 <- data %>%
    filter(SEX == 'T', AGE == '_T', GEO == 'CH') %>%
    filter(Obs_status == 'P') %>%
    group_by(TIME_PERIOD) %>%
    summarise(VALUE = sum(VALUE)) %>%
    ungroup()
  return(list(ref1=ref1, ref2=ref2))
}

# function to validate two dataframes
valid_data <- function(new,old) {
  keys <- names(new)[!grepl("VALUE",names(new))]
  
  left_join(new,old, by=keys, suffix=c(".NEW",".OLD")) %>%
    mutate_if(is.numeric, function(x){if_else(is.na(x),0L,x)}) %>%
    mutate(DIFF = VALUE.NEW-VALUE.OLD) %>%
    filter(DIFF != 0)
}

