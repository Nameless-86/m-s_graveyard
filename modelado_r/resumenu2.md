---

## 1. Introducción

La presentación parte de una idea clave del curso: en muchos problemas de probabilidad y estadística, modelar es relativamente simple, pero obtener soluciones exactas puede ser muy difícil o directamente imposible. Por eso se usan métodos de simulación (Monte Carlo), que reemplazan cálculos analíticos complicados por repeticiones masivas de procedimientos computables.

Para hacer simulación probabilística se necesitan números aleatorios. Históricamente se generaban con dispositivos físicos (monedas, dados, cartas, ruido electrónico), pero esos métodos son lentos para las escalas actuales (cientos de miles o millones de valores). Entonces se utilizan algoritmos determinísticos que producen secuencias con comportamiento "suficientemente aleatorio" para fines prácticos: los números pseudoaleatorios.

La presentación se organiza en dos grandes bloques:

1. Cómo generar y validar secuencias pseudoaleatorias Uniforme(0,1).
2. Cómo transformar variables Uniforme(0,1) en otras distribuciones de interés.

---

## 2. Generadores de congruencia lineal (GCL)

Se presenta el generador congruencial lineal:

`r_(i+1) = (a * r_i + b) mod d`

donde:
- `a`: multiplicador
- `b`: incremento
- `d`: módulo
- `r_1 = s`: semilla inicial

La operación `mod` devuelve el resto de la división por `d`.  
Si `b = 0`, el generador es **multiplicativo**.

### Ideas importantes

- El método es computacionalmente barato y rápido.
- Es totalmente determinístico: misma semilla y mismos parámetros implican exactamente la misma secuencia.
- Aunque no produce aleatoriedad "real", puede comportarse como tal si está bien diseñado.

### Ejemplo: "barajado" de cartas

Se modela un mazo como números 1 a 52 y se usa un GCL con `d = 53`.

- Con `a = 20, b = 0, s = 21`, la secuencia recorre los 52 valores antes de repetirse (período completo).
- Con `a = 23`, el período cae a 4 (secuencia muy mala para simular barajado).

Además, aunque un generador tenga período completo, eso no garantiza buen barajado real: cambia la primera carta con la semilla, pero mantiene patrones estructurales en el orden subsiguiente. El material enfatiza que el espacio de permutaciones alcanzable puede ser minúsculo comparado con `52!`.

---

## 3. Propiedades deseables y validación de un generador

Los valores enteros `r_i` se reescalan con:

`u_i = (r_i + 0.5) / d`

para trabajar en `(0,1)`. Se buscan secuencias que se comporten como i.i.d. Uniforme(0,1).

### Propiedades deseables

1. **Período largo** (idealmente mucho mayor que la cantidad de valores que se van a usar).
2. **Uniformidad** (histograma compatible con Unif(0,1)).
3. **Independencia** (al menos de a pares y, en general, en dimensiones superiores).

### Diagnósticos gráficos

- Histograma de `u_i`.
- Nube de puntos `(u_i, u_(i+1))`, que debería "llenar" el cuadrado unitario sin patrones visibles.

Se aclara que en GCL siempre existe una estructura de rejilla; lo importante es que sea lo bastante fina para no generar sesgos detectables a la escala de trabajo.

### Ejemplo 2: "bastante bueno", pero insuficiente

Con parámetros `a = 1093, b = 18257, d = 86436, s = 7`:
- Período completo de 86436.
- Con `m = 1000`, el comportamiento parece aceptable.
- Con `m = 50000`, aparecen señales problemáticas:
  - Histograma "demasiado perfecto" (variabilidad sospechosamente baja).
  - Estructura de rejilla visible al hacer zoom en gráficos bivariados.

Conclusión: un generador puede parecer bueno en inspecciones superficiales y aun así fallar en usos exigentes.

### Ejemplo 3: RANDU de IBM

RANDU (`a = 65539, d = 2^31, b = 0`) fue muy usado y luego desacreditado.

- En histogramas y gráficos 2D puede no mostrar fallas claras.
- En 3D (analizando triples `(u_i, u_(i+1), u_(i+2))`) se observa concentración en pocos planos.

