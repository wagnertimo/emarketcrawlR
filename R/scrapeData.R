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
#' @description This function returns the price data of the EPEX SPOT Continuous Intraday Trading for a time period.
#' In december 2011 the 15min products started in Germany // For the Intrady-Auction (important for Bilanzkreisverantwortliche) the 15min products were introducd in december 2014
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
#' @return a data.frame with DateTime as POSIXct object and the cont. intra. trading prices
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


  sdate <- as.Date(startDate, "%Y-%m-%d", tz = "Europe/Berlin")
  edate <- as.Date(endDate, "%Y-%m-%d", tz = "Europe/Berlin")
  # calls for every day in dates array --> !! maybe every two days, depends if always two dates for one date request are shown in table
  # Therefore it is good to start with the loop at the last date, then the day before the last date can be also on the table
  dates_array = seq(sdate, edate, by = "days")


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
  if(getOption("logging")) pb <- txtProgressBar(min = 0, max = ifelse(length(dates_array) > 1, length(dates_array) - 1, length(dates_array)), style = 3)

  for(i in seq(length(dates_array), 1, -2)) {

    if(getOption("logging")) loginfo(paste("getIntradayContinuousEPEXSPOT - Call for: ", dates_array[i], " and ", dates_array[i-1], " | REMEBER 2 dates on site!"))

    url = paste("https://www.epexspot.com/en/market-data/intradaycontinuous/intraday-table/", dates_array[i], "/", country, sep="")

    payload = list();

    postResponse <- POST(url, body = payload, encode = "form")

    parsedHtml <- htmlParse(content(postResponse, "text", encoding = "UTF-8"))
    r <- rbind(parseICEPEXSPOT(parsedHtml, product, country), r)

    # update progress bar
    if(getOption("logging")) setTxtProgressBar(pb, length(dates_array) - i + 1)

  }

  # CLose the progress bar
  if(getOption("logging")) close(pb)

  r <- r %>% filter(format(DateTime, "%Y-%m-%d") >= sdate) # %>% arrange(DateTime) # do not arrange --> it should already be in order --> ALSO DST otherwise makes problems

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

  date_list <- as.Date(xpathSApply(htmlDoc, "id('content')/div/table/tbody/tr[1]/th[contains(@class, 'date')]/text()", saveXML), "%d/%m/%Y", tz = "Europe/Berlin")
  # Get the Base and Peak index price for both dates
  index_price_list <- xpathSApply(htmlDoc, "id('content')/div/table/tbody/tr/th[contains(@class, 'date')]/text()", saveXML)
  base_1 <- sapply(strsplit(gsub("\n", "", gsub(" ", "", index_price_list[3:6], fixed = TRUE)), ":"), function(x) as.numeric(x[2]))[1]
  peak_1 <- sapply(strsplit(gsub("\n", "", gsub(" ", "", index_price_list[3:6], fixed = TRUE)), ":"), function(x) as.numeric(x[2]))[2]
  base_2 <- sapply(strsplit(gsub("\n", "", gsub(" ", "", index_price_list[3:6], fixed = TRUE)), ":"), function(x) as.numeric(x[2]))[3]
  peak_2 <- sapply(strsplit(gsub("\n", "", gsub(" ", "", index_price_list[3:6], fixed = TRUE)), ":"), function(x) as.numeric(x[2]))[4]

  # Time: Hour (First 00 - 01) --> But only 00 needed
  # ---> contains all time slots: id('content')/div/table/tbody/tr/td[contains(@class, 'title')]
  times_list <- xpathSApply(htmlDoc, "id('content')/div/table/tbody/tr/td[contains(@class, 'title')]/text()", saveXML)
  # Clean the strings --> remove newline and whitespcaes and in case of DST+1 the 02a and 02b
  times_list <- gsub("a|b", "", gsub("\n", "", gsub(" ", "", times_list, fixed = TRUE)))

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
  df1 <- data.frame(DateTime = as.POSIXct(c(paste(date_list[1], times_list)), format = "%Y-%m-%d %H:%M", tz = "Europe/Berlin"))
  df2 <- data.frame(DateTime = as.POSIXct(c(paste(date_list[2], times_list)), format = "%Y-%m-%d %H:%M", tz = "Europe/Berlin"))

  end <- if(country == "DE") 19 else 17
  shift1 <- if(country == "DE") 0 else 1
  shift2 <- if(country == "DE") 0 else 2
  # add columns/variables to the initial data.frames
  for(i in 2:end) {
    # after 10 the next date starts
    if(i < (11 - shift1)) {
      # 2nd is Low 3rd High .... buy and sell vol have comma seperated value fot thousands
      if(i == (9 - shift1) | i == (10 - shift1)) column <- as.numeric(gsub(",", "", tds_list[seq(i, length(tds_list), (19 - shift2))])) else column <- as.numeric(tds_list[seq(i, length(tds_list)-1, (19 - shift2))])
      df1 <- cbind(df1, i = column)
    }
    else {
      # buy and sell vol have comma seperated value fot thousands
      if(i == (18 - shift2) | i == (19 - shift2)) column <- as.numeric(gsub(",", "", tds_list[seq(i, length(tds_list), (19 - shift2))])) else column <- as.numeric(tds_list[seq(i, length(tds_list)-1, (19 - shift2))])
      df2 <- cbind(df2, i = column)
    }
  }

  df1 <- cbind(df1, Index_Base = base_1, Index_Peak = peak_1)
  df2 <- cbind(df2, Index_Base = base_2, Index_Peak = peak_2)


  df1 = deleteExtraDSTHour(df1, product)
  df2 = deleteExtraDSTHour(df2, product)

  r <- rbind(df1, df2)
  colnames(r) <- if(country == "DE") c("DateTime","Low","High","Last","Weighted_Avg","Idx","ID3", "ID1","Buy_Vol","Sell_Vol","Index_Base","Index_Peak") else c("DateTime","Low","High","Last","Weighted_Avg","Idx","Buy_Vol","Sell_Vol","Index_Base","Index_Peak")

  # Get rid of NA columns when there is DST+1
  # There are always two days to be crawled --> so either the day before or after DST has an extra 2 hour obs --> get rid off


  # if ((as.Date(dst_date, tz = "Europe/Berlin") - 1) == as.Date(r$DateTime, tz = "Europe/Berlin") |
  #     (as.Date(dst_date, tz = "Europe/Berlin") + 1) == as.Date(r$DateTime, tz = "Europe/Berlin")){
  #    r = r[!(hour(r$DateTime) == 2 & is.na(r$Low) & is.na(r$High) & is.na(r$Last)), ]
  # }

  # Get rid of NA columns when there is DST-1
  #r = r[!(hour(r$DateTime) == 1 & is.na(r$Low) & is.na(r$High) & is.na(r$Last)), ]

  return(r)

}

