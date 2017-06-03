# emarketcrawlR <br/> – The R package for crawling data of the german energy market (EPEX SPOT) - 


## Goal

This R package provides functions to crawl the german energy market at https://www.epexspot.com


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

The function `getIntradayContinuousEPEXSPOT()` retrieves the continuous intraday trading data of the EPEX SPOT in Paris. Therefore it crawls the website https://www.epexspot.com/en/market-data/intradaycontinuous/intraday-table/. You can specify a time period in the format YYYY-MM-DD, a trading product (the time in minutes 60, 30, 15) and the country ("DE", "FR", "CH"). The returned data.frame contains information about the Low(€/MWh), High(€/MWh), Last(€/MWh), Weighted Avg.(€/MWh), Index(€/MWh), ID3(€/MWh, only for German Market), Buy and Sell Volume(MW) as well as the Base and Peak Load(€/MWh).

A big disadvantage of the function is, that the website of EPEX SPOT only provides information of two days on one site. Hence a request to retrieve a longer time period of data can take awhile since the function has to make a request for every two days within that time interval.

```r
# Set Logging to print out the state of process including a progress bar
setLogging(TRUE)

# Get the 15min (default: hour data) trading price data in the given time period of the german cont. intra. at EPEX SPOT
prices <- getIntradayContinuousEPEXSPOT("2017-05-20", "2017-05-26", "15", "DE")

head(prices)
# Output:
#              DateTime  Low High Last Weighted_Avg   Idx   ID3 Buy_Vol Sell_Vol Index_Base Index_Peak
# 1 2017-05-20 00:00:00 17.5 35.0 24.0        25.74 25.74 25.58   329.8    420.8      21.22      18.82
# 2 2017-05-20 00:15:00 -1.2 32.0 32.0        20.48 20.48 20.48   264.5    286.5      21.22      18.82
# 3 2017-05-20 00:30:00 -3.7 33.0 28.0        21.85 21.85 21.85   347.5    347.5      21.22      18.82
# 4 2017-05-20 00:45:00 12.8 32.0 30.0        24.90 24.90 24.91   510.1    510.1      21.22      18.82
# 5 2017-05-20 01:00:00 15.0 31.8 29.5        23.19 23.19 23.17   292.7    292.7      21.22      18.82
# 6 2017-05-20 01:15:00  2.8 25.0 13.7        10.75 10.75 10.69   220.4    220.4      21.22      18.82

```


