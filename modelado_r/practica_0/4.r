Ejercicio 4. ´Indices y asignaciones
Analizar cada una de las siguientes instrucciones y explicar qu´e es lo que hace.
x = 0:10; #vector x = c(0, 1, 2, ..., 10)

f = x*(10-x) # fi = xi(10-xi) 

f; #f es un vector de long 11

f[5:7]; #elementos 5, 6, and 7 de f (standard 1-based indexing).

f[6:11] = f[6]; # reemplaza las posiciones 6 a 11 de f con el valor de f[6]

f; # muestra el vector f ya modificado

x[11:1] # devuelve los elementos de x desde la posición 11 hasta la 1 (vector invertido)

x1 = (1:10)/(1:5); # división elemento a elemento con reciclado de (1:5) para alcanzar longitud 10

x1; # muestra el vector x1 resultante

x1[8] = pi; # asigna el valor pi al elemento en la posición 8 de x1

x1[6:8] # muestra los elementos 6, 7 y 8 de x1