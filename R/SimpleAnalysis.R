library(raster)
library(gdalUtils)


setwd('~/Documents/Projects/Spatial Stats/Connectivity - Red Tree Vole/')

# load the polygon
area = shapefile('GIS/population.area.2.shp')
plot(area)

# load the elevation data and make sure it's in the right place
elevation = raster('../Lesson-SDM/GIS/DEMSRE2a.tif')
plot(elevation)
plot(area, add=T)

# mask to our species area
resistance.surface = mask(elevation, area)
plot(resistance.surface)

resistance.surface

resistance.surface[resistance.surface < 0] = -1
elevation.max = max(resistance.surface[resistance.surface > 0])
resistance.surface[resistance.surface > 0] = (resistance.surface[resistance.surface > 0] / elevation.max) * 1000

plot(resistance.surface)

# write out the file
writeRaster(resistance.surface, 'GIS/Resistances.tiff')
gdal_translate('GIS/Resistances.tif', 'GIS/Resistances.asc', of = 'AAIGrid' )  # 'NULL' return value is OK


# don't forget about the focal nodes

focalNodes = shapefile('GIS/MyFocalNodes.shp')
plot(focalNodes, add=T)

# now we rasterize our vector layer
project.area.empty.raster = raster(extent(resistance.surface))
res(project.area.empty.raster) = res(resistance.surface)
project.area.empty.raster[] = 0


focalNodes.raster = rasterize(focalNodes, project.area.empty.raster)
plot(focalNodes.raster)
writeRaster(focalNodes.raster, 'GIS/FocalNodes.tif', NAflag=-1, overwrite=T)


gdal_translate('GIS/FocalNodes.tif', 'GIS/FocalNodes.asc', of = 'AAIGrid' )  # 'NULL' return value is OK



