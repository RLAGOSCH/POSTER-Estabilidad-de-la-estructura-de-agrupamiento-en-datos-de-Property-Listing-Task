# flstFreqToMtW ---------------------------------------------------------------
# Construye la matriz W (propiedades x conceptos) a partir de una lista de
# vectores de frecuencia. Las propiedades ausentes en un concepto quedan en 0.
# No se aplica ningún umbral de frecuencia.
#
# lstFreq : lista nombrada por concepto, cada elemento con nombres de propiedad.
# Devuelve una matriz con conceptos en columnas, lista para lsa::cosine().
#
# Nota: versión mínima para que el repositorio funcione de punta a punta.
# Si tu versión original difiere, reemplaza este archivo por ella.

flstFreqToMtW <- function(lstFreq){

  vProp <- sort(unique(unlist(lapply(lstFreq, function(v) names(v)))))

  mtW <- matrix(0,
                nrow = length(vProp),
                ncol = length(lstFreq),
                dimnames = list(vProp, names(lstFreq)))

  for (concepto in names(lstFreq)) {
    vFreq <- lstFreq[[concepto]]
    mtW[names(vFreq), concepto] <- vFreq
  }

  return(mtW)
}
