#misma idea que el generico
#target beta(2.7,6,3) desde otra Beta(2,5)
#soporte: se refiere a los vlaores donde la densidad de la distribucion es mayor a 0
# basicamente que valroes puede geenrar
a_target <- 2.7
b_target <- 6.3
a_prop <- 2
b_prop <- 5

Nsim <- 5000
X <- rep(runif(1), Nsim)

for(i in 2:Nsim){
  Y <- rbeta(1, a_prop, b_prop) #aca tenes que proponer desde donde
  rho <- (dbeta(Y, a_target, b_target) / dbeta(X[i-1], a_target, b_target)) *  ((dbeta(X[i-1], a_prop, b_prop)) / dbeta(Y, a_prop, b_prop)) 
  X[i] <- X[i-1] + (Y - X[i-1]) * (runif(1) < rho)
}

#grafico
hist(X, breaks = 50, freq = FALSE,
     main = "MH independiente — target Beta(2.7, 6.3)",
     xlab = "x", col = "gray91")
curve(dbeta(x, a_target, b_target), add = TRUE, col = "red", lwd = 2)
curve(dbeta(x, a_prop, b_prop), add = TRUE, col = "blue", lwd = 2, lty = 2)
legend("topright", legend = c("target", "propuesta"),
       col = c("red", "blue"), lty = c(2, 2), bty = "n")

#azul propuiesta, target rojo
#la propuesta no necesita ser igual al target, solo cubrir su soporte

#tasa de aceptacion
acc <- sum(diff(X) != 0) / (Nsim -1)
cat(sprintf("Tasa de aceptacion: %.3f\n", acc)) #da 0.9 casi, puede ser en base a que las dsitribuciones son muy parecidas

#
#comparacion de rho generico e independiente
#MH Genérico (propuesta Uniforme):
#rho <- dbeta(Y, a, b) / dbeta(X[i-1], a, b)
#
#MH Independiente (propuesta Beta(2,5)):
#rho <- (dbeta(Y,      a_target, b_target) / dbeta(X[i-1], a_target, b_target)) *
#       (dbeta(X[i-1], a_prop,   b_prop)   / dbeta(Y,      a_prop,   b_prop))
#
#La diferencia es que el independiente tiene dos términos multiplicados y el genérico uno solo.
#
#Pero en realidad son la misma fórmula. El ratio completo siempre es:
#
#rho = [f(Y) / f(X)] × [g(X) / g(Y)]


#ejemplo 6.2 de simalr cauchy
#target cauchy C(0,1) #cola pesada
#prop normal N(0,1) #no tiene valores extremos por lo gral
Nsim <- 10^4
X <- c(rt(1, df=1)) #rt(1, df=1) genera un valor de la distribución t con 1 grado de libertad, que es exactamente la Cauchy C(0,1). Es la función de R para samplear de una t
#no runif porque cauchy tiene soporte de -inf a + inf, runif da de 0 a 1
X <- rep(X, Nsim)

for (t in 2:Nsim) {
  Y <- rnorm(1)
  rho <- dt(Y, df=1) * dnorm(X[t-1]) / (dt(X[t-1], df=1) * dnorm(Y))
  X[t] <- X[t-1] + (Y- X[t-1]) * (runif(1) < rho)
}


plot(X, type="l", col="steelblue", lwd=0.5,
     main="Trace plot — Cauchy con propuesta Normal",
     xlab="Iteración", ylab="X")
#trace plot
#tarda mucho en arrancar ya que la normal no propone valores tan extremos
#la cadena arranco en -5, despues llega a un valor extremo a las 8 mil oscilaciones
# 4 tambien es un extremo para la normal y se estanca de vuelta
#despues se va


#solucion del libro
X2 <- rep(rt(1, df=1), Nsim)
for (t in 2:Nsim) {
  Y    <- rt(1, df=0.5)
  rho  <- dt(Y, df=1) * dt(X2[t-1], df=0.5) / (dt(X2[t-1], df=1) * dt(Y, df=0.5))
  X2[t] <- X2[t-1] + (Y - X2[t-1]) * (runif(1) < rho)
}
plot(X2, type="l", col="darkorange", lwd=0.5,
     main="Trace plot — Cauchy con propuesta t(0.5)",
     xlab="Iteración", ylab="X")


#histogramas y trace plots

par(mfrow = c(2, 2))

plot(X, type="l", col="steelblue", lwd=0.5,
     main="Trace Normal", xlab="Iteracion", ylab="X", ylim=c(-10,10))

plot(X2, type="l", col="darkorange", lwd=0.5,
     main="Trace t(0.5)", xlab="Iteracion", ylab="X", ylim=c(-10,10))

hist(X, breaks=80, freq=FALSE, col="gray90",
     main="Histograma Normal", xlab="x", xlim=c(-10,10))
curve(dt(x, df=1), add=TRUE, col="red", lwd=2)

X2_plot <- X2[X2 > -10 & X2 < 10]
hist(X2_plot, breaks=80, freq=FALSE, col="gray90",
     main="Histograma t(0.5)", xlab="x",
     xlim=c(-10,10), ylim=c(0,0.4))
curve(dt(x, df=1), add=TRUE, col="red", lwd=2)


par(mfrow = c(1, 1))

#Trace Normal (azul):
#La cadena arrancó en -6 y se quedó pegada hasta la iteración ~1200. Después escapó y mezcla razonablemente, pero tiene dos períodos más donde se traba — la barra horizontal cerca de iteración 7500. La propuesta Normal no puede proponer valores extremos, entonces cuando la cadena llega a las colas de la Cauchy queda atrapada.
#
#Trace t(0.5) (naranja):
#Mezcla desde el principio y llega regularmente a -10 y +10. El problema es el inverso — propone valores demasiado extremos frecuentemente, incluyendo ese ~40000 que tuvimos que filtrar. La cadena nunca se traba pero tampoco es estable.
#
#Histograma Normal:
#Dos barras aisladas a -5 y +4 — exactamente los períodos de atascamiento del trace. El centro sigue bien la Cauchy roja pero adas.
#
#Histograma t(0.5):
#El mejor ajuste de los dos. La inciden bien en el centro y enlas colas. El precio es ese valxiste en la cadena pero noaparece en el gráfico.Conclusión: ninguna propuesta en las colas, la t(0.5) proponevalores absurdos. La t(2) que cntermedio.
