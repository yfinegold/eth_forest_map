###   ###   ###   ###   ###   ###   ###   ###   ###   ###   ###   ###   ###   ###   
## script to run random forest classification for land cover classification
# # USER INPUTS
# # input file directory and file name
# inputdir <- '~/SARtraining/Multisensor_new/'
# inputstack <- "lsat_srtm.vrt"
# 
# # output file directory and file name
# outdir <- "~/ethiopia/forestmapping/"
# outfinal <- 'f_nf_2016_v0.tif'
# 
# # training data file directory and file name without extension
# training_dir <- '~/ethiopia/forestmapping'
# # name of shapefile
# trainingdata <- "training_data_workshop_nov2017_25mbuffer"
# # column name in trainingdata with classification codes
# column <- "recode"


###   ###   ###   ###   ###   ###   ###   ###   ###   ###   ###   ###   ###   ###   ###   
###   THE SCRIPT RUNS FROM HERE
###   ###   ###   ###   ###   ###   ###   ###   ###   ###   ###   ###   ###   ###   ###   

# run classification
system(sprintf("python %s -r %s -v %s -f %s -o %s",
               paste0(scriptdir,'s3_classification/lc_rf_class.py'),
               paste0(inputdir,inputstack),
               paste0(training_dir, '/',trainingdata, '.shp'),
               column,
               paste0(outdir,'tmp_',outfinal)
))

#compress output
system(sprintf("gdal_translate -co COMPRESS=LZW -ot Byte %s %s",
               paste0(outdir,'tmp_',outfinal),
               paste0(outdir,outfinal)
))

# remove tmp files
system(sprintf("rm %s",
               paste0(outdir,'tmp_',outfinal)
))