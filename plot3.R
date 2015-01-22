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

  BaltimoreTable <- NEI["fips" == "24510", ]
  
  print("Read data, saving the Baltimore data for later re-use")
  saveRDS(BaltimoreTable, file = BaltimoreTableFilename)
} else {
  print("Found baltimoreTable.rds, will use this.") 
  BaltimoreTable <- readRDS(BaltimoreTableFilename)
}

BaltimoreEmissions <- tapply(BaltimoreTable$Emissions[BaltimoreTable$fips == "24510"],
                             BaltimoreTable$year[BaltimoreTable$fips == "24510"], FUN = sum)


print("Plotting Baltimore emissions by type")
emissionsByType <- aggregate(Emissions ~ type + year, data = BaltimoreTable,
                             )
