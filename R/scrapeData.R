#
# This R package provides functions to crawl the EPEX SPOT Market
#
#   Build and Reload Package:  'Cmd + Shift + B'
#   Check Package:             'Cmd + Shift + E'
#   Test Package:              'Cmd + Shift + T'


#'
#' @export
#'
setLogging <- function(logger) {
  options("logging" = logger)
  ifelse(logger == TRUE, print("Outputs/logs will be displayed!"), print("No console outputs/logs will be displayed!"))
}


#' @title getIntradayContinuousEPEXSPOT
#'
#' @description This function returns the price data of the EPEX SPOT Continuous Intraday Trading for a time period. STATUS QUO only last prices
#' #' In december 2011 the 15min products started in Germany // For the Intrady-Auction (important for Bilanzkreisverantwortliche) the 15min products were introducd in december 2014
#' In june 2013 the 15min products started in Swiss. France has only 1h and 30min products.
#' At EPEX SPOT website there seem to be always two days in one table at the site.
#' It is also only possible to get one day (or two in the table) at once. No time period option.
#' The data is only retrievable via the html document
#' example link for 2017-05-25 for german/austrian market: https://www.epexspot.com/en/market-data/intradaycontinuous/intraday-table/2017-05-25/DE
#'
#' @param startDate - Set the start date for the price data period
#' @param endDate - Set the end date for the price data period
#' @param product - Sets which product should be crawled. There are hourly ("60"), 30min ("30") and 15min ("15") data. Default value is "60" for the hourly data.
#' @param country - Defines the country from which the data should be crawled. Default value is "DE". There is also "FR" (France) and "CH" (Swiss)
#'
#' @return a data.frame with DateTime as POSIXct object and Last prices of hourly data.
#'
#' @examples
#' h <- getIntradayContinuousEPEXSPOT("2017-05-20", "2017-05-26", "60")
#'
#' @export
#'
getIntradayContinuousEPEXSPOT <- function(startDate, endDate, product = "60", country = "DE") {
  library(logging)
  library(httr)
  library(XML)
  library(dplyr)

  # Check that 15min products for France is not allowed --> set to default
  if(country == "FR" & product == "15"){
    product = "60"
    print("There are no 15min products for France --> Changed to default: 60min")
  }

  # Setup the logger and handlers
  basicConfig(level="DEBUG") # parameter level = x, with x = debug(10), info(20), warn(30), critical(40) // setLevel()
  #nameLogFile <- paste("getReserveNeeds_", Sys.time(), ".txt", sep="")
  #addHandler(writeToFile, file=nameLogFile, level='DEBUG')


  sdate <- as.Date(startDate, "%Y-%m-%d")
  edate <- as.Date(endDate, "%Y-%m-%d")
  # calls for every day in dates array --> !! maybe every two days, depends if always two dates for one date request are shown in table
  # Therefore it is good to start with the loop at the last date, then the day before the last date can be also on the table
  dates_array = seq(sdate, edate, by="days")


  # url = paste("https://www.epexspot.com/en/market-data/intradaycontinuous/intraday-table/", dates_array[length(dates_array)], "/DE", sep="")
  #
  # payload = list();
  #
  # postResponse <- POST(url, body = payload, encode = "form")
  #
  # parsedHtml <- htmlParse(content(postResponse, "text", encoding = "UTF-8"))
  # return(parseICEPEXSPOT(parsedHtml))


  r = data.frame()
  # Init progress bar // CAUTION --> the length of auctionIds can be longer than needed (retrieves all auctionIds but stops at the input end date)
  if(getOption("logging")) pb <- txtProgressBar(min = 0, max = length(dates_array) - 1, style = 3)

  for(i in seq(length(dates_array), 1, -2)) {

    if(getOption("logging")) loginfo(paste("getIntradayContinuousEPEXSPOT - Call for: ", dates_array[i], " and ", dates_array[i-1], " | REMEBER 2 dates on site!"))

    url = paste("https://www.epexspot.com/en/market-data/intradaycontinuous/intraday-table/", dates_array[i], "/", country, sep="")

    payload = list();

    postResponse <- POST(url, body = payload, encode = "form")

    parsedHtml <- htmlParse(content(postResponse, "text", encoding = "UTF-8"))
    r <- rbind(r, parseICEPEXSPOT(parsedHtml, product, country))

    # update progress bar
    if(getOption("logging")) setTxtProgressBar(pb, length(dates_array) - i + 1)

  }

  # CLose the progress bar
  if(getOption("logging")) close(pb)

  r <- r %>% filter(format(DateTime, "%Y-%m-%d") >= sdate) %>% arrange(DateTime)

  if(getOption("logging")) loginfo(paste("getIntradayContinuousEPEXSPOT - DONE"))

  return(r)

}

