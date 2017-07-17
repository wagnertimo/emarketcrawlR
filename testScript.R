# The test script

library(emarketcrawlR)
setLogging(TRUE)

lastPrices <- getIntradayContinuousEPEXSPOT("2017-05-26", "2017-05-28", "15", "DE")

qplotIntradayContinuous(lastPrices)

auctionPrices <- getIntradayAuctionEPEXSPOT("2017-05-19", "2017-05-26")

a <- getDayAheadAuctionEPEXSPOT("2017-05-19", "2017-05-28", "CH")


a <- getDayAheadAuctionEPEXSPOT("2016-11-01", "2016-10-30", "DE")

latestDate = as.POSIXct(paste("2016-03-28", "00:00", sep = ""), tz = "Europe/Berlin")




lastPrices <- getIntradayContinuousEPEXSPOT("2016-03-26", "2016-03-27", "60", "DE")

# No data for 30min contracts
lastPrices2 <- getIntradayContinuousEPEXSPOT("2016-10-29", "2016-10-30", "30", "DE")

lastPrices3 <- getIntradayContinuousEPEXSPOT("2016-10-29", "2016-10-30", "60", "FR")