Lección histórica: no alcanza con revisar 1D/2D; hay que evaluar estructura en dimensiones más altas y con baterías de pruebas.

### Ejemplo 4: `runif` y generador de R

Se destaca que `runif` usa Mersenne Twister (según el material), con período enorme y muy buen comportamiento práctico.  
En contraste con RANDU, se comporta mejor también en análisis de mayor dimensión.

---

## 4. Transformaciones de variables Uniformes

Se explica que muchos procedimientos aleatorios en R se apoyan en `runif`, y que a partir de Uniforme(0,1) se puede construir una gran variedad de distribuciones.

### Ejemplos introductorios

- Si `U ~ Unif(0,1)`, entonces `(b-a)*U + a ~ Unif(a,b)`.
- Simulación de dados/cartas:
  - Puede hacerse con `runif` + `ceiling`.
  - Pero en R suele ser preferible `sample` (especialmente sin reposición).

### Binomial por indicadores

Para `X ~ Bin(n,p)`, una idea básica es:

`X = sum_{i=1..n} 1{U_i < p}`

con `U_i ~ Unif(0,1)` independientes.

Es conceptualmente útil, pero puede ser ineficiente para \(n\) grande. En la práctica se recomienda `rbinom`, que usa métodos optimizados.

### Transformación no lineal simple: `X = U^2`

Aunque `U` y `X = U^2` tienen soporte en (0,1), `X` no es uniforme.  
Se muestra por simulación y por derivación analítica:

- `F_X(x) = sqrt(x)`, para `0 < x < 1`.
- `f_X(x) = 1 / (2*sqrt(x))`, densidad Beta(1/2,1).

Esto ilustra cómo una transformación cambia drásticamente la distribución.

---

## 5. Método de la transformación inversa

Principio general:

Si `U ~ Unif(0,1)` y `F_X` es la CDF de una variable continua, entonces:

`Y = F_X^(-1)(U)`

tiene distribución `X`.

### Esquema de simulación

1. Simular `u_1, ..., u_n` de Unif(0,1).
2. Definir `x_i = F_X^(-1)(u_i)`.

Para aplicarlo directamente, se necesita que la CDF sea invertible en forma manejable.

### Ejemplos continuos

1. **Beta(alpha, 1)**  
   `F(x) = x^alpha  =>  F^(-1)(u) = u^(1/alpha)`.  
   También puede usarse `qbeta`; en general para Beta se recomienda `rbeta`.

2. **Exponencial(lambda)**  
   `F(x) = 1 - exp(-lambda*x)  =>  x = -log(1-u)/lambda`.  
   Como `1-U ~ U`, se usa `x = -log(U)/lambda`.  
   En práctica: `rexp`.

3. **Normal**  
   La CDF no tiene forma cerrada elemental, así que se usan aproximaciones numéricas (`qnorm`) o directamente `rnorm`, que es más conveniente para simular.

### Caso discreto

El método inverso se adapta a distribuciones discretas usando saltos de la CDF:

`{X = x} <=> {F_X(x-1) < U <= F_X(x)}`

Se muestra con Binomial(5,0.6), implementable con `qbinom`.  
En uso habitual, sigue siendo preferible `rbinom`.

---

## 6. Transformaciones con variables Normales

Se estudia el problema geométrico de tiros con error:
- `Z1, Z2` independientes `N(0,1)`, como errores horizontal y vertical.
- Distancia al origen: `R = sqrt(Z1^2 + Z2^2)`.
- Entonces: `T = R^2 = Z1^2 + Z2^2 ~ chi-cuadrado(2) = Exp(1/2)`.

Por simulación se verifica:
- Histograma de `T` ajusta a densidad exponencial con tasa 1/2.
- `E(T) ~ 2`.
- Se pueden aproximar probabilidades como `P(R < 2)`.

También se analiza el ángulo `theta`:
- En el primer cuadrante, `theta ~ Unif(0, pi/2)`.
- Globalmente, `theta ~ Unif(0, 2*pi)`.

Esto conecta coordenadas rectangulares normales con coordenadas polares:
- `theta` uniforme
- `R^2` exponencial

---

