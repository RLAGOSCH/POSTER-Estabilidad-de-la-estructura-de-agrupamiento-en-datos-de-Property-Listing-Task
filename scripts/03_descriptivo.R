# 03_descriptivo.R ------------------------------------------------------------
# Análisis descriptivo de la simulación.
#
# Entrada : output/simulacion/dfSim.rds
# Salida  : output/tablas/
#             01_replicas_validas.csv     réplicas descartadas (NA) por T
#             02_resumen_global.csv       Jaccard global por T
#             03_resumen_conceptos.csv    resumen por concepto y T
#             04_resumen_entre_conceptos.csv  distribución entre conceptos por T
#             05_incrementos.csv          cambio entre niveles sucesivos de T
#           output/figuras/
#             fig1_curva_estabilidad      mediana entre conceptos e IQR
#             fig2_porcentaje_J1_J0       % réplicas con J = 1 y J = 0
#             fig3_ridge_conceptos        distribución de Jaccard medio por concepto

source(file.path("scripts", "00_config.R"))
library(dplyr)
library(tidyr)
library(ggplot2)
library(ggridges)

dfSim <- readRDS(file.path(ruta_sim, "dfSim.rds"))

tol <- 1e-9   # tolerancia para identificar J = 1 y J = 0

# 1. Réplicas válidas ---------------------------------------------------------
# Una réplica es inválida si algún concepto quedó vacío en el remuestreo.

dfValidas <- dfSim %>%
  distinct(T_sim, B, .keep_all = TRUE) %>%
  group_by(T_sim) %>%
  summarise(replicas       = n(),
            replicas_NA    = sum(is.na(J)),
            porcentaje_NA  = 100 * replicas_NA / replicas,
            .groups = "drop")

write.csv(dfValidas, file.path(ruta_tablas, "01_replicas_validas.csv"), row.names = FALSE)

dfSim <- dfSim %>% filter(!is.na(J))

# 2. Resumen global por T -----------------------------------------------------
# Todas las combinaciones réplica x concepto de cada nivel de T.

dfGlobal <- dfSim %>%
  group_by(T_sim) %>%
  summarise(n          = n(),
            media      = mean(J),
            mediana    = median(J),
            Q1         = quantile(J, 0.25),
            Q3         = quantile(J, 0.75),
            pct_J1     = 100 * mean(abs(J - 1) < tol),
            pct_J0     = 100 * mean(abs(J) < tol),
            .groups = "drop")

# 3. Resumen por concepto y T -------------------------------------------------

dfConceptos <- dfSim %>%
  group_by(concepto, T_sim) %>%
  summarise(media   = mean(J),
            mediana = median(J),
            Q1      = quantile(J, 0.25),
            Q3      = quantile(J, 0.75),
            IQR     = Q3 - Q1,
            pct_J1  = 100 * mean(abs(J - 1) < tol),
            pct_J0  = 100 * mean(abs(J) < tol),
            .groups = "drop")

write.csv(dfConceptos, file.path(ruta_tablas, "03_resumen_conceptos.csv"), row.names = FALSE)

# Varianza entre conceptos (de los Jaccard medios por concepto)
dfVarEntre <- dfConceptos %>%
  group_by(T_sim) %>%
  summarise(var_entre_conceptos = var(media), .groups = "drop")

dfGlobal <- dfGlobal %>% left_join(dfVarEntre, by = "T_sim")

write.csv(dfGlobal, file.path(ruta_tablas, "02_resumen_global.csv"), row.names = FALSE)

# 4. Distribución entre conceptos por T --------------------------------------
# Mediana (Q1 a Q3) entre los conceptos de cada indicador por concepto.

fMedIQR <- function(v, dig = 3){
  q <- quantile(v, c(0.25, 0.5, 0.75))
  sprintf(paste0("%.", dig, "f (%.", dig, "f–%.", dig, "f)"), q[2], q[1], q[3])
}

dfEntre <- dfConceptos %>%
  group_by(T_sim) %>%
  summarise(conceptos       = n(),
            mediana_J       = fMedIQR(mediana),
            media_J         = fMedIQR(media),
            IQR_J           = fMedIQR(IQR),
            pct_J1          = fMedIQR(pct_J1, dig = 1),
            pct_J0          = fMedIQR(pct_J0, dig = 1),
            .groups = "drop")

