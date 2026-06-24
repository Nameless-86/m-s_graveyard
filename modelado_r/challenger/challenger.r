#Parte 1 — Regresión logística con glm

lib <- path.expand("~/R/library")
.libPaths(c(lib, .libPaths()))
library(mcsm)
data(challenger)

fit <- glm(oring ~ temp, data = challenger, family = binomial(link = "logit"))
summary(fit)

# Extraer MLEs y errores estándar
alpha_mle <- coef(fit)[1]
beta_mle  <- coef(fit)[2]
se_alpha  <- summary(fit)$coefficients[1, 2]
se_beta   <- summary(fit)$coefficients[2, 2]

cat("alpha MLE:", alpha_mle, "  SE:", se_alpha, "\n")
cat("beta  MLE:", beta_mle,  "  SE:", se_beta,  "\n")

#Parte 2 — Algoritmo Metropolis-Hastings

# --- Distribucion Laplace (no viene en base R) ---
rlaplace <- function(n, mu = 0, b = 1) {
  u <- runif(n, -0.5, 0.5)
  mu - b * sign(u) * log(1 - 2 * abs(u))
}
dlaplace <- function(x, mu = 0, b = 1, log = FALSE) {
  val <- -log(2 * b) - abs(x - mu) / b
  if (log) val else exp(val)
}

# --- Log-verosimilitud logistica ---
log_lik <- function(a, b, datos) {
  p <- plogis(a + b * datos$temp)
  p <- pmax(pmin(p, 1 - 1e-10), 1e-10)   # evitar log(0)
  sum(datos$oring * log(p) + (1 - datos$oring) * log(1 - p))
}

# --- M-H: random walk con paso Exp para alpha y paso Laplace para beta ---
# Propuestas simetricas => ratio = solo diferencia de log-verosimilitudes
mh_challenger <- function(Nsim = 5000, datos, a0, b0, se_a, se_b) {
  alpha <- numeric(Nsim)
  beta  <- numeric(Nsim)
  alpha[1] <- a0
  beta[1]  <- b0

  step_a <- se_a * 0.5   # tamano de paso exponencial para alpha
  step_b <- se_b * 0.5   # tamano de paso Laplace para beta

  acc <- 0
  for (t in 2:Nsim) {
    # Paso exponencial con signo aleatorio (random walk simetrico, alpha > 0)
    eps_a  <- rexp(1, rate = 1 / step_a) * sample(c(-1, 1), 1)
    a_star <- alpha[t-1] + eps_a

    # Paso Laplace centrado en valor actual
    b_star <- rlaplace(1, mu = beta[t-1], b = step_b)

    # Con propuestas simetricas: log_r = diferencia de log-lik
    if (a_star > 0) {
      log_r <- log_lik(a_star, b_star, datos) - log_lik(alpha[t-1], beta[t-1], datos)
    } else {
      log_r <- -Inf   # alpha debe ser positivo
    }

    if (!is.nan(log_r) && !is.na(log_r) && log(runif(1)) < log_r) {
      alpha[t] <- a_star
      beta[t]  <- b_star
      acc <- acc + 1
    } else {
      alpha[t] <- alpha[t-1]
      beta[t]  <- beta[t-1]
    }
  }
  cat(sprintf("Tasa de aceptacion: %.3f\n", acc / (Nsim - 1)))
  list(alpha = alpha, beta = beta)
}

#Parte 3 — 5000 iteraciones y grafico tipo Figura 6.6

set.seed(42)
chain <- mh_challenger(5000, challenger, alpha_mle, beta_mle, se_alpha, se_beta)

# Grilla de temperaturas para la curva
temps <- seq(50, 85, by = 0.5)

# Calcular p(x) para cada muestra del chain
p_mat <- outer(chain$alpha, rep(1, length(temps))) +
         outer(chain$beta,  temps)
p_mat <- plogis(p_mat)

p_mean  <- colMeans(p_mat)
p_lower <- apply(p_mat, 2, quantile, 0.025)
p_upper <- apply(p_mat, 2, quantile, 0.975)

# --- Grafico guardado como PNG ---
png("challenger/challenger_plot.png", width = 800, height = 500)
plot(temps, p_mean, type = "l", lwd = 2, ylim = c(0, 1),
     xlab = "Temperatura (F)", ylab = "P(falla O-ring)",
     main = "Variabilidad posterior de p(x) - Challenger")
lines(temps, p_lower, lty = 2, col = "gray40")
lines(temps, p_upper, lty = 2, col = "gray40")
points(challenger$temp, challenger$oring, pch = 19, col = "red")
legend("topright",
       legend = c("Media posterior", "IC 95%", "Observaciones"),
       lty = c(1, 2, NA), pch = c(NA, NA, 19),
       col = c("black", "gray40", "red"))
dev.off()
cat("Grafico guardado en challenger/challenger_plot.png\n")

#Parte 4 — Estimacion de P(falla) a 60, 50 y 40 F

for (temp in c(60, 50, 40)) {
  p_vals <- plogis(chain$alpha + chain$beta * temp)
  cat(sprintf("T = %d F:  P(falla) = %.4f  +-  %.4f\n",
              temp, mean(p_vals), sd(p_vals)))
}
