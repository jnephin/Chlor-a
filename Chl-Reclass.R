## Created by Jessica Nephin
## Last edited 2016-11-21

## Reclassifies spline interpolated monthly chla
##--- Spline interpolation output can contain negative values
##--- Reclass is needed to convert negative values to zeros
## Mask EEZ to convert all cells over land to NA


# required packages
require(raster)
require(rgdal)

# working directory
#setwd('..')

#-------------------------------------------------------------------------------#


# Import BC EEZ
bc <- readOGR(dsn = "Data/Shapefiles/BC_EEZ", layer = "BC_EEZ_1km_albers")



# loop through year and month sub directories
year <- 2012:2015
month <- c("03","04","05","06")
for(y in year){
  for(m in month){
    
    # list Mosaiced Geotiff files
    tifs <-list.files(file.path("Data/Downloads",y,m), pattern="spline.tif$")
    
    # loop through tifs
    for(f in tifs){
      
      # load spline raster
      ras <- raster(file.path("Data/Downloads",y,m,f),band = 1)
      
      #reclass negatives to zeros
      rclna <- matrix(data = c(-Inf,0, 0), ncol=3, byrow=TRUE)
      r <- reclassify(ras, rcl = rclna, include.lowest = TRUE, right = TRUE) # if(-Inf < x <= 0, then = NA)
      #plot(r)
      #plot(bc, add=T)
      
      # mask reclass with 1km buffered BC EEZ
      r <- mask(r,bc)
      #plot(r)
      
      # write reclass and masked raster
      outname <- paste0(sub(".tif","",f),"_reclass.tif")
      writeRaster(r, filename = file.path("Data/Downloads",y,m,outname), 
                  format = "GTiff", datType = "FLT4S", overwrite = TRUE)
      
      
    }
  }
}





