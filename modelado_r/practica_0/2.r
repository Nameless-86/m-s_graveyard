#Ejercicio 2. Definiendo y operando con vectores
#Ejecutar cada una de las siguientes sentencias y explicar qu´e es lo que se obtiene en cada caso.

numeric(100);  #vector de 100 0s
numeric(10); # vector de 10 ceros
rep(0, 10); #es un loop que repite 0 10 veces
rep(10, 10); # loop que repite 10 10 veces

seq(0, 10);
seq(0, 10.5, by = 1); #loop de 0 a 10.5 que saltea de 1, se queda en 10
seq(0, 10, length = 11); #loop de 0 a 10 es lo mismo que seq(0, length = 11)

0:9.5; #loop de 0 a 9.5 termina en 9
-.5:10; #loop de -0.5 a 9.5,  
0:10 - .5; #loop de 0 a 10 pero le resta 0.5 a cada resultado
-1:9 + .5; # loop de -1 a 9 pero suma 0.5 a cada resultado
seq(-.5, 9.5) #loop de 0.5 a 9.5

-4:11; #loop de -4 a 11
4:-1; #loop de 4 a -1
4.5:10; #4.5 a 9.5
-4:-11.5

(10:22)/10;
10:22/10;
10/2:22;
(10/2):22;


seq(1, 2.2, by = 0.1); seq(by = 0.1, to = 2.2, from = 1)
seq(1, 2.2, length.out = 13); seq(1, 2.2, len = 13)

r = 1:5; s = -2:2; s/r; r/s; s/s

r^0; s^0; s^.5; 1000^1000; #?NaN

rep("No me gustan los lugares que venden comida chatarra con los juguetes", 20)

rep(1:4, times = 3); rep(1:4, each = 3)