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

print("Plotting total emissions vs year")
EvsY <- tapply(NEI$Emissions, NEI$year, FUN = sum)

png(filename = "plot1.png", width = 480, height = 480)

plot(names(EvsY), EvsY/(1e6), xlab = "Year",
     ylab = "PM2.5 emission / Megatons", type = "b", pch = 19, axes=F,
     main = "Total PM2.5 emissions per year from all sources\nin the United States")

axis(side = 1, at = unique(names(EvsY)))
axis(side = 2, at = floor(seq(from = ceiling(range(EvsY)[1]/1e6-1), to = floor(range(EvsY)[2]/1e6+1), length=6)))

dev.off()