## 7. Método de Box-Muller para generar N(0,1)

A partir de `U1, U2 ~ Unif(0,1)` independientes:

`R = sqrt(-2*log(U1))`  
`Theta = 2*pi*U2`

y transformando a coordenadas cartesianas:

`Z1 = R*cos(Theta)`  
`Z2 = R*sin(Theta)`

se obtienen dos variables independientes `N(0,1)`:

`Z1 = sqrt(-2*log(U1)) * cos(2*pi*U2)`  
`Z2 = sqrt(-2*log(U1)) * sin(2*pi*U2)`

El material lo presenta como método exacto, eficiente y ampliamente usado para generar normales estándar.

---

## 8. Comentarios finales de la presentación

- La generación uniforme en `(0,1)` es la base de gran parte de la simulación.
- La calidad del generador importa: no basta mirar sólo histogramas; hay que revisar dependencia y estructura en varias dimensiones.
- En la práctica, conviene usar funciones especializadas de R (`runif`, `sample`, `rbinom`, `rexp`, `rbeta`, `rnorm`, etc.) porque son eficientes y están bien probadas.
- Conocer los métodos (GCL, transformada inversa, Box-Muller) es valioso para entender fundamentos y para casos donde no exista función lista para una distribución particular.

---

## Referencias citadas en la diapositiva

1. Owen Jones, Robert Maillardet, Andrew Robinson. *Introduction to Scientific Programming and Simulation Using R*, cap. de simulación.
2. Eric A. Suess, Bruce E. Trumbo. *Introduction to Probability Simulation and Gibbs Sampling with R*, cap. sobre generación de números aleatorios.

---

## Ejemplos en R (prácticos y cortos)

### 1) Uniforme en otro intervalo

```r
set.seed(123)

# Dos formas equivalentes de generar Unif(5, 7)
u1 <- runif(10, min = 5, max = 7)
u2 <- 2 * runif(10) + 5

u1
u2
```

### 2) GCL simple y chequeo de período

```r
# Generador congruencial lineal: r[i+1] = (a*r[i] + b) mod d
a <- 20; b <- 0; d <- 53; s <- 21
m <- 60
r <- numeric(m)
r[1] <- s

for (i in 1:(m - 1)) {
  r[i + 1] <- (a * r[i] + b) %% d
}

r
length(unique(r))  # si da 52 (sin contar repetición final), hay período completo en este caso
```

### 3) Binomial por transformación vs función optimizada

```r
set.seed(123)

# Método conceptual: suma de indicadores
x_manual <- sum(runif(4) < 0.5)  # Bin(4, 0.5)

# Método recomendado en práctica
x_rbinom <- rbinom(1, size = 4, prob = 0.5)

x_manual
x_rbinom
```

### 4) Transformación inversa para Exponencial

```r
set.seed(123)

n <- 10000
lambda <- 1.2

u <- runif(n)
x_inv <- -log(u) / lambda   # transformación inversa
x_rexp <- rexp(n, rate = lambda)

mean(x_inv)   # debería estar cerca de 1/lambda
mean(x_rexp)  # también cerca de 1/lambda
1 / lambda
```

### 5) Normal estándar por Box-Muller

```r
set.seed(123)

n <- 10000
u1 <- runif(n)
u2 <- runif(n)

z1 <- sqrt(-2 * log(u1)) * cos(2 * pi * u2)
z2 <- sqrt(-2 * log(u1)) * sin(2 * pi * u2)

# Validación rápida
mean(z1); var(z1)
mean(z2); var(z2)
cor(z1, z2)   # debería estar cerca de 0
```

### 6) Diagnóstico gráfico básico de uniformidad e independencia

```r
set.seed(123)

u <- runif(5000)

par(mfrow = c(1, 2))
hist(u, breaks = 20, prob = TRUE, col = "wheat",
     main = "Histograma de U ~ Unif(0,1)", xlab = "u")
abline(h = 1, lty = 2, col = "blue")

plot(u[-length(u)], u[-1], pch = 16, cex = 0.4,
     xlab = expression(u[i]), ylab = expression(u[i+1]),
     main = "Pares consecutivos")
par(mfrow = c(1, 1))
```
