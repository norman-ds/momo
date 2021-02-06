# Extract data from the most recent week
# If weeks a not valid number, the return value will be the last

# return value is dataframe
extract_mrw <- function(data, vogeo = 'CH', weeks = 1) {
  
  # most recent weeks
  mrw <- sort(unique(data$TIME_PERIOD), TRUE)
  if (weeks >= 1 & weeks <= length(mrw))
    mrw <- mrw[1:weeks]
  else
    mrw <- max(data$TIME_PERIOD)

  data %>% 
    filter(AGE == '_T' & SEX == 'T') %>%
    filter(GEO %in% vogeo) %>%
    filter(TIME_PERIOD %in% mrw)
}

