grad_log_f <- function(x) -x       # gradiente de log N(0,1)
sigma <- 1
Nsim  <- 10^4
X4    <- rep(rnorm(1), Nsim)

for (t in 2:Nsim) {
  mean_prop <- X4[t-1] + (sigma^2/2) * grad_log_f(X4[t-1])
  Y         <- rnorm(1, mean=mean_prop, sd=sigma)

  mean_rev  <- Y + (sigma^2/2) * grad_log_f(Y)

  log_rho <- dnorm(Y, log=TRUE) - dnorm(X4[t-1], log=TRUE) +
             dnorm(X4[t-1], mean=mean_rev,  sd=sigma, log=TRUE) -
             dnorm(Y,        mean=mean_prop, sd=sigma, log=TRUE)

  X4[t] <- X4[t-1] + (Y - X4[t-1]) * (log(runif(1)) < log_rho)
}


acc <- sum(diff(X4) != 0) / (Nsim - 1)
cat(sprintf("Tasa de aceptacion Langevin: %.3f\n", acc))

par(mfrow = c(1, 2))
plot(X4, type="l", col="purple", lwd=0.5,
     main="Trace Langevin N(0,1)",
     xlab="Iteracion", ylab="X")
abline(h=0, col="red", lty=2)

hist(X4, breaks=80, freq=FALSE, col="gray90",
     main="Histograma Langevin N(0,1)", xlab="x")
curve(dnorm(x), add=TRUE, col="red", lwd=2)
par(mfrow = c(1, 1))
