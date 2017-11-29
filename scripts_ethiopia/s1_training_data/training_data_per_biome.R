######################################### 
## number of samples per class and biome
## updated 21/11/2017
## yelena.finegold@fao.org
######################################### 

### user parameters, works in SEPAL or windows, make sure to change these
# enter the file path for the training data
trainingdatafile <- '~/ethiopia/forestmapping/training_data_workshop_nov2017.csv'

# enter the folder of the biomes shapefile
biomesfolder <- '~/ethiopia/biomes/'

# enter the file name of the biomes shapefile
biomesfilename <- 'Biomes.shp' 

# where do you want to save the data? enter the folder
outputfolder <- '~/ethiopia/forestmapping/' 


######################################### 
### the script runs from here

# read the biomes data
# first set the working directory to the biomes folder
setwd(biomesfolder)
# then read the shapefile
biome <- readOGR('Biomes.shp')

# read the training data
trainingdatacsv <- read.csv(trainingdatafile)
# read the table as spatial information
coordinates(trainingdatacsv) <- ~XCoordinate+YCoordinate

setwd(outputfolder)
# check the CRS of the biomes data
crs(biome)
crs(trainingdatacsv) <- crs(biome)

# extract the biomes at each training data point
biomesover <- over(trainingdatacsv,biome)
trainingdatacsv2 <- cbind(as.data.frame(trainingdatacsv), biomesover)
# display the crosstable between the training data class and biome
table(trainingdatacsv2$recode, trainingdatacsv2$FRL_Catago)

# write the output to a CSV called'training_data_by_biomes.csv' in the output folder
write.csv(table(trainingdatacsv2$recode, trainingdatacsv2$FRL_Catago), file = paste0(outputfolder, 'training_data_by_biomes.csv'), row.names = T)

