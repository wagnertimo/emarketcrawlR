# The test script

library(emarketcrawlR)
setLogging(TRUE)


lastPrices <- getIntradayContinuousEPEXSPOT("2012-01-01", "2012-01-02", "15", "DE")
lastPrices <- getIntradayContinuousEPEXSPOT("2012-02-03", "2012-02-04", "15", "DE")

s <- getIntradayContinuousEPEXSPOT("2011-10-28", "2011-10-30", "60", "DE")

s[2,]$DateTime
(as.Date(s[2,]$DateTime, tz = "Europe/Berlin")-1)

r = getIntradayContinuousEPEXSPOT("2011-07-01", "2011-12-31", "60", "DE")
# r = getIntradayContinuousEPEXSPOT("2012-01-01", "2012-12-31", "60", "DE")
# r = getIntradayContinuousEPEXSPOT("2013-01-01", "2013-12-31", "60", "DE")
# r = getIntradayContinuousEPEXSPOT("2014-01-01", "2014-12-31", "60", "DE")
# r = getIntradayContinuousEPEXSPOT("2015-01-01", "2015-12-31", "60", "DE")
# r = getIntradayContinuousEPEXSPOT("2016-01-01", "2016-12-31", "60", "DE")
# r = getIntradayContinuousEPEXSPOT("2017-01-01", "2017-06-30", "60", "DE")

# create the time sequence for the data --> this is done because it is not possible to convert the UTC time (with 2 hours at DST to CET)
t = seq(as.POSIXct("2011-07-01", tz = "Europe/Berlin"), as.POSIXct("2012-01-01", tz = "Europe/Berlin"), by = "hour")
t = t[1:length(t)-1]
nrow(r)
length(t)

head(r)
tail(r)


'%nin%' <- Negate('%in%')
t[t %nin% r$DateTime]

continuousEPEX_60min.2011.2017$DateTime = t
nrow(continuousEPEX_60min.2011.2017)
length(t)


attr(continuousEPEX_60min.2011.2017$DateTime, "tzone") = "UTC"

head(continuousEPEX_60min.2011.2017$DateTime)
nrow(continuousEPEX_60min.2011.2017)
length(t)

write_csv(continuousEPEX_60min.2011.2017, "continuousEPEX_60min.2011.2017.csv")
continuousEPEX_60min.2011.2017 = read_csv("continuousEPEX_60min.2011.2017.csv")
nrow(continuousEPEX_60min.2011.2017)



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



