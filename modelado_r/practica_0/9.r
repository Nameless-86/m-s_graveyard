# Ejercicio 9. Muestreando de una poblacion finita
#
# 1) Simular el lanzamiento de una moneda equilibrada n = 10 veces.
#    Contar el numero y la proporcion de caras obtenidas en la simulacion.
#
# 2) Repetir la simulacion para n = 1000 y, para cada valor m = 1,2,...,n,
#    calcular y graficar la proporcion de caras obtenidas (proporcion acumulada).

set.seed(123)

# -----------------------
# Parte 1: n = 10
# -----------------------
n1 <- 10
tosses_10 <- rbinom(1, size = n1, prob = 0.5)  # numero de caras en 10 lanzamientos
prop_10 <- tosses_10 / n1

# Mostrar resultado de una simulacion
tosses_10
prop_10

# -----------------------
# Parte 2: n = 1000
# -----------------------
n <- 1000

# Secuencia de n lanzamientos (1 = cara, 0 = cruz)
tosses <- rbinom(n, size = 1, prob = 0.5)

# Proporcion acumulada de caras para cada prefijo m = 1..n
cum_heads <- cumsum(tosses)
m_vals <- 1:n
prop_cum <- cum_heads / m_vals

# Mostrar algunas proporciones (para no imprimir todo)
tabla_head <- data.frame(
  m = c(1, 2, 5, 10, 20, 50, 100, 200, 500, 1000),
  prop_cum = prop_cum[c(1, 2, 5, 10, 20, 50, 100, 200, 500, 1000)]
)
tabla_head

# Grafica: proporcion acumulada vs m
png("ejercicio9_prop_cum.png", width = 900, height = 520)
plot(m_vals, prop_cum,
     type = "l",
     col = "blue",
     xlab = "m (numero de lanzamientos)",
     ylab = "proporcion acumulada de caras",
     main = "Convergencia empirica: proporcion de caras -> 0.5")
abline(h = 0.5, col = "red", lty = 2, lwd = 2)
dev.off()

# --------------------------------------------------------------------
# Explicacion (que se esta haciendo en el Ejercicio 9)
#
# Modelamos la moneda equilibrada como una v.a. Bernoulli(p=0.5):
#   - X_i = 1 si sale cara en el i-esimo lanzamiento
#   - X_i = 0 si sale cruz
# Cada lanzamiento es independiente y:
#   P(X_i = 1) = 0.5
#
# Entonces, si hacemos m lanzamientos:
#   numero de caras = sum_{i=1}^m X_i
# y la proporcion acumulada de caras es:
#   S_m / m, donde S_m = sum_{i=1}^m X_i
#
# Por la Ley de los Grandes Numeros, S_m/m tiende a p=0.5 cuando m -> infinito.
# El codigo ilustra esto:
# - Parte 1: hacemos una simulacion corta (n=10) y calculamos caras y proporcion.
# - Parte 2: simulamos una secuencia larga (n=1000), calculamos S_m/m para
#   todos los m=1..n y graficamos la trayectoria.
#
# Nota: aqui asumimos lanzamientos independientes (con reemplazo).
# Si quisieras un modelo "sin reemplazo" (verdadera poblacion finita),
# tendrias que cambiar el generador (por ejemplo muestreo sin reemplazo).
# --------------------------------------------------------------------