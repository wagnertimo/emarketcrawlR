# The test script

library(emarketcrawlR)
setLogging(TRUE)


lastPrices <- getIntradayContinuousEPEXSPOT("2017-06-01", "2017-06-30", "15", "DE")


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



