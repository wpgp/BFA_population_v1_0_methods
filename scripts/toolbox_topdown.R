library(sf); library(dplyr); library(raster); library(data.table)
library(dtplyr); library(tictoc); library(tmap); library(stringr)
library(tidyverse); library(spatialEco); library(fasterize)

drive_path <-  "//worldpop.files.soton.ac.uk/worldpop/Projects/WP517763_GRID3/"
if(.Platform$OS.type == "unix"){
  drive_path <- "/Volumes/worldpop/Projects/WP517763_GRID3/"
}
if (exists("iridis")) {
  if (iridis==T) {
    drive_path <- "/home/ecd1u18/WorldpopDrive/"
  }
} 

raster_path <-  paste0(drive_path, "Raster/BFA/")
table_path <-   paste0(drive_path, "Table/BFA/")
vector_path <- paste0(drive_path, "Vector/BFA/")
output_path <- paste0(drive_path, "DataIn/BFA/")
working_path <- paste0(drive_path, "Working/BFA/model")

removeAccent <- function(input){
  unwanted_array <- list('Š'='S', 'š'='s', 'Ž'='Z', 'ž'='z', 'À'='A', 'Á'='A', 'Â'='A', 'Ã'='A', 'Ä'='A', 'Å'='A', 'Æ'='A', 'Ç'='C', 'È'='E', 'É'='E',
                         'Ê'='E', 'Ë'='E', 'Ì'='I', 'Í'='I', 'Î'='I', 'Ï'='I', 'Ñ'='N', 'Ò'='O', 'Ó'='O', 'Ô'='O', 'Õ'='O', 'Ö'='O', 'Ø'='O', 'Ù'='U',
                         'Ú'='U', 'Û'='U', 'Ü'='U', 'Ý'='Y', 'Þ'='B', 'ß'='Ss', 'à'='a', 'á'='a', 'â'='a', 'ã'='a', 'ä'='a', 'å'='a', 'æ'='a', 'ç'='c',
                         'è'='e', 'é'='e', 'ê'='e', 'ë'='e', 'ì'='i', 'í'='i', 'î'='i', 'ï'='i', 'ð'='o', 'ñ'='n', 'ò'='o', 'ó'='o', 'ô'='o', 'õ'='o',
                         'ö'='o', 'ø'='o', 'ù'='u', 'ú'='u', 'û'='u', 'ý'='y', 'ý'='y', 'þ'='b', 'ÿ'='y')
  output <- chartr(paste(names(unwanted_array), collapse=''),
                   paste(unwanted_array, collapse=''),
                   input)
  return(output)
}


computeRaster <- function(x, bfa_settled_id=bfa_settled_id){
  rst <- raster(x)
  name <- names(rst)
  print(name)
  print(paste("Right resolution:", all(res(rst)==res(masterGrid))))
  print(paste("Right dimension:", all(dim(rst)==dim(masterGrid))))
  print(paste("Right crs:", all(crs(rst)@projargs==crs(masterGrid)@projargs)))
  if(!all(res(rst)==res(masterGrid))){
    rst <- resample(rst, masterGrid)
  }
  if(grepl("travelTime|frictionSurface|worldpop", name)){
    print("fill NA")
    size <- 15
  rst <- focal(rst, w=matrix(1,size,size), fun=mean,na.rm=T, NAonly=T)
  }
  if(grepl("cv|sd", name)){
    print("fill 0")
   rst[is.na(rst)] <- 0
  }
  
  rst_df <- data.table(rst[])[bfa_settled_id,]
  colnames(rst_df) <- name
  return(rst_df)
}


extractCov <- function(rst, bfa_settled_id){
  print(names(rst))
  rst_df <- data.table(rst[])[bfa_settled_id,]
  colnames(rst_df) <- names(rst)
  return(rst_df)
}
