
<!-- README.md is generated from README.Rmd. Please edit that file  -->

# MOMO

Das Mortalitätsmonitoring (MOMO) überwacht die wöchentliche Anzahl
Todesfälle in der Schweiz.

<!-- badges: start -->

![Render
README](https://github.com/norman-ds/momo/workflows/Render%20README/badge.svg)
![Run
download](https://github.com/norman-ds/momo/workflows/Run%20download/badge.svg)
![Deploy
dashboard](https://github.com/norman-ds/momo/workflows/Deploy%20dashboard/badge.svg)
<!-- badges: end -->

Die Todesfälle werden täglich den Zivilstandsämtern gemeldet und dem
[BFS](https://www.bfs.admin.ch/bfs/de/home/statistiken/bevoelkerung/geburten-todesfaelle/todesfaelle.html)
im Rahmen der Statistik der natürlichen Bevölkerungsbewegung (BEVNAT)
mitgeteilt. Der Melde- und Verarbeitungsprozess braucht Zeit. In der
Regel ist nach **neun Tagen** ein genügend grosser Anteil (\> 85%) der
Todesfälle registriert, so dass die Schätzung der tatsächlichen Zahl der
Todesfälle auf einer breiten Datenbasismöglich ist.
[Mortalitäsmonitoring Schweiz](https://norman-ds.github.io/momo/)

## API

Die Website bietet eine Datenübersicht und stellt die Datensätze in
einer API (JSON) wieder zur Verfügung. Zusätzlich wird ein Datensatz mit
den laufenden Veränderungen angeboten.

## Daten

Todesfälle nach Fünf-Jahres-Altersgruppe, Geschlecht, Woche und Kanton
der Jahre 2000 bis 2020. Die erfassten Daten des laufenden Jahres werden
automatisch täglich überprüft und auf der Homepage aktualisiert.

## DevOps

MOMO verfolgt einen kontinuierlichen Prozessansatz, der
Softwareentwicklung und IT-Betrieb abdeckt. Alle Scripts sind in
[R](https://www.r-project.org) geschrieben. Wobei für die
reproduzierbare Softwareentwicklung das Kontainersystem von
[Docker](https://hub.docker.com/r/rocker/verse) eingesetzt wird. Als
Versionierungssystem dient
[GitHub](https://help.github.com/en/actions/building-and-testing-code-with-continuous-integration),
GitHub *Action* für CI/CD und GitHub *Page* als
[Webserver](https://norman-ds.github.io/momo/).

Das IDE von RStudio wird in einem Docker gestartet und über den Browser
darauf zugegriffen
(<http://localhost:8787>).

``` yaml
docker run --name MOMO -d -p 8787:8787 -v $(pwd):/home/rstudio -e PASSWORD=pwd rocker/verse:3.6.3
```

Das Docker Image von *rocker/verse* hat die R Version 3.6.3 und einige
Packages installiert und erspart uns somit ein Nachinstallieren.

``` r
sessionInfo()
#> R version 3.6.3 (2020-02-29)
#> Platform: x86_64-pc-linux-gnu (64-bit)
#> Running under: Debian GNU/Linux 10 (buster)
#> 
#> Matrix products: default
#> BLAS/LAPACK: /usr/lib/x86_64-linux-gnu/libopenblasp-r0.3.5.so
#> 
#> locale:
#>  [1] LC_CTYPE=en_US.UTF-8       LC_NUMERIC=C              
#>  [3] LC_TIME=en_US.UTF-8        LC_COLLATE=en_US.UTF-8    
#>  [5] LC_MONETARY=en_US.UTF-8    LC_MESSAGES=C             
#>  [7] LC_PAPER=en_US.UTF-8       LC_NAME=C                 
#>  [9] LC_ADDRESS=C               LC_TELEPHONE=C            
#> [11] LC_MEASUREMENT=en_US.UTF-8 LC_IDENTIFICATION=C       
#> 
#> attached base packages:
#> [1] stats     graphics  grDevices utils     datasets  methods   base     
#> 
#> loaded via a namespace (and not attached):
#>  [1] compiler_3.6.3  magrittr_1.5    tools_3.6.3     htmltools_0.4.0
#>  [5] yaml_2.2.1      Rcpp_1.0.4.6    stringi_1.4.6   rmarkdown_2.1  
#>  [9] knitr_1.28      stringr_1.4.0   xfun_0.13       digest_0.6.25  
#> [13] rlang_0.4.5     evaluate_0.14
```

Die Versions-Liste der verwendeten
R-Packages.

``` r
libs <- c("RCurl","jsonlite","readr","dplyr","purrr","ggplot2","lubridate","flexdashboard","DT","dygraphs","xts")
ip <- installed.packages(fields = c("Package", "Version"))
ip <- ip[ip[,c("Package")] %in% libs,]
paste(ip[,c("Package")],ip[,c("Version")])
#>  [1] "dplyr 0.8.5"           "DT 0.13"               "dygraphs 1.1.1.6"     
#>  [4] "flexdashboard 0.5.1.1" "ggplot2 3.3.0"         "jsonlite 1.6.1"       
#>  [7] "lubridate 1.7.8"       "purrr 0.3.4"           "RCurl 1.98-1.2"       
#> [10] "readr 1.3.1"           "xts 0.12-0"
```
