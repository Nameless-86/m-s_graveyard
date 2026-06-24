# Enunciado:
# En Marte hay 669 dias por ano y se asume distribucion uniforme de nacimientos.
# 1) Para un grupo de tamano n, calcular pn = P(al menos una coincidencia de cumpleanos).
# 2) Evaluar y graficar pn en R para un rango adecuado de n.
# 3) Hallar min{n : pn >= 1/2} usando min(n[pn >= 1/2]).
#
# Ejercicio 5 - Coincidencias de cumpleanos en Marte

dias_marte <- 669 # Cantidad de dias del ano marciano.
n <- 1:120 # Rango de tamanos de grupo para evaluar.

pn <- 1 - (choose(dias_marte, n) * factorial(n)) / (dias_marte^n) # P(al menos una coincidencia).
pn # Muestro vector de probabilidades para cada n del rango.

plot(n, pn, type = "l", lwd = 2, col = "blue", xlab = "n", ylab = "pn") # Grafico pn vs n.
abline(h = 0.5, col = "red", lwd = 2, lty = 2) # Linea horizontal en 0.5 para referencia.

min(n[pn >= 0.5]) # Minimo n tal que pn es al menos 1/2.

# Verificacion por simulacion para un n concreto (opcional).
set.seed(40) # Fijo semilla para reproducibilidad.
B <- 50000 # Numero de repeticiones Monte Carlo.
n0 <- 31 # Valor cercano al umbral de 1/2 (puede ajustarse segun resultado exacto).
x <- logical(B) # Vector logico para marcar si hubo coincidencia.

for (i in 1:B) { # Recorro todas las simulaciones.
  m <- sample(1:dias_marte, n0, replace = TRUE) # Simulo cumpleanos para n0 personas.
  x[i] <- any(duplicated(m)) # TRUE si existe al menos una coincidencia.
}

mean(x) # Aproximacion simulada de pn para n = n0.

# Explicacion general:
# Para una poblacion con cumpleanos uniformes en 669 dias, la probabilidad de
# al menos una coincidencia se obtiene como 1 menos la probabilidad de que todos
# sean distintos. El grafico de pn en funcion de n permite visualizar como crece
# el riesgo de coincidencia y encontrar el umbral minimo donde supera 1/2.
