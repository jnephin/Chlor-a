## build stats and pyramids for GeoTiffs

for r in $(ls Data/*.tif); do
   gdalinfo -stats $r
   gdaladdo -r nearest $r 2 4 8 16
done
