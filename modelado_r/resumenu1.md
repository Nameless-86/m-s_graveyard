---

## Glosario

- **Modelado**: representacion simplificada de un problema real con supuestos explicitos.
- **Simulacion**: repeticion computacional de un modelo para aproximar cantidades de interes.
- **Monte Carlo**: aproximacion por frecuencias relativas o promedios sobre muchas repeticiones aleatorias.
- **v.a.**: variable aleatoria.
- **Hipergeometrica**: distribucion de conteos en muestreo sin reposicion de poblacion finita.
- **IC (intervalo de confianza)**: rango estimado de valores plausibles para un parametro.
- **Cobertura de un IC**: probabilidad de que el intervalo incluya al valor verdadero.
- **`set.seed`**: instruccion en R para reproducir resultados pseudoaleatorios.

---

## 1. Introduccion

La Presentacion 1 usa ejemplos concretos para mostrar como se combinan:

1. enfoque analitico (resultados exactos o formulas),
2. enfoque por simulacion (aproximaciones numericas).

La idea central es que la simulacion no solo sirve cuando no hay solucion exacta, sino tambien para entender, verificar y explorar modelos probabilisticos.

---

## 2. Ejemplo 1: muestreo de chips (poblacion finita)

Se plantea una caja con 100 chips, 90 buenos y 10 fallados. Se extraen 5 sin reposicion.

Interesan probabilidades como:

- `P(X = 5)` (todos buenos),
- `P(X >= 4)` (a lo sumo uno fallado),

donde `X` es la cantidad de chips en buen estado.

### Enfoque analitico

Se resuelve por conteo combinatorio:

- casos posibles: `choose(100, 5)`,
- casos favorables para `X = 5`: `choose(90, 5)`,
- distribucion completa: formula hipergeometrica.

Resultados destacados:

- `P(X = 5) ≈ 0.584`,
- `P(X >= 4) ≈ 0.923`,
- `E(X) = 4.5`.

### Enfoque simulacion

Se replica el experimento muchas veces en R usando `sample` y se aproxima:

- distribucion de `X`,
- probabilidades puntuales,
- valor esperado.

Con `m = 100000`, las aproximaciones quedan muy cerca de los valores teoricos, ilustrando la Ley de los Grandes Numeros en accion.

---

## 3. Ejemplo 2: paradoja del cumpleanos

Para `n = 25` personas, se estudia la probabilidad de al menos una coincidencia de fecha de cumpleanos.

### Enfoque analitico

Bajo supuestos estandar (365 dias, uniformidad, independencia aproximada):

- `P(no coincidencia) = prod(1 - i/365, i=0..24)`,
- `p25 = P(coincidencia) ≈ 0.5687`.

Tambien se generaliza a `pn` para distintos `n`, mostrando crecimiento no lineal y rapido al principio.

### Enfoque simulacion

Se simulan muchas muestras de 25 fechas con reposicion y se define:

- `X = 25 - length(unique(muestra))` (cantidad de coincidencias).

Esto permite aproximar no solo `P(X >= 1)`, sino tambien:

- toda la distribucion de `X`,
- `E(X)`.

Mensaje importante: la simulacion puede aportar informacion adicional aun cuando el problema principal tenga formula cerrada.

---

## 4. Cobertura de IC para proporciones

Se repasa el IC aproximado del 95% para una proporcion `p`:

`p_hat ± 1.96 * sqrt(p_hat*(1-p_hat)/n)`

y se discute que su validez depende de aproximaciones asintoticas (TLC, LGN, Slutsky).

Punto clave del bloque:

- cuando `n` es chico o `p` esta lejos de 0.5, la cobertura real del IC puede diferir del 95% nominal.

La presentacion compara cobertura por simulacion y por calculo analitico, destacando la utilidad de simular para auditar metodos estadisticos usuales.

---

## 5. Ideas metodologicas transversales

- **Supuestos primero**: todo modelo simplifica; hay que explicitar supuestos y juzgar su impacto.
- **Reproducibilidad**: fijar semilla cuando se necesita repetir exactamente resultados.
- **Escala**: una simulacion util requiere muchas repeticiones.
- **Comparacion analitico/simulacion**: cuando hay solucion exacta, sirve para validar implementacion y entender precision.

---

## 6. Cierre de la presentacion

La unidad muestra, con problemas clasicos y cercanos, la logica de trabajo del curso:

1. modelar,
2. calcular si se puede,
3. simular para aproximar, contrastar y extender resultados.

Se consolida ademas el uso practico de R como herramienta de experimentacion probabilistica.

