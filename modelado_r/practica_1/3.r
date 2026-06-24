# Enunciado:
# Una mano de poker tiene 5 cartas de una baraja de 52 (4 ases).
# 1) Calcular por combinatoria la probabilidad de no tener ases y dar valor numerico.
# 2) Si X es el numero de ases, reconocer su distribucion y calcular P(X = x) para x=0..4.
# 3) Simular varias manos con sample y contar ases (tomando 1,2,3,4 como ases).
# 4) Simular m = 100000 manos para aproximar la distribucion de X y comparar con la exacta.
#
# Ejercicio 3 - Mano de poker y numero de ases

# Punto 1: probabilidad de no obtener ases por combinatoria.
p_sin_ases <- choose(48, 5) / choose(52, 5) # Elijo 5 de las 48 no ases sobre total de manos.
p_sin_ases # Muestro probabilidad exacta.
round(p_sin_ases, 5) # Muestro probabilidad redondeada a cinco decimales.

# Punto 2: distribucion de X = numero de ases en una mano de 5 cartas.
x <- 0:4 # Valores posibles de cantidad de ases.
px <- dhyper(x, m = 4, n = 48, k = 5) # Hipergeometrica: exitos=4, fracasos=48, extracciones=5.
data.frame(x = x, P_X_igual_x = px) # Tabla de probabilidades exactas.
sum(px) # Verifico que la suma total sea 1.

# Punto 3: simulacion de algunas manos y conteo de ases.
set.seed(20) # Fijo semilla para reproducibilidad.

mano1 <- sample(1:52, 5) # Simulo primera mano.
sum(mano1 %in% 1:4) # Cuento ases (ids 1,2,3,4).

mano2 <- sample(1:52, 5) # Simulo segunda mano.
sum(mano2 %in% 1:4) # Cuento ases de la segunda mano.

mano3 <- sample(1:52, 5) # Simulo tercera mano.
sum(mano3 %in% 1:4) # Cuento ases de la tercera mano.

# Punto 4: simulacion masiva para aproximar la distribucion.
m <- 100000 # Defino cantidad de manos simuladas.
x_sim <- numeric(m) # Reservo vector para cantidad de ases por mano.

for (i in 1:m) { # Recorro todas las simulaciones.
  mano <- sample(1:52, 5) # Extraigo una mano sin reemplazo.
  x_sim[i] <- sum(mano %in% 1:4) # Guardo cantidad de ases de esa mano.
}

dist_sim <- table(x_sim) / m # Distribucion aproximada por frecuencia relativa.
dist_sim # Muestro distribucion simulada.
data.frame(x = x, exacta = px, simulada = as.numeric(dist_sim[as.character(x)])) # Comparacion.

# Explicacion general:
# El numero de ases en una mano de poker sigue una distribucion hipergeometrica.
# Se puede calcular exactamente con combinatoria y dhyper(), y tambien aproximar
# por simulacion Monte Carlo con sample(). Con m grande, la distribucion simulada
# se acerca mucho a la exacta, validando el modelo probabilistico.
