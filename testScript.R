# The test script

unique(format(lastPrices$DateTime, "%Y-%m-%d"))

as.numeric(as.POSIXct(paste(unique(date(lastPrices$DateTime))[1:length(unique(date(lastPrices$DateTime)))-1], "00:00:00", sep = "")))

as.numeric(unique(date(lastPrices$DateTime)))

lastPrices$date <- date(lastPrices$DateTime)
unique(lastPrices)
(1:(length(unique(date(lastPrices$DateTime)))-1)) * 24

hours <- rep(unique(lastPrices$hour), length(unique(date(lastPrices$DateTime))))
min(lastPrices$Low) - 10

setLogging(FALSE)

lastPrices <- getIntradayContinuousEPEXSPOT("2017-05-26", "2017-05-28", "15", "DE")

plot <- qplotContIntraEPEXSPOT(lastPrices)
plot

auctionPrices <- getIntradayAuctionEPEXSPOT("2017-05-19", "2017-05-26")









