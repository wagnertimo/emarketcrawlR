# The test script

library(emarketcrawlR)
setLogging(TRUE)


lastPrices <- getIntradayContinuousEPEXSPOT("2012-01-01", "2012-01-02", "15", "DE")


lastPrices <- getIntradayContinuousEPEXSPOT("2012-10-28", "2012-10-28", "15", "DE")
lastPrices2 <- getIntradayContinuousEPEXSPOT("2012-10-28", "2012-10-29", "60", "DE")
lastPrices2 <- getIntradayContinuousEPEXSPOT("2012-10-27", "2012-10-29", "60", "DE")

attr(lastPrices2$DateTime, "tzone")

dst_date = lastDayOfMonth(1,10,2012)
attr(dst_date, "tzone") = "Europe/Berlin"

lastPrices2 %>% filter(as.Date(DateTime, tz = "Europe/Berlin") == (dst_date - 1))

d = lastPrices2 %>% filter(as.Date(DateTime, tz = "Europe/Berlin") == (dst_date - 1))
d1 = lastPrices2 %>% filter(as.Date(DateTime, tz = "Europe/Berlin") == (dst_date + 1))


d2 = deleteExtraDSTHour(d1, "60")
d1 = d1[-d2,]



deleteExtraDSTHour <- function(df, time) {


  # Get rid of NA columns when there is DST+1
  # There are always two days to be crawled --> so either the day before or after DST has an extra 2 hour obs --> get rid off
  dst_date = lastDayOfMonth(1,10,2012)
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



