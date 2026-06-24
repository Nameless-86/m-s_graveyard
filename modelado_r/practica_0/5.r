#Ejercicio 5. Funciones vectoriales
#1. Predecir y verificar que es lo que hace cada una de las siguientes sentencias.

length(0:5); # longitud (numero de elementos) del vector 0:5  -> Resultado: 6

diff(0:5); # diferencia "entre vecinos": (x[i+1] - x[i]) -> Resultado: 1 1 1 1 1

length(diff(0:5)); # la longitud de diff es 1 menor que la del vector original -> Resultado: 5

diff((0:5)^2) # diff aplicada al vector de cuadrados (0:5)^2 -> Resultado: 1 3 5 7 9

x2 = c(1, 2, 7, 6, 5); # vector original

cumsum(x2); # suma acumulada: (x2[1], x2[1]+x2[2], ...) -> Resultado: 1 3 10 16 21

diff(cumsum(x2)) # diff de la suma acumulada: recupera diferencias entre acumulados -> Resultado: 2 7 6 5

unique(-5:5); # elimina duplicados y devuelve solo valores distintos -> Resultado: -5 -4 -3 -2 -1 0 1 2 3 4 5

unique((-5:5)^2); # valores distintos de los cuadrados de -5:5 -> Resultado: 25 16 9 4 1 0

length(unique((-5:5)^2)) # cantidad de valores distintos al cuadrar -5:5 -> Resultado: 6

prod(1:5); # producto de los elementos del vector 1:5 -> Resultado: 120

factorial(5); # 5! (factorial de un escalar) -> Resultado: 120

factorial(1:5) # factorial elemento a elemento para el vector 1:5 -> Resultado: 1 2 6 24 120


###################################################################################################
###################################################################################################
#2. Las siguientes sentencias aproximan el numero e2 sumando los primeros 11 terminos de
#la serie de Taylor (MacLaurin) ex = ∑∞ j=0 xj j! , con x = 2. Modificar el codigo para hallar
#el minimo n tal que el error de aproximacion por ∑n j=0 xj j! sea menor a 10^−6.
# Aproximacion de e^2 usando la serie de Taylor de exp(x)

a1 = exp(2) # valor "exacto" (hasta precision numerica de R)

# Queremos el n minimo tal que | a1 - sum_{j=0}^n 2^j/j! | < 1e-6
tope = 1e-6

# Calculamos terminos incrementalmente para evitar overflow de factorial.
n = 0
term = 1 # termino j=0: 2^0/0! = 1
aprox = term

while (abs(a1 - aprox) >= tope) {
  n = n + 1
  term = term * 2 / n # termino j = n usando recurrencia
  aprox = aprox + term
  if (n > 10000) stop("No se alcanzó la tolerancia (revisar tope o revisar el bucle).")
}

n # Resultado: 13
aprox # Resultado: 7.389056
a1 - aprox # Resultado: 2.165414e-07

# --------------------------------------------------------------------
# Explicacion (que se esta haciendo realmente en el Ejercicio 5.2)
#
# Usamos la identidad de la serie de Taylor:
#   exp(x) = sum_{j=0}^infty x^j / j!
# Si tomamos x = 2, entonces exp(2) = e^2.
#
# La aproximacion con suma parcial es:
#   aprox_n = sum_{j=0}^n 2^j / j!
# El ejercicio pide el menor n tal que el error absoluto sea menor que 1e-6:
#   | exp(2) - aprox_n | < 1e-6
#
# En vez de calcular cada termino con factorial( n ), acumulamos usando una
# recurrencia para mantener el calculo estable y eficiente:
#   termino_0 = 1
#   termino_j = termino_{j-1} * 2 / j
# porque:
#   (2^j / j!) = (2^(j-1) / (j-1)!) * 2 / j
#
# El while va sumando terminos hasta que la condicion de error se cumple.
# Al final, n indica cuantas iteraciones fueron necesarias (terminos j=0..n)
# para que la aproximacion quede suficientemente cerca de exp(2).
# --------------------------------------------------------------------