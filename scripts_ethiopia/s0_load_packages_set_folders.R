####################################################################################################
####################################################################################################
## SETUP ALL ENVIRONMENT, PACKAGES AND PARAMETERS
## Contact remi.dannunzio@fao.org 
## 2017/11/02
####################################################################################################
####################################################################################################
options(stringsAsFactors = FALSE)

#############################################################
### Load necessary packages
#install.packages("gfcanalysis")
library(gfcanalysis)
library(rgeos)
library(ggplot2)
library(rgdal)
library(dplyr)
library(stringr)

#############################################################
### WORK ENVIRONMENT 
setwd("~/")
rootdir     <- paste0(getwd(),"/")
clone_dir   <- paste0(rootdir,"eth_forest_map/")

datadir   <- paste0(clone_dir,"data/")
scriptdir <- paste0(clone_dir,"scripts_ethiopia/")

limit_dir <- paste0(datadir,"boundaries/")
class_dir <- paste0(datadir,"classification/")
mosaicdir <- paste0(datadir,"satellite_mosaic/")

esa_dir  <- paste0(datadir,"esa_data/")
gfc_dir  <- paste0(datadir,"gfc_data/")
seg_dir  <- paste0(datadir,"segments/")
res_dir  <- paste0(datadir,"results/")

esa <- paste0(esa_dir,"esa_cci_eth.tif")
gtc <- paste0(gfc_dir,"gfc_eth_treecover2000.tif")
gly <- paste0(gfc_dir,"gfc_eth_lossyear.tif")
ggn <- paste0(gfc_dir,"gfc_eth_gain.tif")

dir.create(datadir,showWarnings = F)
dir.create(limit_dir,showWarnings = F)
dir.create(class_dir,showWarnings = F)
dir.create(mosaicdir,showWarnings = F)
dir.create(esa_dir,showWarnings = F)
dir.create(gfc_dir,showWarnings = F)
dir.create(seg_dir,showWarnings = F)
dir.create(res_dir,showWarnings = F)
