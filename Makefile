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
		--projection='width = 960, height = 800, d3.geo.albers() \
			.rotate([98, 0]) \
		    .center([-22, 55]) \
		    .parallels([20, 65.5]) \
		    .scale(2500) \
		    .translate([width / 2, height / 2])' \
	    --properties='province=PRENAME' \
		--simplify=0.5 \
		-- prov=$<

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