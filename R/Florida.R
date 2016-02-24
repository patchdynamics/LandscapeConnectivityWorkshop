nlcd.downsampled = raster('GIS-Florida/NLCD_Florida_240.tif')

project.empty = raster(extent(nlcd.downsampled))
crs(project.empty) = crs(nlcd.downsampled)
res(project.empty) = res(nlcd.downsampled)

reclassification = c(0, NA,
                     11, -1,    # water
                     41, 20,   # deciduous forests
                     42, 20,   # evergreen forests
                     43, 20,   # mixed forests
                     90, 20,   # woody wetlands
                     95, 100,   # herbaceous wetlands
                     52, 80,   # shrub or scrub
                     71, 100,   # herbaceous grasslands
                     81, 400,   # pasture and hay fields
                     82, 750,   # cultivated crops
                     24, -1,    # developed high intensity - set to impassible
                     23, -1,   # developed medium intensity - set to impassible
                     22, 950,   # developed low intensity
                     21, 850)   # deleloped open space
reclassification.matrix = matrix(reclassification, ncol=2, byrow=TRUE)
resistance = reclassify(nlcd.downsampled, reclassification.matrix)


# write out raster, setting NA values to -1
writeRaster(resistance,'GIS-Florida/PantherResistance.tif', NAflag=-1, overwrite = T)
plot(resistance)


# now set up the focal zones
#focalZones = readShapeSpatial('GIS-Florida/PantherFocalZones.shp')  # multiple focal zones
focalZones = readShapeSpatial('GIS-Florida/PantherFocalZonesSimple.shp')  # only 2 focal zones
plot(focalZones, add=T)
focalZones.raster = rasterize(focalZones, project.empty)
plot(focalZones.raster)
writeRaster(focalZones.raster, 'GIS-Florida/PantherFocalZones.tif', NAflag=-1, overwrite = T)



# these need to be converted to a special 
gdal_translate('GIS-Florida/PantherResistance.tif', 'GIS-Florida/PantherResistance.asc', of = 'AAIGrid' )  # 'NULL' return value is OK
gdal_translate('GIS-Florida/PantherFocalZones.tif', 'GIS-Florida/PantherFocalZones.asc', of = 'AAIGrid' )  # 'NULL' return value is OK



# let's try looking only at a corridor
corridor = readShapeSpatial('GIS-Florida/Corridor.shp')
corridor.raster = rasterize(corridor, project.empty)

resistance[is.na(corridor.raster)] = NA
plot(resistance)

writeRaster(resistance,'GIS-Florida/PantherResistance.tif', NAflag=-1, overwrite = T)
gdal_translate('GIS-Florida/PantherResistance.tif', 'GIS-Florida/PantherResistance.asc', of = 'AAIGrid' )  # 'NULL' return value is OK

