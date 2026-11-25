# flstMTtoListLFreqAbs --------------------------------------------------------
# Convierte una lista de matrices individuales (propiedades x participantes)
# en una lista de vectores de frecuencia absoluta por propiedad.
#
# lstMt : lista nombrada por concepto.
# Devuelve una lista nombrada de vectores con nombres de propiedad.
#
# Nota: versión mínima para que el repositorio funcione de punta a punta.
# Si tu versión original difiere, reemplaza este archivo por ella.

flstMTtoListLFreqAbs <- function(lstMt){

  lstFreq <- lapply(lstMt, function(v) rowSums(v))

  return(lstFreq)
}
