# The test script



setLogging(FALSE)

lastPrices <- getIntradayContinuousEPEXSPOT("2017-05-20", "2017-05-26", "15", "DE")

auctionPrices <- getIntradayAuctionEPEXSPOT("2017-05-19", "2017-05-26")

head(auctionPrices)

getIntradayAuctionEPEXSPOT("2017-05-20", "2017-05-26", "15")

names(c)



