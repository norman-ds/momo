
# function of selected fieldes out of json file
pivotfile <- function(jfile) {
  list(start_date = as.Date(jfile$temporals$start_date, format="%Y-%m-%d"),
       end_date = as.Date(jfile$temporals$end_date, format="%Y-%m-%d"),
       url = jfile$resources$download_url[jfile$resources$media_type=='text/csv'])
}

# create a dataframe of file, url and dates
df_files <- list.files(path = config$path,
                       pattern = config$pattern, all.files = T, full.names = T, recursive = F, no.. = T) %>%
  purrr::map_dfr(function(x){df <- jwrapper(x) %>% pivotfile; df$file=x; df}) 

# save validate state of urls
df_files$urlexist <- RCurl::url.exists(df_files$url)
anybox$add(validate = df_files)

# function of find url of the most recent week
file_of_mrw <- function(data, unique_url = TRUE ) {
  df_red <- data %>%
    filter(end_date == max(end_date))
  
  if (!unique_url) {
    return(df_red)
  } else {
    myfile <- unique(df_red$url)
    stopifnot(length(myfile) == 1)
    return(myfile)
  }
}

# download data
#newfile <- file.path(config$path, config$datafile)
newfile <- config_all$filepath("datafile")  
if (file.exists(newfile)) unlink(newfile)

df_files %>%
  file_of_mrw() %>%
  curl::curl_download(newfile)

stopifnot(file.exists(newfile))

