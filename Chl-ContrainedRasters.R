###############################################################################
#
# Authors:      Jessica Nephin
# Affiliation:  Fisheries and Oceans Canada (DFO)
# Group:        Marine Spatial Ecology and Analysis
# Location:     Institute of Ocean Sciences
# Contact:      e-mail: jessica.nephin@dfo-mpo.gc.ca | tel: 250.363.6564
# Project:      Satellite Surface CHlorophyll Layers
#
# Overview:   Create contrained layer to only show data that is not 100% interpolated
#
###############################################################################

# Load packages
library(rgdal)
library(sp)
library(rgeos)
library(raster)

# Go to parent directory
setwd('..')


category <- c("straylight", "maskall")
type <- c("Chla_mean","Bloom_Freq")

for(i in category){
  for(j in type){
    
    # -------------------------------------------------#
    # Load rasters
    
    chla <- raster(paste0("Data/", j, "_", i, ".tif")) 
    uncert <- raster(paste0("Data/Uncertainty_", i, ".tif"))
    
    # resample to match extents
    rchla = resample(chla, uncert, "bilinear")
    
    # -------------------------------------------------#
    # reclass uncert raster
    m <- c(-1, 31, 1,  31, 32, -1)
    rclmat <- matrix(m, ncol=3, byrow=TRUE)
    binaryuncert <- reclassify(uncert, rclmat)
    
    # -------------------------------------------------#
    # remove uncertain areas from chla rasters
    unc_chla <- rchla * binaryuncert

    # -------------------------------------------------#
    # reclass negatives to NA 
    m <- c(-Inf, -0.00000001, NA)
    rclmat <- matrix(m, ncol=3, byrow=TRUE)
    nchla <- reclassify(unc_chla, rclmat)

    
    # -------------------------------------------------#
    # write 
    writeRaster(nchla, paste0("Data/", j, "_", i, "_noextrap.tif"), overwrite=T)

  }
}