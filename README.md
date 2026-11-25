# Estabilidad del clustering jerárquico en normas de propiedades conceptuales

Código del estudio de simulación sobre cómo el número de participantes por concepto (T) afecta la estabilidad de la estructura de agrupamiento que se obtiene a partir de datos de Property Listing Task (PLT).

Usamos el conjunto CSLB (638 conceptos, 30 participantes por concepto). Para cada T remuestreamos participantes con reemplazo, reconstruimos la matriz de similitud coseno y aplicamos clustering jerárquico con enlace promedio. La estabilidad se mide con el índice de Jaccard entre los k = 4 vecinos más cercanos de cada concepto en la réplica y en una referencia fija, construida con los 30 participantes originales.

## Estructura

```
estabilidad-clustering-plt/
├── README.md
├── LICENSE
├── .gitignore
├── estabilidad-clustering-plt.Rproj
├── R/                          funciones
│   ├── fResample_rep.R         remuestreo bootstrap de participantes
│   ├── flstMTtoListLFreqAbs.R  matrices individuales a frecuencias
│   ├── flstFreqToMtW.R         frecuencias a matriz W (propiedades x conceptos)
│   ├── fknn_overlap.R          Jaccard de k vecinos por concepto
│   ├── fJaccarT_sim.R          una réplica completa
│   └── fSimula_stability.R     todas las réplicas, en paralelo
├── scripts/                    se corren en orden
│   ├── 00_config.R             parámetros, rutas y paquetes
│   ├── 01_referencia.R         estructura de referencia (T = 30, sin remuestreo)
│   ├── 02_simulacion.R         simulación bootstrap
│   └── 03_descriptivo.R        tablas y figuras descriptivas
├── data/
│   ├── README.md               cómo obtener y preparar los datos
│   └── raw/                    datos de entrada (no se versionan)
└── output/                     se genera al correr los scripts
    ├── referencia/
    ├── simulacion/
    ├── tablas/
    └─ figuras/
```

## Cómo reproducirlo

1. Clona el repositorio y abre `estabilidad-clustering-plt.Rproj`. Todos los scripts asumen que la carpeta de trabajo es la raíz del proyecto.
2. Instala los paquetes:

   ```r
   install.packages(c("lsa", "dplyr", "tidyr", "ggplot2", "ggridges", "viridis"))
   ```

3. Deja los datos en `data/raw/listMtICSLB_corregido.RDS` (ver `data/README.md`).
4. Corre los scripts en orden:

   ```r
   source("scripts/01_referencia.R")
   source("scripts/02_simulacion.R")
   source("scripts/03_descriptivo.R")
   ```

Los parámetros (T, B, k, semilla y número de núcleos) se cambian en `scripts/00_config.R`.

La simulación usa `parallel::mclapply`, que funciona en Mac y Linux. En Windows corre en un solo núcleo, así que conviene dejar `n_cores <- 1` o correrla en otro sistema. Antes de la corrida completa, `02_simulacion.R` hace una prueba corta e imprime el tiempo estimado.

## Qué produce cada paso

`01_referencia.R` guarda la matriz W, el dendrograma y la matriz cofenetica de referencia.

`02_simulacion.R` guarda `dfSim.rds`, una tabla larga con una fila por réplica y concepto (columnas `B`, `T_sim`, `concepto`, `J`), y un archivo con los parámetros de la corrida y la información de la sesión de R.

`03_descriptivo.R` genera:

| Archivo | Contenido |
|---|---|
| `01_replicas_validas.csv` | réplicas descartadas por nivel de T |
| `02_resumen_global.csv` | media, mediana, Q1, Q3, % con J = 1, % con J = 0 y varianza entre conceptos, por T |
| `03_resumen_conceptos.csv` | los mismos indicadores para cada concepto y T |
| `04_resumen_entre_conceptos.csv` | mediana (Q1–Q3) entre conceptos de cada indicador, por T |
| `05_incrementos.csv` | cambio de cada indicador entre niveles sucesivos de T |
| `fig1_curva_estabilidad` | curva de estabilidad: mediana entre conceptos y banda Q1 a Q3 |
| `fig2_porcentaje_J1_J0` | % de réplicas con solapamiento perfecto y nulo |
| `fig3_ridge_conceptos` | distribución del Jaccard medio por concepto en cada T |

Las figuras se guardan en PNG (300 dpi) y PDF.


## Limitaciones

El remuestreo es independiente en cada concepto, porque en CSLB no se puede vincular a un mismo participante entre conceptos. Esto probablemente infla un poco la estabilidad estimada.


