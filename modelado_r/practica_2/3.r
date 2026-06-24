# Glosario:
# - Formula: r_(i+1) = (a * r_i + b) mod d
# - GCL: generador congruencial lineal. vamos a obtener los numeros siguientes en base a los anteriores
# - r_i: i-esimo numero entero generado por el GCL. ()
# - a: multiplicador del generador. entero positivo que no tenga factores comunes con m, evitar multiplos de 2 
# - b: incremento del generador (aca b = 0).se recomienda un valor impar y pequeño
# - d: modulo del generador (aca d = 53). tiene que ser un primo grande o potencia de dos para garantizar buena distribucion de los numeros generados, evita ciclos cortos
# un modulo chico puede dar un ciclo corto y secuencia repetitiva
# - s: semilla inicial (valor de r_1). necesitas arrancar con un numero menor a d 
# - m: cantidad de valores a generar.
# - u_i: version reescalada de r_i al intervalo (0, 1).
# - distintos: cantidad de valores no repetidos en la secuencia, medida con length(unique(r)).
# b = 0 implica un generador multiplicativo y ri no puede tomar el valor 0


# Enunciado:
# Explorar un generador congruencial lineal con b = 0 y d = 53, generando m = 60 valores.
# En cada caso, usar:
# - length(unique(r)) para contar cuantos numeros distintos aparecen.
# - u = (r - 1/2)/(d - 1), y luego graficar pares consecutivos (u_i, u_(i+1)).
# Partes:
# a) a = 23 con s = 21, y luego a = 23 con s = 5.
# b) s = 21 con a = 15, y luego s = 21 con a = 18.
# c) a = 22 y luego a = 26, en cada caso con semilla s a eleccion.

# Ejercicio 3 - Explorando generadores de congruencia lineal

gcl <- function(a, s, m = 60, d = 53, b = 0) { # Generador congruencial lineal basico.
  r <- numeric(m) # Vector para guardar la secuencia r_i.
  r[1] <- s # Cargo semilla inicial.
  for (i in 1:(m - 1)) { # Genero m-1 valores adicionales.
    r[i + 1] <- (a * r[i] + b) %% d # formula del enesimo termino del GCL. Formula: r_(i+1) = (a * r_i + b) mod d
  }
  r # devuelve el vector
}

analizar_caso <- function(a, s, m = 20000, d = 2147483648, b = 0, titulo = "") { # Ejecuta y resume un caso.
  r <- gcl(a = a, s = s, m = m, d = d, b = b) # Genero secuencia de enteros.
  distintos <- length(unique(r)) # Cuento cantidad de valores distintos observados.
  u <- (r - 1 / 2) / (d - 1) # Reescaleo de r a valores en (0, 1) segun consigna.
  u1 <- u[1:(m - 1)] # Primer componente del par consecutivo.
  u2 <- u[2:m] # Segundo componente del par consecutivo.
  plot(u1, u2, pch = 19, cex = 0.8, col = "navy", # Grafico 2d
       xlab = "u_i", ylab = "u_(i+1)",
       main = paste0(titulo, " | distintos = ", distintos))
  list(r = r, u = u, distintos = distintos) # Devuelvo resultados para inspeccion.
}

m <- 20000 # Cantidad de valores a generar en cada corrida.
d <- 2147483648 # Modulo dado en el enunciado.
b <- 0 # Incremento multiplicativo puro. b: incremento del generador (aca b = 0).se recomienda un valor impar y pequeño b = 0 implica un generador multiplicativo y ri no puede tomar el valor 0
 
# - GCL: generador congruencial lineal. vamos a obtener los numeros siguientes en base a los anteriores

# - d: modulo del generador (aca d = 53). tiene que ser un primo grande o potencia de dos para garantizar buena distribucion de los numeros generados, evita ciclos cortos
# un modulo chico puede dar un ciclo corto y secuencia repetitiva
# - u_i: version reescalada de r_i al intervalo (0, 1).
# - distintos: cantidad de valores no repetidos en la secuencia, medida con length(unique(r)).
# - s: semilla inicial (valor de r_1). necesitas arrancar con un numero menor a d 
# - a: multiplicador del generador
# Parte a) a = 23, con s = 21 y s = 5.
par(mfrow = c(1, 2)) # Dos graficos lado a lado para comparar.
caso_a1 <- analizar_caso(a = 23, s = 21, m = m, d = d, b = b, titulo = "a1: a=23, s=21")
caso_a2 <- analizar_caso(a = 23, s = 5, m = m, d = d, b = b, titulo = "a2: a=23, s=5")
par(mfrow = c(1, 1)) # Restauro panel grafico.
caso_a1$distintos # Numero de distintos para a=23, s=21.
caso_a2$distintos # Numero de distintos para a=23, s=5.

