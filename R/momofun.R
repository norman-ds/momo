## Drei Funktionen für 
## ... fundeath() erstellt dataframe
## ... plotline() erstellt geom_line chart
## ... plotbar() erstellt geom_bar chart

## liest todesfalldaten und regionen
## gibt liste mit daten zürück
fundeath <- function(fdata, fregio) {
  
  # Kantonsliste mit KZ und Namen
  dfkanton <- readr::read_delim(fregio,
                                delim = ';',
                                col_types = cols(.default = col_character())) 
  
  ##############
  # dataframe nach Kanton und drei Altersgruppen
  dfdeath <- readr::read_delim(fdata,
                               delim = ';',
                               col_types = cols(.default = col_character())) %>%
    filter(AGE != '_T', SEX=='T') %>%
    mutate(year=gsub('^(.{4}).*','\\1',TIME_PERIOD), cw=gsub('.*(.{2})$','\\1',TIME_PERIOD)) %>%
    mutate(cw = as.integer(cw)) %>%
    mutate(AC0=gsub('(.+[ET])([0-9]?)([049])$','\\2\\3',AGE)) %>%
    mutate(AC1=as.integer(AC0)) %>%
    #mutate(age=if_else(AC1<=64,'0-64','65+')) %>%
    mutate(age=as.character(cut(AC1, breaks = c(0,64,80,100), labels = c("0-64", "65-79", "80+")))) %>%
    group_by(geo=GEO, year, cw, age) %>%
    summarise(value=sum(as.double(Obs_value))) %>%
    group_by(geo, year, age) %>%
    mutate(value_cum = cumsum(value)) %>%
    ungroup() %>%
    mutate(ggeo=gsub('^(CH0[1-7]).$','\\1',geo)) %>%
    inner_join( dfkanton, by='geo' )
  
  ##############
  # Konstanten zum aktuellsten Jahr und Kalenderwoche
  year_last <- '2020'
  cw_last <- max(dfdeath[dfdeath$year==year_last,]$cw)
  
  return(list(data=dfdeath, regions=dfkanton, year=year_last, cw=cw_last))
}



## erstellt ggplot mit liniendiagram
plotline <- function(datalist, kanton) {
  
  ##############
  # Funktion für line-plot nach Region
  
  # Grafiktitel
  my_titel <- sprintf('Wöchentliche Fälle, %s',
                      datalist$regions$kanton2[datalist$regions$kanton==kanton])
  
  # Koordinaten für Grafiktext
  xtxt <- datalist$cw + 1
  ytxt <- filter(datalist$data, kanton==!!kanton, year==datalist$year, cw==datalist$cw) 
  ytxt <- unlist(ytxt$value)
  
  # Koordinaten für vertikale Line
  xlin <- datalist$cw
  ylin <- min(ytxt)
  
  
  # return lineplot
  datalist$data %>%
    filter(kanton==!!kanton, cw<53, year>'2009') %>%
    mutate(highlight=year!=datalist$year) %>%
    mutate(yeage = paste(year,age)) %>%
    
    ggplot(aes(x=cw, y=value, group=yeage, color=highlight, size=highlight)) +
    geom_line() +
    scale_color_manual(values = c("#69b3a3", "lightgrey")) +
    scale_size_manual(values=c(1.5,0.2)) +
    scale_x_continuous(limits = c(1, 52)) +
    theme_minimal() +
    ggtitle(my_titel) +
    ylab(NULL) +
    xlab('Kalenderwoche') +
    geom_label(x=xtxt, y=ytxt[3], label='Altersgruppe 80 Jahre und älter', size=2, color='#69b3a3', fill='white', hjust = 0) +
    geom_label(x=xtxt, y=ytxt[2], label='Altersgruppe 65 -79 Jahre', size=2, color='#69b3a3', fill='white', hjust = 0) +
    geom_label(x=xtxt, y=ytxt[1], label='Altersgruppe 0 - 64 Jahre', size=2, color='#69b3a3', fill='white', hjust = 0) +
    geom_vline(xintercept = xlin, colour = "lightblue") +
    geom_label(x=xlin, y=ylin, label=xlin, size=2, color='lightblue', fill='white', vjust = 1) +
    theme(
      legend.position="none",
      plot.title = element_text(size=14)
    ) 
}  


## erstellt ggplot mit balkendiagram
plotbar <- function(datalist, kanton) {
  
  ##############
  # Funktion für bar-plot nach Region
  
  # Grafiktitel
  my_titel <- sprintf('Fälle (Summe KW 1-%s), %s',
                      datalist$cw,
                      datalist$regions$kanton2[datalist$regions$kanton==kanton])
  
  # return barplot
  dfbar <- datalist$data %>% 
    filter(kanton==!!kanton) %>%
    filter(cw <= datalist$cw) %>%
    group_by(year, age) %>%
    summarise(N=sum(value)) %>%
    ungroup() %>%
    mutate(highlight=(!year %in% c('2015',datalist$year)))  %>%
    mutate(year = as.integer(year))
  
  # Koordinaten für Grafiktext
  ycord <- group_by(dfbar, age) %>% summarise(y=max(N))
  ycord <- unlist(ycord$y)*1.2
  ycord[3] <- ycord[3]/2
  labtxt <- data.frame(year=2010, N=ycord, age=c("0-64", "65-79", "80+"), 
                       label=c("Altersgruppe 0 - 64 Jahre",
                               "Altersgruppe 65 -79 Jahre",
                               "Altersgruppe 80 Jahre und älter"))
  
  ggplot(dfbar, aes(x=year, y=N, fill=highlight)) +
    geom_bar(stat = "identity", width = 1) +
    geom_smooth(method = lm, se = T, fill='lightblue') +
    scale_fill_manual(values = c("#69b3a3", "lightgrey")) +
    theme_minimal() +
    ggtitle(my_titel) +
    ylab(NULL) +
    xlab('Jahr') +
    theme(
      legend.position="none",
      plot.title = element_text(size=14),
      axis.text.x = element_text(angle=45),      ) +
    facet_wrap(age ~ .) +
    theme(strip.background = element_blank(), strip.text = element_blank()) +
    geom_label(data = labtxt, label=labtxt$label, size=2, color='#69b3a3', fill='white') 
}

## ---- data --------
