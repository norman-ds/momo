build_config <- function() {
 
  # read download in config.yaml
  config <- yaml::read_yaml('config.yaml')
  
  # local directories must exist
  map_chr(config, ~ unlist(.x['path'])) %>%
    map_if(~ !is.na(.x), ~ if (!dir.exists(.x)) dir.create(.x))
  
  # get filename full path
  getfile <- function(configname) {
#    c <- unlist(as.relistable(config))
    c <- unlist(config)
    tmpnams <- names(c)[grep(configname, names(c))] # location of configname
    tmpkeys <- unlist(strsplit(tmpnams,'[.]')) # delete keys after configname
    
    # configname in nested list must be on level 1 or 2
    if (length(tmpkeys)>2) warning("File in config.yaml not on level 2")

    file.path(config[[tmpkeys[1]]][['path']], c[tmpnams])
    
  }
  
  tmpdir <- function() {
    tmpdir <- config$tmpdir
    oudir <- config$outputpath
    
    if (dir.exists(tmpdir)) unlink(tmpdir, T, T)
    dir.create(tmpdir)
    
    add <- function(from, ...) {
      file.copy(from=from, to=tmpdir, ...)
    }
    
    dopublic <- function() {
      if (!dir.exists(oudir)) dir.create(oudir)
      
      list.files(tmpdir, full.names = T, recursive = T) %>%
        lapply(file.copy, to=oudir, recursive = T)
      unlink(tmpdir, T, T)
    }
    
    return(list(path = tmpdir, add = add, dopublic = dopublic))
  }
  
  list(data=config, filepath=getfile, tmpdir=tmpdir)
}

