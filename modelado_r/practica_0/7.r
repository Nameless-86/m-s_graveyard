# Ejercicio 7. Explorando sucesiones infinitas
#
# Se considera la sucesion
#   s_n = 1 + 2 + ... + n
#
# 1) Explicar por que s_n cuenta el numero de piezas de domino con n simbolos.
#    (ejemplo: s_7 = 28 para el domino tradicional)
#    Puede un juego de domino (no tradicional) tener 25 fichas?
#
# 2) Escribir un codigo en R para ilustrar que:
#      lim_{n->infty} s_n / n^2 = 1/2
#    Sugerencia: usar una expresion simplificada de s_n.

# -----------------------
# Parte 1: domino (punto 1)
# -----------------------

# Numero de fichas de un domino "completo" con n simbolos:
# s_n = n(n+1)/2
n_domino <- 7
s7 <- n_domino * (n_domino + 1) / 2
s7 # Resultado esperado para domino tradicional: 28

# Verificar si 25 es un numero triangular (existe n entero con n(n+1)/2 = 25)
objetivo <- 25
n_sol <- (-1 + sqrt(1 + 8 * objetivo)) / 2
es_triangular <- abs(n_sol - round(n_sol)) < 1e-12

n_sol
es_triangular # FALSE => 25 no corresponde a un domino completo "tradicional"

# Aun asi, un juego NO tradicional puede tener 25 fichas
# (por ejemplo, tomar 25 de las 28 fichas del domino de 7 simbolos).
simbolos <- 0:6
fichas_ordenadas <- expand.grid(a = simbolos, b = simbolos)
fichas_unicas <- fichas_ordenadas[fichas_ordenadas$a <= fichas_ordenadas$b, ]

nrow(fichas_unicas) # 28 fichas totales
fichas_25 <- fichas_unicas[1:25, ]
nrow(fichas_25) # 25 fichas en un juego no tradicional

# -----------------------
# Parte 2: Ilustracion
# -----------------------

# Formula cerrada (sumatoria triangular):
#   s_n = 1 + 2 + ... + n = n(n+1)/2
n_vals <- c(1, 2, 3, 4, 5, 7, 10, 100, 1000, 10000)
s_n <- n_vals * (n_vals + 1) / 2
ratio <- s_n / (n_vals^2)
error <- abs(ratio - 1/2)

tabla <- data.frame(
  n = n_vals,
  s_n = s_n,
  s_n_over_n2 = ratio,
  error_abs_vs_1_2 = error
)
tabla

# Resultado (ejemplo con estos n_vals):
#   n=1     s_n=1        s_n/n^2=1.0000000  error=0.50000000
#   n=2     s_n=3        s_n/n^2=0.7500000  error=0.25000000
#   n=3     s_n=6        s_n/n^2=0.6666667  error=0.16666667
#   n=4     s_n=10       s_n/n^2=0.6250000  error=0.12500000
#   n=5     s_n=15       s_n/n^2=0.6000000  error=0.10000000
#   n=7     s_n=28       s_n/n^2=0.5714286  error=0.07142857
#   n=10    s_n=55       s_n/n^2=0.5500000  error=0.05000000
#   n=100   s_n=5050     s_n/n^2=0.5050000  error=0.00500000
#   n=1000  s_n=500500   s_n/n^2=0.5005000  error=0.00050000
#   n=10000 s_n=50005000 s_n/n^2=0.5000500  error=0.00005000
# Se observa que s_n/n^2 se acerca a 1/2.

# Graficar (guardando a archivo, sin depender de GUI).
png("ejercicio7_limit_ratio.png", width = 900, height = 520)
plot(n_vals, ratio,
     type = "b",
     log = "x",
     xlab = "n (escala log)",
     ylab = "s_n / n^2",
     main = "Convergencia de s_n/n^2 hacia 1/2")
abline(h = 1/2, col = "red", lty = 2, lwd = 2)
dev.off()

# --------------------------------------------------------------------
# Explicacion (que se esta haciendo realmente en el Ejercicio 7)
#
# Parte 1: por que s_n cuenta fichas de domino
# En el domino tradicional con n simbolos, las fichas corresponden a pares
# (i, j) con i <= j, donde i y j recorren los n simbolos.
#
# Para i = 1 (o el primer valor), hay n opciones para j.
# Para i = 2, hay n-1 opciones para j.
# ...
# Para i = n, hay 1 opcion para j.
#
# Entonces el total de fichas es:
#   n + (n-1) + ... + 1 = 1 + 2 + ... + n = s_n.
#
# Por eso, por ejemplo, si n = 7:
#   s_7 = 1 + 2 + ... + 7 = 28.
#
# Puede un juego (no tradicional) tener 25 fichas?
# - Si exigieras "exactamente" el domino tradicional (todas las combinaciones),
#   entonces el numero de fichas tiene que ser triangular: s_n.
#   Como 25 no es triangular, no existiria un "tradicional" con exactamente 25.
# - Pero en un juego no tradicional puedes escoger un subconjunto de fichas:
#   por ejemplo, el tradicional con n=7 tiene 28 fichas, asi que puedes quedarte
#   con 25 (quitando 3) y formar un juego no tradicional con 25 fichas.
#
# Parte 2: por que s_n/n^2 -> 1/2
# Usamos la expresion simplificada:
#   s_n = n(n+1)/2
# Entonces:
#   s_n / n^2 = [n(n+1)/2] / n^2 = (n+1)/(2n) = 1/2 + 1/(2n).
# Como 1/(2n) -> 0 cuando n -> infinito, el limite vale 1/2.
# En el codigo se calcula s_n y el cociente s_n/n^2 para n cada vez mas grandes
# y se verifica numericamente que se acerca a 0.5.
# --------------------------------------------------------------------