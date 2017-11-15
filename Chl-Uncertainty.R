## Created by Jessica Nephin
## Last edited 2017-02-27

## Calculates chl-a uncertainty
## Uncertainty layer = 0-32,
## the number of times the cell values were derived from extrapolation


# required packages
require(raster)
require(rgdal)
require(sp)
require(rgeos)
require(fields)

# working directory
#setwd('..')


#-------------------------------------------------------------------------------#

# Speed up raster processes
rasterOptions(chunksize = 1e+08, maxmemory = 1e+09)

# Import BC EEZ
bc <- readOGR(dsn = "Boundary", layer = "BC_EEZ_1km_albers")


#------------------------------#
#    Interpolated Frequency    #
#------------------------------#

category <- c("straylight", "maskall")

for(i in category){

# list all chla rasters
chl.list <- list.files(path = "Data/Downloads", pattern = paste0("Chla_",i,"_20*"),
                         full.names = TRUE, recursive = TRUE)
chl.list <- chl.list[grep(".tif$",chl.list)]
chl.list <- chl.list[-grep("spline",chl.list)]

# create raster stack
chl.stack <- stack(chl.list, bands = 1)

# reclass values to 0 or 1
rcl <- matrix(data = c(-Inf, 0, 1, 0, Inf, 0), ncol=3, byrow=TRUE)
frq.stack <- reclassify(chl.stack, rcl = rcl, include.lowest = TRUE, right = TRUE) # if(-Inf < x <= 0, then = 1)

# sum frequency (0 to 32) to get uncertainty layer
# 0 = never interpolated, 32 = always interpolated (no data for that cell)
uncLayer <- calc(frq.stack, sum, na.rm=T)

# mask with 1km buffered BC EEZ
uncLayer <- crop(uncLayer, bc)
uncLayer <- mask(uncLayer, bc)

# export uncertainty raster
name <- paste0("Uncertainty_",i,".tif")
writeRaster(uncLayer, format = "GTiff", datType = "FLT4S", overwrite = TRUE,
            filename = file.path("Data",name))

}
