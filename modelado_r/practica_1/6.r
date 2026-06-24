# Enunciado:
# Se considera un patron no uniforme de nacimientos en 366 dias con:
# p = c(rep(96, 61), rep(98, 89), rep(99, 62), rep(100, 61), rep(104, 62), rep(106, 30), 25)
# 1) Ejecutar e interpretar:
#    length(p); 1/366; unique(p/sum(p))
#    plot(1:366, p/sum(p), type="p", ...)
#    abline(h = 1/366, ...)
# 2) Ejecutar la simulacion de coincidencias con prob = p y comparar con el caso uniforme.
#
# Ejercicio 6 - Cumpleanos con nacimientos no uniformes (parte 1)

p <- c(rep(96, 61), rep(98, 89), rep(99, 62), rep(100, 61), rep(104, 62), rep(106, 30), 25) # Frecuencias relativas.
length(p) # Verifico que haya 366 dias.
1 / 366 # Probabilidad diaria si fuera uniforme.
unique(p / sum(p)) # Distintos niveles de probabilidad normalizada.

plot(1:366, p / sum(p), type = "p", xlab = "dia", ylab = "prob", cex = 0.25, pch = 19) # Perfil no uniforme.
abline(h = 1 / 366, lwd = 2, col = "red") # Referencia uniforme para comparar.

set.seed(50) # Fijo semilla.
B <- 100000 # Numero de simulaciones.
n <- 25 # Tamano de grupo.
x_no_uniforme <- numeric(B) # Coincidencias con distribucion no uniforme.
x_uniforme <- numeric(B) # Coincidencias con distribucion uniforme.

for (i in 1:B) { # Recorro todas las repeticiones.
  m1 <- sample(1:366, n, replace = TRUE, prob = p) # Muestro segun probabilidades no uniformes.
  x_no_uniforme[i] <- sum(duplicated(m1)) # Cuento coincidencias en caso no uniforme.

  m2 <- sample(1:366, n, replace = TRUE) # Muestro con distribucion uniforme.
  x_uniforme[i] <- sum(duplicated(m2)) # Cuento coincidencias en caso uniforme.
}

mean(x_no_uniforme >= 1) # Probabilidad de al menos una coincidencia (no uniforme).
mean(x_uniforme >= 1) # Probabilidad de al menos una coincidencia (uniforme).
mean(x_no_uniforme) # Esperanza de coincidencias (no uniforme).
mean(x_uniforme) # Esperanza de coincidencias (uniforme).

# Explicacion general:
# Al usar prob en sample(), los dias no tienen la misma probabilidad de nacimiento.
# Eso incrementa concentracion en ciertos dias y, en general, aumenta la chance de
# coincidencias frente al caso uniforme. La comparacion lado a lado por simulacion
# permite cuantificar ese efecto en probabilidad de coincidencia y en su valor esperado.
