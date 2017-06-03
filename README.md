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
#              DateTime  Low High Last Weighted_Avg   Idx Buy_Vol Sell_Vol Index_Base Index_Peak
# 1 2017-05-23 00:00:00 29.0 31.0 30.0        30.27 30.27    83.0    293.5      33.66      35.44
# 2 2017-05-23 01:00:00 28.6 31.1 29.0        29.44 29.44    75.0    368.7      33.66      35.44
# 3 2017-05-23 02:00:00 28.0 32.1 30.0        29.36 29.36   235.7    441.7      33.66      35.44
# 4 2017-05-23 03:00:00 21.0 29.9 28.4        28.32 28.32   139.3    327.8      33.66      35.44
# 5 2017-05-23 04:00:00 19.0 29.1 26.4        28.03 28.03   208.5    329.0      33.66      35.44
# 6 2017-05-23 05:00:00 -5.3 32.7 -5.3        27.53 27.53   176.5    314.5      33.66      35.44

```


