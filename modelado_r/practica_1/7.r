# Enunciado:
# Se usa el modelo no uniforme:
# p = c(rep(3, 65), rep(1, 300), 1/4),
# donde 65 dias de "pleno verano" tienen tasa triple.
# 1) Calcular la probabilidad total de nacer en un dia de pleno verano.
# 2) Para n = 25, estimar por simulacion p25 = P(X >= 1) y E(X),
#    donde X es el numero de coincidencias de cumpleanos.
# 3) Generalizar por simulacion y hallar min{n : pn >= 1/2}.
#
# Ejercicio 7 - Cumpleanos con nacimientos no uniformes (parte 2)

p <- c(rep(3, 65), rep(1, 300), 1 / 4) # Defino frecuencias relativas con "pleno verano".
sum(p) # Verifico suma total de pesos.

prob_pleno_verano_total <- sum(p[1:65]) / sum(p) # Probabilidad total de nacer en los 65 dias de verano.
prob_pleno_verano_total # Muestro resultado del punto 1.

set.seed(60) # Fijo semilla.
B <- 100000 # Numero de simulaciones para n = 25.
n <- 25 # Tamano del grupo.
x <- numeric(B) # Guardo cantidad de coincidencias por simulacion.

for (i in 1:B) { # Recorro simulaciones para n fijo.
  m <- sample(1:366, n, replace = TRUE, prob = p) # Genero cumpleanos con distribucion no uniforme.
  x[i] <- sum(duplicated(m)) # Cuento coincidencias.
}

p25 <- mean(x >= 1) # Estimacion de P(X >= 1) para n = 25.
ex <- mean(x) # Estimacion de E(X) para n = 25.
p25 # Muestro probabilidad estimada de al menos una coincidencia.
ex # Muestro valor esperado estimado de coincidencias.

# Punto 3: hallar min{n : pn >= 1/2} por simulacion.
ns <- 2:80 # Rango de tamanos de grupo a evaluar.
pn_sim <- numeric(length(ns)) # Guardo probabilidad estimada para cada n.

for (j in seq_along(ns)) { # Recorro cada tamano de grupo.
  n_j <- ns[j] # Tomo tamano actual.
  hubo_coincidencia <- logical(B) # Registro si hubo al menos una coincidencia.

  for (i in 1:B) { # Simulo B grupos de tamano n_j.
    m <- sample(1:366, n_j, replace = TRUE, prob = p) # Muestreo no uniforme.
    hubo_coincidencia[i] <- any(duplicated(m)) # Marco TRUE si hubo coincidencia.
  }

  pn_sim[j] <- mean(hubo_coincidencia) # Estimo pn para este n_j.
}

min(ns[pn_sim >= 0.5]) # Devuelvo el minimo n que supera o iguala 1/2.

# Explicacion general:
# Cuando algunos dias concentran muchos mas nacimientos, la probabilidad de
# coincidencias aumenta respecto del caso uniforme. Primero se calcula la masa
# total de "pleno verano", luego se estima para n = 25 la probabilidad de al
# menos una coincidencia y el numero esperado de coincidencias. Finalmente, se
# generaliza el calculo de pn para distintos n y se identifica el umbral de 1/2.
