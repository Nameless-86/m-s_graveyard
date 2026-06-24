# ── Parte 1: Regresion logistica con glm ──────────────────────────────────────

lib <- path.expand("~/R/library")
.libPaths(c(lib, .libPaths()))
library(mcsm)
data(challenger)
summary(challenger)
dim(challenger)
names(challenger)

fit      <- glm(oring ~ temp, data = challenger, family = binomial(link = "logit"))
summary(fit)

alpha_mle <- coef(fit)[1]
beta_mle  <- coef(fit)[2]
se_alpha  <- summary(fit)$coefficients[1, 2]
se_beta   <- summary(fit)$coefficients[2, 2]

cat(sprintf("alpha MLE: %.4f  SE: %.4f\n", alpha_mle, se_alpha))
cat(sprintf("beta  MLE: %.4f  SE: %.4f\n", beta_mle,  se_beta))

# ── Parte 2: Funciones auxiliares y M-H con propuestas independientes ─────────

rlaplace <- function(n, mu = 0, b = 1) {
  u <- runif(n, -0.5, 0.5)
  mu - b * sign(u) * log(1 - 2 * abs(u))
}

dlaplace <- function(x, mu = 0, b = 1, log = FALSE) {
  val <- -log(2 * b) - abs(x - mu) / b
  if (log) val else exp(val)
}

log_lik <- function(a, b, datos) {
  p <- plogis(a + b * datos$temp)
  p <- pmax(pmin(p, 1 - 1e-10), 1e-10)
  sum(datos$oring * log(p) + (1 - datos$oring) * log(1 - p))
}

mh_independent <- function(Nsim = 5000, datos, a0, b0, se_b) {
  alpha    <- numeric(Nsim)
  beta     <- numeric(Nsim)
  alpha[1] <- a0
  beta[1]  <- b0

  rate_a  <- 1 / a0
  scale_b <- abs(se_b)

  acc <- 0
  for (t in 2:Nsim) {
    a_star <- rexp(1, rate = rate_a)
    b_star <- rlaplace(1, mu = b0, b = scale_b)

    log_r <- log_lik(a_star, b_star, datos) - log_lik(alpha[t-1], beta[t-1], datos) +
             dexp(alpha[t-1],    rate = rate_a,  log = TRUE) -
             dexp(a_star,        rate = rate_a,  log = TRUE) +
             dlaplace(beta[t-1], mu = b0, b = scale_b, log = TRUE) -
             dlaplace(b_star,    mu = b0, b = scale_b, log = TRUE)

    if (!is.nan(log_r) && !is.na(log_r) && log(runif(1)) < log_r) {
      alpha[t] <- a_star
      beta[t]  <- b_star
      acc      <- acc + 1
    } else {
      alpha[t] <- alpha[t-1]
      beta[t]  <- beta[t-1]
    }
  }
  cat(sprintf("Tasa de aceptacion (independiente): %.3f\n", acc / (Nsim - 1)))
  list(alpha = alpha, beta = beta)
}

# ── Parte 3: 5000 iteraciones, trace plots y curva posterior ──────────────────

set.seed(42)
chain <- mh_independent(5000, challenger, alpha_mle, beta_mle, se_beta)

# Trace plots
png("challenger/challenger_independent_trace.png", width = 800, height = 500)
par(mfrow = c(2, 1), mar = c(4, 4, 2, 1))
plot(chain$alpha, type = "l", col = "steelblue", lwd = 0.5,
     main = "Trace plot alpha — M-H Independiente",
     xlab = "Iteracion", ylab = "alpha")
abline(h = alpha_mle, col = "red", lty = 2, lwd = 1.5)
legend("topright", legend = "MLE alpha", col = "red", lty = 2, bty = "n")

plot(chain$beta, type = "l", col = "darkorange", lwd = 0.5,
     main = "Trace plot beta — M-H Independiente",
     xlab = "Iteracion", ylab = "beta")
abline(h = beta_mle, col = "red", lty = 2, lwd = 1.5)
legend("topright", legend = "MLE beta", col = "red", lty = 2, bty = "n")
dev.off()
cat("Trace plot guardado en challenger/challenger_independent_trace.png\n")

# Curva posterior p(x)
temps   <- seq(50, 85, by = 0.5)
p_mat   <- plogis(outer(chain$alpha, rep(1, length(temps))) + outer(chain$beta, temps))
p_mean  <- colMeans(p_mat)
p_lower <- apply(p_mat, 2, quantile, 0.025)
p_upper <- apply(p_mat, 2, quantile, 0.975)

idx_last <- (length(chain$alpha) - 499):length(chain$alpha)

png("challenger/challenger_independent_plot.png", width = 800, height = 500)
plot(temps, p_mat[idx_last[1], ], type = "l", col = "gray80", lwd = 0.5,
     ylim = c(0, 1), xlab = "Temperatura (F)", ylab = "P(falla O-ring)",
     main = "M-H Independiente — Variabilidad posterior de p(x)")
for (i in idx_last[-1]) lines(temps, p_mat[i, ], col = "gray80", lwd = 0.5)
lines(temps, p_mean, col = "red", lwd = 2)
points(challenger$temp, challenger$oring, pch = 19, col = "black")
legend("topright",
       legend = c("Curvas MCMC (ult. 500)", "Media posterior", "Observaciones"),
       lty = c(1, 1, NA), pch = c(NA, NA, 19),
       col = c("gray60", "red", "black"), lwd = c(1, 2, NA))
dev.off()
cat("Grafico guardado en challenger/challenger_independent_plot.png\n")

# ── Parte 4: Probabilidad de falla a 60, 50, 40 F ────────────────────────────

cat("\nProbabilidad de falla (M-H Independiente):\n")
for (temp in c(60, 50, 40)) {
  p_vals <- plogis(chain$alpha + chain$beta * temp)
  cat(sprintf("  T = %d F:  P(falla) = %.4f  +-  %.4f\n", temp, mean(p_vals), sd(p_vals)))
}



































# ── Variante: propuesta t-Student para beta en lugar de Laplace ───────────────
#
# En mh_independent, reemplazar estas dos lineas:
#
#   b_star <- rlaplace(1, mu = b0, b = scale_b)
#
#   dlaplace(beta[t-1], mu = b0, b = scale_b, log = TRUE) -
#   dlaplace(b_star,    mu = b0, b = scale_b, log = TRUE)
#
# Por estas:
#
#   b_star <- b0 + rt(1, df = 3) * scale_b
#
#   dt(beta[t-1] - b0, df = 3, log = TRUE) -
#   dt(b_star    - b0, df = 3, log = TRUE)
#
# Notas:
#   - b0 es el centro de la propuesta (beta_mle), igual que antes
#   - scale_b controla el ancho del paso, igual que antes
#   - dt evalua la densidad t en la distancia al centro, no en el valor absoluto
#   - df = 1 es Cauchy (colas muy pesadas), df = 30 se parece a Normal
#   - df = 3 o df = 5 son valores tipicos para propuestas robustas
#   - la funcion necesita recibir b0 = beta_mle como argumento (ya lo recibe)
