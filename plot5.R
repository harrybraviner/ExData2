# Methodology for searching for 'emissions from motor vehicle sources'
#
# I will take a source of type 'ON-ROAD' to be a motor vehicle source

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

  BaltimoreTable <- NEI[NEI$fips == "24510", ]
  
  print("Read data, saving the Baltimore data for later re-use")
  saveRDS(BaltimoreTable, file = BaltimoreTableFilename)
} else {
  print("Found baltimoreTable.rds, will use this.") 
  BaltimoreTable <- readRDS(BaltimoreTableFilename)
}

ORBaltimore <- BaltimoreTable[BaltimoreTable$type == "ON-ROAD",]

EvsY <- aggregate(Emissions ~ year, data = ORBaltimore, FUN = sum)

png(filename = "plot5.png", width = 480, height = 480)
plot(EvsY$year, EvsY$Emissions/(1e3), xlab = "Year",
     ylab = "PM2.5 emission / Kilotons", type = "b", pch = 19, axes=F,
     main = "Total PM2.5 emissions per year from motor vehicle\nsources in Baltimore")

axis(side = 1, at = unique(EvsY$year))
axis(side = 2, at = c(0.1, 0.15, 0.2, 0.25, 0.3, 0.35))
dev.off()
