# The test script

library(emarketcrawlR)
setLogging(TRUE)


lastPrices <- getIntradayContinuousEPEXSPOT("2017-06-01", "2017-06-30", "15", "DE")

auctionPrices <- getIntradayAuctionEPEXSPOT("2017-05-19", "2017-05-26")

a <- getDayAheadAuctionEPEXSPOT("2017-05-19", "2017-05-28", "CH")


a <- getDayAheadAuctionEPEXSPOT("2017-06-01", "2017-06-30", "DE")

latestDate = as.POSIXct(paste("2016-03-28", "00:00", sep = ""), tz = "Europe/Berlin")


auctionPrices <- getIntradayAuctionEPEXSPOT("2016-03-21", "2016-03-27")



