# 02_simulacion.R -------------------------------------------------------------
# Simulación bootstrap: B réplicas para cada T en T_grid.
# En cada réplica se calcula el Jaccard de k vecinos de cada concepto
# contra la referencia fija.
#
# Entrada : data/raw/listMtICSLB_corregido.RDS
#           output/referencia/mtCoph_ref.rds  (correr antes 01_referencia.R)
# Salida  : output/simulacion/dfSim.rds         (B x T x concepto, formato largo)
#           output/simulacion/info_corrida.txt  (parámetros, tiempo y sesión)

source(file.path("scripts", "00_config.R"))

lstMtI     <- readRDS(ruta_datos)
mtCoph_ref <- readRDS(file.path(ruta_referencia, "mtCoph_ref.rds"))

# Semilla compatible con procesos paralelos (mclapply)
RNGkind("L'Ecuyer-CMRG")
set.seed(semilla)

# Prueba corta para estimar el tiempo total -----------------------------------
B_prueba <- 20
t0 <- Sys.time()
invisible(fSimula_stability(T_grid = max(T_grid), B = B_prueba,
                            lstMtI = lstMtI, mtCoph = mtCoph_ref,
                            k = k, n_cores = n_cores))
seg_por_replica <- as.numeric(difftime(Sys.time(), t0, units = "secs")) / B_prueba
cat("Tiempo estimado:",
    round(seg_por_replica * B * length(T_grid) / 60, 1), "minutos\n")

# Corrida completa ------------------------------------------------------------
set.seed(semilla)
t0 <- Sys.time()

dfSim <- fSimula_stability(T_grid = T_grid, B = B,
                           lstMtI = lstMtI, mtCoph = mtCoph_ref,
                           k = k, n_cores = n_cores)

duracion <- difftime(Sys.time(), t0, units = "mins")
cat("Duración:", round(as.numeric(duracion), 1), "minutos\n")

saveRDS(dfSim, file.path(ruta_sim, "dfSim.rds"))

# Registro de la corrida ------------------------------------------------------
sink(file.path(ruta_sim, "info_corrida.txt"))
cat("Fecha:", format(Sys.time()), "\n")
cat("T_grid:", T_grid, "\n")
cat("B:", B, "\n")
cat("k:", k, "\n")
cat("Semilla:", semilla, "(RNG L'Ecuyer-CMRG)\n")
cat("Núcleos:", n_cores, "\n")
cat("Duración (min):", round(as.numeric(duracion), 1), "\n\n")
print(sessionInfo())
sink()
