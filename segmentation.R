#################### ########## ########## ########## ##########  
######## land cover mapping                           ########## 
######## yelena.finegold@fao.org                      ##########
######## updated 01/11/2017                           ########## 
################### ########### ########## ########## ##########
######## combining segmentation and supervised classification

## load libraries
library(rgdal)
library(sp)

## user inputs
classification <- '~/downloads/classification-2017-11-01-1156-landsatdemo/classification-2017-11-01-1156-landsatdemo.tif'
segmentation_path <- '~/downloads/landsat_demo2/'
setwd(segmentation_path)
mosaic <- '~/downloads/landsat_demo2/landsat_demo2.tif'
segmentation_layername <- 'landsat_demo_segmentation_rad10_minregion10'
oftseg_output_name <- 'landsat_demo_classification_segmentation.tif'


## get some metadata about the classified map
r.map1 <- raster(classification)
r.map1.xmin <- as.matrix(extent(r.map1))[1]
r.map1.ymin <- as.matrix(extent(r.map1))[2]
r.map1.xmax <- as.matrix(extent(r.map1))[3]
r.map1.ymax <- as.matrix(extent(r.map1))[4]
r.map1.xres <- res(r.map1)[1]
r.map1.yres <- res(r.map1)[2]
r.map1.maxval <- maxValue(r.map1)
r.map1.maxval <- system(sprintf("oft-mm -um %s %s | grep 'Band 1 max = '",paste0(inputdir, map1), paste0(inputdir, map1)), intern = TRUE)
r.map1.maxval <- as.numeric(substring(r.map1.maxval,14))
r.map1.proj <- as.character(projection(r.map1))

# read the segmentation file
segshp <- readOGR(paste0(segmentation_layername, '.shp'),segmentation_layername)
segshp_attributename <- names(segshp)

datatype <- 'UInt16'
## rasterize the segmentation
system(sprintf("gdal_rasterize -l %s -te %s %s %s %s -tr %s %s -a %s -ot %s -co COMPRESS=LZW %s %s",
               segmentation_layername,
               r.map1.xmin,
               r.map1.ymin,
               r.map1.xmax,
               r.map1.ymax,
               r.map1.xres,
               r.map1.yres,
               segshp_attributename,
               datatype,
               paste0(segmentation_path,segmentation_layername, '.shp'),
               paste0(segmentation_path,segmentation_layername, '.tif')
))

## burn the mode from the classification into the segments
system(sprintf('bash oft-segmode.bash %s %s %s',
               paste0(segmentation_path,segmentation_layername, '.tif'),
               classification,
               paste0(segmentation_path,'tmp_',oftseg_output_name)
))

system(sprintf("gdalinfo %s",
               paste0(segmentation_path,'tmp_',oftseg_output_name)))
## compress the output
system(sprintf("gdal_translate -ot Byte -co COMPRESS=LZW %s %s",
               paste0(segmentation_path,'tmp_',oftseg_output_name),
               paste0(segmentation_path,oftseg_output_name)))

## delete tmp files
system(sprintf("rm %s",
               paste0(segmentation_path,'tmp_',oftseg_output_name)))

