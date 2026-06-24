# Script — Presentación verbal: Exercise 6.13 Challenger
**Duración estimada: 15 minutos**

---

## [0:00 – 1:30] Introducción: el contexto histórico

El 28 de enero de 1986, el transbordador espacial Challenger explotó 73 segundos después del despegue. Los siete astronautas a bordo murieron. Fue uno de los accidentes más devastadores en la historia de la NASA.

La causa fue la falla de un O-ring: un aro de goma que sella las juntas del cohete. Ese día, la temperatura en el lugar de lanzamiento era de 31°F, es decir, alrededor de 0°C. Era, por lejos, el día más frío en que se había intentado un lanzamiento.

Lo que hace a este caso especialmente trágico es que **los datos existían**. La NASA tenía registros de 23 lanzamientos anteriores, con información sobre la temperatura y si había ocurrido o no una falla de O-ring. El objetivo de este ejercicio es hacer exactamente lo que no se hizo antes del desastre: modelar estadísticamente esa relación y estimar la probabilidad de falla a bajas temperaturas.

---

## [1:30 – 3:00] El dataset y el modelo

El dataset `challenger` del paquete `mcsm` de R tiene 23 observaciones y dos variables:

- `oring`: indicador de falla (1 = hubo falla, 0 = no hubo falla)
- `temp`: temperatura de lanzamiento en grados Fahrenheit

La pregunta central es: **¿cómo varía la probabilidad de falla con la temperatura?**

Para responderla usamos una **regresión logística**. Este modelo es apropiado porque la variable respuesta es binaria — falla o no falla — y queremos modelar una probabilidad, que debe estar acotada entre 0 y 1.

La forma del modelo es:

```
P(Yi = 1 | xi) = p(xi) = exp(α + β·xi) / (1 + exp(α + β·xi))
```

Donde `xi` es la temperatura del lanzamiento `i`, y α y β son los dos parámetros a estimar. Esta función se llama función logística o sigmoide: toma cualquier valor real y lo transforma en una probabilidad entre 0 y 1.

---

## [3:00 – 5:30] Parte 1 — Regresión logística y los MLEs

La primera tarea es estimar α y β usando **máxima verosimilitud** a través de la función `glm` de R. Corremos:

```r
fit <- glm(oring ~ temp, data = challenger, family = binomial(link = "logit"))
```

Los resultados son:

| Parámetro | Estimado (MLE) | Error Estándar |
|---|---|---|
| α (intercepto) | 15.04 | 7.38 |
| β (pendiente) | -0.232 | 0.108 |

¿Cómo se interpretan?

**β = -0.232** es el parámetro clave. Es negativo, lo que confirma la hipótesis: a medida que la temperatura **baja**, la probabilidad de falla **sube**. Por cada grado Fahrenheit que baja la temperatura, el logit de la probabilidad de falla aumenta en 0.232.

**α = 15.04** es el intercepto. Solo tiene interpretación conjunta con β — determina el nivel base de la curva.

Ambos coeficientes son estadísticamente significativos con p-value menor a 0.05, marcados con un asterisco en el output de R. Esto nos dice que la temperatura es un predictor relevante de la falla, con evidencia estadística.

El error estándar de α es bastante grande (7.38 sobre 15.04), lo que anticipa que hay **incertidumbre considerable** en la estimación. Eso es exactamente lo que vamos a explorar con el método de Monte Carlo.

---

## [5:30 – 8:30] Parte 2 — Algoritmo Metropolis-Hastings

En lugar de quedarnos solo con los MLEs, queremos caracterizar la **distribución posterior completa** de α y β. Para eso usamos un algoritmo de Metropolis-Hastings, que es un método de Monte Carlo vía Cadenas de Markov — MCMC.

La idea central del M-H es generar una secuencia de pares (α, β) tal que, en el largo plazo, esa secuencia muestree la distribución de verosimilitud del modelo.

El algoritmo funciona así en cada iteración:

1. Proponer un nuevo par (α*, β*) usando una distribución candidata
2. Calcular el ratio de aceptación: si el nuevo par tiene mayor verosimilitud que el actual, se acepta casi siempre; si tiene menor, se acepta con una probabilidad proporcional al ratio
3. Si se acepta, la cadena se mueve al nuevo punto; si no, se queda donde está

Implementamos **dos versiones** para comparar:

**Versión independiente**: propone α* directamente desde una distribución Exponencial con media igual al MLE de α, y β* desde una distribución Laplace centrada en el MLE de β. Cada propuesta parte de cero, sin considerar dónde está la cadena ahora.

