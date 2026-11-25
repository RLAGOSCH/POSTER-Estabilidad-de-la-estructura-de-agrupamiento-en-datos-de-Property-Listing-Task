# fJaccarT_sim ----------------------------------------------------------------
# Una réplica de la simulación para un tamaño muestral T_sim.
#
# Pasos: remuestreo por concepto -> frecuencias -> W -> similitud coseno ->
# distancia (1 - coseno) -> clustering jerárquico de enlace promedio ->
# matriz cofenética -> Jaccard de k vecinos contra la referencia.
#
# T_sim  : participantes por concepto en la réplica.
# lstMtI : lista de matrices individuales (propiedades x participantes).
# mtCoph : matriz cofenética de referencia (30 participantes, sin remuestreo).
# k      : número de vecinos.
#
# Devuelve un vector nombrado con un Jaccard por concepto.
# Si algún concepto queda vacío o las etiquetas no coinciden, devuelve NA
# para todos los conceptos (la réplica se descarta, pero la simulación sigue).
#
# Las funciones auxiliares y lsa se cargan fuera, una sola vez.

fJaccarT_sim <- function(T_sim, lstMtI, mtCoph, k = 4){

  mtCoph   <- as.matrix(mtCoph)
  vNA      <- setNames(rep(NA_real_, nrow(mtCoph)), rownames(mtCoph))

  lstMt_Rep <- lapply(lstMtI, FUN = fResample_rep, T_sim = T_sim)

  if (any(sapply(lstMt_Rep, is.null))) {
    return(vNA)
  }

  lstFreq_Rep <- flstMTtoListLFreqAbs(lstMt_Rep)
  mtW_rep     <- flstFreqToMtW(lstFreq = lstFreq_Rep)
  mtCosi_rep  <- lsa::cosine(mtW_rep)
  mtDis_rep   <- as.dist(1 - mtCosi_rep)
  hc_rep      <- hclust(mtDis_rep, method = "average")
  mtCoph_rep  <- as.matrix(cophenetic(hc_rep))

  if (!setequal(rownames(mtCoph), rownames(mtCoph_rep))) {
    return(vNA)
  }

  vJ <- fknn_overlap(mtCoph, mtCoph_rep, k = k)

  return(vJ)
}
