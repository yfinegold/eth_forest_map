###   
## script to run random forest classification for land cover classification
# USER INPUTS
# input file directory and file name
inputdir <- '~/SARtraining/Multisensor_new/'
inputstack <- "lsat_srtm.vrt"

# output file directory and file name
outdir <- "~/ethiopia/forestmapping/"
outfinal <- 'f_nf_2016_v0.tif'

# training data file directory and file name without extension
training_dir <- '~/ethiopia/forestmapping'
# name of shapefile
trainingdata <- "training_data_workshop_nov2017_25mbuffer"
# column name in trainingdata with classification codes
column <- "recode"

# script directory for python script
py_scriptdir <- '~/eth_forest_map/scripts_ethiopia/s3_classification/' 


# ################
# # test a smaller area
# stack1 <- stack(inputstack)
# 
# # name of the output
# crop_output <- '~/SARtraining/Multisensor_new/lsat_srtm_stack_croptest.vrt'
# 
# # bounding box to clip the test area
# Xmin <- 40.1066
# Ymin <- 9.1685
# Xmax <- 40.9761
# Ymax <- 9.7344
# 
# system(sprintf("gdalwarp -te %s %s %s %s -tr %s %s -tap -co COMPRESS=LZW -ot Byte -overwrite %s %s",
#                Xmin,
#                Ymin,
#                Xmax,
#                Ymax,
#                res(stack1)[1],
#                res(stack1)[2],
#                inputstack,
#                crop_output
# ))
# 
# setwd(training_dir)
# shp <- readOGR(trainingdata)
# out <- crop(shp, extent(Xmin, Xmax, Ymin, Ymax))
# writeOGR(out, dsn=paste0(trainingdata, '_buffercrop.shp'), layer=paste0(trainingdata, '_buffercrop'),overwrite_layer = T,  driver='ESRI Shapefile')
# cropshp <-
# system(sprintf("python %s -r %s -v %s -f %s -o %s",
#                paste0(py_scriptdir,'lc_rf_class.py'),
#                crop_output,
#                cropshp,
#                column,
#                paste0(outdir,'tmp_',outfinal)
# ))