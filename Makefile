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
		--projection='width = 960, height = 600, d3.geo.albers() \
			.rotate([96, 0]) \
		    .center([-32, 53.9]) \
		    .parallels([20, 60]) \
		    .scale(1970) \
		    .translate([width / 2, height / 2])' \
	    --properties='province=PRENAME' \
		--simplify=0.5 \
		-- prov=$<



# prov.json: build/gpr_000b11a_e.shp
# 	node_modules/.bin/topojson \
# 		-o $@ \
# 	    --properties='province=PRENAME' \
# 		-- prov=$<

newUs.json: build/us.json
	node_modules/.bin/topojson \
		-o $@ \
		--projection='width = 960, height = 800, d3.geo.albers() \
			.rotate([98, 0]) \
		    .center([-22, 55]) \
		    .parallels([20, 65.5]) \
		    .scale(2500) \
		    .translate([width / 2, height / 2])' \
	    -- newUs=$<


# relief.tiff: band1Out2.tif
# 	gdalwarp \
# 	  -r lanczos \
# 	  -ts 960 0 \
# 	  -t_srs "+proj=aea +lat_1=50 +lat_2=58.5 +lat_0=45 +lon_0=-126 +x_0=1000000 +y_0=0 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs " \
# 	  band1Out2.tif \
# 	  relief.tiff

build/relief.tiff: band1Out2.tif
	gdalwarp \
	  -r lanczos \
	  -ts 960 0 \
	  -t_srs "+proj=aea +lat_1=20 +lat_2=60 +lat_0=40 +lon_0=-96 +x_0=0 +y_0=0 +datum=NAD83 +units=m +no_defs " \
  -te -2950000 1000000 -1000000 2950000 \
	  band1Out2.tif \
	  build/relief.tiff


band1.png: build/relief.tiff
	gdal_translate -of PNG build/relief.tiff band1.png