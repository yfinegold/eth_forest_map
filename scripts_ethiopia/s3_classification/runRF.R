####################################################################################
####### Object:  Run supervised classification           
####### Author:  yelena.finegold@fao.org                               
####### Update:  2017/11/20                                     
####################################################################################
# run classification
system(sprintf("python %s -r %s -v %s -f %s -o %s",
               paste0(scriptdir,'s3_classification/lc_rf_class.py'),
               paste0(inputdir,inputstack),
               paste0(training_dir, 'training_combined/',trainingdata, '.shp'),
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