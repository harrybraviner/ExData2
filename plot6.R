WD <- getwd()
summaryDataFilename <- paste(WD, "summarySCC_PM25.rds", sep="/")
codeDataFilename <- paste(WD, "Source_Classification_Code.rds", sep="/")
zipFilename <- paste(WD, "exdata-data-NEI_data.zip", sep="/");
dataURL <- "https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2FNEI_data.zip"

# Does the data file exist?
if(!file.exists(summaryDataFilename) | !file.exists(codeDataFilename)){
  if(!file.exists(zipFilename)){
    print(paste("Unable to find the data in the working directory, will download from",
                dataURL, sep=" "))
    download.file(, method = "wget")
  } else {
    print("Found file exdata-data-NEI_data.zip locally, will use this.");
  }
  unzip(zipFilename, exdir = WD)
} else {
  print("Found files summarySCC_PM25.rds and Source_Classification_Code.rds locally, will use them.")
}

print("Reading in data (may take some time)")
NEI <- readRDS(summaryDataFilename)

# Restrict to Maltimore and LA
BaltimoreLATable <- NEI[NEI$fips == "24510" | NEI$fips == "06037", ]
# Restrict to on-road sources
BaltimoreLATable <- BaltimoreLATable[BaltimoreLATable$type == "ON-ROAD", ]

# Create a nicer label than the fips number
BaltimoreLATable$EkT = BaltimoreLATable$Emissions/1e3
BaltimoreLATable$Region <- sapply(BaltimoreLATable$fips,
                                  FUN = function(x) {
                                    if(x == "24510")
                                      "Baltimore"
                                    else
                                      "Los Angeles County"
                                    })

# Sum by region and year
emissionsByRegion <- aggregate(EkT ~ Region + year,
                               data = BaltimoreLATable, FUN = sum)

library(ggplot2)

png(filename = "plot6.png", width = 480, height = 480)
emissionsPlot <- ggplot(emissionsByRegion, aes(year, EkT))
emissionsPlot <- emissionsPlot + geom_line(aes(color = emissionsByRegion$Region, linetype = emissionsByRegion$Region))
emissionsPlot <- emissionsPlot + geom_point(aes(color = emissionsByRegion$Region), size = 2.5)
emissionsPlot <- emissionsPlot + scale_linetype_manual(name = "Region", values = c("solid", "dashed"))
emissionsPlot <- emissionsPlot + scale_color_hue(name = "Region")
emissionsPlot <- emissionsPlot + labs(x = "Year", y = "PM2.5 / Kilotons",
									                    title = "Total PM2.5 emissions per year",
                                      color = "Source type")
emissionsPlot <- emissionsPlot + theme_bw()
emissionsPlot <- emissionsPlot + theme(legend.justification=c(1,1), legend.position = c(0.97, 0.7))

emissionsPlot

dev.off()
