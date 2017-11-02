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
segmentation_path <- '~/downloads/landsat_demo2/'
mosaic <- '~/downloads/landsat_demo2/landsat_demo2.tif'
segmentation_layername <- 'landsat_demo_segmentation_rad10_minregion10'
oftseg_output_name <- 'landsat_demo_classification_segmentation.tif'
decisiontree_output_name <- 'landsat_demo_decisiontree_seg_class.tif'
# set the working directory
setwd(segmentation_path)

## get some metadata about the classified map
r.map1 <- raster(classification)
r.map1.xmin <- as.matrix(extent(r.map1))[1]
r.map1.ymin <- as.matrix(extent(r.map1))[2]
r.map1.xmax <- as.matrix(extent(r.map1))[3]
r.map1.ymax <- as.matrix(extent(r.map1))[4]
r.map1.maxval <- system(sprintf("oft-mm -um %s %s | grep 'Band 1 max = '",paste0(inputdir, map1), paste0(inputdir, map1)), intern = TRUE)
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
names(df) <- c("id","total","forest","nonforest",'water','something','something2')
df$smforest <- 0
df$smnonforest <- 0
df$class  <- 0


out <- df[,c(1:5)]

length(unique(out$id))
head(out)
out$code<-0

# at least 2 forest pixels 
# FACET: Fp+Fs+Fm > 20%
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
# nbands <- 1
# nbands <- nbands(raster(classification))
# norm_eq <- paste0("echo ",nbands)
# 
# for(band in 1:nbands){
#   bstat <- 1
#   element <- paste0("echo \"#",band," ",r.map1.maxval, " / 100 *\"")
#   norm_eq <- paste0(norm_eq," ;",element)
# }
# 
# norm_eq <- paste0("(",norm_eq,")")
# 
# ## Apply  normalization equation
# system(sprintf(
#   "%s | oft-calc -ot Byte %s %s",
#   norm_eq,
#   im_input,
#   paste0(outdir,"/","tmp_norm.tif")
# ))
# max(out$code)
# system(sprintf('%s | oft-reclass -oi %s %s \n  %s \n 1 \n 1 \n %s \n 0 \n eof',
#                norm_eq,
#                paste0(segmentation_path,'tmp_',decisiontree_output_name, '.tif'),
#                paste0(segmentation_path,segmentation_layername, '.tif'),
#                paste0 ()output,
#                max(out$code)
# ))
# 
# system "  $outdir/$base\_tmp.tif $in_dir/$base\_clump.tif ";
# system "gdal_translate -ot Byte -co \"COMPRESS=LZW\" $outdir/$base\_tmp.tif $outdir/$base\_filtered.tif";
# system "rm $outdir/$base\_tmp.tif";

