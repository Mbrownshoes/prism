wget --output-document=myfile.txt --header "Cookie: beaker.session.id=160e7a46fa0145f7a66ccf23c5c7a131" http://tools.pcic.uvic.ca/dataportal/bc_prism/data/tmax_monClim_PRISM_historical_run1_197101-200012.nc

As csv
wget --output-document=- --header "Cookie: beaker.session.id=160e7a46fa0145f7a66ccf23c5c7a131" http://tools.pcic.uvic.ca/dataportal/bc_prism/data/tmax_monClim_PRISM_historical_run1_197101-200012.nc.csv

so to get the yearly values (13th timestep)
wget --output-document=- --header "Cookie: beaker.session.id=160e7a46fa0145f7a66ccf23c5c7a131" http://tools.pcic.uvic.ca/dataportal/bc_prism/data/tmax_monClim_PRISM_historical_run1_197101-200012.nc.csv?tmax[13][200:210][200:210]  2> /dev/null

convert to Geotiff and select band
gdal_translate -of GTiff NETCDF:"/Users/mathewbrown/projects/PCIC/tmax.nc":tmax -b 1 /Users/mathewbrown/projects/PCIC/stuff.tif

- that worked. then set colors in qgis.