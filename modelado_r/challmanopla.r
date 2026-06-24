#Cargo las librerias y el dataset
lib <- path.expand ("~/R/library")
.libPaths(c(lib, .libPaths()))
library(mcsm)
data(challenger)


head(challenger)
str(challenger)
summary(challenger)
#
 # oring=1 es fallo, 0 no fallo, temp es temperatura en F
 # 23 filas en el dataset ambas tipo int, temp minima 53, max 81, promedio 69,57
# media de oring es 0.3043 significa que 30% aprox de los lanzamientos tuvo fallos


#Reg logistica

fit <- glm(oring ~ temp, data = challenger, family = binomial(link = "logit"))

summary(fit)

Coefficients:
            Estimate Std. Error z value Pr(>|z|)
(Intercept)  15.0429     7.3786   2.039   0.0415 *
temp         -0.2322     0.1082  -2.145   0.0320 *
---
el estimate es el MLE(Maximum Likelihood Estimator) menos el valor de alfa o beta uqe  maximiza la verosimilitud, o sea que tan bien mis parametros explican los datos observados
alfa tiene un estimado 15.0429 - 7.3786 = +-7.3786 entre 8 y 22
beta -0.2322 - 0.1082 = +-0.1082 entre -0.45 y -0.02

Null deviance: Qué tan mal ajusta un modelo sin predictores (solo intercepto) 28.267

Residual deviance: Qué tan mal ajusta tu modelo con temperatura — menor es mejor 20.315
agregar la temperatura mejora el ajuste

AIC es para comparar con otros modelos, scoring de fischer es un algoritmo para encontrar mles, avisa que convergio


ahora a ver los resultados
alpha_mle <- coef(fit)[1]
beta_mle <- coef(fit)[2]
se_alpha <- summary(fit)$coefficients[1,2]
se_beta <- summary(fit)$coefficients[2,2]

cat("alpha MLE:", alpha_mle, " SE:", se_alpha, "\n")
cat("beta MLE:", beta_mle, " SE:", se_beta, "\n")

α = 15.0429    SE = 7.3786
β = −0.2322    SE = 0.1082


#definir funcion de laplace porque R no tiene por defecto
# r genera las muestras aleatorias, com oen R rnorm(), o rexp()
rlaplace <- function(n, mu = 0, b = 1) {
  u <- runif(n, -0.5, 0.5)
mu - b * sign(u) * log(1 - 2 * abs(u))
}
#d calcula la densidad como dnorm en R
dlaplace <- function(x, mu = 0, b= 1, log = FALSE) {
  val <- -log(2 * b) - abs(x - mu) / b
  if (log) val else exp(val)
}

#seria algo asi
#rlaplace(1, mu=0, b=1)  genera 1 número aleatorio de una Laplace
# dlaplace(x, mu=0, b=1)  devuelve qué tan probable es el valor x bajo esa Laplace

log_lik <- function(a, b, datos) {
  p <- plogis(a+b * datos$temp) #plogis es la funcion logistica inversa (es parte de R)
  p <- pmax(pmin(p, 1 - 1e-10), 1e-10) #limita el calculo para que p nunca sea 0 o 1
  sum(datos$oring * log(p) + (1 - datos$oring) * log(1-p))
}

#agarra un numero real y lo castea a prob (0,1)
#la funcion calcula p(xi) en cada lanzamiento y usando alfa y beta propuestas
# devuelve un vector de probabilidades, 23, una por lanzamiento
#despues calcula la log-verosimilitud sumando en los 23 lanzamientos

#sum(datos$oring * l#og(p) + (1 - datos$oring) * log(1 - p))
# oring=1 → entra log(p)      → qué tan probable es la falla
# oring=0 → entra log(1-p)   → qué tan probable es no fallar

#entra un par alfa beta y devuelve que tan bien por que ese par explica los 23 lanzamientos

