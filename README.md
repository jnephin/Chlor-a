 Author:       Jessica Nephin  
 Affiliation:   IOS, Fisheries and Oceans Canada (DFO)  
 Group:        Marine Spatial Ecology & Analysis, Ecosystems Science Division  
 Address:      9860 West Saanich Road, Sidney, British Columbia, V8L 4B2, Canada  
 Contact:      e-mail: jessica.nephin@dfo-mpo.gc.ca | tel: 250.363.6564  


Bloom Frequency from MODIS L2 Product Methods
=============================================

The following describes the automated process of transforming the MODIS L2 (1 x 1 km) Chlor_a
(mg m^-3) band into the frequency of monthly plankton blooms between March and October
over a 4 year period from 2012 to 2015. November to February were excluded because of limited
data due to increased cloud cover.


Download
--------
* Download full res (1km) daily swath data (L2) from aqua MODIS from 2012 to 2015 between
March and October. Data source: http://oceandata.sci.gsfc.nasa.gov
* Only download daily swaths between 19:00 and 24:00 UTC when aqua MODIS is capturing data
from the BC region.
* Delete daily swaths if they do not include any data in the region of interest (BC EEZ).
* Run Chl-Download.R from cygwin environment


Project / Mask
--------------
* Reprojection and quality flag masking is carried out using the command line tool gpt from
 Sentinel Application Platform (SNAP) which can be found here http://step.esa.int/main/toolboxes/snap/
* Chlor_a (mg m^-3) band was reprojected to BC Albers projected coordinate system (EPSG:3005).
* Two different Chlor_a layers were produced. 1) Which masked all data quality flags which are masked
by default in L3 products (LAND, ATMFAIL, HIGLINT, HILT, HISATZEN, CLDICE, COCCOLITH, HISOLZEN, LOWLW,
NAVFAIL, MAXAERITER, ABSAER and STRAYLIGHT). 2) Which masked all data quality flags which are masked
by default in L3 products expect for STRAYLIGHT. Masking the straylight flag causes significant amount
of data loss, especially in the coastal region.


Mosaic
------
* Projected and masked daily swath Chlor_a was mosaiced by month using SNAP's command line tool gpt.
* Mosaic was performed using billinear interpolation at the native resolution 1 x 1 km.
* When daily swaths were overlapping the mean value was calculated.


Interpolate
-----------
* The monthly ChlA data was interpolated spatially using Spline with Barriers (ArcGIS 10.4) to fill in
any gaps that remained after mosaicking. These gaps were typically located nearshore and in coastal inlets.
* Raster interpolation was performed in ArcMap using Spline with Barrier algorithm (SplineBarriers.py).
* Chla was interpolated with a 1 x 1 km cell size (its native resolution)
* Both products, 1) all masked and 2) no straylight masked, were interpolated.


Bloom Frequency
----------------
* Monthly bloom frequency was caluclated in R using the raster package.
* Cells with Chlor_a ≥ 3.0 mg m^-3 were reclassified as blooming. For each month, each cell was
classified as either blooming (== 1) or not (== 0). This method was previously used by Gregr et al. (2016).
* The 3 mg m^-3 is a chlorophyll bloom threshold reported for the study area (Mackas et al. 2007).
* Monthly bloom rasters were added together to calculate bloom frequency which ranged from 0 to 32.
Values of 32 represent regions where monthly Chla concentrations exceeded the bloom threshold during
all months from March to October over a 4 year period from 2012 to 2015.


Mean Chla
---------
* Mean chla (from the monthly interpolated chla) was caluclated in R using the raster package.


Uncertainty
-----------
* Uncertainty layer represents the extent to which the chl-a layer was interpolated/extrapolated.
* Uncertainty values represent the frequency (0 to 32) each cell was interpolated. A value of 32
indicates that no data vas available for that cell for the 32 months examined. A value of 0 indicates
that there was data available for that cell for all 32 months examined.
* The uncertainty layers for both maskall and straylight products, helps visualize the
differences between the two layers.
* To limit highly uncertain values, mainly in those areas, the interpolated ChlA surface was
constrained by re-classifying locations which had data gaps in all 32 months to ‘no data’. This
layer was suffixed with 'noextrap'.


References
----------

		Gregr, E.J., Gryba, R., Li, M.Z., Alidina, H., Kostylev, V., and Hannah, C.G. 2016. A
                benthic habitat template for Pacific Canada’s continental shelf. Can. Tech. Rep. Hydrogr.
                Ocean Sci. 312: vii + 37 p.

		Mackas, D., Peña, A., Johannessen, D., Birch, R., Borg, K., and Fissel, D. 2007. Appendix D:
		Plankton. Pages iv + 33 p. in Lucas BG, Verrin S, Brown R, eds. Ecosystem overview: Pacific
		North Coast Integrated Management Area (PNCIMA), vol. 2667 Can. Tech. Rep. Fish. Aquat. Sci.
