# Methodology for searching for 'coal related' emissions
#
# In the SCC data table, the variables Short.Name, EI.Sector, SCC.Level.Three,
# and SCC.Level.Four all mention 'coal' in some entries
# My crude search strategy is to include the sources that contains the word
# 'coal' in the EI.Sector field.
# All of these sources are Fuel Combustion, whereas some of those containing
# 'coal' in the Short.Name field are sources such as drilling coal.

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
SCC <- readRDS(codeDataFilename)


coalIndices <- grep("coal", SCC$EI.Sector, ignore.case = TRUE, value = FALSE) 

coalSCC <- SCC$SCC[coalIndices]

coalNEI <- NEI[as.character(NEI$SCC) %in% as.character(coalSCC),]

CoalvsYear <- aggregate(Emissions ~ year, data = coalNEI, FUN = sum)

print("Plotting coal-related emissions vs year")

png(filename = "plot4.png", width = 480, height = 480)

plot(CoalvsYear$year, CoalvsYear$Emissions/(1e3), xlab = "Year",
     ylab = "PM2.5 emission / Kilotons", type = "b", pch = 19, axes=F,
     main = "Total PM2.5 emissions per year from coal combustion\nin the United States")

axis(side = 1, at = unique(CoalvsYear$year))
axis(side = 2, at = floor(seq(from = ceiling(range(CoalvsYear$Emissions)[1]/1e3-1), to = floor(range(CoalvsYear$Emissions)[2]/1e3+1), length=6)))

dev.off()
