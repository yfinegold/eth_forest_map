####################################################################################
####### Object:  merge and buffer training points            
####### Author:  yelena.finegold@fao.org                               
####### Update:  2017/11/20                                     
####################################################################################


# read directory with training data files, merge the files in this directory
# loop through all the folders and write the file names into the list
files  <- list.files(path=training_dir,pattern = '\\.csv')
tables <- lapply(paste0(training_dir,files), read.csv, header = TRUE)
# to implement- check if the csv inputs have the same number of columns
combined.df <- do.call(rbind , tables)
# convert the csv to a spatialpointdataframe
coordinates(combined.df) <- ~XCoordinate+YCoordinate
# add projection information
crs(combined.df) <- crs(raster(paste0(inputdir,inputstack)))

# reproject into UTM
?spTransform
trainingutm <- spTransform(combined.df, CRS("+init=epsg:32637")) # code for UTM 37N
# add 25m buffer around the points
?gBuffer
trainingutmBuffer <- gBuffer(trainingutm, width=25)
plot(trainingutmBuffer)
trainingdata_combined <- spTransform(combined.df, CRS("+init=epsg:4326")) # code for latlong
dir.create(paste0(training_dir,'training_combined'))
dsnshp <- paste0(training_dir,"training_combined" )
setwd( paste0(training_dir,"training_combined" ))
writeOGR(trainingdata_combined, dsn =paste0(trainingdata,'.shp') , layer = trainingdata, driver = 'ESRI Shapefile')
?writeOGR
