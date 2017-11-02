#################### ########## ########## ########## ##########  
######## land cover mapping                           ########## 
######## yelena.finegold@fao.org                      ##########
######## updated 01/11/2017                           ########## 
################### ########### ########## ########## ##########
######## combining segmentation and supervised classification

## load libraries
options(stringsAsFactors=FALSE)

library(Hmisc)
library(sp)
library(rgdal)
library(raster)
library(plyr)
library(foreign)

## user inputs
classification <- '~/downloads/classification-2017-11-01-1156-landsatdemo/classification-2017-11-01-1156-landsatdemo.tif'
## folder where your segmentation file is located
segmentation_path <- '~/downloads/landsat_demo2/'
segmentation_layername <- 'landsat_demo_segmentation_rad10_minregion10'
## output file names
oftseg_output_name <- 'landsat_demo_classification_segmentation.tif'
decisiontree_output_name <- 'landsat_demo_decisiontree_seg_class.tif'

## input class names in order
numberofclasses <- 4
classes <- c('no data', 'forest', 'nonforest', 'water')
class0 <- 'no data'
class1 <- 'forest'
class2 <- 'nonforest'
class3 <- 'water'

# set the working directory
setwd(segmentation_path)

## get some metadata about the classified map
r.map1 <- raster(classification)
r.map1.xmin <- as.matrix(extent(r.map1))[1]
r.map1.ymin <- as.matrix(extent(r.map1))[2]
r.map1.xmax <- as.matrix(extent(r.map1))[3]
r.map1.ymax <- as.matrix(extent(r.map1))[4]
r.map1.maxval <- system(sprintf("oft-mm -um %s %s | grep 'Band 1 max = '",classification, classification), intern = TRUE)
r.map1.maxval <- as.numeric(substring(r.map1.maxval,14))
r.map1.xres <- res(r.map1)[1]
r.map1.yres <- res(r.map1)[2]
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

## compress the output
system(sprintf("gdal_translate -ot Byte -co COMPRESS=LZW %s %s",
               paste0(segmentation_path,'tmp_',oftseg_output_name),
               paste0(segmentation_path,oftseg_output_name)))

## delete tmp files
system(sprintf("rm %s",
               paste0(segmentation_path,'tmp_',oftseg_output_name)))


## histogram
system(sprintf("
               oft-his -i %s -o %s -um %s -maxval %s",
               classification,
               paste0(segmentation_path,'histo_',segmentation_layername,'.txt'),
               paste0(segmentation_path,segmentation_layername, '.tif'),
               r.map1.maxval))

hist <- paste0(segmentation_path,'histo_',segmentation_layername,'.txt')
output <- paste0(segmentation_path,'output_',segmentation_layername,'.txt')

##############################
### Read the data table

df<-read.table(hist)
head(df)
nrow(df)
names(df) <- c("id","total","forest","nonforest")
df$smforest <- 0
df$smnonforest <- 0
df$class  <- 0


out <- df[,c(1:5)]

length(unique(out$id))
head(out)
out$code<-0

# at least 2 forest pixels and 20% of the segment has forest pixels to be defined forest

# two is nonforest
tryCatch({
  out[
    out$id %in% df[df$forest < 2,]$id
    &
      out$id %in% df[df$forest/ df$total < 0.2,]$id
    ,]$code<-2
}, error=function(e){cat("Configuration impossible \n")}
)

# one is forest
tryCatch({
  out[
    out$id %in% df[df$forest >= 2,]$id
    &
      out$id %in% df[df$forest/ df$total >= 0.2,]$id
    ,]$code<-1
}, error=function(e){cat("Configuration impossible \n")}
)

# three is small patches of forest, less than 20% 
tryCatch({
  out[
    out$id %in% df[df$forest >= 2,]$id
    &
      out$id %in% df[df$forest/ df$total < 0.2,]$id
    ,]$code<-3
}, error=function(e){cat("Configuration impossible \n")}
)
head(out)
table(out$code, out$forest)

write.table(file=output,out,sep=" ",quote=FALSE, col.names=FALSE,row.names=FALSE)

max(out$code)
norm_eq <- paste0("echo ",output, " \"", 1, " ", 1,  " ", 6, " ", 99, "\"")
norm_eq <- paste0("(",norm_eq,")")

system(sprintf('%s | oft-reclass -oi %s %s',
               norm_eq,
               paste0(segmentation_path,'tmp_',decisiontree_output_name),
               paste0(segmentation_path,segmentation_layername, '.tif')
))

## compress the output
system(sprintf("gdal_translate -ot Byte -co COMPRESS=LZW %s %s",
               paste0(segmentation_path,'tmp_',decisiontree_output_name),
               paste0(segmentation_path, decisiontree_output_name)))

# 
# delete tmp files
system(sprintf("rm %s",
               paste0(segmentation_path,'tmp_',decisiontree_output_name)))
