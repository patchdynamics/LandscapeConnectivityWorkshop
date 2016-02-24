install.packages("gdalUtils")

library(maptools)
library(raster)
library(gdalUtils)


# this just sets up a project area and a resolution for our simulated landscape
project.area = readShapeSpatial('GIS/ProjectArea.shp')
project.area.empty.raster = raster(extent(project.area))
res(project.area.empty.raster) = .005
project.area.empty.raster[] = 0
plot(project.area.empty.raster)
writeRaster(project.area.empty.raster, 'GIS/ProjectArea.tif', overwrite=TRUE)


# load our focal nodes from a shape file (vector) we created in QGIS
# these are where we believe our species are in relatively high numbers
focalNodes = readShapeSpatial('GIS/FocalNodes.shp')
plot(sourceAreas, add=T)

# now we rasterize our vector layer
focalNodes.raster = rasterize(sourceAreas, project.area.empty.raster)
plot(focalNodes.raster)
writeRaster(focalNodes.raster, 'GIS/FocalNodes.tif', NAflag=-1, overwrite=T)

# load impassible areas from a shape file (vector) we create in QGIS
# we also rasterize these, with a value of -1 indicating infinite resistance
impassibleAreas = readShapeSpatial('GIS/ImpassibleAreas.shp')
impassibleAreas.raster = rasterize(impassibleAreas, project.area.empty.raster,-1)
plot(impassibleAreas.raster)

# we've also set up resistances in QGIS as a vectory layer
# load and rasterize these as well, using the 'resistance' attribute for the raster value
resistances = readShapeSpatial('GIS/BackgroundResistance.shp')
resistances.raster = rasterize(resistances, project.area.empty.raster, 'resistance')
plot(resistances.raster)

# now combine the resistance and impassible layers
# since our rasters have the same extents, resolution, and coordinate system, we can
# assign values using indexing
resistances.raster[!is.na(impassibleAreas.raster)] = impassibleAreas.raster[!is.na(impassibleAreas.raster)]
plot(resistances.raster)

# and save out our resistances tif
# this can also be visualized in QGIS
# note the extra parameters 'NAflag=-1' - this is required for CircuitScape to read the file
writeRaster(resistances.raster, 'GIS/Resistances.tif', NAflag=-1, overwrite=T)

# convert these files to the format the CircuitScape needs (knows as Golden Surfer Grid)
gdal_translate('GIS/Resistances.tif', 'GIS/Resistances.asc', of = 'AAIGrid' )  # 'NULL' return value is OK
gdal_translate('GIS/FocalNodes.tif', 'GIS/FocalNodes.asc', of = 'AAIGrid' )  # 'NULL' return value is OK

# now head over to CircuitScape and run the analysis
# then visualize results in QGIS




