####################################################################################################
####################################################################################################
## Use a decision tree to integrate raster values inside segments
## Contact remi.dannunzio@fao.org 
## 2017/11/02
####################################################################################################
####################################################################################################
time_start <- Sys.time() 

#################### CALL SUPERVISED CLASSIFICATION
spc <- paste0(class_dir,classif_name)

####################################################################################################
#################### OPTION 1: MAJORITY RULE OF SCP
####################################################################################################

#################### ALIGN SUPERVISED CLASSIFICATION MAP WITH SEGMENTS
mask   <- paste0(seg_dir,"segs_mmu_id.tif")
input  <- spc
ouput  <- paste0(seg_dir,"tmp_spc_clip.tif")

proj   <- proj4string(raster(mask))
extent <- extent(raster(mask))
res    <- res(raster(mask))[1]

system(sprintf("gdalwarp -co COMPRESS=LZW -t_srs \"%s\" -te %s %s %s %s -tr %s %s %s %s -overwrite",
               proj4string(raster(mask)),
               extent(raster(mask))@xmin,
               extent(raster(mask))@ymin,
               extent(raster(mask))@xmax,
               extent(raster(mask))@ymax,
               res(raster(mask))[1],
               res(raster(mask))[2],
               input,
               ouput
))

#################### TAKE MAJORITY CLASS PER POLYGON
system(sprintf("bash oft-segmode.bash %s %s %s",
               paste0(seg_dir,"segs_mmu_id.tif"),
               paste0(seg_dir,"tmp_spc_clip.tif"),
               paste0(seg_dir,"tmp_spc_segmode.tif")
))


#################### CREATE COLOR TABLE
pct <- data.frame(cbind(my_classes,
                        my_colors[1,],
                        my_colors[2,],
                        my_colors[3,]))

write.table(pct,paste0(seg_dir,"/color_table.txt"),row.names = F,col.names = F,quote = F)

################################################################################
## Add pseudo color table to result
system(sprintf("(echo %s) | oft-addpct.py %s %s",
               paste0(seg_dir,"/color_table.txt"),
               paste0(seg_dir,"tmp_spc_segmode.tif"),
               paste0(seg_dir,"tmp_pct_spc_segmode.tif")
))

#################### COMPRESS
system(sprintf("gdal_translate -ot Byte -co COMPRESS=LZW %s %s",
               paste0(seg_dir,"tmp_pct_spc_segmode.tif"),
               paste0(res_dir,"spc_segmode.tif")
))


####################################################################################################
#################### OPTION 2: DECISION TREE 
####################################################################################################

#################### ZONAL FOR SPC MAP
system(sprintf("oft-his -i %s -o %s -um %s -maxval %s",
               paste0(seg_dir,"tmp_spc_clip.tif"),
               paste0(seg_dir,"tmp_zonal_spc.txt"),
               paste0(seg_dir,"segs_mmu_id.tif"),
               max(my_classes)
))

#################### ALIGN ESA MAP WITH SEGMENTS
mask   <- paste0(seg_dir,"segs_mmu_id.tif")
input  <- esa
ouput  <- paste0(seg_dir,"tmp_esa_clip.tif")

proj   <- proj4string(raster(mask))
extent <- extent(raster(mask))
res    <- res(raster(mask))[1]

system(sprintf("gdalwarp -co COMPRESS=LZW -t_srs \"%s\" -te %s %s %s %s -tr %s %s %s %s -overwrite",
               proj4string(raster(mask)),
               extent(raster(mask))@xmin,
               extent(raster(mask))@ymin,
               extent(raster(mask))@xmax,
               extent(raster(mask))@ymax,
               res(raster(mask))[1],
               res(raster(mask))[2],
               input,
               ouput
))

#################### ZONAL FOR ESA MAP
system(sprintf("oft-his -i %s -o %s -um %s -maxval 10",
               paste0(seg_dir,"tmp_esa_clip.tif"),
               paste0(seg_dir,"tmp_zonal_esa.txt"),
               paste0(seg_dir,"segs_mmu_id.tif")
))

