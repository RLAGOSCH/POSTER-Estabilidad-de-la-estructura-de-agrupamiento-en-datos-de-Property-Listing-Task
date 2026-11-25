# fResample_rep ---------------------------------------------------------------
# Remuestreo bootstrap de participantes para un concepto.
#
# mtI   : matriz binaria propiedades x participantes de un concepto.
# T_sim : número de participantes a remuestrear (con reemplazo).
#
# Devuelve la matriz remuestreada sin las propiedades que quedaron en cero.
# Si ninguna propiedad sobrevive, devuelve NULL.
# drop = FALSE evita que una matriz de una sola fila se convierta en vector.

fResample_rep <- function(mtI, T_sim){

  T_pob <- ncol(mtI)
  mtSample <- mtI[, sample(x = seq_len(T_pob), size = T_sim, replace = TRUE), drop = FALSE]
  mtSample <- mtSample[rowSums(mtSample) > 0, , drop = FALSE]

  if (nrow(mtSample) == 0) {
    return(NULL)
  }

  return(mtSample)
}
