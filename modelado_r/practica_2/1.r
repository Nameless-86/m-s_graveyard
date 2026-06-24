# Enunciado:
# Antes de los generadores congruenciales lineales, se uso el metodo de cuadrados medios.
# Regla: partir de una semilla r1 con cantidad par de digitos, elevar al cuadrado, completar
# con ceros a la izquierda hasta tener el doble de digitos y tomar la mitad central como r2.
# Repetir para obtener r3, r4, etc.
# Consignas:
# - Empezar con r1 = 23, verificar que r2 = 52 y demostrar que r3 = 70.
# - Continuar la secuencia hasta detectar un problema del metodo.
# - Repetir comenzando con r1 = 19.

# Ejercicio 1 - Antes de los generadores de congruencia lineal

extraer_centro <- function(r, d = 2) { # Funcion para obtener d digitos centrales de r^2.
  cuadrado <- r^2 # Elevo la semilla al cuadrado.
  texto <- sprintf(paste0("%0", 2 * d, "d"), cuadrado) # Completo con ceros a izquierda.
  inicio <- d / 2 + 1 # Posicion inicial del bloque central.
  fin <- inicio + d - 1 # Posicion final del bloque central.
  as.integer(substr(texto, inicio, fin)) # Convierto el bloque central a entero.
}

# Parte A: secuencia iniciando en r1 = 23.
r <- numeric(12) # Reservo espacio para varios terminos.
r[1] <- 23 # Fijo semilla pedida por el ejercicio.

for (i in 1:(length(r) - 1)) { # Genero terminos sucesivos con cuadrados medios.
  r[i + 1] <- extraer_centro(r[i], d = 2) # Tomo los 2 digitos centrales.
}

r # Muestro secuencia completa para inspeccion.

r[2] # Verifica r2 = 52.
r[3] # Verifica r3 = 70.

# Parte B: secuencia iniciando en r1 = 19.
r_alt <- numeric(12) # Reservo espacio para segunda secuencia.
r_alt[1] <- 19 # Segunda semilla pedida.

for (i in 1:(length(r_alt) - 1)) { # Repito el mismo proceso.
  r_alt[i + 1] <- extraer_centro(r_alt[i], d = 2) # Actualizo por cuadrados medios.
}

r_alt # Muestro secuencia para detectar el problema.

# Visualizacion 1: evolucion de ambas secuencias en el tiempo.
par(mfrow = c(1, 2)) # Divido la ventana grafica en 1 fila y 2 columnas.

plot(1:length(r), r, type = "b", pch = 19, col = "blue", # Grafico indice vs valor para semilla 23.
     xlab = "i", ylab = "r_i", main = "Cuadrados medios (r1 = 23)")
abline(h = 10, col = "red", lty = 2) # Marco el valor fijo donde queda atrapada la secuencia.

plot(1:length(r_alt), r_alt, type = "b", pch = 19, col = "darkgreen", # Grafico indice vs valor para semilla 19.
     xlab = "i", ylab = "r_i", main = "Cuadrados medios (r1 = 19)")
abline(h = 0, col = "red", lty = 2) # Marco el punto fijo 0 al que converge la secuencia.

par(mfrow = c(1, 1)) # Restauro una sola figura por ventana.

# Visualizacion 2: diagrama de transicion r_i -> r_(i+1).
plot(r[-length(r)], r[-1], pch = 19, col = "blue", # Pares consecutivos para semilla 23.
     xlab = "r_i", ylab = "r_(i+1)", main = "Transiciones (r1 = 23)")
text(r[-length(r)], r[-1], labels = 1:(length(r) - 1), pos = 4, cex = 0.7) # Etiqueto orden temporal.

plot(r_alt[-length(r_alt)], r_alt[-1], pch = 19, col = "darkgreen", # Pares consecutivos para semilla 19.
     xlab = "r_i", ylab = "r_(i+1)", main = "Transiciones (r1 = 19)")
text(r_alt[-length(r_alt)], r_alt[-1], labels = 1:(length(r_alt) - 1), pos = 4, cex = 0.7) # Etiqueto orden temporal.

# Explicacion general:
# El metodo de cuadrados medios cae rapido en ciclos cortos o puntos fijos.
# Con semilla 23 la secuencia llega a 10 y queda atrapada en 10 para siempre.
# Con semilla 19 la secuencia termina en 00 y luego permanece en 00.
# Esto muestra mala calidad pseudoaleatoria (periodo corto y degeneracion), por eso
# historicamente fue reemplazado por metodos mas robustos como los congruenciales.