# Helper function
# Allows complex patterns for sequence method
cseq <- function(from, to, by){
  times <- (to-from) %/% sum(by)
  x <- cumsum(c(from, rep(by, times+1)))
  x[x<=to]
}

# returns boolean if date (input) is the last sunday in october == DST time saving at 2hour
isDSTDateInOctober <- function(date) {
  library(lubridate)

  return(as.Date(lastDayOfMonth(1,10,year(date)), tz = "Europe/Berlin") == date)

}

# returns the last date in a given month for a given day (sunday == 1, monday == 2, ...)
lastDayOfMonth <- function(day, month, year){
  library(lubridate)
  library(zoo)

  lastDate = as.Date(zoo::as.yearmon(paste(year,"-",month,"-01",sep = "")), frac = 1, tz = "Europe/Berlin")
  # 1 = sunday , 2 = monday ... 7 saturday
  lastWeekDay = wday(lastDate)
  diff = lastWeekDay - day
  if(diff == 0) {
    return(lastDate)
  }
  else {
    # e.g target sunday = 1 and lastWeekDay monday = 2 --> diff 2 - 1 = 1 --> shift lastDate back 1 (diff) day(s)
    # e.g target sunday = 1 and lastWeekDay tuesday = 3 --> diff 3 - 1 = 2 --> shift lastDate back 2 (diff) day(s)
    # e.g target wednesday = 4 and lastWeekDay tuesday = 3 --> diff 3 - 4 = -1 --> if negative --> 7 - diff = 6 --->shift lastDate back 6 (diff) day(s)
    # e.g target tuesday = 3 and lastWeekDay monday = 2 --> diff 2 - 3 = -1 --> if negative --> 7 - diff = 6 --->shift lastDate back 6 (diff) day(s)
    if(diff < 0) {
      # shift lastDate back by 7 - diff
      shiftback = 7  + diff
    }
    else {
      # diff positive --> shift lastDate back by diff
      shiftback = diff
    }

    return(lastDate - shiftback)
  }
}


# Helper function
# Deletes the extra 2am hour at DST (CEST --> CET).
# This is caused by crawling the table with multiple dates where one date is the DST date (last sunday in october).
# Then all other dates (before or after, depends where the DST date is located in the table) have also the extra 2 am hour (02a and 02b)
# Table has 2 columns (dates) in e.g. @seealso getIntradayContinuousEPEXSPOT
deleteExtraDSTHour <- function(df, time) {
  library(dplyr)
  library(lubridate)


  # Get rid of NA columns when there is DST+1
  # There are always two days to be crawled --> so either the day before or after DST has an extra 2 hour obs --> get rid off
  dst_date = lastDayOfMonth(1,10, year(as.Date(df$DateTime, tz = "Europe/Berlin")))
  attr(dst_date, "tzone") = "Europe/Berlin"

  if ((as.Date(dst_date, tz = "Europe/Berlin") - 1) == as.Date(df$DateTime, tz = "Europe/Berlin") |
      (as.Date(dst_date, tz = "Europe/Berlin") + 1) == as.Date(df$DateTime, tz = "Europe/Berlin")){

    d = df[hour(df$DateTime) == 2,]
    rows = 0

    if(time == "15") {
      # extra 2am hour occured
      if(nrow(d) > 4) {
        # get rows of the 2am hours and save the last 4 (if 15min or 2 if 30min or 1 if 60min) of them --> delete
        rows = which(hour(df$DateTime) == 2)
        rows = rows[5:8]
        # get rid off the extra 2am hours
        df = df[-rows,]
      }
    }
    else if(time == "30"){
      # extra 2am hour occured
      if(nrow(d) > 4) {
        # get rows of the 2am hours and save the last 4 (if 15min or 2 if 30min or 1 if 60min) of them --> delete
        rows = which(hour(df$DateTime) == 2)
        rows = rows[3:4]
        # get rid off the extra 2am hours
        df = df[-rows,]

      }
    }
    else if(time == "60") {
      # extra 2am hour occured
      if(nrow(d) > 1) {
        # get rows of the 2am hours and save the last 4 (if 15min or 2 if 30min or 1 if 60min) of them --> delete
        rows = which(hour(df$DateTime) == 2)
        rows = rows[2]
        # get rid off the extra 2am hours
        df = df[-rows,]

      }
    }
  }

  return(df)
}




