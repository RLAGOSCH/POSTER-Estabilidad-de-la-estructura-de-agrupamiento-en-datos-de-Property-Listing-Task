# fknn_overlap ----------------------------------------------------------------
# Índice de Jaccard entre los k vecinos más cercanos de cada concepto en la
# referencia y en la réplica.
#
# D_ref, D_rep : matrices cuadradas de distancia (cofenética) con nombres.
# k            : número de vecinos.
#
# Devuelve un vector nombrado con un Jaccard por concepto (0 a 1).
# La réplica se reordena según la referencia para comparar por nombre.

fknn_overlap <- function(D_ref, D_rep, k = 4){

  labs  <- rownames(D_ref)
  D_rep <- D_rep[labs, labs]

  vJ <- sapply(labs, function(v) {
    nn_ref <- names(sort(D_ref[v, labs != v])[1:k])
    nn_rep <- names(sort(D_rep[v, labs != v])[1:k])
    length(intersect(nn_ref, nn_rep)) / length(union(nn_ref, nn_rep))
  })

  return(vJ)
}
