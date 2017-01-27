 Author:       Jessica Nephin  
 Affiliation:   IOS, Fisheries and Oceans Canada (DFO)  
 Group:        Marine Spatial Ecology & Analysis, Ecosystems Science Division  
 Address:      9860 West Saanich Road, Sidney, British Columbia, V8L 4B2, Canada  
 Contact:      e-mail: jessica.nephin@dfo-mpo.gc.ca | tel: 250.363.6564  

 
Bloom Frequency from MODIS L2 Product Methods
=============================================

** For more detailed procedures and methods refer to codes in the Scripts directory **

The following describes the automated process of transforming the MODIS L2 (1 x 1 km) Chlor_a 
(mg m^-3) band into the frequency of monthly plankton blooms between March 18 and June 21
over a 4 year period from 2012 to 2015. These dates were chosen by Ed Gregr to temporally 
cover the average timing of the spring bloom in BC waters (Stockner et al. 1979; Pan et al. 1988; 
Pen~a et al. 1999).


Download
--------
* Download full res (1km) daily swath data (L2) from aqua MODIS from 2012 to 2015 between 
March 18 and June 21. Data source: http://oceandata.sci.gsfc.nasa.gov
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
* Monthly mosaiced Chlor_a was interpolated to fill remaining data gaps (from clouds for example). 
* Raster interpolation was performed in ArcMap using Spline with Barrier algorithm (SplineBarriers.py).
* Chla was interpolated with a 1 x 1 km cell size (its native resolution)
* Both products, 1) all masked and 2) no straylight masked, were interpolated.


Bloom Frequency
----------------
* Monthly bloom frequency was caluclated in R using the raster package.
* Cells with Chlor_a ≥ 2.0 mg m^-3 were reclassified as blooming. For each month, each cell was 
classified as either blooming (== 1) or not (== 0).
* The 2 mg m^-3 was used by (Gregr et al., 2016), it is the average of two thresholds reported for 
the study area (> 1 mg/m3, Gower 2004, and > 3 mg/m3, Mackas et al. 2007). 
* Monthly bloom rasters were added together to calculate bloom frequency which ranged between 0 to 16. 
Values of 16 represent regions where monthly Chla concentrations exceeded the bloom threshold during 
all months between March 18 and June 21 over a 4 year period from 2012 to 2015. 

Mean Chla
---------
* Mean chla (from the monthly interpolated chla) was caluclated in R using the raster package.




References
----------

		Gower, J.F.R. 2004. SeaWiFS global composite images show significant features of Canadian 
		waters for 1997-2001. Canadian Journal of Remote Sensing 30:26-35.
		
		Gregr, E. J., Gryba, R., Li, M. Z., Alidina, H., Kostylev, V., & Hannah, C. G. (2016). 
		A Benthic Habitat Template for Pacific Canada ’s Continental Shelf (312th ed.). Canadian 
		Technical Report of Hydrography and Ocean Sciences.
		
		Mackas, D., Peña, A., Johannessen, D., Birch, R., Borg, K., and Fissel, D. 2007. Appendix D: 
		Plankton. Pages iv + 33 p. in Lucas BG, Verrin S, Brown R, eds. Ecosystem overview: Pacific 
		North Coast Integrated Management Area (PNCIMA), vol. 2667 Can. Tech. Rep. Fish. Aquat. Sci.

		Pan, D., J. F. R. Gower, and G. A. Borstad. 1988. Seasonal variation of the surface 
		chlorophyll distribution along the British Columbia coast as shown by CZCS satellite 
		imagery. Limnology and Oceanography 33(2):227-244.
		
		Pen~a, M. A., K. L. Denman, S. E. Calvert, R. E. Thomson, and J. R. Forbes. 1999. 
		The seasonal cycle in sinking particle fluxes off Vancouver Island, British Columbia. 
		Deep-Sea Research II 46:2969-2992.
		
        Stockner, J. G., D. D. Cliff, and K. R. S. Shortreed. 1979. Phytoplankton ecology of 
		the Strait of Georgia, British Columbia. J. Fish. Res. Board Can. 36:657-666.
		
		