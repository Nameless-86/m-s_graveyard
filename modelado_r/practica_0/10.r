# Ejercicio 10. Muestreando de una poblacion finita
#
# Se lanza 3 veces un dado equilibrado (6 caras).
# Se definen:
#   - X: suma de los 3 dados
#   - Y: vale 1 si los 3 dados coinciden (mismo numero en los 3), y 0 si no.
#
# 1) Simular 3 dados una vez. Calcular X e Y en esa simulacion y dar
#    la probabilidad exacta de esos valores.
#
# 2) Simular 10000 veces y aproximar las distribuciones de X e Y.
#    Comparar numerica y graficamente contra los resultados exactos.

set.seed(123)

# ---------------------------------------------------------
# Calculo exacto (enumerando las 6^3 combinaciones)
# ---------------------------------------------------------
comb <- expand.grid(d1 = 1:6, d2 = 1:6, d3 = 1:6)
X_exact <- comb$d1 + comb$d2 + comb$d3
Y_exact <- as.integer(comb$d1 == comb$d2 & comb$d1 == comb$d3)

prob_X_exact <- as.numeric(prop.table(table(factor(X_exact, levels = 3:18))))
names(prob_X_exact) <- as.character(3:18)

prob_Y_exact <- as.numeric(prop.table(table(factor(Y_exact, levels = c(0, 1)))))
names(prob_Y_exact) <- c("0", "1")

# ---------------------------------------------------------
# Parte 1: una simulacion
# ---------------------------------------------------------
dice_once <- sample(1:6, size = 3, replace = TRUE)
X_once <- sum(dice_once)
Y_once <- as.integer(dice_once[1] == dice_once[2] & dice_once[1] == dice_once[3])

X_once
Y_once

# Probabilidad exacta de los valores observados en la simulacion
p_X_once <- prob_X_exact[as.character(X_once)]
p_Y_once <- prob_Y_exact[as.character(Y_once)]

p_X_once
p_Y_once

# ---------------------------------------------------------
# Parte 2: simulaciones (aproximacion)
# ---------------------------------------------------------
n_sims <- 10000

dice <- matrix(sample(1:6, size = n_sims * 3, replace = TRUE), nrow = n_sims, ncol = 3)
X_sim <- rowSums(dice)
Y_sim <- as.integer(dice[, 1] == dice[, 2] & dice[, 1] == dice[, 3])

# Distribuciones simuladas (proporciones de ocurrencia)
prob_X_sim <- as.numeric(prop.table(table(factor(X_sim, levels = 3:18))))
names(prob_X_sim) <- as.character(3:18)

prob_Y_sim <- as.numeric(prop.table(table(factor(Y_sim, levels = c(0, 1)))))
names(prob_Y_sim) <- c("0", "1")

# Comparacion numerica
tabla_X <- data.frame(
  X = 3:18,
  P_exact = prob_X_exact,
  P_sim = prob_X_sim,
  error_abs = abs(prob_X_exact - prob_X_sim)
)
tabla_X

tabla_Y <- data.frame(
  Y = c(0, 1),
  P_exact = prob_Y_exact[c("0", "1")],
  P_sim = prob_Y_sim[c("0", "1")],
  error_abs = abs(prob_Y_exact[c("0", "1")] - prob_Y_sim[c("0", "1")])
)
tabla_Y

# -----------------------
# Graficas (guardadas)
# -----------------------
k_vals <- 3:18

png("ejercicio10_dist_X.png", width = 900, height = 520)
plot(k_vals, prob_X_exact,
     type = "b",
     pch = 19,
     col = "red",
     xlab = "X (suma de 3 dados)",
     ylab = "Probabilidad",
     main = "Distribucion de X: exacta vs simulada")
points(k_vals, prob_X_sim, pch = 17, col = "blue")
legend("topright",
       legend = c("Exacta", "Simulada"),
       col = c("red", "blue"),
       pch = c(19, 17),
       lty = 1,
       bty = "n")
dev.off()

png("ejercicio10_dist_Y.png", width = 900, height = 520)
barplot(rbind(prob_Y_exact, prob_Y_sim),
        beside = TRUE,
        names.arg = c("0", "1"),
        col = c("red", "blue"),
        main = "Distribucion de Y: exacta vs simulada",
        xlab = "Y",
        ylab = "Probabilidad")
legend("topright",
       legend = c("Exacta", "Simulada"),
       col = c("red", "blue"),
       pch = 15,
       lty = 1,
       bty = "n")
dev.off()

# --------------------------------------------------------------------
# Explicacion (que se esta haciendo en el Ejercicio 10)
#
# - Como los dados son justos e independientes, hay 6^3 = 216 resultados
#   equiprobables.
#
# Para Y:
#   Y=1 <=> d1 = d2 = d3.
#   Hay 6 casos (1-1-1, 2-2-2, ..., 6-6-6).
#   Entonces:
#     P(Y=1) = 6 / 216 = 1/36
#     P(Y=0) = 35/36
#
# Para X:
#   X toma valores de 3 a 18.
#   La distribucion exacta se obtiene contando cuantas combinaciones
#   producen cada suma. En el codigo lo hacemos por enumeracion exhaustiva.
#
# Para la parte 2:
#   Repetimos el experimento n_sims veces y aproximamos la distribucion
#   observando frecuencias relativas. Al aumentar n_sims, las frecuencias
#   relativas convergen a las probabilidades exactas (Ley de los Grandes Numeros).
# --------------------------------------------------------------------