# Ejercicio 6. Comparacion de vectores
# 1) Predecir y verificar lo que hacen las siguientes sentencias.

# Vector desde -1 hasta 1 con paso 0.1.
x4 <- seq(-1, 1, by = 0.1)

# Redondeo al entero mas cercano (convierte valores en -1, 0, 1, ...).
x5 <- round(x4)

# Mostrar los vectores.
x4 # Resultado: -1.0 -0.9 -0.8 -0.7 -0.6 -0.5 -0.4 -0.3 -0.2 -0.1 0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0
x5 # Resultado (redondeo): cinco -1, once 0, cinco 1

# Valores distintos que aparecen en x5.
unique(x5) # Resultado: -1 0 1

# Comparacion elemento a elemento: TRUE donde x5 vale 0.
x5 == 0 # Resultado: 5 FALSE, 11 TRUE, 5 FALSE

# Extraer solo los elementos de x5 que son 0.
x5[x5 == 0] # Resultado: 0 repetido 11 veces

# Contar cuantas posiciones cumplen x4 == x5.
sum(x4 == x5) # Resultado: 3

# Contar cuantas entradas de x5 son 0.
sum(x5 == 0) # Resultado: 11

# Longitud de x5 (numero de elementos).
length(x5) # Resultado: 21

# Proporcion de ceros en x5: mean(TRUE/FALSE) = fraccion de TRUE.
mean(x5 == 0) # Resultado: 11/21 = 0.5238095

# Forzar x5 a ser un vector de ceros y mostrarlo.
x5 <- 0
x5 # Resultado: vector de 21 ceros
###################################################################################################
###################################################################################################
###################################################################################################
# 2) Busqueda en una grilla para aproximar el maximo de la funcion
#    f(t) = 6(t - t^2), con t en [0, 1].
#    Comparar el resultado con la solucion analitica.

# Grilla con 201 puntos: incluye exactamente t = 0.5.
t <- seq(0, 1, len = 201)
f <- 6 * (t - t^2)

# Maximo aproximado en la grilla.
mx.f <- max(f)
mx.f # Resultado: 1.5

# Valores de t donde se alcanza ese maximo.
t[mx.f == f] # Resultado: 0.5 (aqui cae exactamente en la grilla)

# Graficar y marcar el/los maximos.
plot(t, f, type = "l", main = "f(t) = 6(t - t^2) (grilla)", xlab = "t", ylab = "f(t)")
points(t[mx.f == f], mx.f, pch = 19, col = "red")

# Solucion analitica:
# f(t) = 6t(1-t) tiene maximo en t = 1/2.
t_star <- 0.5
f_star <- 6 * (t_star - t_star^2)
t_star # Resultado analitico: 0.5
f_star # Resultado analitico: 1.5

# Mostrar que si en cambio usamos 200 puntos, el maximo en la grilla
# no cae exactamente en t=0.5 (por lo general), y puede no ser unico.
t2 <- seq(0, 1, len = 200)
f2 <- 6 * (t2 - t2^2)

mx.f2 <- max(f2)
mx.f2 # Resultado con len=200: 1.499962
t2[mx.f2 == f2] # Resultado: 0.4974874 0.5025126 (no cae unico)

# --------------------------------------------------------------------
# Explicacion (Ejercicio 6.2: busqueda de maximo en una grilla)
#
# La funcion es:
#   f(t) = 6(t - t^2) = 6t(1-t),  con t en [0,1]
#
# En el continuo, el maximo se puede obtener reescribiendo como cuadrado
# perfecto:
#   f(t) = 6(t - t^2)
#        = 6( - (t^2 - t) )
#        = -6( t^2 - t )
#        = -6( (t-1/2)^2 - 1/4 )
#        = -6(t-1/2)^2 + 6*(1/4)
#        = -6(t-1/2)^2 + 3/2
#
# Como (t-1/2)^2 >= 0, el termino -6(t-1/2)^2 <= 0 y el maximo ocurre
# cuando t = 1/2, dando:
#   f(1/2) = 3/2 = 1.5
#
# El codigo "aproxima" ese maximo evaluando f(t) en una grilla finita y
# eligiendo el maximo entre los valores muestreados (no el maximo real
# continuo, sino el maximo discreto).
#
# 1) Con len=201:
#    seq(0,1,len=201) genera puntos con paso 1/200, o sea t = 0 + k*(1/200).
#    Para k=100, t = 100/200 = 0.5, asi que la grilla incluye exactamente el
#    punto donde esta el maximo analitico. Por eso sale mx.f = 1.5 y el vector
#    t[mx.f == f] contiene solo 0.5.
#
# 2) Con len=200:
#    seq(0,1,len=200) tiene paso 1/199, que es distinto, y en general el
#    valor exacto 0.5 NO coincide con ninguno de los puntos de la grilla.
#    Entonces el maximo discreto ocurre en los puntos cercanos a 0.5.
#
#    Debido a que la funcion es simetrica alrededor de t=0.5 (porque depende
#    de (t-1/2)^2), los dos puntos equidistantes a ambos lados producen el
#    mismo valor de f (o valores que coinciden por muestreo), por eso aparecen
#    dos "maximos" en t2[mx.f2 == f2]: 0.4974874 y 0.5025126.
# --------------------------------------------------------------------