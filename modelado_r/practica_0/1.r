#Ejercicio 1. R como calculadora
#Predecir los resultados de cada una de las sentencias siguientes de R y luego verificar las res-
#puestas. La constante pi respresenta al numero π = 3·141593 . . . y las funciones exp, log,
#log10, log2, sin y tan tienen sus significados obvios, aunque por cualquier duda se puede
#consultar la ayuda respectiva haciendo ?exp, etc.

2 + 5^2 - 4^2; 2 / (5^2 - 4)^2    # 11 ; 2/441 ≈ 0.004535147  
#(suma/resta con potencias; fracción con potencias)

2 + (3^2 + 4^2)^(2/4); 2 * (3^2 - 4^2)^2 / 4    # 7 ; 24.5  
#(usa paréntesis y potencias; diferencia de cuadrados elevada al cuadrado)

exp(1); exp(1)^2; exp(2); log(exp(2))           # ≈ 2.71828 ; ≈ 7.38906 ; ≈ 7.38906 ; 2  
#(función exponencial y logaritmo natural inverso de exp)

log10(10^10); log2(1024); log10(10^(1:5))       # 10 ; 10 ; c(1, 2, 3, 4, 5)  
#(logaritmos en base 10 y 2; vector de logaritmos)

pi; sin(pi/2); tan(pi/4)                        # ≈ 3.14159 ; 1 ; 1  
#(constante pi y funciones trigonométricas en radianes)