#' @title getIntradayAuctionEPEXSPOT
#'
#' @description This function returns the price data of the EPEX SPOT Intraday Auction for a time period.
#' Only for German Market. Only 15min data, bock prices with base and peak
#' https://www.epexspot.com/en/market-data/intradayauction
#'
#' Always get 7 days on one website (request). Date in request link is the latest date.
#'
#'
#' @param startDate - Set the start date for the price data period
#' @param endDate - Set the end date for the price data period
#'
#' @return a data.frame with DateTime as POSIXct object and intraday auction price data of the given product. The columns are DateTime and the 15min Prices with the Volume as well as daily data of: OffPeak, OffPeak1, SunPeak, OffPeak2, BasePrice", BaseVolume, PeakPrice, PeakVolume
#'
#' @examples
#' h <- getIntradayAuctionEPEXSPOT("2017-05-20", "2017-05-26")
#'
#' @export
#'
getIntradayAuctionEPEXSPOT <- function(startDate, endDate) {

  library(logging)
  library(httr)
  library(XML)
  library(dplyr)

  # Setup the logger and handlers
  basicConfig(level="DEBUG") # parameter level = x, with x = debug(10), info(20), warn(30), critical(40) // setLevel()
  #nameLogFile <- paste("getReserveNeeds_", Sys.time(), ".txt", sep="")
  #addHandler(writeToFile, file=nameLogFile, level='DEBUG')

  sdate <- as.Date(startDate, "%Y-%m-%d", tz = "Europe/Berlin")
  edate <- as.Date(endDate, "%Y-%m-%d", tz = "Europe/Berlin")
  # calls for every day in dates array --> !! maybe every two days, depends if always two dates for one date request are shown in table
  # Therefore it is good to start with the loop at the last date, then the day before the last date can be also on the table
  dates_array = seq(sdate, edate, by="days")

  r = data.frame()
  # Init progress bar // CAUTION --> the length of auctionIds can be longer than needed (retrieves all auctionIds but stops at the input end date)
  if(getOption("logging")) pb <- txtProgressBar(min = 0, max = ifelse(length(dates_array) > 1, length(dates_array) - 1, length(dates_array)), style = 3)

  for(i in seq(length(dates_array), 1, -7)) {

    if(getOption("logging")) loginfo(paste("getIntradayAuctionEPEXSPOT - Call for: ", dates_array[i], " - ", dates_array[i-6], " | REMEBER 7 dates on site!"))

    url = paste("https://www.epexspot.com/en/market-data/intradayauction/quarter-auction-table/", dates_array[i], "/DE", sep="")

    payload = list();

    postResponse <- POST(url, body = payload, encode = "form")

    parsedHtml <- htmlParse(content(postResponse, "text", encoding = "UTF-8"))
    r <- rbind(parseIAEPEXSPOT(parsedHtml, dates_array[i]), r)

    # update progress bar
    if(getOption("logging")) setTxtProgressBar(pb, length(dates_array) - i + 1)

  }

  # CLose the progress bar
  if(getOption("logging")) close(pb)

  r <- r %>% filter(format(DateTime, "%Y-%m-%d") >= sdate)

  if(getOption("logging")) loginfo(paste("getIntradayAuctionEPEXSPOT - DONE"))

  return(r)

}


