#
for d in */; do
   cd $d
   y="$d"
     for sd in */; do
     cd $sd
     m="$sd"
	 # project chlor_a band, mask flags and save as tiff
       for f in *.nc; do
         e=${f%.nc}
		 x="${e}_straylight"
         gpt F:\\Chl_a\\Scripts\\Project-Mask-nostraylight.xml -Ssource=$f -Pexportfilename=$e
		 gpt F:\\Chl_a\\Scripts\\Project-Mask-straylight.xml -Ssource=$f -Pexportfilename=$x
       done
	   # Mosaic monthly chlor_a with and without straylight masked
	   i=$(ls *.L2_LAC_OC.tif)
	   t="Chla_maskall_${y:0:4}_${m:0:2}"
	   gpt F:\\Chl_a\\Scripts\\Mosaic.xml -Pexportfilename=$t $i
	   j=$(ls *.L2_LAC_OC_straylight.tif)
	   z="Chla_straylight_${y:0:4}_${m:0:2}"
	   gpt F:\\Chl_a\\Scripts\\Mosaic.xml -Pexportfilename=$z $j
     cd ..
     done
   cd ..
done

cd ../../

# Run points
Rscript --vanilla --verbose Scripts/Chl-Points.R

# Run interpolation in Arc python window
SplineBarriers.py

# Run reclass
Rscript --vanilla --verbose  Scripts/Chl-Reclass.R

# Run Bloom frequency
Rscript --vanilla --verbose  Scripts/Chl-Bloom.R

# Run Uncertainty
Rscript --vanilla --verbose  Scripts/Chl-Uncertainty.R

# Build stats and pyramids
bash Scripts/BuildStatsPyramids.sh
