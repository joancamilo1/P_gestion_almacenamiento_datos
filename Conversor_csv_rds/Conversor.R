
library(devtools)
#En primera instancia declaramos el path en donde vamos a trabajar
mypath <- dirname(rstudioapi::getActiveDocumentContext()$path) 
setwd(mypath)
#se pide un numero de datos (
#en caso tal de que se quieran extraer mas o menos datos de los archivos)
ndatos= 10000

#Extraemos los archivos que tengan la extension .csv con pattern 
# y declaramos en nrows con la cantidad de datos solicitada anteriormente
files <- list.files(mypath, pattern='*.csv', full.names = F, recursive = TRUE)

# inicializamos la cantidad de iteraciones 
# una iteraccion equivale a un archivo transformado en .rds
cantidad_docs <- length(files)

#ciclo for donde se hara el cambio de formato de cada archivo

for (i in 1:cantidad_docs) {
    
    #leemos el csv y tomamos el numero de datos
    doc1<- read.csv(file = files[i], encoding = "UTF-8", sep = ";", fill = T, 
                    header = T,nrows = ndatos)
    
    #Extraemos los archivos sin extension y se lo asignamos a una nueva variable
    archivosinextencion <- tools::file_path_sans_ext(files[i]) 
    
    # archivo sin extension en cada iteraccion  
    #(se puede poner directo en el paste0 para acortar lineas extra, 
    #pero se deja por separado para tener un mayor orden)
    doc <- archivosinextencion  
    
    # se declara el formato y se concatena
    formato <- "rds"                 
    doc_rds = paste0(doc, ".", formato)
   
    #finalmente se procede a guardar los archivos en cada iteraccion
    saveRDS(doc1, file = paste0(mypath, "/", doc_rds))
}