#' Helper function for @seealso getIntradayAuctionEPEXSPOT
#'
parseIAEPEXSPOT <- function(htmlDoc, latestDate) {

  # Get the hours --> check if length is 24 or in DST+1 (CEST-->CET) 25 // For DST-1 it is still 24 since 7 days are displayed
  # --> FIRST read out the dates
  # --> THEN read out the starting hours and build the total date string ---> !! For DST+1 there is 02a (- 02b) and 02b (- 03)

  # Read out the dates --> id('tab_de')//span[contains(@class, 'date')]/text() # retrieves date range
  dateRange = xpathSApply(htmlDoc, paste("id('tab_de')/div[1]/div/span/text()", sep = ""), saveXML)
  # Delete the line break and the whitespaces and then split the date range on "-" to get the start and end date
  dateRange = gsub(" ", "", gsub("\n", "", dateRange))
  sd = strsplit(dateRange, "-")[[1]][1]
  ed = strsplit(dateRange, "-")[[1]][2]


  # Read Hours -->
  hourRange = xpathSApply(htmlDoc, paste("//div[contains(@class, 'quarter_auction_hours')]/div//td/text()", sep = ""), saveXML)
  hourRange = gsub(" ", "", gsub("\n", "", hourRange))
  hourVector = hourRange[seq(1,length(hourRange), 3)]


  # Build DateTime List
  # --> 02a and 02b are converted to 02 --> there will be two 02 hours
  hourVector = paste(gsub("a|b", "", hourVector), ":00:00", sep="")
  # adds the 15mins to the hours
  hourVector = addQuartersToHourVector(hourVector)
  # Get date range
  dateRange = seq.Date(as.Date(sd, "%d/%m/%Y", tz = "Europe/Berlin"), as.Date(ed, "%d/%m/%Y", tz = "Europe/Berlin"), by = "1 day")
  # Combine with all combinations the dates with the hours --> In cas of DST+1, dates will have also two 2hours --> those have to be removed after the values "-" are added
  timeList = apply(expand.grid(hourVector, dateRange), 1, function(x) paste(x[2], x[1]))


  # init the data.frame with the DateTimes of the seven days with 15minute interval
  df1 <- data.frame(DateTime = timeList)

  # xpath for 15mins (product)
  x <- xpathSApply(htmlDoc, "id('quarter_auction_table_wrapp')/table/tbody/tr[contains(@class, 'hour')]/td/text()", saveXML)
  # price is every ... entry. It starts with the earliest date till the latest date
  # price starts with 4, vol with 12
  prices <- c()
  vols <- c()
  for(day in 0:6) {
    prices <- c(prices, x[seq(4 + day, length(x), 18)])
    vols <- c(vols, x[seq(12 + day, length(x), 18)])
  }

  df1 <- cbind(df1, Prices = prices, Volume = vols)

  #xpath for block prices (product)
  # id('tab_de')/x:table[2]/tbody/tr/td[contains(@class, 'title')]/../td
  y <- xpathSApply(htmlDoc, "id('tab_de')/table[2]/tbody/tr/td[contains(@class, 'title')]/../td/text()", saveXML)
  offPeak <- c()
  offPeak1 <- c()
  sunPeak <- c()
  offPeak2 <- c()

  # set the day offset in 15min sections: 96 * 15min = 24h in normal case and in DST+1 case 100 * 15min = 25h (4*15min = 60min = +1h)
  # for 7days --> 672 15min times (96*7) with DST+1 there are 700 (additional 4*7=28)
  dayoffset = ifelse(nrow(df1) > 672, 100, 96)

  for(day in 0:6) {
    offPeak <- c(offPeak, rep(y[2 + day],dayoffset))
    offPeak1 <- c(offPeak1, rep(y[18 + day],dayoffset))
    sunPeak <- c(sunPeak, rep(y[34 + day],dayoffset))
    offPeak2 <- c(offPeak2, rep(y[42 + day],dayoffset))
  }

  df1 <- cbind(df1, OffPeak = offPeak, OffPeak1 = offPeak1, SunPeak = sunPeak, OffPeak2 = offPeak2)

  # xpath for base and peak loads prices (also in block prices xpath) AND VOLUME  (product)
  # id('tab_de')/x:table[1]/tbody/tr/td
  z <- xpathSApply(htmlDoc, "id('tab_de')/table[1]/tbody/tr/td/text()", saveXML)
  base_price <- c()
  base_vol <- c()
  peak_price <- c()
  peak_load <- c()
  for(day in 0:6) {
    base_price <- c(base_price, rep(z[2 + day],dayoffset))
    base_vol <- c(base_vol, rep(z[10 + day],dayoffset))
    peak_price <- c(peak_price, rep(z[25 + day],dayoffset))
    peak_load <- c(peak_load, rep(z[33 + day],dayoffset))
  }

  df1 <- cbind(df1, BasePrice = base_price, BaseVolume = base_vol, PeakPrice = peak_price, PeakVolume = peak_load)

  #Format DataSet
  df1$DateTime = as.POSIXct(df1$DateTime, format = "%Y-%m-%d %H:%M:%S", tz = "Europe/Berlin")
  df1$Prices = as.numeric(levels(df1$Prices))[df1$Prices]
  df1$Volume = as.numeric(gsub(",", "", df1$Volume))
  df1$OffPeak = as.numeric(levels(df1$OffPeak))[df1$OffPeak]
  df1$OffPeak1 = as.numeric(levels(df1$OffPeak1))[df1$OffPeak1]
  df1$SunPeak = as.numeric(levels(df1$SunPeak))[df1$SunPeak]
  df1$OffPeak2 = as.numeric(levels(df1$OffPeak2))[df1$OffPeak2]
  df1$BasePrice = as.numeric(levels(df1$BasePrice))[df1$BasePrice]
  df1$BaseVolume = as.numeric(gsub(",", "", df1$BaseVolume))
  df1$PeakPrice = as.numeric(levels(df1$PeakPrice))[df1$PeakPrice]
  df1$PeakVolume = as.numeric(gsub(",", "", df1$PeakVolume))


  # Get rid of NA columns when there is DST+1
  # if (isDSTDateInOctober(as.Date(df1$DateTime, tz = "Europe/Berlin"))){
  #   df1 = df1[!(hour(df1$DateTime) == 2 & is.na(df1$Low) & is.na(df1$High) & is.na(df1$Last)), ]
  # }
  # Get rid of NA columns when there is DST-1
  #df1 = df1[!(hour(df1$DateTime) == 1 & is.na(df1$Prices) & is.na(df1$Volume)), ]

  return(df1)

}

