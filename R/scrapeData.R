# Hello, world!
#
# This is an example function named 'hello'
# which prints 'Hello, world!'.
#
# You can learn more about package authoring with RStudio at:
#
#   http://r-pkgs.had.co.nz/
#
# Some useful keyboard shortcuts for package authoring:
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
#' In june 2013 the 15min products started in Swiss
#' At EPEX SPOT website there seem to be always two days in one table at the site.
#' It is also only possible to get one day (or two in the table) at once. No time period option.
#' The data is only retrievable via the html document
#' example link for 2017-05-25 for german/austrian market: https://www.epexspot.com/en/market-data/intradaycontinuous/intraday-table/2017-05-25/DE
#'
#' @param startDate -
#' @param endDate -
#' @param product - Sets which product should be crawled. There are hourly ("60"), 30min ("30") and 15min ("15") data. Default value is "60" for the hourly data.
#'
#' @return a data.frame with DateTime as POSIXct object and Last prices of hourly data.
#'
#' @examples
#' h <- getIntradayContinuousEPEXSPOT("2017-05-20", "2017-05-26", "60")
#'
#' @export
#'
getIntradayContinuousEPEXSPOT <- function(startDate, endDate, product = "60") {
  library(logging)
  library(httr)
  library(XML)
  library(dplyr)

  # Setup the logger and handlers
  basicConfig(level="DEBUG") # parameter level = x, with x = debug(10), info(20), warn(30), critical(40) // setLevel()
  #nameLogFile <- paste("getReserveNeeds_", Sys.time(), ".txt", sep="")
  #addHandler(writeToFile, file=nameLogFile, level='DEBUG')


  sdate <- as.Date(startDate, "%Y-%m-%d")
  edate <- as.Date(endDate, "%Y-%m-%d")
  # calls for every day in dates array --> !! maybe every two days, depends if always two dates for one date request are shown in table
  # Therefore it is good to start with the loop at the last date, then the day before the last date can be also on the table
  dates_array = seq(sdate, edate, by="days")

  r = data.frame()
  # Init progress bar // CAUTION --> the length of auctionIds can be longer than needed (retrieves all auctionIds but stops at the input end date)
  if(getOption("logging")) pb <- txtProgressBar(min = 0, max = length(dates_array) - 1, style = 3)

  for(i in seq(length(dates_array), 1, -2)) {

    if(getOption("logging")) loginfo(paste("getIntradayContinuousEPEXSPOT - Call for: ", dates_array[i], " and ", dates_array[i-1], " | REMEBER 2 dates on site!"))

    url = paste("https://www.epexspot.com/en/market-data/intradaycontinuous/intraday-table/", dates_array[i], "/DE", sep="")

    payload = list();

    postResponse <- POST(url, body = payload, encode = "form")

    parsedHtml <- htmlParse(content(postResponse, "text"))
    r <- rbind(r, parseICEPEXSPOT(parsedHtml))

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
parseICEPEXSPOT <- function(htmlDoc) {
  library(logging)
  library(XML)

  if(getOption("logging")) loginfo(paste("parseICEPEXSPOT - Parsing Continuous Intraday EPEX website with 2 dates"))

  date_list <- as.Date(xpathSApply(htmlDoc, "id('content')/div/table/tbody/tr[1]/th[contains(@class, 'date')]/text()", saveXML), "%d/%m/%Y")

  # Time: Hour (First 00 - 01) --> But only 00 needed
  # id('content')/x:div/x:table/x:tbody/x:tr[4]/x:td[3]
  # ---> contains all time slots: id('content')/div/table/tbody/tr/td[contains(@class, 'title')]
  times_list <- xpathSApply(htmlDoc, "id('content')/div/table/tbody/tr/td[contains(@class, 'title')]/text()", saveXML)
  # Clean the strings --> remove newline and whitespcaes
  times_list <- gsub("\n", "", gsub(" ", "", times_list, fixed = TRUE))
  # ---> every 7th entry is hour data --> e.g. 1. 8. 15. 22. ......
  # get every hour: 00-01 01-02 ...and also reduce to 00 01 ... and append by ":00" for nice format 00:00 01:00 ...
  hour_list <- sapply(strsplit(times_list[seq(1, length(times_list)-1, 7)], "-"), function(x) paste(x[1], ":00", sep=""))

  # Last priceof first date
  # Gets every td elements of table (also times etc)
  tds_list <- xpathSApply(htmlDoc, "id('content')/div/table/tbody/tr/td[contains(@class, 'toggle_30min_info_closed')]/../td/text()", saveXML)
  # every 17th entry starting at the 4th e.g. 4. 21. ...
  last_price_1 <- as.numeric(tds_list[seq(4, length(tds_list)-1, 17)])
  # CAUTION: WHAT IF NO SECOND PRICE ?????
  # Last price of second date
  # every 17th entry starting at the 12th e.g. 12. 29. ...
  last_price_2 <- as.numeric(tds_list[seq(12, length(tds_list)-1, 17)])

  # CAUTION: WHAT IF NO SECOND PRICE ?????
  # Combine Dates and hours to a DateTime array
  d <- as.POSIXct(c(paste(date_list[1], hour_list), paste(date_list[2], hour_list)), tz = "Europe/Berlin")

  df <- data.frame(DateTime = d, Last = c(last_price_1, last_price_2))


  return(df)
}



#'
#' Two possible sources: from EEX website or from EPEX SPOT Website. EPEX SPOT has few days on one site EEX only one day
#'
#' example link for 2017-05-25 for german/austrian market: https://www.epexspot.com/en/market-data/dayaheadauction/auction-table/2017-05-25/DE/24
#'
getDayAheadAuctionEEX <- function(startDate, endDate, product) {
  print("Hello, world!")
}


