# fSimula_stability -----------------------------------------------------------
# Corre B réplicas bootstrap para cada valor de T_grid, en paralelo.
#
# T_grid  : vector de tamaños muestrales simulados.
# B       : réplicas por nivel de T.
# lstMtI  : lista de matrices individuales por concepto.
# mtCoph  : matriz cofenética de referencia.
# k       : número de vecinos.
# n_cores : núcleos para mclapply (fork; funciona en Mac y Linux, no en Windows).
#
# Devuelve un data.frame largo con columnas B, T_sim, concepto y J
# (una fila por réplica y concepto).
#
# Reproducibilidad: el script que llama a esta función debe fijar
# RNGkind("L'Ecuyer-CMRG") y set.seed() antes de ejecutarla.

fSimula_stability <- function(T_grid, B, lstMtI, mtCoph, k = 4,
                              n_cores = max(1, parallel::detectCores() - 1)){

  dfGrid <- expand.grid(B = seq_len(B), T_sim = T_grid)
  dfGrid <- dfGrid[order(dfGrid$T_sim, dfGrid$B), ]

  vConceptos <- rownames(as.matrix(mtCoph))

  lstRes <- parallel::mclapply(seq_len(nrow(dfGrid)), function(v) {
    fJaccarT_sim(T_sim  = dfGrid$T_sim[v],
                 lstMtI = lstMtI,
                 mtCoph = mtCoph,
                 k      = k)
  }, mc.cores = n_cores, mc.set.seed = TRUE)

  # Si un proceso falla, mclapply devuelve un try-error: se reemplaza por NA
  lstRes <- lapply(lstRes, function(v) {
    if (inherits(v, "try-error") || length(v) != length(vConceptos)) {
      return(setNames(rep(NA_real_, length(vConceptos)), vConceptos))
    }
    v[vConceptos]
  })

  mtJ <- do.call(rbind, lstRes)

  dfSim <- data.frame(
    B        = rep(dfGrid$B,     times = ncol(mtJ)),
    T_sim    = rep(dfGrid$T_sim, times = ncol(mtJ)),
    concepto = rep(vConceptos,   each  = nrow(mtJ)),
    J        = as.vector(mtJ),
    stringsAsFactors = FALSE
  )

  return(dfSim)
}
