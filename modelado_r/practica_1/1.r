# Enunciado:
# Tomando como base el ejemplo de muestreo de chips:
# 1) Ejecutar set.seed(1) y sample(1:100, 5) cinco veces.
# 2) Ejecutar set.seed(1) y luego sum(sample(1:100, 5) <= 90) cinco veces.
# 3) Decidir cuales muestras no podrian salir de sample(1:90, 5) y justificar.
# 4) Ejecutar:
#    chips = rep(c("bien", "fallados"), times = c(90, 10))
#    set.seed(3)
#    muestra = sample(chips, 5)
#    muestra == "bien"
#    sum(muestra == "bien")
#    y analizar ventajas/desventajas del modelado.
#
# Ejercicio 1 - Simulando muestras aleatorias (parte 1)

set.seed(1) # Fijo semilla para que el experimento sea reproducible.

sample(1:100, 5) # Muestra 1 de 5 chips (ids entre 1 y 100, sin reemplazo).
sample(1:100, 5) # Muestra 2.
sample(1:100, 5) # Muestra 3.
sample(1:100, 5) # Muestra 4.
sample(1:100, 5) # Muestra 5.

set.seed(1) # Reinicio la semilla para repetir el mismo flujo aleatorio.

sum(sample(1:100, 5) <= 90) # Cantidad de chips en buen estado en muestra 1.
sum(sample(1:100, 5) <= 90) # Cantidad de chips en buen estado en muestra 2.
sum(sample(1:100, 5) <= 90) # Cantidad de chips en buen estado en muestra 3.
sum(sample(1:100, 5) <= 90) # Cantidad de chips en buen estado en muestra 4.
sum(sample(1:100, 5) <= 90) # Cantidad de chips en buen estado en muestra 5.

# Punto 3: muestras que NO pueden salir de sample(1:90, 5).
c(2, 62, 84, 68, 60) # Posible: todos los valores estan en 1:90 y no se repiten.
c(46, 39, 84, 16, 39) # Imposible: el 39 se repite y sample por defecto no reemplaza.
c(43, 20, 79, 32, 84) # Posible: todos en 1:90 y sin repetidos.
c(68, 2, 98, 20, 50) # Imposible: aparece 98 y no pertenece al rango 1:90.

chips <- rep(c("bien", "fallados"), times = c(90, 10)) # Creo poblacion explicita de estados.
set.seed(3) # Fijo semilla para esta segunda forma de modelar.
muestra <- sample(chips, 5) # Tomo 5 chips desde etiquetas textuales.
muestra == "bien" # Marco con TRUE/FALSE cuales estan en buen estado.
sum(muestra == "bien") # Cuento cuantos "bien" hay en la muestra.

# Explicacion general:
# Este ejercicio muestra dos maneras equivalentes de modelar el muestreo de chips:
# (1) usando ids numericos y condicion <= 90, y (2) usando etiquetas "bien"/"fallados".
# La semilla permite reproducibilidad, sample toma sin reemplazo por defecto,
# y la cantidad de chips en buen estado se calcula con una suma de valores logicos.
