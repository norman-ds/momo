## function berestful to be restful

berestful <- function(jpath = 'json.json' ,html=FALSE) {
 
  if (!html) {
    list.of.dts <-   jsonlite::read_json(jpath, simplifyVector = T) %>%
      mutate(subject = 1:n()) %>% 
      mutate(title = sprintf('**%s**  [download](%s)', display_name, download_url)) %>%
      select(-display_name, -download_url) %>%
      select(title, everything()) %>%
      tidyr::pivot_longer(-subject) %>%
      mutate(text = if_else(name=='title',value,
                            sprintf('- %s : %s', name, value))) %>%
      select(subject, text) %>%
      split(.$subject)
    
    purrr::map_chr(list.of.dts, ~paste(.x$text, collapse = "  \n")) %>%
      paste(., collapse = "\n\n")
    
  } else {
    list.of.dts <-jsonlite::read_json(jpath, simplifyVector = T) %>%
      mutate(subject = 1:n()) %>% 
      select(-download_url) %>%
      tidyr::pivot_longer(-subject) %>%
      split(.$subject)
    
    for (dti in list.of.dts) {
      print(knitr::kable(paste(dti$name, ' : ', dti$value),
                         caption = dti$value[1], 
                         table.attr = "class=\"striped\"", 
                         format = "html"))
      
      cat('\n\n<!-- -->\n\n')
    }
  }
}