# Helper function in @seealso parseIAEPEXSPOT()
#
# Add Quarters th the hours: "XX:00:00", "XX:15:00", "XX:30:00", "XX:45:00"
# No other option since in case of DST+1 two conecutive 2am hours are following
addQuartersToHourVector <- function(hours) {

  res = c()

  for(i in 1:length(hours)) {

    res = c(res, hours[i],
            paste(strsplit(hours[i], ":")[[1]][1], ":15:00", sep=""),
            paste(strsplit(hours[i], ":")[[1]][1], ":30:00", sep=""),
            paste(strsplit(hours[i], ":")[[1]][1], ":45:00", sep="")
    )
  }

  return(res)
}






#' @title getDayAheadAuctionEPEXSPOT
#'
#' @description This function returns the price data of the EPEX SPOT Day-Ahead-Auction for a time period.
#' For french, german (Phelix) and swiss (swissix) --> MCC = Market Coulped Contracts??
#' https://www.epexspot.com/en/market-data/dayaheadauction
#'
#' Always get 7 days on one website (request). Date in request link is the latest date.
#'
#' @param startDate - Set the start date for the price data period
#' @param endDate - Set the end date for the price data period
#' @param country - Defines the country from which the data should be crawled. Default value is "DE". There is also "FR" (France) and "CH" (Swiss)
#'
#' @return a data.frame with DateTime as POSIXct object and Last prices of hourly data.
#'
#' @examples
#' h <- getDayAheadAuctionEPEXSPOT("2017-05-20", "2017-05-26", "60")
#'
#' @export
#'
getDayAheadAuctionEPEXSPOT <- function(startDate, endDate, country = "DE") {

  library(logging)
  library(httr)
  library(XML)
  library(dplyr)

  # Setup the logger and handlers
  basicConfig(level="DEBUG") # parameter level = x, with x = debug(10), info(20), warn(30), critical(40) // setLevel()
  #nameLogFile <- paste("getReserveNeeds_", Sys.time(), ".txt", sep="")
  #addHandler(writeToFile, file=nameLogFile, level='DEBUG')

  sdate <- as.Date(startDate, "%Y-%m-%d", tz = "Europe/Berlin")
  edate <- as.Date(endDate, "%Y-%m-%d", tz = "Europe/Berlin")
  # calls for every day in dates array --> !! maybe every two days, depends if always two dates for one date request are shown in table
  # Therefore it is good to start with the loop at the last date, then the day before the last date can be also on the table
  dates_array = seq(sdate, edate, by="days")

  r = data.frame()
  # Init progress bar
  if(getOption("logging")) pb <- txtProgressBar(min = 0, max = ifelse(length(dates_array) > 1, length(dates_array) - 1, length(dates_array)), style = 3)

  for(i in seq(length(dates_array), 1, -7)) {

    if(getOption("logging")) loginfo(paste("getDayAheadAuctionEPEXSPOT - Call for: ", dates_array[i], " - ", dates_array[i-6], " | REMEBER 7 dates on site!"))

    url = paste("https://www.epexspot.com/en/market-data/dayaheadauction/auction-table/", dates_array[i], "/", country, sep="")

    payload = list();

    postResponse <- POST(url, body = payload, encode = "form")

    parsedHtml <- htmlParse(content(postResponse, "text", encoding = "UTF-8"))
    r <- rbind(parseDAAEPEXSPOT(parsedHtml, country, dates_array[i]), r)

    # update progress bar
    if(getOption("logging")) setTxtProgressBar(pb, length(dates_array) - i + 1)

  }

  # CLose the progress bar
  if(getOption("logging")) close(pb)

  # subset the data to the appropriate input date range
  r <- r %>% filter(format(DateTime, "%Y-%m-%d") >= sdate)

  if(getOption("logging")) loginfo(paste("getDayAheadAuctionEPEXSPOT - DONE"))

  return(r)


}

