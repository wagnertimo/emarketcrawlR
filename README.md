# emarketcrawlR <br/> – The R package for crawling data of the german energy market (EPEX SPOT) - 


## Goal

This R package provides functions to crawl the german energy market (https://www.epexspot.com).

## Status Quo

It can get hourly price data of the last price of the EPEX SPOT Continuous Intraday Trading.

## Get Started

### Installing

When installing this package you should at least use the *R version 3.3.0 (2016-05-03)*. For the library dependecies see the section below. You can easily install this R package by using the `install_github()` function from the `devtools` package:

```r
library(devtools)
install_github("wagnertimo/emarketcrawlR")
```
### Library dependencies

Before using this R package, please check that you have installed the following R packages. Normally during the installation of the package those dependencies will also be installed. If not you have to do it manually.

- `httr`
- `xml2`
- `XML`
- `lubridate`
- `dplyr`
- `logging`


### Usage

#### 1. Continuous Intraday Trading at EPEX SPOT

A big disadvantage of the function is, that the website of EPEX SPOT only provides information of two days on one site. Hence a request to retrieve a longer time period of data can take awhile since the function has to make a request for every two days within that time interval.

```r
# Set Logging to print out the state of process including a progress bar
setLogging(TRUE)

# Get the hourly (default) last price data in the given time period
lastPrices <- getIntradayContinuousEPEXSPOT("2017-05-20", "2017-05-26", "60")

head(lastPrices)
# Output:
#              DateTime Last
# 1 2017-05-20 00:00:00 26.9
# 2 2017-05-20 01:00:00 16.5
# 3 2017-05-20 02:00:00 22.1
# 4 2017-05-20 03:00:00 15.0
# 5 2017-05-20 04:00:00 22.9
# 6 2017-05-20 05:00:00 24.0

```


