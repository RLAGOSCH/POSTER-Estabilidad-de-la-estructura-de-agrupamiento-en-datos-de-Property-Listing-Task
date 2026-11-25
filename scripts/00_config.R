# 00_config.R -----------------------------------------------------------------
# Parámetros, rutas y carga de funciones. Lo llaman los demás scripts.
# Ejecutar siempre desde la raíz del repositorio (abrir el .Rproj).

# Parámetros del estudio ------------------------------------------------------
T_grid <- c(5, 10, 15, 20, 25, 30)   # participantes por concepto
B      <- 1000                       # réplicas bootstrap por nivel de T
k      <- 4                          # vecinos para el Jaccard
semilla <- 20260630
n_cores <- max(1, parallel::detectCores() - 1)

# Rutas -----------------------------------------------------------------------
ruta_datos      <- file.path("data", "raw", "listMtICSLB_corregido.RDS")
ruta_referencia <- file.path("output", "referencia")
ruta_sim        <- file.path("output", "simulacion")
ruta_tablas     <- file.path("output", "tablas")
ruta_figuras    <- file.path("output", "figuras")

for (v in c(ruta_referencia, ruta_sim, ruta_tablas, ruta_figuras)) {
  dir.create(v, recursive = TRUE, showWarnings = FALSE)
}

# Paquetes --------------------------------------------------------------------
paquetes <- c("lsa", "dplyr", "tidyr", "ggplot2", "ggridges", "viridis")
faltan   <- paquetes[!sapply(paquetes, function(v) requireNamespace(v, quietly = TRUE))]
if (length(faltan) > 0) {
  stop("Faltan paquetes: ", paste(faltan, collapse = ", "),
       ". Instálalos con install.packages().")
}

# Funciones -------------------------------------------------------------------
for (v in list.files("R", pattern = "\\.R$", full.names = TRUE)) {
  source(v)
}
