# Guía rápida: cómo identificar distribuciones en ejercicios

Esta guía sirve para decidir **qué distribución usar** según lo que describe el enunciado.

## 1) Primero: ¿variable discreta o continua?

- **Discreta**: cuenta valores enteros (`0, 1, 2, ...`), por ejemplo "número de fallas", "cantidad de éxitos".
- **Continua**: mide en una escala real, por ejemplo "tiempo", "peso", "altura", "error de medición".

## 2) Checklist para elegir distribución

Hacete estas preguntas en orden:

1. ¿Estoy **contando éxitos** en varios intentos?
2. ¿Los intentos son independientes?
3. ¿La probabilidad de éxito `p` es constante?
4. ¿Hay **reemplazo** o **sin reemplazo**?
5. ¿Estoy modelando **tiempo hasta que ocurra algo**?
6. ¿Estoy sumando muchos efectos pequeños (aprox. normal)?

---

## Distribuciones discretas más comunes

## Bernoulli
- **Qué modela**: un solo ensayo con dos resultados (éxito/fracaso).
- **Variable**: `X in {0,1}`.
- **Palabras clave**: "un intento", "sí/no", "aprueba/no aprueba".
- **Parámetro**: `p = P(exito)`.
- **R**: `dbinom(x, size = 1, prob = p)`.

## Binomial
- **Qué modela**: cantidad de éxitos en `n` ensayos independientes, con `p` constante.
- **Variable**: `X = # exitos`.
- **Palabras clave**: "en n intentos", "con reemplazo", "independientes".
- **Parámetros**: `n, p`.
- **R**: `dbinom(x, size = n, prob = p)`.
- **Señal fuerte**: si hay conteo de éxitos y no cambia `p`, suele ser binomial.

## Hipergeométrica
- **Qué modela**: éxitos en una muestra **sin reemplazo** de población finita.
- **Variable**: `X = # exitos en la muestra`.
- **Palabras clave**: "lote", "población de N", "sin reemplazo", "muestra de tamaño k".
- **Parámetros**: población con `m` éxitos y `n` fracasos, muestra `k`.
- **R**: `dhyper(x, m, n, k)`.
- **Diferencia con binomial**: en hipergeométrica, al no reemplazar, cambia la composición.

## Poisson
- **Qué modela**: número de eventos en un intervalo (tiempo, área, longitud), con tasa constante.
- **Variable**: `X = # eventos`.
- **Palabras clave**: "promedio por hora", "llamadas por minuto", "defectos por metro".
- **Parámetro**: `lambda` (media esperada en el intervalo).
- **R**: `dpois(x, lambda)`.
- **Señal fuerte**: conteos de eventos raros en intervalos.

## Geométrica
- **Qué modela**: número de fallos antes del primer éxito (en R).
- **Palabras clave**: "hasta el primer éxito".
- **Parámetro**: `p`.
- **R**: `dgeom(x, prob = p)` (ojo: en R, `x` = fallos antes del primer éxito).

## Binomial negativa
- **Qué modela**: número de fallos antes del `r`-ésimo éxito.
- **Palabras clave**: "hasta lograr r éxitos".
- **Parámetros**: `r, p`.
- **R**: `dnbinom(x, size = r, prob = p)`.

---

## Distribuciones continuas más comunes

## Uniforme continua
- **Qué modela**: todos los valores en `[a,b]` son igual de probables.
- **Palabras clave**: "uniformemente distribuido entre a y b".
- **Parámetros**: `a, b`.
- **R**: `dunif(x, min = a, max = b)`.

## Exponencial
- **Qué modela**: tiempo entre eventos de un proceso Poisson.
- **Palabras clave**: "tiempo de espera", "vida útil con tasa constante", "sin memoria".
- **Parámetro**: `lambda`.
- **R**: `dexp(x, rate = lambda)`.
- **Señal fuerte**: tiempos de espera con tasa constante.

## Normal
- **Qué modela**: variables continuas centradas alrededor de una media; suma de muchos efectos pequeños.
- **Palabras clave**: "errores de medición", "aprox. normal", "campana".
- **Parámetros**: `mu, sigma`.
- **R**: `dnorm(x, mean = mu, sd = sigma)`.

## Gamma
- **Qué modela**: tiempo hasta que ocurren varios eventos (generaliza exponencial).
- **Palabras clave**: "tiempo hasta el k-ésimo evento", asimetría positiva.
- **Parámetros**: forma y tasa (`shape, rate`).
- **R**: `dgamma(x, shape = alpha, rate = beta)`.

## Beta
- **Qué modela**: variable continua acotada entre 0 y 1 (proporciones, probabilidades).
- **Palabras clave**: "proporción", "tasa entre 0 y 1".
- **Parámetros**: `alpha, beta`.
- **R**: `dbeta(x, shape1 = alpha, shape2 = beta)`.

---

## Árbol de decisión corto (práctico)

1. Si es **conteo de éxitos**:
   - un intento -> **Bernoulli**
   - `n` intentos independientes con `p` fija -> **Binomial**
   - muestra de población finita sin reemplazo -> **Hipergeométrica**
2. Si es **conteo de eventos por intervalo** con tasa media -> **Poisson**
3. Si es **espera hasta evento**:
   - hasta primer evento -> **Geométrica** (discreta) o **Exponencial** (continua)
   - hasta `r` eventos -> **Binomial negativa** (discreta) o **Gamma** (continua)
4. Si es medición continua:
   - valores equiprobables en `[a,b]` -> **Uniforme**
   - forma de campana -> **Normal**
   - proporción entre 0 y 1 -> **Beta**

---

## Errores comunes (muy frecuentes)

- Confundir **binomial** con **hipergeométrica**:
  - con reemplazo / independencia aproximada -> binomial
  - sin reemplazo en población finita -> hipergeométrica
- Usar normal en muestras muy pequeñas sin justificar.
- Olvidar cómo parametriza R algunas distribuciones (`dgeom`, `dnbinom`).
- Mezclar "número de intentos" con "número de fallos".

---

## Mini tabla resumen

| Distribución | Tipo | Cuándo usar |
|---|---|---|
| Bernoulli | Discreta | 1 ensayo, éxito/fracaso |
| Binomial | Discreta | # éxitos en `n` ensayos indep., `p` constante |
| Hipergeométrica | Discreta | # éxitos en muestra sin reemplazo |
| Poisson | Discreta | # eventos en intervalo con tasa constante |
| Geométrica | Discreta | espera hasta 1er éxito |
| Binomial negativa | Discreta | espera hasta `r`-ésimo éxito |
| Uniforme | Continua | valores equiprobables en `[a,b]` |
| Exponencial | Continua | tiempo entre eventos (Poisson) |
| Normal | Continua | variable tipo campana |
| Gamma | Continua | tiempo hasta varios eventos |
| Beta | Continua | proporciones en `(0,1)` |

---

Si querés, te puedo hacer una **versión 2** de esta guía pero con ejemplos de tus ejercicios (`0.r` y `1.r`) y qué función de R usar en cada inciso (`d`, `p`, `q`, `r`).
