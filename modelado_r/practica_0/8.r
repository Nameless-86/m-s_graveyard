# Ejercicio 8. Explorando sucesiones infinitas
#
# Escribir un codigo en R para ilustrar numerica y graficamente que:
#   b_n = (1 + 2/n)^n
# converge a e^2.

# -----------------------
# Parte 1: demostracion numerica
# -----------------------

# Elegimos algunos valores de n (crecientes) para ver la convergencia.
n_vals <- c(1, 2, 5, 10, 20, 50, 100, 200, 500, 1000, 5000, 10000)

# Valor limite teorico: e^2.
e2 <- exp(2)

# Calculo de b_n.
b_n <- (1 + 2 / n_vals) ^ n_vals

# Error absoluto respecto a e^2.
error_abs <- abs(b_n - e2)

tabla <- data.frame(
  n = n_vals,
  b_n = b_n,
  error_abs_vs_e2 = error_abs
)

tabla

# -----------------------
# Parte 2: demostracion grafica
# -----------------------

# Graficamos el valor de b_n contra n (en escala log para ver mejor la convergencia).
png("ejercicio8_convergence.png", width = 900, height = 520)
plot(n_vals, b_n,
     type = "b",
     log = "x",
     pch = 19,
     xlab = "n (escala log)",
     ylab = "b_n = (1 + 2/n)^n",
     main = "Convergencia de b_n hacia e^2")
abline(h = e2, col = "red", lty = 2, lwd = 2)
dev.off()

# --------------------------------------------------------------------
# Explicacion (que se esta haciendo realmente en el Ejercicio 8)
#
# El limite clasico que define el numero e es:
#   exp(x) = lim_{n->infty} (1 + x/n)^n
#
# Tomamos x = 2:
#   lim_{n->infty} (1 + 2/n)^n = exp(2) = e^2
#
# Por eso b_n se acerca cada vez mas a exp(2) cuando n crece.
#
# En el codigo:
# - Calculamos b_n exactamente para varios n.
# - Mostramos la diferencia numerica (error_abs) respecto a exp(2).
# - Graficamos b_n (y la linea horizontal e^2) para visualizar como se aproxima.
# --------------------------------------------------------------------