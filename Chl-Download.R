## Created by Jessica Nephin
## Last edited 2016-11-04

## Download full res aqua MODIS L2 products from 2012 to 2015 
## Daily between March 18 and June 21

## Run via command line using:
##### nohup Rscript --vanilla --verbose Chl-Download.R year month >logs/logfilename.out &
## Command line arguments:
##### 1) year e.g. 2012
##### 2) month e.g. 3


# required packages
require(stringr)
require(ncdf4)

# working directory
setwd('..')


#---------------------------------------------------------------------------------------#


# NASA ocean colour data
siteurl <- "http://oceandata.sci.gsfc.nasa.gov"

# years command line argument
args = commandArgs(trailingOnly=TRUE)
year <- args[1]
mnth <- paste0("0", args[2])

# days in a year
days <- 1:365

# datetime
dates <- merge(days,year)
dates$date <- as.Date(dates$x-1, origin=paste(year,"01-01", sep = "-"))
dates$month <- format(dates$date, "%m")
dates$day <- format(dates$date, "%d")

# subset datetime for timeframe of interest
# March 18 and June 21
tf <- dates[dates$month == mnth,]
tf <- tf[(tf$month == "03" & tf$day > 17) | tf$month == "04" | tf$month == "05" | 
           (tf$month == "06" & tf$ day < 22),]


#---------------------------------------------------------------------------------------#
# Get files name which have already been downloaded (including those deleted) from nohup

# list download log files (stderr and stdout)
log.list <- list.files(path = file.path("Scripts/logs"), pattern = "*.out", full.names = TRUE)

# read in logs and append
out <- NULL
for(l in log.list){
  tmp <- readLines(l)
  out <- c(out,tmp)
}

# get lines with just file names
dls <- grep("Data/Downloads/",out, value = TRUE)
dls <- grep(" saved ",dls, value = TRUE)

#extract file names
fn <- sub(".*Data/Downloads/","",dls)
fn <- sub(".L2_LAC_OC.nc.*",".L2_LAC_OC.nc",fn)
fn <- sub(".*/","",fn)

# list files already in folder
nc.list <- list.files(path = file.path("Data/Downloads",year,mnth), pattern = "*.nc")
nc.list <- unique(c(nc.list,fn))


#---------------------------------------------------------------------------------------#

# loop through timeframe
  for(i in 1:nrow(tf)){
    
    # year
    y <- tf$y[i]
    
    # days in the year
    d <- tf$x[i]
    d <- sprintf("%03d", d)
    
    # list links to download
    urlines <- readLines(paste(siteurl,"MODIS-Aqua/L2",y,d, sep = "/"))
    urlmatched <- str_match(urlines, "(?<=.L2_LAC_OC.nc'>)(.*)(?=</a></td>)")[,1]
    files <- urlmatched[!is.na(urlmatched)]
    
    # filter times when MODIS is over BC region
    times <- as.numeric(substr(files,9,12))
    files <- files[times > 1900 & times < 2400]
    
    # remove files already downloaded
    files <- files[!files %in% nc.list]
    
    # loop through files
    if(length(files) > 0){
    for(f in files){
      
      # filename
      ddir <- paste("Data/Downloads", year, mnth, sep = "/")
      suppressWarnings(dir.create(ddir,recursive=TRUE))
      dfile <- file.path(ddir, f)
      
      # Download netCDF files
      ncloc <- paste(siteurl,"cgi/getfile",f, sep = "/")
      download.file(ncloc, destfile=dfile, method = "wget",cacheOK = FALSE)
      
      
      nc <- nc_open(dfile)
      
      # get lat long attributes
      nlat <- ncatt_get(nc, varid = 0, attname = "northernmost_latitude")$value
      slat <- ncatt_get(nc, varid = 0, attname = "southernmost_latitude")$value
      elon <- ncatt_get(nc, varid = 0, attname = "easternmost_longitude")$value
      wlon <- ncatt_get(nc, varid = 0, attname = "westernmost_longitude")$value
      
      # remove from netcdf file form memory
      nc_close(nc)
      remove(nc)
      gc(reset = TRUE)
      closeAllConnections()
      
      # is swath is not in the area of interest, delete netcdf file
      if(!(wlon < -110 & elon > -145 & nlat > 44 & slat < 58)){
        unlink(dfile, force = TRUE)
      }
    }
  }
}
