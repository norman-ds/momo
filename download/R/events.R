build_events <- function() {

  # load files
  staticlog <- config_all$filepath('staticlog') %>% read_csv(col_types = "ccTcc") 
  eventsfile <- config_all$filepath('eventsfile')
  eventlog <-  read_csv(eventsfile, col_types = "ccTcc") 
  newstatic <- anti_join(staticlog, eventlog)
  
  # get last activity of each source
  sourcelast <- eventlog %>%
    group_by(source) %>%
    filter(timestamp == max(timestamp)) %>%
    ungroup %>%
    filter(activity == 'check-in')
    
  # Check if any new check-in
  newevents <- sourcelast %>%
    mutate(available=NA) %>%
    bind_rows(tibble(source=anybox$get()$json, available=T)) %>%
    group_by(source) %>%
    summarise(available=any(available, na.rm = T),n=n()) %>%
    mutate(validate = if_else(n>1, 'update', 
                              if_else(available, 'check-in', 'hidden'))) %>%
    group_by(source, validate) %>%
    mutate(timestamp = writedate(),
           status = "complete",
           resource = "BfS") %>%
    select(source, 
           activity=validate,
           timestamp,
           status,
           resource)  %>%
    filter(activity != 'update')

  # write events
  if(nrow(newstatic) + nrow(newevents) > 0) {
    newstatic %>%
      mutate_at(vars('timestamp'), writedate) %>%
      bind_rows(newevents) %>% 
      write_csv(eventsfile, append = T)
  }
   
  stopifnot(file.exists(eventsfile))
  
  message("... events completed ...")
  
}

