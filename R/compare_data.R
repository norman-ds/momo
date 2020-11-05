# install.packages('arsenal')
library(dplyr)
library(readr)
library(lubridate)
#library(arsenal)

# Data of the year 2020
file1 <- file.path('..', 'stand20201105', 'todesfaelle_woche8id_of20200926.csv') # Stand 26.September
file2 <- file.path('..', 'stand20201105', 'new_todesfaelle_woche26id.csv') # Stand 26.September 2020-W37
file2 <- file.path('..', 'stand20201105', 'ts-q-01.04.02.01.30-2020.csv') # Stand 26.September 2020-W37
file2 <- file.path('..', 'stand20201105', 'new_todesfaelle_woche20id.csv') # Stand 25.Oktober 2020-W43
file2 <- file.path('..', 'stand20201105', 'ts-q-01.04.02.01.30-2020-2.csv') # Stand 25.Oktober 2020-W43

# Data of yeras 2000 to 2019
file1 <- file.path('..', 'data', 'todesfaelle2000to2019.csv') # Stand 09.Juni
file2 <- file.path('..', 'stand20201105', 'ts-q-01.04.02.01.30.csv') # Stand 05.November

stopifnot(file.exists(file1))
stopifnot(file.exists(file2))

df1 <- readr::read_delim(file1,
                        delim = ';',
                        col_types = cols(Obs_value = col_integer(),
                                         .default = col_character()))
df2 <- readr::read_delim(file2,
                         delim = ';',
                         col_types = cols(Obs_value = col_integer(),
                                          .default = col_character()))


# myby <- NULL
myby <- c("TIME_PERIOD", "GEO", "AGE", "SEX")
arsenal::comparedf(df1,df2, by = myby)
summary(arsenal::comparedf(df1,df2, by = myby, tol.num.val = 10))

max(df2$TIME_PERIOD)
