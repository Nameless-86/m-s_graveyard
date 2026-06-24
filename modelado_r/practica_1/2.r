# Enunciado:
# 1) Ejecutar y explicar:
#    muestra = c(4, 47, 82, 21, 92); muestra <= 90; sum(muestra <= 90)
#    muestra[1:90]; muestra[muestra <= 90]; length(muestra[muestra <= 90])
#    as.numeric(muestra <= 90); y = numeric(5); y; y[1] = 10; y
#    w = c(1:5, 1:5, 1:10); mean(w); mean(w >= 5)
#    indicando que hace cada sentencia, que salida produce, largo y tipo de vector.
# 2) Proponer una alternativa para la segunda linea dentro del for del programa
#    de simulacion de chips, usando length en lugar de sum para contar chips buenos.
#
# Ejercicio 2 - Simulando muestras aleatorias (parte 2)

muestra <- c(4, 47, 82, 21, 92) # Creo vector numerico con 5 observaciones.
muestra <= 90 # Comparo elemento a elemento y obtengo vector logico.
sum(muestra <= 90) # Sumo TRUE como 1 para contar chips en buen estado.

muestra[1:90] # Pido posiciones 1 a 90; las posiciones fuera de rango dan NA.
muestra[muestra <= 90] # Filtro y me quedo solo con los elementos <= 90.
length(muestra[muestra <= 90]) # Cuento cuantos elementos pasaron el filtro.

as.numeric(muestra <= 90) # Convierto TRUE/FALSE en 1/0.
y <- numeric(5) # Inicializo vector numerico de largo 5 con ceros.
y # Muestro contenido inicial de y.
y[1] <- 10 # Modifico el primer elemento de y.
y # Muestro y actualizado.

w <- c(1:5, 1:5, 1:10) # Armo vector combinando tres secuencias.
mean(w) # Calculo promedio aritmetico de w.
mean(w >= 5) # Proporcion de elementos >= 5 (promedio de logicos).

# Alternativa con length en lugar de sum para el conteo dentro del for.
set.seed(10) # Fijo semilla para reproducir la simulacion.
B <- 10000 # Defino cantidad de repeticiones de Monte Carlo.
x <- numeric(B) # Reservo vector para guardar resultados.

for (i in 1:B) { # Recorro todas las repeticiones.
  m <- sample(1:100, 5) # Tomo una muestra aleatoria de 5 chips.
  x[i] <- length(m[m <= 90]) # Cuento "buenos" usando filtrado + length.
}

table(x) / B # Aproximo la distribucion del numero de chips en buen estado.
mean(x) # Estimo el valor esperado del numero de chips buenos.

# Explicacion general:
# El ejercicio refuerza operaciones basicas con vectores en R (comparar, filtrar,
# indexar, convertir tipos y resumir). Ademas, muestra que contar TRUE con sum()
# es equivalente a filtrar y medir largo con length(). En simulacion, ambas ideas
# producen el mismo resultado conceptual para contar exitos en cada muestra.