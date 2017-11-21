####################################################################################################
####################################################################################################
## LOCAL PARAMETERS FOR THE PROCESS
####################################################################################################
####################################################################################################

### LOCATION AND NAME OF SUPERVISED CLASSIFICATION
downclassdir <- paste0(rootdir,"downloads/ethiopia_2016_classification/")
classif_name <- "ethiopia_2016_classification.tif"


### LOCATION AND NAME OF SATELLITE MOSAIC FOR SEGMENTATION
downmosaidir <- paste0(rootdir,"downloads/ethiopia_2016_RNIRSWIR12/")
mosaic_name  <- "ethiopia_2016_RNIRSWIR12.tif"

### TREE COVER THRESHOLD FOR GRC PRODUCT
gfc_threshold <- 20

### CREATE A PSEUDO COLOR TABLE
# my_classes <- c(11,12,13,21,22,23,24,25,26,31,32,33,41,42,43,44,45,51,61,62,63)
# my_colors  <- col2rgb(c("brown","yellow","yellow", # agriculture 
#                         "lightgreen","lightgreen","purple","darkgreen","purple2","green", # forest
#                         "orange","green1","green2", # grassland
#                         "paleturquoise2","paleturquoise3","darkblue","darkblue","grey", # wetland
#                         "darkred", # urban
#                         "grey1","grey2","grey3" # other
# ))
#colors()