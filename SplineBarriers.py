# Name: SplineBarriers.py
# Description: Interpolate a series of point features onto a 
#    rectangular raster using a barrier, using a 
#    minimum curvature spline technique.
# Requirements: Spatial Analyst Extension and Java Runtime 
# Author: Jessica Nephin
# Date: Nov 18, 2016

# Import system modules
import os
import arcpy
from arcpy import env
from arcpy.sa import *

year = ["2012","2013","2014","2015"]
month = ["03","04","05","06"]

for y in year:
	for m in month:
		# Set environment settings
		env.workspace = "F:/Chl_a/Data/Downloads/"+y+"/"+m+"/points"
		
		# Returns a list of shapefiles
		shp = arcpy.ListFeatureClasses()
		
		for s in shp:

			# Set local variables
			zField = "chla"
			inBarrierFeature = "C:/Users/NephinJ/Documents/Projects/Spatial/Coastlines/coast_buffer_1km.shp"
			cellSize =  1000.0
			smoothing = 1

			# Check out the ArcGIS Spatial Analyst extension license
			arcpy.CheckOutExtension("Spatial")

			# Execute Spline with Barriers
			outSB = SplineWithBarriers(s, zField, inBarrierFeature, cellSize, smoothing)

			# Use splitext to set the output name
			outfilename = os.path.splitext(s)[0] + "_spline.tif"
			
			# Save the output 
			outfile = "F:/Chl_a/Data/Downloads/"+y+"/"+m+"/"+outfilename
			outSB.save(outfile)

