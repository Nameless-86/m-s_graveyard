lib <- path.expand("~/R/library")
.libPaths(c(lib, .libPaths()))
library(mcsm)
data(challenger)

#de vuelta las librerias y el fit de la curva logistica es igual

fit <- glm(oring ~ temp, data = challenger, family = binomial(link = "logit"))
summary(fit)

alpha_mle <- coef(fit)[1]
beta_mle  <- coef(fit)[2]
se_alpha  <- summary(fit)$coefficients[1, 2]
se_beta   <- summary(fit)$coefficients[2, 2]

cat(sprintf("alpha MLE: %.4f  SE: %.4f\n", alpha_mle, se_alpha))
cat(sprintf("beta  MLE: %.4f  SE: %.4f\n", beta_mle,  se_beta))

#sigue igual que el anterior
#hay que hacer las funciones auxiliares ahora para laplace

log_lik <- function(a,b, datos) {
  p <- plogis(a+b * datos$temp)
  p <- pmax(pmin(p, 1 - 1e-10), 1e-10)
  sum(datos$oring * log(p) + (1 - datos$oring) * log(1 - p))
}

rlaplace <- function(n, mu = 0, b=1) {
  u <- runif(n, -0.5, 0.5)
  mu - b * sign(u) * log(1- 2 * abs(u))
}


 #vector de 0s de long Nsim, es mas rapido que el loop
 #mitad del error estandar porque el se es la dispercion del ml # asi la cadena se mueve en un rango razonable sin saltar muy lejo
#rexp(1, rate = 1/step_a) genera un paso positivo con media step_a. sample(c(-1,1), 1) le asigna signo aleatorio
  #así la propuesta es simétrica alrededor del estado actual

mh_random_walk <- function(Nsim, datos, a0, b0, se_a, se_b) {
  alpha    <- numeric(Nsim)
  beta     <- numeric(Nsim)
  alpha[1] <- a0
  beta[1]  <- b0
  step_a   <- se_a * 0.5
  step_b   <- se_b * 0.5
  acc      <- 0

  for (t in 2:Nsim) {
    eps_a  <- rexp(1, rate = 1 / step_a) * sample(c(-1, 1), 1)
    a_star <- alpha[t-1] + eps_a
    b_star <- rlaplace(1, mu = beta[t-1], b = step_b)

    if (a_star > 0) {
      log_r <- log_lik(a_star, b_star, datos) - log_lik(alpha[t-1], beta[t-1], datos)
    } else {
      log_r <- -Inf
    }

    if (!is.nan(log_r) && !is.na(log_r) && log(runif(1)) < log_r) {
      alpha[t] <- a_star
      beta[t]  <- b_star
      acc      <- acc + 1
    } else {
      alpha[t] <- alpha[t-1]
      beta[t]  <- beta[t-1]
    }
  }

  cat(sprintf("Tasa de aceptacion: %.3f\n", acc / (Nsim - 1)))
  list(alpha = alpha, beta = beta)
}


set.seed(42)
chain <- mh_random_walk(5000, challenger, alpha_mle, beta_mle, se_alpha, se_beta)


par(mfrow = c(2, 1), mar = c(4, 4, 2, 1))
plot(chain$alpha, type="l", col="steelblue", lwd=0.5,
     main="Trace plot alpha", xlab="Iteracion", ylab="alpha")
abline(h=alpha_mle, col="red", lty=2, lwd=1.5)

plot(chain$beta, type="l", col="darkorange", lwd=0.5,
     main="Trace plot beta", xlab="Iteracion", ylab="beta")
abline(h=beta_mle, col="red", lty=2, lwd=1.5)
par(mfrow = c(1, 1))



temps   <- seq(50, 85, by=0.5)
p_mat   <- plogis(outer(chain$alpha, rep(1, length(temps))) + outer(chain$beta, temps))
p_mean  <- colMeans(p_mat)
idx_last <- (length(chain$alpha) - 499):length(chain$alpha)

plot(temps, p_mat[idx_last[1],], type="l", col="gray80", lwd=0.5,
     ylim=c(0,1), xlab="Temperatura (F)", ylab="P(falla)",
     main="Random Walk — Variabilidad posterior de p(x)")
for (i in idx_last[-1]) lines(temps, p_mat[i,], col="gray80", lwd=0.5)
lines(temps, p_mean, col="red", lwd=2)
points(challenger$temp, challenger$oring, pch=19, col="black")


cat("\nProbabilidad de falla (Random Walk):\n")
for (temp in c(60, 50, 40)) {
  p_vals <- plogis(chain$alpha + chain$beta * temp)
  cat(sprintf("  T = %d F:  P(falla) = %.4f  +-  %.4f\n",
              temp, mean(p_vals), sd(p_vals)))
}


