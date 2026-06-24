# Enunciado:
# Como alternativa para el problema de coincidencias de cumpleanos:
# 1) Ejecutar y explicar:
#    a = c(5, 6, 7, 6, 8, 7); length(a); unique(a)
#    length(unique(a)); length(a) - length(unique(a))
#    duplicated(a); length(duplicated(a)); sum(duplicated(a))
# 2) Proponer e implementar una alternativa a la vista en clase para aproximar
#    por simulacion la distribucion del numero de coincidencias.
#
# Ejercicio 4 - Coincidencia de cumpleanos con duplicated

a <- c(5, 6, 7, 6, 8, 7) # Vector de ejemplo con valores repetidos.
length(a) # Largo total del vector.
unique(a) # Valores unicos preservando orden de primera aparicion.
length(unique(a)) # Cantidad de valores distintos.
length(a) - length(unique(a)) # Numero de coincidencias por diferencia de largos.
duplicated(a) # Marca TRUE desde la segunda aparicion de cada valor repetido.
length(duplicated(a)) # Largo del vector logico devuelto por duplicated.
sum(duplicated(a)) # Numero total de elementos repetidos (coincidencias).

# Simulacion alternativa del problema de cumpleanos usando duplicated.
set.seed(30) # Fijo semilla para reproducibilidad.
B <- 100000 # Numero de grupos simulados.
n <- 25 # Tamano del grupo.
x <- numeric(B) # Guardo cantidad de coincidencias por grupo.

for (i in 1:B) { # Recorro simulaciones.
  m <- sample(1:365, n, replace = TRUE) # Simulo n cumpleanos uniformes con reemplazo.
  x[i] <- sum(duplicated(m)) # Cuento coincidencias usando duplicated.
}

table(x) / B # Aproximo distribucion del numero de coincidencias.
mean(x) # Estimo numero esperado de coincidencias.
mean(x >= 1) # Estimo probabilidad de al menos una coincidencia.

# Explicacion general:
# duplicated() es una alternativa directa y clara para contar repeticiones:
# cada TRUE representa una coincidencia adicional respecto de la primera vez
# que aparece ese dia. En simulacion de cumpleanos, sum(duplicated(m))
# calcula rapido cuantas coincidencias hay en cada grupo y permite estimar
# tanto la distribucion completa como probabilidades de interes.
