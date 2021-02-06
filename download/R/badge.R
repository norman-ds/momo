## a badge function

badge <- function(lable, message, status='I') {
  
  badge_build <- function(lable, message, color) {
    sprintf('![%s](https://img.shields.io/badge/%s-%s-%s)',
            lable, lable, message, color)
  }
  badge_color <- function(status) {
    ifelse(any(status=='E'),'critical',
           ifelse(any(status=='W'),'blue',
                  'success'))
  }
  badge_message <- function(message) {
    gsub('-','--',message)
  }
  
  return(badge_build(lable, badge_message(message), badge_color(status)))
}
