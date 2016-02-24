library('raster')
nlcd = raster("NLCD_Farmingon_Cropped.tif")

blank = raster(extent(nlcd))
crs(blank) <- crs(nlcd)
res(blank) <- 30
blank[] = 0
shortcircuit = blank
shortcircuit[nlcd>40 & nlcd < 80] = 1
writeRaster(shortcircuit, 'shortcircuit.tiff')

openwater = blank
openwater[nlcd == 11] = 1

impassible_developed = blank
impassible_developed[nlcd == 23 | nlcd == 24] = 1

barren = blank
barren[nlcd == 31] = 1
plot(barren)

farmlands = blank
farmlands[nlcd == 81 | nlcd == 82] = 1


roads = raster('Resistance.tif')
crossable_roads = raster('Roads_Crossable.tif')
breaches = raster('I696Breaches.tif')
resistance = blank
resistance[] = 1
resistance[openwater == 1] = 255
resistance[impassible_developed == 1] = 255
resistance[crossable_roads == 1] = 125
resistance[nlcd == 22] = 125
resistance[nlcd == 21] = 65
resistance[barren == 1] = 10
resistance[farmlands == 1] = 15
resistance[roads == 255] = 255
resistance[breaches == 1] = 160
writeRaster(resistance, 'ResistanceCompiledFull5.tiff')
plot(resistance)

focalNodes = raster('FocalNodesPoints3.tif')
f = blank
f[focalNodes > 0] = focalNodes[focalNodes > 0]
f[f == 0] = NA
writeRaster(f, 'FocalNodesFinal7.tif')
