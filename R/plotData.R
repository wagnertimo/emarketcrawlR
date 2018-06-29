#
# The plot script
#

#' @title qplotIntradayContinuous
#'
#' @description This qick plot (qplot...) function visualizes the Lows, Highs and Last prices as well as their buy and sell volume of a given data.frame of continuous intraday trading data of the EPEX SPOT @seealso getIntradayContinuousEPEXSPOT
#' The plot function makes only sense to visualize a few days. Otherwise the visual elements are to small
#'
#'
#' @param df - The input data.frame with a few days of cont. intr. trading data (Low,High,Last and DateTimes)
#'
#' @return a pre-defined quick plot with Price and volume data (Low, High, Last in €/MWh) and Volume in GWh (Buy and Sell). No plot object!
#'
#' @examples
#' # get the input data
#' df <- getIntradayContinuousEPEXSPOT("2017-05-24", "2017-05-26", "15", "DE")
#'
#' plot <- qplotContIntraEPEXSPOT(df)
#' plot
#'
#' @export
#'
qplotIntradayContinuous <- function(df) {

  library(ggplot2)
  library(scales)
  library(grid)
  library(gridExtra)
  # Lubridate package seems not to be loaded
  # library(lubridate)

  df$Buy_Vol = df$Buy_Vol/1000
  df$Sell_Vol = df$Sell_Vol/1000

  g <- ggplot(df, aes(DateTime)) +
        geom_line(aes(y = Last, colour = "Last")) +
        geom_line(aes(y = High, colour = "High")) +
        geom_line(aes(y = Low, colour = "Low")) +
        geom_vline(xintercept = as.numeric(as.POSIXct(paste(unique(format(df$DateTime, "%Y-%m-%d"))[2:length(unique(format(df$DateTime, "%Y-%m-%d")))], "00:00:00", sep = ""))), linetype = 4, color = "#9B9B9B") +
        geom_hline(yintercept = 0, color = "#9B9B9B") +
        scale_color_manual(values=c("#FF9C52", "#FFCCA7", "#9B9B9B")) +
        coord_cartesian(ylim = c(min(df$Low) - 5, max(df$High) + 5), expand = FALSE) +
        scale_x_datetime(date_breaks = "1 hour", labels = function(x) paste(format(x, "%H", tz = "Europe/Berlin"))) +
        xlab("") +
        ylab("€/MWh") +
        ggtitle("EPEX SPOT Continuous Intraday Prices") +
        theme(plot.title = element_text(size = 16, hjust = 0.5, face = "bold", colour = "#FF9C52", vjust = -1)) +
        guides(colour = FALSE) +
        theme(panel.background = element_blank(), panel.grid.minor.y = element_line(colour = "#9B9B9B")) +
        annotate("text", color = "#9B9B9B", x = as.POSIXct(paste(unique(format(df$DateTime, "%Y-%m-%d"))[1:length(unique(format(df$DateTime, "%Y-%m-%d")))], "12:00:00", sep = "")), y = min(df$Low), label = unique(format(df$DateTime, "%a %d/%m/%y")))

  b <- ggplot(df, aes(x = DateTime, y = Buy_Vol)) +
    geom_bar(aes(fill="Buy Volume"), stat = "identity", fill="#9B9B9B", alpha = 0.5) +
    geom_vline(xintercept = as.numeric(as.POSIXct(paste(unique(format(df$DateTime, "%Y-%m-%d"))[2:length(unique(format(df$DateTime, "%Y-%m-%d")))], "00:00:00", sep = ""))), linetype = 4, color = "#9B9B9B") +
    geom_hline(yintercept = 0, color = "#9B9B9B") +
    coord_cartesian(ylim = c(0, max(df$Buy_Vol) + 0.1), expand = FALSE) +
    scale_x_datetime(date_breaks = "1 hour", labels = function(x) paste(format(x, "%H", tz = "Europe/Berlin"))) +
    xlab("") +
    ylab("GWh") +
    ggtitle("Volume Buy") +
    theme(plot.title = element_text(size = 16, hjust = 0.5, face = "bold", colour = "#FF9C52", vjust = -1)) +
    theme(panel.background = element_blank(), panel.grid.minor.y = element_line(colour = "#9B9B9B")) +
    annotate(geom = "text", label = paste("Total:", round(sum(df$Buy_Vol),3),"GWh"), color = "black", x = as.POSIXct(paste(unique(format(df$DateTime, "%Y-%m-%d"))[length(unique(format(df$DateTime, "%Y-%m-%d")))], "20:00:00", sep = "")), y = max(df$Buy_Vol)) +
    annotate("text", color = "black", x = as.POSIXct(paste(unique(format(df$DateTime, "%Y-%m-%d"))[1:length(unique(format(df$DateTime, "%Y-%m-%d")))], "12:00:00", sep = "")), y = 0.1, label = unique(format(df$DateTime, "%a %d/%m/%y")))


  s <- ggplot(df, aes(x = DateTime, y = Sell_Vol)) +
    geom_bar(aes(fill="Buy Volume"), stat = "identity", fill="#9B9B9B", alpha = 0.5) +
    geom_vline(xintercept = as.numeric(as.POSIXct(paste(unique(format(df$DateTime, "%Y-%m-%d"))[2:length(unique(format(df$DateTime, "%Y-%m-%d")))], "00:00:00", sep = ""))), linetype = 4, color = "#9B9B9B") +
    geom_hline(yintercept = 0, color = "#9B9B9B") +
    coord_cartesian(ylim = c(0, max(df$Sell_Vol) + 0.1), expand = FALSE) +
    scale_x_datetime(date_breaks = "1 hour", labels = function(x) paste(format(x, "%H", tz = "Europe/Berlin"))) +
    xlab("") +
    ylab("GWh") +
    ggtitle("Volume Sell") +
    theme(plot.title = element_text(size = 16, hjust = 0.5, face = "bold", colour = "#FF9C52", vjust = -1)) +
    theme(panel.background = element_blank(), panel.grid.minor.y = element_line(colour = "#9B9B9B")) +
    annotate(geom = "text", label = paste("Total:", round(sum(df$Sell_Vol),3),"GWh"), color = "black", x = as.POSIXct(paste(unique(format(df$DateTime, "%Y-%m-%d"))[length(unique(format(df$DateTime, "%Y-%m-%d")))], "20:00:00", sep = "")), y = max(df$Sell_Vol)) +
    annotate("text", color = "black", x = as.POSIXct(paste(unique(format(df$DateTime, "%Y-%m-%d"))[1:length(unique(format(df$DateTime, "%Y-%m-%d")))], "12:00:00", sep = "")), y = 0.1, label = unique(format(df$DateTime, "%a %d/%m/%y")))




  gg <- grid.arrange(g, b, s, nrow = 3, heights = c(0.5,0.25,0.25))

  return(gg)

}












