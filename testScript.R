# The test script

library(emarketcrawlR)
setLogging(TRUE)

lastPrices <- getIntradayContinuousEPEXSPOT("2017-05-26", "2017-05-28", "15", "DE")

qplotIntradayContinuous(lastPrices)

auctionPrices <- getIntradayAuctionEPEXSPOT("2017-05-19", "2017-05-26")

a <- getDayAheadAuctionEPEXSPOT("2017-05-19", "2017-05-28", "CH")


a <- getDayAheadAuctionEPEXSPOT("2016-11-01", "2016-10-30", "DE")

latestDate = as.POSIXct(paste("2016-03-28", "00:00", sep = ""), tz = "Europe/Berlin")

# Normal
(s = as.POSIXct(latestDate - 6*86400, tz="Europe/Berlin"))
(e = as.POSIXct(latestDate + 86400 - 3600, tz="Europe/Berlin"))
# --

# in case of DST+1
# --> There are two cases:
# 1. DST is NOT the latestDate (it is within the date range of the 7 days), then adjust the start by subtracting an extra hour and the end stays the same.
#
# 2. DST IS the latestDate (it marks the end date of the sequence), then adjust the end by NOT subtracting an hour and the start stays the same.
#

# Check if DST+1 occurs at latest (end) or within or not

# DST+1
(s = as.POSIXct(latestDate - 6*86400 - 3600, tz="Europe/Berlin"))
(e = as.POSIXct(latestDate + 86400, tz="Europe/Berlin")) # in case of daylight saving
# ---


# in case of DST-1
# --> There are two cases:
# 1. DST is NOT the latestDate (it is within the date range of the 7 days), then adjust the start by adding an extra hour and the end stays the same.
#
# 2. DST IS the latestDate (it marks the end date of the sequence), then adjust the end by subtracting TWO hours and the start stays the same.
#

# Check if DST-1 occurs at latest (end) or within or not

# DST-1
(s = as.POSIXct(latestDate - 6*86400 + 3600, tz="Europe/Berlin"))
(e = as.POSIXct(latestDate + 86400 - 2*3600, tz="Europe/Berlin")) # in case of daylight saving
# ---


latestDate

(l <- format(seq.POSIXt(s, e, by = "60 min"), "%Y-%m-%d %H:%M", tz="Europe/Berlin"))
length(l)




seq.POSIXt(s, e, by = "60 min")


sdate <- as.Date("2016-10-30", "%Y-%m-%d")
url = paste("https://www.epexspot.com/en/market-data/dayaheadauction/auction-table/", sdate, "/", "DE", sep="")
payload = list();
postResponse <- POST(url, body = payload, encode = "form")

parsedHtml <- htmlParse(content(postResponse, "text", encoding = "UTF-8"))


(string = parseDAAEPEXSPOT(parsedHtml, "DE", sdate))

df1 = string

df1 = df1[rownames(df1)[rownames(df1) != "NA"] , ]

rownames(df1)[rownames(df1) != "NA"]


# DST+1 case
sd
ed
ss

# build DateTime list

# normal case (and case with DST-1 --> since it also has 24 hours due to 7 days are displayed)
sd2
ed2
ss2

# build DateTime list
# --> 02a and 02b are converted to 02 --> there will be two 02 hours

(ss = paste(gsub("a|b", "", ss), ":00:00", sep=""))
(ss2 = paste(gsub("a|b", "", ss2), ":00:00", sep=""))

# Get date range
(daterange = seq.Date(as.Date(sd, "%d/%m/%Y"), as.Date(ed, "%d/%m/%Y"), by = "1 day"))

ss
paste(daterange, ss, sep = " ")

expand.grid(ss, daterange)

apply(expand.grid(daterange, ss), 1, paste, collapse=" ")

ss1 = apply(expand.grid(ss, daterange), 1, function(x) paste(x[2], x[1]))

df1 <- data.frame(DateTime = ss1)



a <- getDayAheadAuctionEPEXSPOT("2016-04-03", "2016-04-03", "DE")



sdate <- as.Date("2016-10-28", "%Y-%m-%d")
edate <- as.Date("2016-10-28", "%Y-%m-%d")
# calls for every day in dates array --> !! maybe every two days, depends if always two dates for one date request are shown in table
# Therefore it is good to start with the loop at the last date, then the day before the last date can be also on the table
(dates_array = seq(sdate, edate, by="days"))
length(dates_array)





