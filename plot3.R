WD <- getwd()
summaryDataFilename <- paste(WD, "summarySCC_PM25.rds", sep="/")
codeDataFilename <- paste(WD, "Source_Classification_Code.rds", sep="/")
zipFilename <- paste(WD, "exdata-data-NEI_data.zip", sep="/")
BaltimoreTableFilename <- paste(WD, "baltimoreTable.rds", sep = "/")
dataURL <- "https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2FNEI_data.zip"

# Does the data file exist?
if(!file.exists(BaltimoreTableFilename)){
  if(!file.exists(summaryDataFilename) | !file.exists(codeDataFilename)){
    if(!file.exists(zipFilename)){
      print(paste("Unable to find the data in the working directory, will download from",
                  dataURL, sep=" "))
      download.file(url = dataURL, destfile = zipFilename, method = "wget")
    } else {
      print("Found file exdata-data-NEI_data.zip locally, will use this.");
    }
    unzip(zipFilename, exdir = WD)
  } else {
    print("Found files summarySCC_PM25.rds and Source_Classification_Code.rds locally, will use them.")
  }
  print("Reading in data (may take some time)")
  NEI <- readRDS(summaryDataFilename)

  BaltimoreTable <- NEI[NEI$fips == "24510", ]
  
  print("Read data, saving the Baltimore data for later re-use")
  saveRDS(BaltimoreTable, file = BaltimoreTableFilename)
} else {
  print("Found baltimoreTable.rds, will use this.") 
  BaltimoreTable <- readRDS(BaltimoreTableFilename)
}

BaltimoreTable$type <- as.factor(BaltimoreTable$type)
levels(BaltimoreTable$type)[which(levels(BaltimoreTable$type) == "POINT")] <- "Point"
levels(BaltimoreTable$type)[which(levels(BaltimoreTable$type) == "NONPOINT")] <- "Non-point"
levels(BaltimoreTable$type)[which(levels(BaltimoreTable$type) == "ON-ROAD")] <- "On-road"
levels(BaltimoreTable$type)[which(levels(BaltimoreTable$type) == "NON-ROAD")] <- "Non-road"
# Make a columns for emissions in thousands of tons
BaltimoreTable$EkT <- BaltimoreTable$Emissions/1e3

print("Plotting Baltimore emissions by type")
library(ggplot2)

emissionsByType <- aggregate(EkT ~ type + year, data = BaltimoreTable,
                             FUN = sum)

emissionsPlot <- ggplot(emissionsByType, aes(year, EkT))
emissionsPlot <- emissionsPlot + geom_line(aes(color = emissionsByType$type, linetype = emissionsByType$type))
emissionsPlot <- emissionsPlot + geom_point(aes(color = emissionsByType$type), size = 2.5)
emissionsPlot <- emissionsPlot + scale_linetype_manual(name = "Source type", values = c("solid", "dashed", "dotted", "dotdash"))
emissionsPlot <- emissionsPlot + scale_color_hue(name = "Source type")
emissionsPlot <- emissionsPlot + labs(x = "Year", y = "PM2.5 / Kilotons",
									                    title = "Total PM2.5 emissions per year\nin Baltimore, by source",
                                      color = "Source type")
emissionsPlot <- emissionsPlot + theme_bw()
emissionsPlot <- emissionsPlot + theme(legend.justification=c(1,1), legend.position = c(0.97, 0.99))

emissionsPlot

ggsave(file = "plot3.png", width=5, height=5, units = "in")
