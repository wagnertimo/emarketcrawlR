# The test script

library(emarketcrawlR)
setLogging(TRUE)

prices <- getIntradayContinuousEPEXSPOT("2017-05-20", "2017-05-26", "15", "DE")
qplotIntradayContinuous(prices)

lastPrices <- getIntradayContinuousEPEXSPOT("2013-03-30", "2013-03-31", "60", "DE")
lastPrices <- getIntradayContinuousEPEXSPOT("2013-03-31", "2013-03-31", "15", "DE")

lastPrices <- getIntradayContinuousEPEXSPOT("2013-10-26", "2013-10-27", "60", "DE")

lastPrices <- getIntradayAuctionEPEXSPOT("2013-10-26", "2013-10-27")
lastPrices <- getIntradayAuctionEPEXSPOT("2015-03-28", "2015-03-29")


lastPrices <- getDayAheadAuctionEPEXSPOT("2015-10-24", "2015-10-25", "DE")
lastPrices <- getDayAheadAuctionEPEXSPOT("2015-03-28", "2015-03-29", "DE")


auctionPrices <- getIntradayAuctionEPEXSPOT("2017-05-01", "2017-05-30")

install.packages("tidyverse")
install.packages("lubridate")
library(tidyverse)
library(lubridate)


auctionPrices %>% mutate(Time = format(DateTime, format="%H:%M:%S")) %>%
  group_by(Time) %>%
  summarise(MeanOfTime = mean(Prices))



a <- getDayAheadAuctionEPEXSPOT("2017-05-19", "2017-05-28", "CH")


a <- getDayAheadAuctionEPEXSPOT("2017-06-01", "2017-06-30", "DE")

latestDate = as.POSIXct(paste("2016-03-28", "00:00", sep = ""), tz = "Europe/Berlin")

auctionPrices <- getIntradayAuctionEPEXSPOT("2016-03-21", "2016-03-27")



Sys.setenv(TZ = "Europe/Berlin")
Sys.timezone()



#
# EEX market: e.g. https://www.eex.com/data//view/data/detail/ws-power-futures-german_v4/2017/05.03.json?&jsonace=18
#
# --> API

library(emarketcrawlR)
setLogging(TRUE)


startDate = "2017-08-02"
endDate = "2017-08-04"
product = "Day" # product type == Day, Weekend, Week, Month, Quarter, Year

#seq.Date(as.Date("2017-08-02")-1, as.Date("2017-08-04"),1)

df = getPHELIXDEFuturesEEX(startDate, endDate, product)

head(df)