#################### CREATE GFC 2016 TREE COVER MAP
system(sprintf("gdal_calc.py -A %s -B %s -C %s --co COMPRESS=LZW --outfile=%s --calc=\"%s\"",
               gtc,
               gly,
               ggn,
               paste0(gfc_dir,"gfc_tc2016_th",gfc_threshold,".tif"),
               paste0("(A>",gfc_threshold,")*((B==0)+(C==1))*A")
))


#################### ALIGN GFC MAP WITH SEGMENTS
mask   <- paste0(seg_dir,"segs_mmu_id.tif")
input  <- paste0(gfc_dir,"gfc_tc2016_th",gfc_threshold,".tif")
ouput  <- paste0(seg_dir,"tmp_gfc_tc_clip.tif")

proj   <- proj4string(raster(mask))
extent <- extent(raster(mask))
res    <- res(raster(mask))[1]

system(sprintf("gdalwarp -co COMPRESS=LZW -t_srs \"%s\" -te %s %s %s %s -tr %s %s %s %s -overwrite",
               proj4string(raster(mask)),
               extent(raster(mask))@xmin,
               extent(raster(mask))@ymin,
               extent(raster(mask))@xmax,
               extent(raster(mask))@ymax,
               res(raster(mask))[1],
               res(raster(mask))[2],
               input,
               ouput
))

#################### ZONAL FOR GFC TREE COVER MAP
system(sprintf("oft-his -i %s -o %s -um %s -maxval 100",
               paste0(seg_dir,"tmp_gfc_tc_clip.tif"),
               paste0(seg_dir,"tmp_zonal_gfc_tc.txt"),
               paste0(seg_dir,"segs_mmu_id.tif")
))

#################### READ THE ZONAL STATS
df_spc <- read.table(paste0(seg_dir,"tmp_zonal_spc.txt"))
df_esa <- read.table(paste0(seg_dir,"tmp_zonal_esa.txt"))
df_gfc <- read.table(paste0(seg_dir,"tmp_zonal_gfc_tc.txt"))

names(df_spc)  <- c("clump_id","total","nospc",paste0("spc_",1:max(my_classes)))
names(df_gfc)  <- c("clump_id","total","nogfc",paste0("gfc_",1:100))
names(df_esa)  <- c("clump_id","total","noesa",paste0("esa_",1:10))

summary(df_esa$total - df_gfc$total)
missing <- names(df_spc[,colSums(df_spc)==0])
missing <- missing[missing %in% paste0("spc_",my_classes)]

df_spc <- df_spc[,colSums(df_spc)!=0]

df <- df_spc[,c("clump_id","total","nospc")]
head(df)
nrow(df)
df$out <- 0 
df[df_spc[,names(df_spc) %in% paste0("spc_",1)] > 0.3 * df$total,]$out <- 1
df[df_spc[,names(df_spc) %in% paste0("spc_",2)] > 0.1 * df$total,]$out <- 2
table(df$out)
write.table(df[,c("clump_id","total","out")],
            paste0(seg_dir,"reclass.txt"),row.names = F,col.names = F)



####### Reclassify 
system(sprintf("(echo %s; echo 1; echo 1; echo 3; echo 0) | oft-reclass  -oi %s  -um %s %s",
               paste0(seg_dir,"reclass.txt"),
               paste0(seg_dir,"tmp_reclass.tif"),
               paste0(seg_dir,"segs_mmu_id.tif"),
               paste0(seg_dir,"segs_mmu_id.tif")
))


#################### CONVERT TO BYTE
system(sprintf("gdal_translate -ot Byte -co COMPRESS=LZW %s %s",
               paste0(seg_dir,"tmp_reclass.tif"),
               paste0(res_dir,"decision_tree.tif")
))

time_decision_tree <- Sys.time() - time_start