#' Helper function for @seealso getDayAheadAuctionEPEXSPOT
#'
parseDAAEPEXSPOT <- function(htmlDoc, country, latestDate) {

  # Get the hours --> check if length is 24 or in DST+1 (CEST-->CET) 25 // For DST-1 it is still 24 since 7 days are displayed
  # --> FIRST read out the dates
  # --> THEN read out the starting hours and build the total date string ---> !! For DST+1 there is 02a (- 02b) and 02b (- 03)

  # Read out the dates --> id('tab_de')//span[contains(@class, 'date')]/text() # retrieves date range
  dateRange = xpathSApply(htmlDoc, paste("id('tab_", tolower(country), "')//span[contains(@class, 'date')]/text()", sep = ""), saveXML)
  # Delete the line break and the whitespaces and then split the date range on "-" to get the start and end date
  dateRange = gsub(" ", "", gsub("\n", "", dateRange))
  sd = strsplit(dateRange, "-")[[1]][1]
  ed = strsplit(dateRange, "-")[[1]][2]


  # Read Hours --> id('tab_de')/table[3]/tbody/tr/td[contains(@class, 'title')]
  hourRange = xpathSApply(htmlDoc, paste("id('tab_", tolower(country), "')/table[3]/tbody/tr/td[contains(@class, 'title')]/text()", sep = ""), saveXML)
  hourRange = gsub(" ", "", gsub("\n", "", hourRange))
  hourVector = unlist(lapply(strsplit(hourRange, "-"), function(x) x[1]))

  # Build DateTime List
  # --> 02a and 02b are converted to 02 --> there will be two 02 hours
  hourVector = paste(gsub("a|b", "", hourVector), ":00:00", sep="")
  # Get date range
  dateRange = seq.Date(as.Date(sd, "%d/%m/%Y", tz = "Europe/Berlin"), as.Date(ed, "%d/%m/%Y", tz = "Europe/Berlin"), by = "1 day")
  # Combine with all combinations the dates with the hours --> In cas of DST+1, dates will have also two 2hours --> those have to be removed after the values "-" are added
  timeList = apply(expand.grid(hourVector, dateRange), 1, function(x) paste(x[2], x[1]))



  # init the data.frame with the read out and build DateTimes
  df1 <- data.frame(DateTime = timeList)

  # xpath for 60mins (product)
  x <- xpathSApply(htmlDoc, paste("id('tab_", tolower(country), "')/table[3]/tbody/tr/td/text()", sep = ""), saveXML)
  prices <- c()
  vols <- c()
  for(day in 0:6) {
    prices <- c(prices, x[seq(3 + day, length(x), 18)])
    vols <- c(vols, x[seq(12 + day, length(x), 18)])
  }

  df1 <- cbind(df1, Prices = prices, Volume = vols)

  # xpath for block prices (product)
  y <- xpathSApply(htmlDoc, paste("id('tab_", tolower(country), "')/table[2]/tbody/tr/td[contains(@class, 'title')]/../td/text()", sep = ""), saveXML)
  middleNight <- c()
  earlyMorning <- c()
  lateMorning <- c()
  earlyAfternoon <- c()
  rushHour <- c()
  offPeak2 <- c()
  night <- c()
  offPeak1 <- c()
  business <- c()
  offPeak <- c()
  morning <- c()
  highNoon <- c()
  afternoon <- c()
  evening <- c()
  sunPeak <- c()

  # set the day offset in hours: 24h in normal case (24*7 = 168 entries) and in DST+1 case 25h (25*7 = 175 entries)
  dayoffset = ifelse(nrow(df1) > 168, 25, 24)

  for(day in 0:6) {
    middleNight <- c(middleNight, rep(y[2 + day],dayoffset))
    earlyMorning <- c(earlyMorning, rep(y[10 + day],dayoffset))
    lateMorning <- c(lateMorning, rep(y[18 + day],dayoffset))
    earlyAfternoon <- c(earlyAfternoon, rep(y[26 + day],dayoffset))
    rushHour <- c(rushHour, rep(y[34 + day],dayoffset))
    offPeak2 <- c(offPeak2, rep(y[42 + day],dayoffset))
    night <- c(night, rep(y[50 + day],dayoffset))
    offPeak1 <- c(offPeak1, rep(y[58 + day],dayoffset))
    business <- c(business, rep(y[66 + day],dayoffset))
    offPeak <- c(offPeak, rep(y[74 + day],dayoffset))
    morning <- c(morning, rep(y[82 + day],dayoffset))
    highNoon <- c(highNoon, rep(y[90 + day],dayoffset))
    afternoon <- c(afternoon, rep(y[98 + day],dayoffset))
    evening <- c(evening, rep(y[106 + day],dayoffset))
    sunPeak <- c(sunPeak, rep(y[114 + day],dayoffset))
  }

  df1 <- cbind(df1, MiddleNight = middleNight,
               EarlyMorning = earlyMorning,
               LateMorning = lateMorning,
               EarlyAfternoon = earlyAfternoon,
               RushHour = rushHour,
               OffPeak2 = offPeak2,
               Night = night,
               OffPeak1 = offPeak1,
               Business = business,
               OffPeak = offPeak,
               Morning = morning,
               HighNoon = highNoon,
               Afternoon = afternoon,
               Evening = evening,
               SunPeak = sunPeak)

  # xpath for base and peak loads prices (also in block prices xpath) AND VOLUME (product)
  #paste("id('tab_", tolower(country), "')/table[1]/tbody/tr/td", sep = "")
  z <- xpathSApply(htmlDoc, paste("id('tab_", tolower(country), "')/table[1]/tbody/tr/td/text()", sep = ""), saveXML)
  base_price <- c()
  base_vol <- c()
  peak_price <- c()
  peak_load <- c()
  for(day in 0:6) {
    base_price <- c(base_price, rep(z[2 + day],dayoffset))
    base_vol <- c(base_vol, rep(z[10 + day],dayoffset))
    peak_price <- c(peak_price, rep(z[25 + day],dayoffset))
    peak_load <- c(peak_load, rep(z[33 + day],dayoffset))
  }

  df1 <- cbind(df1, BasePrice = base_price, BaseVolume = base_vol, PeakPrice = peak_price, PeakVolume = peak_load)

  # Format DataSet
  df1$DateTime = as.POSIXct(df1$DateTime, format = "%Y-%m-%d %H:%M:%S", tz = "Europe/Berlin")
  df1$Prices = as.numeric(levels(df1$Prices))[df1$Prices]
  df1$Volume = as.numeric(gsub(",", "", df1$Volume))

  df1$OffPeak = as.numeric(levels(df1$OffPeak))[df1$OffPeak]
  df1$OffPeak1 = as.numeric(levels(df1$OffPeak1))[df1$OffPeak1]
  df1$SunPeak = as.numeric(levels(df1$SunPeak))[df1$SunPeak]
  df1$OffPeak2 = as.numeric(levels(df1$OffPeak2))[df1$OffPeak2]

  df1$MiddleNight = as.numeric(levels(df1$MiddleNight))[df1$MiddleNight]
  df1$EarlyMorning = as.numeric(levels(df1$EarlyMorning))[df1$EarlyMorning]
  df1$LateMorning = as.numeric(levels(df1$LateMorning))[df1$LateMorning]
  df1$EarlyAfternoon = as.numeric(levels(df1$EarlyAfternoon))[df1$EarlyAfternoon]
  df1$Night = as.numeric(levels(df1$Night))[df1$Night]
  df1$Business = as.numeric(levels(df1$Business))[df1$Business]
  df1$Morning = as.numeric(levels(df1$Morning))[df1$Morning]
  df1$HighNoon = as.numeric(levels(df1$HighNoon))[df1$HighNoon]
  df1$Afternoon = as.numeric(levels(df1$Afternoon))[df1$Afternoon]
  df1$Evening = as.numeric(levels(df1$Evening))[df1$Evening]

  df1$BasePrice = as.numeric(levels(df1$BasePrice))[df1$BasePrice]
  df1$BaseVolume = as.numeric(gsub(",", "", df1$BaseVolume))
  df1$PeakPrice = as.numeric(levels(df1$PeakPrice))[df1$PeakPrice]
  df1$PeakVolume = as.numeric(gsub(",", "", df1$PeakVolume))


  # Get rid of NA columns when there is DST+1
  # if (isDSTDateInOctober(as.Date(r$DateTime, tz = "Europe/Berlin"))){
  #   r = r[!(hour(r$DateTime) == 2 & is.na(r$Low) & is.na(r$High) & is.na(r$Last)), ]
  # }
  # Get rid of NA columns when there is DST-1
  #df1 = df1[!(hour(df1$DateTime) == 1 & is.na(df1$Prices) & is.na(df1$Volume)), ]

  # And delete the "empty" 2 hour in DST-1 --> the whole row is filled with NA also the index number (rowname) is NA (but as character "NA")
  df1 = df1[rownames(df1)[rownames(df1) != "NA"] , ]


  return(df1)

}









