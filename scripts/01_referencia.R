# 01_referencia.R -------------------------------------------------------------
# Estructura de referencia fija: los 30 participantes originales de CSLB,
# sin remuestreo ni umbral de frecuencia.
#
# Entrada : data/raw/listMtICSLB_corregido.RDS
#           (lista nombrada por concepto; cada elemento es una matriz binaria
#            propiedades x participantes reconstruida desde las listas crudas)
# Salida  : output/referencia/mtW_ref.rds
#           output/referencia/hc_ref.rds
#           output/referencia/mtCoph_ref.rds

source(file.path("scripts", "00_config.R"))

lstMtI <- readRDS(ruta_datos)

# Chequeos básicos de los datos
stopifnot(is.list(lstMtI), !is.null(names(lstMtI)))
cat("Conceptos:", length(lstMtI), "\n")
cat("Participantes por concepto:\n")
print(table(sapply(lstMtI, function(v) ncol(v))))

# W, similitud coseno, clustering y matriz cofenética
lstFreq_ref <- flstMTtoListLFreqAbs(lstMtI)
mtW_ref     <- flstFreqToMtW(lstFreq = lstFreq_ref)
mtCosi_ref  <- lsa::cosine(mtW_ref)
mtDis_ref   <- as.dist(1 - mtCosi_ref)
hc_ref      <- hclust(mtDis_ref, method = "average")
mtCoph_ref  <- as.matrix(cophenetic(hc_ref))

cat("Dimensión de W (propiedades x conceptos):", dim(mtW_ref), "\n")

saveRDS(mtW_ref,    file.path(ruta_referencia, "mtW_ref.rds"))
saveRDS(hc_ref,     file.path(ruta_referencia, "hc_ref.rds"))
saveRDS(mtCoph_ref, file.path(ruta_referencia, "mtCoph_ref.rds"))
