build/gpr_000b11a_e.zip:
	mkdir -p $(dir $@)
	curl -o $@ http://www12.statcan.gc.ca/census-recensement/2011/geo/bound-limit/files-fichiers/$(notdir $@)

build/gpr_000b11a_e.shp: build/gpr_000b11a_e.zip
	unzip -od $(dir $@) $<
	touch $@

# build/BC.json: build/gpr_000b11a_e.shp
# 	ogr2ogr -f GeoJSON -where "PRNAME like 'British%'" \
# 	build/BC.json \
# 	build/gpr_000b11a_e.shp

prov.json: build/gpr_000b11a_e.shp
	node_modules/.bin/topojson \
		-o $@ \
	    --properties='province=PRENAME' \
		--simplify=0.5 \
		-- prov=$<


newUs.json: build/us.json
	node_modules/.bin/topojson \
		-o $@ \
		--simplify=0.5 \
	    -- newUs=$<



build/tempCol.tiff: build/jan.tif
	gdaldem \
	color-relief \
	  build/jan.tif \
	  color_temp.txt \
	  build/tempCol.tiff

build/final.tiff: build/tempCol.tiff
	gdalwarp \
	  -r lanczos \
	  -ts 960 0 \
	  -t_srs EPSG:4326 \
	  build/tempCol.tiff \
	  build/final.tiff

build/relief.tiff: build/final.tiff
	gdalwarp \
	  -r lanczos \
	  -ts 960 0 \
	  -t_srs "+proj=aea +lat_1=20 +lat_2=60 +lat_0=40 +lon_0=-96 +x_0=0 +y_0=0 +datum=NAD83 +units=m +no_defs " \
  -te -2950000 1000000 -1000000 2950000 \
	  build/final.tiff \
	  build/relief.tiff


band1.png: build/relief.tiff
	gdal_translate -of PNG build/relief.tiff band1.png

# set correct projection on 'raw' tif, then add to geoserver

build/finalWms.tiff: build/testWms.tif
	gdalwarp \
	  -r lanczos \
	  -ts 960 0 \
	  -t_srs EPSG:4326 \
	  build/testWms.tif \
	  build/finalWms.tiff

build/reliefWms.tiff: build/finalWms.tiff
	gdalwarp \
	  -r lanczos \
	  -ts 960 0 \
	  -t_srs "+proj=aea +lat_1=20 +lat_2=60 +lat_0=40 +lon_0=-96 +x_0=0 +y_0=0 +datum=NAD83 +units=m +no_defs " \
  -te -2950000 1000000 -1000000 2950000 \
	  build/finalWms.tiff \
	  build/reliefWms.tiff
