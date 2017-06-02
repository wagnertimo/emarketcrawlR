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
- `zoo`
- `lubridate`
- `timeDate`
- `dplyr`
- `tidyr`
- `magrittr`
- `data.table`
- `ggplot2`
- `doParallel`
- `foreach`
- `logging`
- `plotly`


### Usage

```r
# Get the hourly (default) last price data in the given time period
lastPrices <- getIntradayContinuousEPEXSPOT("2017-05-20", "2017-05-26", "60")

```


