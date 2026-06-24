#ejemplo de mh generico del libro, generar una Beta(2.7, 6.3) con propuesta uniforme(0.1)
# se propone un candidato desde uniforme(0,1)
# se acepta o rechaza segun que tan probable es que caiga en la beta(2.7, 6.3)

#el resultado va a ser una distribucion beta, pero jamas sampleamos de ella
a <- 2.7
b <- 6.3
Nsim <- 5000
X <- rep(runif(1), Nsim)

# X[1] -> me da 0.84, beta(2.7,6.3) tiene moda 0.27
#hacemos el loop de la cadena

for (i in 2:Nsim) {
  Y <- runif(1) #candidato propuesto en la iteracion, num aleatorio
  rho <- dbeta(Y, a, b) / dbeta(X[i-1], a,b)
  X[i] <- X[i-1] + (Y - X[i-1]) * (runif(1) < rho)
}

#rho, que tan probable es Y bajo Beta, dividido que tan probable es el estado actual
# X[i-1] bajo la Beta, si Y esta en una zona mas densa rho > 1, se acepta siempre
# si esta en una zona de rho < 1, menos probable que el estado actual, si rho es 0.3 se acepta el 30% de las veces, acepta con probabilidad proporcional a que tan peor es
#esto es para que la cadena explore zonas de baja densidad
# si rho es 0 se rechaza 

#ej estoy en X[i-1] 0.84, Y propone 0.30, Y esta mas cerca de la moda
#dbeta(0.30) > dbeta (0.84) -> rho > 1, acepta siempre

#grafico 
hist(X, breaks = 50, freq = FALSE,
     main = "MH genérico — target Beta(2.7, 6.3)",
     xlab = "x", col = "gray90")
curve(dbeta(x, a, b), add = TRUE, col = "red", lwd = 2)

#en el libro se hace un test de KS es para comprar dos muestras y ver si vienen de la misma distribucion

#> ks.test(jitter(X), rbeta(5000, a, b))
#
#	Asymptotic two-sample Kolmogorov-Smirnov test
#
#data:  jitter(X) and rbeta(5000, a, b)
#D = 0.0276, p-value = 0.04435
#alternative hypothesis: two-sided

# D 0.0276, mientras mas cerca de 0 mas similares son
# p-value = 0.044, probabilidad de ver esa diferencia si las dos muestras vienen de la misma distribucion, por lo general p < 0.05 se rechaza, este justo esta al limite

#el haber arrancado en 0.84 afecta al p val, ya que las primeras iteraciones fueron ahi

#trace plot para ver como se movio la cadena
plot(X, type = "l", col = "steelblue", lwd = 0.5,
     main = "Trace plot — MH genérico Beta(2.7, 6.3)",
     xlab = "Iteración", ylab = "X")
abline(h = 0.27, col = "red", lty = 2)
#del grafico se nota que oscila rapido, no se estanca, baja autocorrelacion, la linea roja esta en 0.27, esto significa que la cadena esta mas tiempo cerca de la moda que de los extremos, muy bien 