mh_independent <- function(Nsim = 5000, datos, a0, b0, se_b) {
  #inicializacion de variables
  alpha <- numeric(Nsim) #5000 ceros para a
  beta <- numeric(Nsim) # 5000 ceros para beta
  alpha[1] <- a0 #primer valor mle de alfa
  beta[1] <- b0 # primer vaor, mle de beta
  #esto significa que la cadena arranca de los mles

  rate_a <- 1 / a0 #exponencial con media = mle de alfa 15.04
  scale_b <- abs(se_b) #laplace con escala error estandar de beta 0.108

  acc <- 0
  for (t in 2:Nsim) {
    a_star <- rexp(1, rate = rate_a) #proponer a* desde exponencial
    b_star <- rlaplace(1, mu = b0, b = scale_b) #proponer b* desde laplace
#generando un candidato (a*,b*)
    #este es el ratio de aceptacion
    log_r <- log_lik(a_star, b_star, datos) - log_lik(alpha[t-1], beta[t-1], datos) + dexp(alpha[t-1], rate = rate_a, log = TRUE) - dexp(a_star, rate = rate_a, log = TRUE) + dlaplace(beta[t-1], mu = b0, b = scale_b, log = TRUE) - dlaplace(b_star, mu = b0, b = scale_b, log = TRUE)

    if (!is.nan(log_r) && !is.na(log_r) && log(runif(1)) < log_r) { #logrunif 1 genera un valor de -inf y 0, si log_r es mayor se acepta, si no la cadena no se mueve
      alpha[t] <- a_star #si acepta mueve la cadena
      beta[t] <- b_star
      acc <- acc + 1
    } else {
      alpha[t] <- alpha[t-1] #rechaza, duplica el valor actual
      beta[t] <- beta[t-1]
    }
  }
  cat(sprintf("Tasa de aceptacion: %.3f\n", acc / (Nsim -1)))
  list(alpha = alpha, beta = beta) #devuelve los 5000 valores de cada parametro
}

#log_r <- log_lik(a_star, b_star, datos) - log_lik(alpha[t-1], beta[t-1], datos) +
#         dexp(alpha[t-1], ...) - dexp(a_star, ...) +
#         dlaplace(beta[t-1], ...) - dlaplace(b_star, ...)
#Tres diferencias en log-escala:
#- Primera línea → qué tan mejor es el candidato que el actual en verosimilitud
#- Segunda línea → corrección por la densidad de la propuesta de α
#- Tercera línea → corrección por la densidad de la propuesta de β

#correr la cadena
set.seed(42)
chain <- mh_independent(5000, challenger, alpha_mle, beta_mle, se_beta)
#da 3.1%, de 100 valores rechazo 97
#la exponencial independiente propone valores de 0, sin considerar donde esta la cadena
#la mayoria estan cayendo lejos de las regiones de alta verosimilitud

length(chain$alpha) #5000 valores guardados correctamente
length(chain$beta) #aca igual
head(chain$alpha) #los primeros 6 valores de alfa son todos 15.0420
#como la cadena arranca en el mle y las primeras propuestas se rechazan se duplica el valor inicial

#grafico
temps   <- seq(50, 85, by = 0.5)
p_mat   <- plogis(outer(chain$alpha, rep(1, length(temps))) + outer(chain$beta, temps))
p_mean  <- colMeans(p_mat)

idx_last <- (length(chain$alpha) - 499):length(chain$alpha)

plot(temps, p_mat[idx_last[1], ], type = "l", col = "gray80", lwd = 0.5,
     ylim = c(0, 1), xlab = "Temperatura (F)", ylab = "P(falla O-ring)",
     main = "M-H Independiente — Variabilidad posterior de p(x)")
for (i in idx_last[-1]) lines(temps, p_mat[i, ], col = "gray80", lwd = 0.5)
lines(temps, p_mean, col = "red", lwd = 2)
points(challenger$temp, challenger$oring, pch = 19, col = "black")
# curvas grises son las ultimas 500 iteraciones de la cadena, todas curvas logisticas con un a,b distinto

#linea roja es la media de las 5000 iteraciones

#negros arriba, fallos, negros abajo lanzamientos sin falla

#hay pocas curvas grises distintas varias se superponen. Eso es la tasa de aceptación del 3% visible: la cadena estuvo pegada en los mismos valores durante muchas iteraciones.

#probabilidades a 60 50 y 40 grados
for(temp in c(60,50,40)) {
  p_vals <- plogis(chain$alpha + chain$beta * temp)
  cat(sprintf("T = %d F: P(falla) = %.4f +- %.4f\n",
              temp, mean(p_vals), sd(p_vals)))
}

#┌─────────────┬──────────┬────────────────┐
#│ Temperatura │ P(falla) │ Error estándar │
#├─────────────┼──────────┼────────────────┤
#│ 60°F        │ 0.749    │ ± 0.156        │
#├─────────────┼──────────┼────────────────┤
#│ 50°F        │ 0.938    │ ± 0.097        │
#├─────────────┼──────────┼────────────────┤
#│ 40°F        │ 0.980    │ ± 0.057        │
#└─────────────┴──────────┴────────────────┘