# Helper function for @seealso getIntradayContinuousEPEXSPOT
#
# parses target website for data of first date and second date on the site
# CAUTION what if not two dates are displayed!!! --> BUT it seems that always two are displayed
parseICEPEXSPOT <- function(htmlDoc, product, country) {
  library(logging)
  library(XML)

  if(getOption("logging")) loginfo(paste("parseICEPEXSPOT - Parsing Continuous Intraday EPEX website with 2 dates"))

  date_list <- as.Date(xpathSApply(htmlDoc, "id('content')/div/table/tbody/tr[1]/th[contains(@class, 'date')]/text()", saveXML), "%d/%m/%Y")
  # Get the Base and Peak index price for both dates
  index_price_list <- xpathSApply(htmlDoc, "id('content')/div/table/tbody/tr/th[contains(@class, 'date')]/text()", saveXML)
  base_1 <- sapply(strsplit(gsub("\n", "", gsub(" ", "", index_price_list[3:6], fixed = TRUE)), ":"), function(x) as.numeric(x[2]))[1]
  peak_1 <- sapply(strsplit(gsub("\n", "", gsub(" ", "", index_price_list[3:6], fixed = TRUE)), ":"), function(x) as.numeric(x[2]))[2]
  base_2 <- sapply(strsplit(gsub("\n", "", gsub(" ", "", index_price_list[3:6], fixed = TRUE)), ":"), function(x) as.numeric(x[2]))[3]
  peak_2 <- sapply(strsplit(gsub("\n", "", gsub(" ", "", index_price_list[3:6], fixed = TRUE)), ":"), function(x) as.numeric(x[2]))[4]

  # Time: Hour (First 00 - 01) --> But only 00 needed
  # ---> contains all time slots: id('content')/div/table/tbody/tr/td[contains(@class, 'title')]
  times_list <- xpathSApply(htmlDoc, "id('content')/div/table/tbody/tr/td[contains(@class, 'title')]/text()", saveXML)
  # Clean the strings --> remove newline and whitespcaes
  times_list <- gsub("\n", "", gsub(" ", "", times_list, fixed = TRUE))

  # get every hour: 00-01 01-02 ...and also reduce to 00 01 ... and append by ":00" for nice format 00:00 01:00 ...
  # for other product shift start by 1 (30min) 2 (15min)
  # Default value is hour start and freq
  if(product == "60") {
    # Pattern for 1h: start: 1 freq: every 7th entry is hour data --> e.g. 1. 8. 15. 22. ......
    # For french 60 min products the sequence of time is different since France has no 15min products: +3... --> 1 4 7 10 ...
    start_freq <- if(country == "FR") seq(1, length(times_list)-1, 3) else seq(1, length(times_list)-1, 7)
    # Set the xpath expression to get the right td elements
    xpath <- "id('content')/div/table/tbody/tr/td[contains(@class, 'toggle_30min_info_closed')]/../td/text()"
  }
  else if(product == "30") {
    # Pattern for 30min:+3 then +4 ---> 2 5 9 12 16 ...
    # For french 30 min products the sequence of time is different since France has no 15min products: +1 +2 ... --> 2 3 5 6 8 9 ..
    start_freq <- if(country == "FR") cseq(2, length(times_list)-1, c(1,2)) else cseq(2, length(times_list)-1, c(3,4))
    # Set the xpath expression to get the right td elements
    # For french 30 min products the xpath is different since France has no 15min products
    xpath <- if(country == "FR") "id('content')/div/table/tbody/tr[contains(@id, 'intra_30')]/td/text()" else "id('content')/div/table/tbody/tr/td[contains(@class, 'toggle_15min_info_closed')]/../td/text()"
  }
  else if(product == "15") {
    # Pattern for 15min: +1 then +2 then +1 then +3 ... --> 3 4 6 7 10 11 13 14 17 ...
    start_freq <- cseq(3, length(times_list)-1, c(1,2,1,3))
    # Set the xpath expression to get the right td elements
    xpath <- "id('content')/div/table/tbody/tr[contains(@id, 'intra_15')]/td/text()"
  }
  else{
    print("WRONG PRODUCT CODE - CHOOSE 60, 30 or 15 as character input!")
  }

  # Get the times
  times_list <- sapply(strsplit(times_list[start_freq], "-"), function(x) x[1])
  # Only for hourly data: Append by ":00" for nice format 00:00 01:00 ...
  times_list <- if(product == "60") paste(times_list, ":00", sep="") else paste(times_list, "", sep="")

  # Gets every td elements of table (also times etc)
  tds_list <- xpathSApply(htmlDoc, xpath, saveXML)

  # initialize data.frames with DateTime for the two dates on the site
  df1 <- data.frame(DateTime = as.POSIXct(c(paste(date_list[1], times_list)), tz = "Europe/Berlin"))
  df2 <- data.frame(DateTime = as.POSIXct(c(paste(date_list[2], times_list)), tz = "Europe/Berlin"))

  end <- if(country == "DE") 17 else 15
  shift1 <- if(country == "DE") 0 else 1
  shift2 <- if(country == "DE") 0 else 2
  # add columns/variables to the initial data.frames
  for(i in 2:end) {
    # after 10 the next date starts
    if(i < (10 - shift1)) {
      # 2nd is Low 3rd High .... buy and sell vol have comma seperated value fot thousands
      if(i == (8 - shift1) | i == (9 - shift1)) column <- as.numeric(gsub(",", "", tds_list[seq(i, length(tds_list), (17 - shift2))])) else column <- as.numeric(tds_list[seq(i, length(tds_list)-1, (17 - shift2))])
      df1 <- cbind(df1, i = column)
    }
    else {
      # buy and sell vol have comma seperated value fot thousands
      if(i == (16 - shift2) | i == (17 - shift2)) column <- as.numeric(gsub(",", "", tds_list[seq(i, length(tds_list), (17 - shift2))])) else column <- as.numeric(tds_list[seq(i, length(tds_list)-1, (17 - shift2))])
      df2 <- cbind(df2, i = column)
    }
  }

  df1 <- cbind(df1, Index_Base = base_1, Index_Peak = peak_1)
  df2 <- cbind(df2, Index_Base = base_2, Index_Peak = peak_2)
  r <- rbind(df1, df2)
  colnames(r) <- if(country == "DE") c("DateTime","Low","High","Last","Weighted_Avg","Idx","ID3","Buy_Vol","Sell_Vol","Index_Base","Index_Peak") else c("DateTime","Low","High","Last","Weighted_Avg","Idx","Buy_Vol","Sell_Vol","Index_Base","Index_Peak")

  return(r)
  #return(index_price_list)
}

# Helper function for @seealso parseICEPEXSPOT
# Allows complex patterns for sequence method
cseq <- function(from, to, by){
  times <- (to-from) %/% sum(by)
  x <- cumsum(c(from, rep(by, times+1)))
  x[x<=to]
}


#'
#' Two possible sources: from EEX website or from EPEX SPOT Website. EPEX SPOT has few days on one site EEX only one day
#'
#' example link for 2017-05-25 for german/austrian market: https://www.epexspot.com/en/market-data/dayaheadauction/auction-table/2017-05-25/DE/24
#'
getDayAheadAuctionEEX <- function(startDate, endDate, product) {
  print("Hello, world!")
}


