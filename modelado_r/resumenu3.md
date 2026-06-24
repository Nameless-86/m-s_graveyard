---

## Glosario

- **Integracion numerica**: aproximacion computacional de integrales definidas.
- **Suma de Riemann**: metodo deterministico que usa grillas regulares y rectangulos.
- **Integracion Monte Carlo (MC)**: metodo estocastico que aproxima integrales con promedios de muestras aleatorias.
- **Aceptacion-rechazo**: metodo que estima areas/probabilidades por proporcion de puntos aceptados bajo una curva.
- **Muestreo aleatorio directo**: aproximar probabilidades simulando directamente de la distribucion de interes.
- **LGN**: Ley de los Grandes Numeros; garantiza estabilidad de promedios simulados.
- **TLC**: Teorema del Limite Central; permite cuantificar error de simulacion.
- **Error de simulacion**: diferencia entre estimacion Monte Carlo y valor verdadero.

---

## 1. Objetivo general de la unidad

La Presentacion 3 profundiza en el uso de simulacion para aproximar probabilidades e integrales, y conecta estas tecnicas con dos pilares teoricos:

1. Ley de los Grandes Numeros (convergencia/estabilidad),
2. Teorema del Limite Central (precision y margenes de error).

La pregunta central es: **como saber si una simulacion funciona y cuan preciso es su resultado**.

---

## 2. Probabilidades como integrales

Se recuerda que para v.a. continuas:

`P(a < X <= b) = integral_a^b f_X(x) dx`

y en dimension mayor:

`P((X1,...,Xk) en A) = integral_A f(x1,...,xk) dx`.

La dificultad computacional depende de la complejidad del integrando y, sobre todo, de la dimension del problema.

---

## 3. Cuatro metodos para aproximar `J = P(0 < Z <= 1)`

Se usa el caso Normal estandar como laboratorio para comparar metodos.

### 3.1 Riemann (deterministico)

- Grilla regular en `[0,1]`.
- Aproxima el area bajo `phi(z)` con rectangulos.
- Muy preciso en 1D para funciones suaves; con m grande puede ser practicamente exacto.

### 3.2 Integracion Monte Carlo

- Simula `U_i ~ Unif(0,1)`.
- Estima `J` con promedio de `phi(U_i)`.
- Tiene variabilidad entre corridas, pero converge con m grande.

### 3.3 Aceptacion-rechazo

- Simula puntos en un rectangulo que contiene el area buscada.
- Usa porcentaje de puntos bajo la curva y multiplica por area del rectangulo.
- Conceptualmente claro, aunque en este ejemplo resulta menos eficiente.

### 3.4 Muestreo aleatorio directo

- Simula `Z_i ~ N(0,1)` y estima `P(0<Z<=1)` por frecuencia relativa.
- No requiere evaluar integral explicitamente ni conocer formula cerrada de CDF.
- Puede tener mayor error para un mismo `m`, segun el caso.

Conclusion comparativa: en problemas simples de baja dimension, metodos deterministicos suelen ganar; en problemas complejos o multivariados, MC suele volverse mas competitivo.

---

## 4. Convergencia y Ley de los Grandes Numeros (LGN)

Se formaliza por que Monte Carlo estabiliza:

- al promediar muchas observaciones iid, el promedio muestral converge a la esperanza.

Ejemplo didactico:

- lanzamientos de moneda equilibrada,
- `X_n` indicador de cara,
- `X_bar_n = (X1+...+Xn)/n`,
- `X_bar_n` converge en probabilidad a `1/2`.

Se muestra que para `n` chico la variabilidad es grande, pero para `n` grande la traza del proceso se pega a `0.5`.

Tambien se discute un ejemplo dependiente (caminata aleatoria) para remarcar que hay convergencias de naturaleza distinta y que no todo proceso aleatorio se comporta igual.

---

## 5. Teorema del Limite Central (TLC) y precision

La LGN garantiza convergencia, pero no da directamente el error para un `m` finito. El TLC completa esa parte:

- sumas/promedios de muchas v.a. independientes (con varianza finita) tienen distribucion aproximadamente Normal.

Uso practico en simulacion:

- construir margenes de error (o IC) de estimaciones Monte Carlo,
- decidir si `m` es suficiente para la precision requerida.

Se presenta tambien un ejemplo donde la aproximacion Normal funciona bien incluso con `n = 12` (muestra de Uniforme), y se aclara que esto depende de la forma de la distribucion original (peor para distribuciones muy asimetricas).

---

## 6. Marco general de integracion Monte Carlo

Para `J = integral_a^b h(x) dx`, se plantea:

- `U_i ~ Unif(a,b)`,
- `X_i = (b-a)h(U_i)`,
- estimador `A_m = (1/m) sum X_i`.

Resultados clave:

- por LGN: `A_m` converge a `J`,
- por TLC: `A_m` es aprox. Normal para `m` grande,
- error tipico de orden `sigma/sqrt(m)`.

Consecuencia practica: para reducir error por factor 10, hace falta multiplicar por 100 la cantidad de simulaciones.

---

## 7. Ejemplo comparativo: integral de `x^2` en `[0, 1.5]`

Se compara Riemann vs MC en una integral con valor exacto conocido (`1.125`):

- Riemann puede dar valor exacto o muy cercano con grilla fina.
- MC da aproximacion razonable con margen de error cuantificable.

Interpretacion:

- en 1D suave, Riemann suele rendir mejor;
- la fortaleza de MC aparece en dimensiones mas altas.

---

## 8. Ejemplo en 2D: probabilidad Normal bivariada

Se estima:

`P(Z1 > 0, Z2 > 0, Z1 + Z2 < 1)`

con `Z1, Z2` normales estandar independientes.

El ejemplo muestra como, al pasar a 2D, la construccion de grillas deterministicas se vuelve mas costosa y pierde ventaja relativa. Monte Carlo mantiene una implementacion simple y escalable.

---

## 9. Cuando es apropiada la simulacion

La presentacion cierra con criterios operativos:

- **Relevancia del modelo**: simulaciones basadas en supuestos razonables y/o datos.
- **Estabilidad**: verificar convergencia al aumentar iteraciones.
- **Diagnostico**: repetir corridas, usar chequeos numericos y graficos.
- **Validacion cruzada**: comparar con casos de solucion conocida cuando sea posible.

---

## 10. Cierre conceptual

La unidad integra metodo y teoria:

- muestra como aproximar probabilidades/integrales con distintas estrategias,
- explica por que esas aproximaciones convergen (LGN),
- y da herramientas para medir su error (TLC).

En sintesis, no se trata solo de "simular mucho", sino de simular con criterio estadistico y control explicito de precision.

