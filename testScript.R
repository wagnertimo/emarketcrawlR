# The test script

library(emarketcrawlR)
setLogging(TRUE)


lastPrices <- getIntradayContinuousEPEXSPOT("2012-01-01", "2012-01-02", "15", "DE")
lastPrices <- getIntradayContinuousEPEXSPOT("2012-02-03", "2012-02-04", "15", "DE")
r <- getIntradayContinuousEPEXSPOT("2012-02-01", "2012-02-02", "15", "DE")






date =  as.Date("2012-10-24", tz = "Europe/Berlin")
isDSTDateInOctober(date)

# returns boolean if date (input) is the last sunday in october == DST time saving at 2hour
isDSTDateInOctober <- function(date) {
  library(lubridate)

  return(as.Date(lastDayOfMonth(1,10,year(date)), tz = "Europe/Berlin") == date)

}


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






r = getIntradayContinuousEPEXSPOT("2015-03-29", "2015-03-29", "60", "DE")




lastPrices <- getIntradayContinuousEPEXSPOT("2013-03-30", "2013-03-31", "60", "DE")
lastPrices <- getIntradayContinuousEPEXSPOT("2013-03-31", "2013-03-31", "15", "DE")

lastPrices <- getIntradayContinuousEPEXSPOT("2013-10-26", "2013-10-27", "60", "DE")

lastPrices <- getIntradayAuctionEPEXSPOT("2013-10-26", "2013-10-27")
lastPrices <- getIntradayAuctionEPEXSPOT("2015-03-28", "2015-03-29")


lastPrices <- getDayAheadAuctionEPEXSPOT("2015-10-24", "2015-10-25", "DE")
lastPrices <- getDayAheadAuctionEPEXSPOT("2015-03-28", "2015-03-29", "DE")


auctionPrices <- getIntradayAuctionEPEXSPOT("2017-05-19", "2017-05-26")

a <- getDayAheadAuctionEPEXSPOT("2017-05-19", "2017-05-28", "CH")


a <- getDayAheadAuctionEPEXSPOT("2017-06-01", "2017-06-30", "DE")

latestDate = as.POSIXct(paste("2016-03-28", "00:00", sep = ""), tz = "Europe/Berlin")


auctionPrices <- getIntradayAuctionEPEXSPOT("2016-03-21", "2016-03-27")



Sys.setenv(TZ = "Europe/Berlin")
Sys.timezone()



