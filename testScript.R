# The test script



setLogging(FALSE)

h <- getIntradayContinuousEPEXSPOT("2017-01-01", "2017-05-26", "60")

plot(h, type="l")
head(h)


# DateTime Last
# 1 2017-05-20 00:00:00 26.9
# 2 2017-05-20 01:00:00 16.5
# 3 2017-05-20 02:00:00 22.1
# 4 2017-05-20 03:00:00 15.0
# 5 2017-05-20 04:00:00 22.9
# 6 2017-05-20 05:00:00 24.0