#' @title getPHELIXDEFuturesEEX
#'
#' @description This function returns the price data of the EEX Phelix DE Futures as seen at https://www.eex.com/en/market-data/power/futures/phelix-de-futures
#' Prices are in EUR/MWh and Volume in MWh. The returned data.frame mimics the table at the EEX website (+ BestBid/BestAsk volume).
#' The name column contains no Date or DateTime object (simply a factor).
#' The data is retrieved by sequentially scraping the data of each day. Therefore the data of the next day (regarding input date) is retrieved.
#' For the Weekend saturday and sunday data is retrieved (at friday dates).
#' Since the next data observation is retrieved (because tables are showing a lot of null values) the function is optimized for the "Day" product.
#' For other products like Week or Year, you will get only the next week or year data of the input date.
#' Note that the website only provides a limited history of the price data! This also depends on the product (Day, Week etc.)
#'
#' @param startDate - Set the start date for the price data period ("YYYY-MM-DD", character)
#' @param endDate - Set the end date for the price data period ("YYYY-MM-DD", character)
#' @param product - Set the product type == Day, Weekend, Week, Month, Quarter or Year --> IT IS RECOOMEND TO ONLY USE "DAY"
#'
#' @return a data.frame with the columns of the table seen on the EEX website. The name column identifies the product. It is not of type Date or DateTime!
#'
#' @examples
#' df = getPHELIXDEFuturesEEX("2017-08-02", "2017-08-04", "Day")
#'
#' @export
#'
getPHELIXDEFuturesEEX <- function(startDate, endDate, product) {

  library(logging)
  library(rjson)
  library(purrr)
  library(lubridate)

  # Setup the logger and handlers
  basicConfig(level="DEBUG") # parameter level = x, with x = debug(10), info(20), warn(30), critical(40) // setLevel()


  startDate = as.Date(startDate)
  endDate = as.Date(endDate)

  # get the startdate befor the input date --> data is always retrieved starting at the next day
  dateSeq = seq.Date(startDate - 1, endDate,1)

  res = data.frame()

  if(getOption("logging")) pb <- txtProgressBar(min = 0, max = length(dateSeq), style = 3)


  for(i in 1:length(dateSeq)) {

    if(getOption("logging")) loginfo(paste("getPHELIXDEFutures - Call PHELIX DE FUTURE price data: ", product ," - ", dateSeq[i]))

    df = getPHELIXDEFuturesForADate(dateSeq[i], product)

    res = rbind(res, df)

    # update progress bar
    if(getOption("logging")) setTxtProgressBar(pb, length(dateSeq) + i)

  }

  if(getOption("logging")) close(pb)

  if(getOption("logging")) loginfo(paste("getPHELIXDEFutures - DONE"))


  return(res)
}



