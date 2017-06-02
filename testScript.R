# The test script



setLogging(TRUE)

h <- getIntradayContinuousEPEXSPOT("2017-05-20", "2017-05-26", "60")

plot(h, type="l")