write.csv(dfEntre, file.path(ruta_tablas, "04_resumen_entre_conceptos.csv"), row.names = FALSE)

# 5. Incrementos entre niveles sucesivos de T --------------------------------

dfIncrementos <- dfGlobal %>%
  arrange(T_sim) %>%
  transmute(T_desde        = lag(T_sim),
            T_hasta        = T_sim,
            delta_media    = media - lag(media),
            delta_mediana  = mediana - lag(mediana),
            delta_pct_J1   = pct_J1 - lag(pct_J1),
            delta_pct_J0   = pct_J0 - lag(pct_J0)) %>%
  filter(!is.na(T_desde))

write.csv(dfIncrementos, file.path(ruta_tablas, "05_incrementos.csv"), row.names = FALSE)

print(dfGlobal)
print(dfIncrementos)

# Figuras ---------------------------------------------------------------------

tema <- theme_minimal(base_size = 13) +
  theme(panel.grid.minor = element_blank(),
        plot.background  = element_rect(fill = "white", colour = NA))

fGuardar <- function(p, nombre, ancho = 7, alto = 5){
  ggsave(file.path(ruta_figuras, paste0(nombre, ".png")), p,
         width = ancho, height = alto, dpi = 300)
  ggsave(file.path(ruta_figuras, paste0(nombre, ".pdf")), p,
         width = ancho, height = alto)
}

col_linea <- viridis::viridis(3, begin = 0.15, end = 0.85)

# Figura 1: curva de estabilidad.
# Línea: mediana entre conceptos del Jaccard medio por concepto.
# Banda: Q1 a Q3 entre conceptos.

dfCurva <- dfConceptos %>%
  group_by(T_sim) %>%
  summarise(mediana = median(media),
            Q1      = quantile(media, 0.25),
            Q3      = quantile(media, 0.75),
            .groups = "drop")

p1 <- ggplot(dfCurva, aes(x = T_sim, y = mediana)) +
  geom_ribbon(aes(ymin = Q1, ymax = Q3), fill = col_linea[2], alpha = 0.25) +
  geom_line(colour = col_linea[1], linewidth = 1) +
  geom_point(colour = col_linea[1], size = 2.5) +
  scale_x_continuous(breaks = T_grid) +
  scale_y_continuous(limits = c(0, 1)) +
  labs(x = "Participantes por concepto (T)",
       y = paste0("Jaccard medio por concepto (k = ", k, ")")) +
  tema

fGuardar(p1, "fig1_curva_estabilidad")

# Figura 2: porcentaje de réplicas con J = 1 y J = 0

dfPct <- dfGlobal %>%
  select(T_sim, pct_J1, pct_J0) %>%
  pivot_longer(-T_sim, names_to = "indicador", values_to = "porcentaje") %>%
  mutate(indicador = recode(indicador,
                            pct_J1 = "Solapamiento perfecto (J = 1)",
                            pct_J0 = "Solapamiento nulo (J = 0)"))

p2 <- ggplot(dfPct, aes(x = T_sim, y = porcentaje, colour = indicador)) +
  geom_line(linewidth = 1) +
  geom_point(size = 2.5) +
  scale_colour_manual(values = col_linea[c(1, 3)]) +
  scale_x_continuous(breaks = T_grid) +
  labs(x = "Participantes por concepto (T)",
       y = "% de réplicas", colour = NULL) +
  tema +
  theme(legend.position = "top")

fGuardar(p2, "fig2_porcentaje_J1_J0")

# Figura 3: distribución entre conceptos del Jaccard medio, por T

p3 <- ggplot(dfConceptos, aes(x = media, y = factor(T_sim), fill = after_stat(x))) +
  geom_density_ridges_gradient(scale = 1.6, rel_min_height = 0.005,
                               colour = "white", linewidth = 0.3) +
  scale_fill_viridis_c(option = "viridis", begin = 0.1, end = 0.95,
                       limits = c(0, 1), guide = "none") +
  scale_x_continuous(limits = c(0, 1)) +
  labs(x = paste0("Jaccard medio por concepto (k = ", k, ")"),
       y = "Participantes por concepto (T)") +
  tema

fGuardar(p3, "fig3_ridge_conceptos", alto = 6)