#' Helper function for @seealso getPHELIXDEFutures
#'
# NOTE: function is optimized for product Day!
# --> it gets the values of the next day (regarding input date)
# --> And for a (input) friday, it gets the values of the two following days (saturday and sunday)
#
# Tables at https://www.eex.com/en/market-data/power/futures/phelix-de-futures are strangely organized
#
# date has to be of class Date, product a chracter
#
getPHELIXDEFuturesForADate <- function(date, product) {


  year = strsplit(as.character(date), "-")[[1]][1]
  month = strsplit(as.character(date), "-")[[1]][2]
  day = strsplit(as.character(date), "-")[[1]][3]

  # url for Phelix DE Futures: P-Power-F-DE-Base-XX --> XX Day, Weekend, Week, Month, Quarter, Year
  url = paste("https://www.eex.com/data//view/data/detail/ws-power-futures-german_v4/", year, "/", month, ".", day,".json", sep = "")
  h = rjson::fromJSON(file = url)

  # Base - Day, Weekend, Week, Month, Quarter, Year // Peak - Day, Weekend, Week, Month, Quarter, Year
  # 12 list elements
  base = h[[1]]
  #peak = h[[1]][[8]]

  #base[[1]][base[[1]]$identifier == "P-Power-F-DE-Base-Day"]

  res = data.frame()

  for(block in c("Base", "Peak")) {

    # get the right product --> Base or Peak and Day or Week or Weekend or.....
    id = paste("P-Power-F-DE-", block, "-", product, sep = "")

    # search through all products and get only the requested ones
    for(i in 1:length(base)){
      if(base[[i]]$identifier == id) {
        r = base[[i]]
      }
    }

    # check if there is data for that product -> if not then return empty data.frame
    if(length(r$rows) != 0) {

      # if friday then add 2 days (saturday and sunday) to the data.frame -> end == 3 (2,3) else get next day info (2)
      end = ifelse(lubridate::wday(date) == 6, 3, 2) # 6 == friday

      df = data.frame()

      for(i in 2:end) {

        # Get the 1/2/3... entry of the table --> for request date always get the data of the next day
        k = r$rows[[i]]

        # columns:
        #
        OpenInterest = ifelse(is.null(k$data$openInterestNoOfContracts), NA, k$data$openInterestNoOfContracts)# Open Interest Prev. Day
        LastPrice = ifelse(is.null(k$data$lastTradePrice), NA, k$data$lastTradePrice) # Last Price
        HighPrice = ifelse(is.null(k$data$highPrice), NA, k$data$highPrice)# High Price
        LastVolume = ifelse(is.null(k$data$openInterestVolume), NA, k$data$openInterestVolume)# Last Vol.
        AbsChange = ifelse(is.null(k$data$lastTradeDifference), NA, k$data$lastTradeDifference)# Abs. Change
        VolumeExchange = ifelse(is.null(k$data$volumeExchange), NA, k$data$volumeExchange)# Vol. Exchange
        LastVolume = ifelse(is.null(k$data$lastTradeVolume), NA, k$data$lastTradeVolume)# last traded volume
        VolumeTradeRegister = ifelse(is.null(k$data$volumeOtc), NA, k$data$volumeOtc)# Vol. Trade Registration
        NoContracts = ifelse(is.null(k$data$noOfTradedContractsTotal), NA, k$data$noOfTradedContractsTotal)# No. of Contracts
        BestAsk = ifelse(is.null(k$data$bestAskPrice), NA, k$data$bestAskPrice)# Best Ask
        BestAskVolume = ifelse(is.null(k$data$bestAskVolume), NA, k$data$bestAskVolume)# Best Ask Volume
        BestBid = ifelse(is.null(k$data$bestBidPrice), NA, k$data$bestBidPrice)# Best Bid
        BestBidVolume = ifelse(is.null(k$data$bestBidVolume), NA, k$data$bestBidVolume)# Best Bid Volume
        LastTime = ifelse(is.null(k$data$lastTradeTime), NA, substr(k$data$lastTradeTime, 12, 16)) # Last Time
        SettlementPrice = ifelse(is.null(k$data$settlementPrice), NA, k$data$settlementPrice)# Settl. Price
        Name =  strsplit(k$contractIdentifier,"-")[[1]][length(strsplit(k$contractIdentifier,"-")[[1]])] # contractIdentifier
        # Product types /names
        #
        # C-Power-F-DE-Base-Day-2017.08.02
        # C-Power-F-DE-Base-Week-2017W31
        # C-Power-F-DE-Peak-Weekend-2017WE47
        # C-Power-F-DE-Peak-Month-2017.10
        # C-Power-F-DE-Peak-Quarter-2017Q4
        # C-Power-F-DE-Peak-Year-2018

        # data.frame
        df2 = data.frame(Name = Name,
                         Block = block,
                         Product = product,
                         BestBid = BestBid,
                         BestBidVolume = BestBidVolume,
                         BestAsk = BestAsk,
                         BestAskVolume = BestAskVolume,
                         NoContracts = NoContracts,
                         LastPrice = LastPrice,
                         AbsChange = AbsChange,
                         LastTime = LastTime,
                         LastVolume = LastVolume,
                         SettlementPrice = SettlementPrice,
                         VolumeExchange = VolumeExchange,
                         VolumeTradeRegister = VolumeTradeRegister,
                         OpenInterest = OpenInterest
        )

        df = rbind(df, df2)
      }

      res = rbind(res, df)

    }
  }

  return(res)
}