# Interpretacion parte a) (graficos a1 y a2):
# Con a = 23 y d = 53, ambos casos dan length(unique(r)) = 4: el GCL(generador congruencial lineal) multiplicativo entra en un
# ciclo muy corto (periodo 4) antes de generar los 60 valores. 

# Parte b) s = 21, con a = 15 y a = 18.
par(mfrow = c(1, 2)) # Dos graficos lado a lado para comparar.
caso_b1 <- analizar_caso(a = 15, s = 21, m = m, d = d, b = b, titulo = "b1: a=15, s=21")
caso_b2 <- analizar_caso(a = 18, s = 21, m = m, d = d, b = b, titulo = "b2: a=18, s=21")
par(mfrow = c(1, 1)) # Restauro panel grafico.
caso_b1$distintos # Numero de distintos para a=15, s=21.
caso_b2$distintos # Numero de distintos para a=18, s=21.

# Interpretacion parte b) (graficos b1 y b2):
# b1 (a = 15): distintos = 13. El periodo sigue siendo corto; el grafico muestra pocos puntos
# dispersos sin llenar el cuadrado. Es otro generador debil: poca variedad de estados antes
# de repetir.
# b2 (a = 18): distintos = 52 (casi el maximo posible con d = 53 y ri distinto de 0)

# Parte c) a = 22 y a = 26, con semillas a eleccion.
# Elijo semillas no nulas para evitar secuencia trivial constante en 0.
par(mfrow = c(1, 2)) # Dos graficos lado a lado para comparar.
caso_c1 <- analizar_caso(a = 65539, s = 10, m = m, d = d, b = b, titulo = "c1: a=65539, s=10")
caso_c2 <- analizar_caso(a = 26, s = 11, m = m, d = d, b = b, titulo = "c2: a=26, s=11")
par(mfrow = c(1, 1)) # Restauro panel grafico.
caso_c1$distintos # Numero de distintos para a=22, s=7.
caso_c2$distintos # Numero de distintos para a=26, s=11.

# Interpretacion parte c) (graficos c1 y c2):
# Ambos llegan a distintos = 52, es decir recorren casi todos los residuos no nulos modulo 53.
# c1 (a = 22, s = 7): la nube de puntos ocupa mejor el cuadrado [0,1]^2; puede verse una rejilla
# leve propia de cualquier GCL, pero no domina un patron de lineas paralelas tan extremo.
# c2 (a = 26, s = 11): con el mismo numero de valores distintos, todos los pares consecutivos
# se concentran en dos rectas paralelas con pendiente negativa. Eso indica correlacion casi
# lineal entre u_i y u_(i+1): el generador es predecible en el plano lag-1 pese al periodo largo.
# Conclusion de la parte c): no basta mirar length(unique(r)); hay que mirar el grafico 2D para
# ver si los pares sucesivos se reparten bien o quedan atrapados en pocas rectas.

# Resumen comparativo de todos los casos.
resumen <- data.frame(
  caso = c("a1_a23_s21", "a2_a23_s5", "b1_a15_s21", "b2_a18_s21", "c1_a22_s7", "c2_a26_s11"),
  distintos = c(caso_a1$distintos, caso_a2$distintos, caso_b1$distintos,
                caso_b2$distintos, caso_c1$distintos, caso_c2$distintos)
) # Tabla compacta para comparar periodos observados.
resumen # Muestro resultados finales en tabla.

# Sintesis (cruza partes a, b y c):
# La eleccion de (a, s) define periodo, orbita y geometria en el plano (u_i, u_(i+1)).
# Misma a y distinta s (parte a): misma longitud de ciclo, distinta posicion de los pocos puntos.
# Misma s y distinta a (parte b): puede pasar de periodo corto a periodo largo pero con red fuerte.
# Mismo "distintos" maximo (parte c) no garantiza buena calidad: c2 muestra falla espectral fuerte.




#Fila	caso	Significado breve
#1	a1_a23_s21	Parte a, a=23, s=21 → solo 4 enteros distintos (ciclo muy corto).
#2	a2_a23_s5	Parte a, a=23, s=5 → otra semilla, mismo número de distintos (4): misma “mala” longitud de órbita.
#3	b1_a15_s21	Parte b, a=15, s=21 → 13 distintos (periodo aún corto).
#4	b2_a18_s21	Parte b, a=18, s=21 → 52 distintos (casi todos los no nulos mod 53).
#5	c1_a22_s7	Parte c, a=22, s=7 → 52 distintos.
#6	c2_a26_s11	Parte c, a=26, s=11 → 52 distintos.