**Versión random walk**: propone α* sumando un pequeño paso exponencial al valor actual, y β* sumando un pequeño paso Laplace al valor actual. La propuesta depende de dónde está parada la cadena.

La diferencia práctica es grande: el independiente tiene una tasa de aceptación del **3%** — de cada 100 propuestas, 97 se rechazan. El random walk logra **12%**, que es más razonable aunque todavía bajo para el óptimo teórico de alrededor del 23%.

---

## [8:30 – 11:00] Parte 3 — Las 5000 iteraciones y el gráfico

Generamos 5000 iteraciones de cada cadena. El resultado es una secuencia de 5000 pares (α⁽ⁱ⁾, β⁽ⁱ⁾), cada uno representando una hipótesis plausible sobre los verdaderos parámetros del modelo.

Para visualizar esto construimos un gráfico al estilo de la Figura 6.6 del libro:

- Tomamos las últimas 500 iteraciones de la cadena
- Para cada par (α⁽ⁱ⁾, β⁽ⁱ⁾) dibujamos la curva logística correspondiente en gris
- Encima dibujamos la media posterior en rojo
- Y superponemos los puntos observados en negro

**Lo que se ve en el gráfico del independiente**: pocas curvas grises distintas. Muchas se superponen porque la cadena se quedó pegada en el mismo par (α, β) durante muchas iteraciones. Esto es la firma visual de la baja tasa de aceptación.

**Lo que se ve en el gráfico del random walk**: muchas más curvas grises, bien distribuidas. La cadena exploró más posibilidades. La dispersión de las curvas entre 50 y 65°F es muy amplia, lo que refleja incertidumbre genuina del modelo en esa zona — justamente donde no hay datos observados.

Los trace plots confirman esto: el independiente muestra escalones largos — períodos donde el valor no cambia — mientras que el random walk muestra una línea continua pero con una deriva notable alrededor de la iteración 2000, donde α sube hasta 50 y β baja hasta -0.8, bastante lejos del MLE. Esto indica que con 5000 iteraciones el random walk todavía no convergió completamente. En la práctica habría que correr más iteraciones y descartar las primeras como burn-in.

---

## [11:00 – 13:30] Parte 4 — Estimación de probabilidades

La aplicación más directa de las muestras del chain es estimar la probabilidad de falla a temperaturas específicas. Para cada temperatura de interés, calculamos:

```
p⁽ⁱ⁾ = logistic(α⁽ⁱ⁾ + β⁽ⁱ⁾ · temperatura)
```

para los 5000 pares de la cadena, y luego tomamos la media y el desvío estándar.

Los resultados del random walk son:

| Temperatura | P(falla) estimada | Error estándar |
|---|---|---|
| 60°F (15.6°C) | **0.797** | ± 0.148 |
| 50°F (10.0°C) | **0.960** | ± 0.070 |
| 40°F (4.4°C) | **0.990** | ± 0.033 |

La lectura es clara y alarmante. A 60°F la probabilidad de falla supera el 79%. A 50°F llega al 96%. A 40°F prácticamente la certeza.

El día del accidente la temperatura era de **31°F**, por debajo de cualquier temperatura observada en los lanzamientos anteriores — el modelo estaría extrapolando, pero todas las curvas del gráfico convergerían a p ≈ 1.0 en ese rango. La evidencia estadística hubiera indicado no lanzar.

---

## [13:30 – 15:00] Conclusión

Este ejercicio ilustra tres cosas fundamentales:

**Primero**, la regresión logística es la herramienta adecuada cuando queremos modelar una probabilidad en función de variables continuas. Los MLEs nos dan la estimación puntual más probable, pero solos no capturan la incertidumbre.

**Segundo**, el enfoque bayesiano vía MCMC permite ir más allá del punto estimado y caracterizar toda la distribución posterior de los parámetros. Cada curva gris del gráfico no es una aproximación — es un modelo posible, consistente con los datos.

**Tercero**, la elección del algoritmo importa. El M-H independiente es simple pero mezcla mal. El random walk mezcla mejor pero necesita más iteraciones para converger. Diagnosticar la convergencia a través de los trace plots no es un paso opcional — es parte del análisis.

Finalmente, más allá de la estadística, este caso es un recordatorio de que los datos y los modelos tienen valor solo si se usan. Los ingenieros de la NASA tenían los datos. El análisis estadístico hubiera mostrado que lanzar a 31°F era extraordinariamente riesgoso. No se hizo el análisis, o no se escuchó. El resultado fue una tragedia que pudo haberse evitado.

---

*Fin de la presentación — 15 minutos aproximados*
