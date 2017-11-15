# Name: SplineBarriers.py
# Description: Interpolate a series of point features onto a
#    rectangular raster using a barrier, using a
#    minimum curvature spline technique.
# Requirements: Spatial Analyst Extension and Java Runtime
# Author: Jessica Nephin
# Date: Nov 18, 2016
# Edited: Jan 24, 2017

# Import system modules
import os
import arcpy
from arcpy import env
from arcpy.sa import *

# move up one directory
#os.chdir('F:/Abiotic_data/Remote_Sensing/Chl_a/Scripts')
#os.chdir('..')


year = ["2012","2013","2014","2015"]
month = ["02","03","04","05","06","07","08","09","10","11"]

for y in year:
	for m in month:

		# set workspace
		env.workspace = os.getcwd()+"/Data/Downloads/"+y+"/"+m+"/points"

		# Returns a list of shapefiles
		shp = arcpy.ListFeatureClasses()

		for s in shp:

			# Set local variables
			zField = "chla"
			inBarrierFeature =  os.getcwd()+"/Boundary/coast_buffer_1km.shp"
			cellSize =  1000.0
			smoothing = 1

			# Check out the ArcGIS Spatial Analyst extension license
			arcpy.CheckOutExtension("Spatial")

			# Execute Spline with Barriers
			outSB = SplineWithBarriers(s, zField, inBarrierFeature, cellSize, smoothing)

			# Use splitext to set the output name
			outfilename = os.path.splitext(s)[0] + "_spline.tif"

			# Save the output
			outfile =  os.getcwd()+"/Data/Downloads/"+y+"/"+m+"/"+outfilename
			outSB.save(outfile)
