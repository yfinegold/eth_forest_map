####################################################################################
####### Object:  Run supervised classification           
####### Author:  yelena.finegold@fao.org                               
####### Update:  2017/11/20                                     
####################################################################################

# check for training data overlapping with no data
training <- read.csv(paste0(training_dir, 'training_combined/',trainingdata, '.csv'))
multistack <- stack(paste0(inputdir,inputstack))
multi_training <- extract(multistack,cbind(training$XCoordinate,training$YCoordinate))
all_multi <- cbind(training, multi_training)
new_DF <- all_multi[rowSums(is.na(all_multi)) > 0,]
all_multi_noNA <- all_multi[complete.cases(all_multi), ]
coordinates(all_multi_noNA) <- ~XCoordinate + YCoordinate 
crs(all_multi_noNA) <- CRS("+init=epsg:4326")
setwd( paste0(training_dir,"training_combined" ))
writeOGR(all_multi_noNA, dsn =paste0(trainingdata,'noNA.shp') , layer = trainingdata, driver = 'ESRI Shapefile')

# run classification
system(sprintf("python %s -r %s -v %s -f %s -o %s",
               paste0(scriptdir,'s3_classification/lc_rf_class.py'),
               paste0(inputdir,inputstack),
               paste0(training_dir, 'training_combined/',trainingdata, 'noNA.shp'),
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
