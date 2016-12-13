## Created by Jessica Nephin
## Last edited 2016-11-18

## Extract points from mosaiced monthly chla rasters


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


# loop through year and month sub directories
year <- 2012:2015
month <- c("03","04","05","06")
for(y in year){
  for(m in month){
    
    # list Mosaiced Geotiff files
    tifs <-list.files(file.path("Data/Downloads",y,m), 
                      pattern=paste(paste0("Chla_straylight_",y,"_", m,".tif"),
                                    paste0("Chla_maskall_",y,"_", m,".tif"), sep="|"))
    
    # loop through tifs
    for(f in tifs){
      
      # load Geotiff
      mr <- raster(file.path("Data/Downloads",y,m,f),band = 1)
      
      # crop chla raster to the spatial extents of the BC 1km buffered EEZ
      mr <- crop(mr, bc)
      
      # reclass 0 to NA, b/c gpt Mosaic operator changes NA values to O
      rclna <- matrix(data = c(-Inf,0, NA), ncol=3, byrow=FALSE)
      mr.na <- reclassify(mr, rcl = rclna, include.lowest = TRUE, right = TRUE) # if(-Inf < x <= 0, then = NA)
      
      # extract points
      xy <- data.frame(xyFromCell(mr.na , 1:ncell(mr.na))) 
      xy$chla <- getValues(mr.na)
      xy <- xy[!is.na(xy$chla),]
      coordinates(xy) <- ~x+y
      proj4string(xy) <- proj4string(bc)
      layer <- sub(".tif","",f)
      dir.create(file.path("Data/Downloads",y,m, "points"))
      writeOGR(xy, dsn = file.path("Data/Downloads",y,m, "points"), 
               layer = layer, driver = "ESRI Shapefile",overwrite_layer=TRUE)
      
    }
  }
}


