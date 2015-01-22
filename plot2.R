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

BaltimoreEmissions <- tapply(BaltimoreTable$Emissions[BaltimoreTable$fips == "24510"],
                             BaltimoreTable$year[BaltimoreTable$fips == "24510"], FUN = sum)


print("Plotting Baltimore emissions vs year")
png(filename = "plot2.png", width = 480, height = 480)

plot(names(BaltimoreEmissions), BaltimoreEmissions/(1e3), xlab = "Year",
     ylab = "PM2.5 emission / Kilotons", type = "b", pch = 19, axes=F,
     main = "Total PM2.5 emissions per year from all sources\nin Baltimore")

axis(side = 1, at = unique(names(BaltimoreEmissions)))
axis(side = 2, at = c(1.5, 2, 2.5, 3, 3.5))

dev.off()
