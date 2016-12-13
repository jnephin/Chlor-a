## Created by Jessica Nephin
## Last edited 2016-11-08

## Calculates bloom raster
## Calculates bloom frequency


# required packages
require(raster)
require(rgdal)
require(sp)
require(rgeos)
require(fields)

# working directory
#setwd('..')


#-------------------------------------------------------------------------------#


# Import BC EEZ
bc <- readOGR(dsn = "Data/Shapefiles/BC_EEZ", layer = "BC_EEZ_1km_albers")


#------------------------------#
#           Reclass            #
#------------------------------#

# loop through year and month sub directories
year <- 2012:2015
month <- c("03","04","05","06")
for(y in year){
  for(m in month){
    
    # list reclassed spline interpolated Geotiff files
    tifs <-list.files(file.path("Data/Downloads",y,m), pattern="reclass.tif$")
    
    # loop through tifs
    for(f in tifs){
      
      # load Geotiff
      mr <- raster(file.path("Data/Downloads",y,m,f))
      
      # reclass
      rclm <- matrix(data = c(-Inf,2, 0, 2, Inf, 1), ncol=3, byrow=TRUE)
      rc.mr <- reclassify(mr, rcl = rclm, include.lowest = TRUE, right = FALSE) # if(-Inf <= x < 2, then = 0)

      # export bloom raster
      tmp <- strsplit(f,"_")[[1]]
      name <- paste0(paste("Bloom", tmp[2], tmp[3], tmp[4], sep ="_"),".tif")
      writeRaster(rc.mr, format = "GTiff", datType = "FLT4S", overwrite = TRUE,
                  filename = file.path("Data/Downloads",y,m,name))
      
    }   
  }
}

#------------------------------#
#       Bloom Frequnecy       #
#-----------------------------#

category <- c("straylight", "maskall")

for(i in category){

# list all bloom rasters
bloom.list <- list.files(path = "Data/Downloads", pattern = paste0("Bloom_",i,"_20*"),
                         full.names = TRUE, recursive = TRUE)

# create raster stack
bloom.stack <- stack(bloom.list)

# sum bloom rasters in stack to get frequency (0 to 16)
bloom.freq <- calc(bloom.stack, sum, na.rm=T)

# reclass NA values to determine where all rasters in stack are == NA
na.rc <- reclassify(bloom.stack, cbind(NA, -1))
na.freq <- calc(na.rc, sum)

# reclass -16 (all raster are == NA) back to NA
rclf <- matrix(data = c(-Inf,-16, NA, -16, 16, 0), ncol=3, byrow=TRUE)
rc.freq <- reclassify(na.freq, rcl = rclf, include.lowest = TRUE, right = TRUE) # if(-Inf < x <= -16, then = NA)

# sum bloom rasters in stack to get frequency (0 to 16)
na.stack <- stack(bloom.freq,rc.freq)
bloom.freq <- calc(na.stack, sum)
#plot(bloom.freq)

# export bloom raster
name <- paste0("Bloom_Freq_",i,".tif")
writeRaster(bloom.freq, format = "GTiff", datType = "FLT4S", overwrite = TRUE,
            filename = file.path("Data",name))

}



#------------------------#
#        Mean Chla       #
#------------------------#

category <- c("straylight", "maskall")

for(i in category){
  
  # list all spline reclass chla rasters
  chla.list <- list.files(path = "Data/Downloads", pattern = paste0("Chla_",i,"_20*"),
                           full.names = TRUE, recursive = TRUE)
  chla.list <- chla.list[grep("reclass.tif$",chla.list)]
  
  # create raster stack
  chla.stack <- stack(chla.list)
  
  # mean chla rasters in stack
  chla.mean <- calc(chla.stack, mean, na.rm=T)
  
  # reclass NA values to determine where all rasters in stack are == NA
  na.rc <- reclassify(chla.stack, cbind(NA, -1))
  na.chla <- calc(na.rc, sum)
  
  # reclass -16 (all raster are == NA) back to NA
  rclf <- matrix(data = c(-Inf,-16, NA, -16, Inf, 0), ncol=3, byrow=TRUE)
  rc.freq <- reclassify(na.chla, rcl = rclf, include.lowest = TRUE, right = TRUE) # if(-Inf < x <= -16, then = NA)
  
  # sum chla mean raster and NA reclass raster
  na.stack <- stack(chla.mean,rc.freq)
  chla.mean <- calc(na.stack, sum)
  
  # export chla mean raster
  name <- paste0("Chla_mean_",i,".tif")
  writeRaster(chla.mean, format = "GTiff", datType = "FLT4S", overwrite = TRUE,
              filename = file.path("Data",name))
  
}




