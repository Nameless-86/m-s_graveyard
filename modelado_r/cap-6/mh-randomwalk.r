# ejemplo de cauchy pero con mh random walk en vez de independiente

Nsim <- 10^4
delta <- 2 #perturbacion
X3 <- rep(rt(1, df=1), Nsim)

for (t in 2:Nsim){
  Y <- runif(1, X3[t-1] - delta, X3[t-1] + delta) # propone cerca del estado actual
  rho <- dt(Y, df=1) / dt(X3[t-1], df=1) #solo el target porque q se cancela
  X3[t] <- X3[t-1] + (Y -X3[t-1]) * (runif(1) < rho)
}

#cauchy con uniformce centrada
# Random walk propone Y cerca de X[t-1], si la cadena esta en 5, lo propone entre 4 y 6
#q en el mh generico q=uniforme(0,1) es cte, da lo mismo evaluear en Y o en X
#en el random walk q(Y|X) = 1/2(2*delta) es cte tambien
# el intervalo siempre tiene el mismo ancho
#en el independiente q(Y) != q(X) porque la beta da distinta densidad en distintos puntos

#rho siempre mantiene la misma idea, que tan probable es el candidato dividido que tan probable es el estado actual, si el candidato esta en una zona mas densa que el target
#rho > 1 y se acepta siempre

#graficos

par(mfrow = c(1, 2))
plot(X3, type="l", col="darkgreen", lwd=0.5,
     main="Trace Random Walk", xlab="Iteracion", ylab="X", ylim=c(-10,10))
hist(X3, breaks=80, freq=FALSE, col="gray90",
     main="Histograma Random Walk", xlab="x", xlim=c(-10,10))
curve(dt(x, df=1), add=TRUE, col="red", lwd=2)
par(mfrow = c(1, 1))

#
#┌─────────────────┬──────────────────┬────────────┬───────────────┐
#│                 │     delta=1      │  delta=2   │    delta=5    │
#├─────────────────┼──────────────────┼────────────┼───────────────┤
#│ Tasa aceptación │ ~85%             │ ~73%       │ ~30%          │
#├─────────────────┼──────────────────┼────────────┼───────────────┤
#│ Problema        │ pasos muy chicos │ sesgo leve │ rechaza mucho │
#└─────────────────┴──────────────────┴────────────┴───────────────┘
#
