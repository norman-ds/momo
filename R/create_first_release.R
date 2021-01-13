# Analyse diff file
library(tidyverse)

# Range of weeks in 2020 W16 - W53
weekmin <- '2020-W16'
weekmax <- '2020-W53'

# Vector of geografic regions
vogeo <- c('CH011', 'CH021', 'CH040', 'CH070')

# File of differences
difffile <- file.path('..', 'data', 'diff.csv')
stopifnot(file.exists(difffile))

# File of first release
filewrite <- file.path('..','data', 'firstrelease.csv')
stopifnot(!file.exists(filewrite))

# read file to dataframe and do not cache within the function
source('diffdf.R')
df <- dff(difffile)$read(put=FALSE) %>%
  filter(TIME_PERIOD >= weekmin & TIME_PERIOD <= weekmax) %>%
  mutate_at(vars(neu,old,diff), as.integer)
glimpse(df)

# Dataframe of first value of each week in switzerland ch
df_ch <- df %>%
  group_by(TIMESTAMP,TIME_PERIOD) %>%
  summarise(old = sum(old), neu = sum(neu), diff = sum(diff)) %>%
  filter(old==0 & diff>10) %>%
  select(TIMESTAMP, TIME_PERIOD, VALUE=neu) %>%
  ungroup()
stopifnot(all(count(df_ch, TIME_PERIOD)$n==1))
stopifnot(all(df_ch$VALUE>500))
weeksnum <- dim(df_ch)[1]

# Dataframe per regions
df_reg <- df %>%
  filter(GEO %in% vogeo) %>%
  group_by(TIMESTAMP, TIME_PERIOD, GEO) %>%
  summarise(old = sum(old), neu = sum(neu), diff = sum(diff)) %>%
  filter(old==0 & diff>1) %>%
  select(TIMESTAMP, TIME_PERIOD, GEO, VALUE=neu) %>%
  ungroup()
stopifnot(all(count(df_reg, TIME_PERIOD, GEO)$n==1))
stopifnot(all(df_reg$VALUE>10))
stopifnot(weeksnum*length(vogeo) == dim(df_reg)[1])

# Write file
(df_fini <- df_ch %>%
  mutate(GEO = 'CH') %>%
  bind_rows(df_reg) %>%
  arrange(TIME_PERIOD, GEO) %>%
  mutate(AGE = '_T', SEX = 'T', Obs_status = 'P', Obs_value=VALUE) %>%
  mutate(YEAR=gsub('^(.{4}).*','\\1',TIME_PERIOD), 
         CW=gsub('.*(.{2})$','\\1',TIME_PERIOD)) %>%
select(TIME_PERIOD, GEO, AGE, SEX, Obs_status, Obs_value))


readr::write_csv2(df_fini, filewrite)
stopifnot(file.exists(filewrite))

# test if file readable
source('fileread.R')
fileread(filewrite)
fileread(filewrite) %>% summarise(min(TIME_PERIOD), max(TIME_PERIOD))
