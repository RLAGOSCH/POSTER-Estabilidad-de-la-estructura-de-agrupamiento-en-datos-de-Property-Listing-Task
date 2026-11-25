# Datos

Los datos no se incluyen en el repositorio. Las normas CSLB (Centre for Speech, Language and the Brain) se descargan desde su sitio oficial, de acuerdo con sus condiciones de uso.

## Formato esperado

`data/raw/listMtICSLB_corregido.RDS` debe contener una lista de R:

- un elemento por concepto, con el nombre del concepto;
- cada elemento es una matriz binaria de propiedades (filas, con nombre) por participantes (columnas);
- un 1 indica que ese participante listó esa propiedad para ese concepto.

Las matrices se reconstruyen desde las listas individuales crudas y no desde las normas agregadas publicadas, porque estas últimas ya traen un filtro de frecuencia mínima.
