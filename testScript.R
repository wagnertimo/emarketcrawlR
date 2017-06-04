# The test script


setLogging(FALSE)

lastPrices <- getIntradayContinuousEPEXSPOT("2017-05-26", "2017-05-28", "15", "DE")

qplotIntradayContinuous(lastPrices)

auctionPrices <- getIntradayAuctionEPEXSPOT("2017-05-19", "2017-05-26")

a <- getDayAheadAuctionEPEXSPOT("2017-05-19", "2017-05-28", "CH")





