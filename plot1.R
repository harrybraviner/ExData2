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
    print(paste("Found file", zipFilename, "locally, will use this.", sep=" "));
  }
  unzip(zipFilename, exdir = WD)
} else {
  print(paste("Found files", summaryDataFilename, "and",
              codeDataFilename, "locally, will use them.", sep=" "))
}


