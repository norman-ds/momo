## a badge function

badge <- function(linkvector, file = "badgelinks.R") {
  
  # badge vector
  bgvec <- linkvector
  
  # add badge link
  add <- function(link) {
    bgvec <<- c(bgvec,link) 
  }
  
  # get vector
  get <- function() {
    bgvec
  }
  
  # Write badge
  write <- function() {
    paste0('badge<-"',
           paste(bgvec, collapse = ' '),
           '"') %>% 
      write_file(file)
  }
  return(list(add=add, get=get, write=write))
}