# Explicación línea por línea — Challenger MCMC

## Archivos

| Archivo | Método | Tasa aceptación |
|---|---|---|
| `challenger_independent.r` | M-H con propuestas independientes | ~3% |
| `challenger_random_walk.r` | M-H con random walk | ~12% |

---

## Sección común: Setup y Parte 1

Ambos archivos abren de la misma manera:

```r
lib <- path.expand("~/R/library")
```
Convierte `"~/R/library"` a la ruta absoluta del usuario (e.g. `/home/user/R/library`). Necesario porque R no siempre expande `~` solo.

```r
.libPaths(c(lib, .libPaths()))
```
Agrega la carpeta de usuario al frente del vector de directorios donde R busca paquetes. Sin esto, `library(mcsm)` no lo encuentra porque fue instalado fuera del path del sistema.

```r
library(mcsm)
data(challenger)
```
Carga el paquete `mcsm` (Monte Carlo Statistical Methods) y el dataset `challenger` en el entorno global. El dataset tiene 23 filas y 2 columnas: `oring` (0/1) y `temp` (°F).

```r
fit <- glm(oring ~ temp, data = challenger, family = binomial(link = "logit"))
```
Ajusta una regresión logística. `glm` = Generalized Linear Model. `family = binomial(link = "logit")` especifica que la variable respuesta es binaria y que el link es la función logit: `log(p/(1-p)) = α + β*x`.

```r
summary(fit)
```
Imprime los coeficientes estimados, errores estándar, z-values y p-values del modelo.

```r
alpha_mle <- coef(fit)[1]
beta_mle  <- coef(fit)[2]
```
Extrae los MLE (Maximum Likelihood Estimators): `coef(fit)[1]` es el intercepto α ≈ 15.04, `coef(fit)[2]` es la pendiente β ≈ -0.232.

```r
se_alpha <- summary(fit)$coefficients[1, 2]
se_beta  <- summary(fit)$coefficients[2, 2]
```
Extrae los errores estándar de cada coeficiente. La columna 2 de la matriz de coeficientes contiene los SE. Se usan para parametrizar las distribuciones candidatas del M-H.

---

## Funciones auxiliares (ambos archivos)

```r
rlaplace <- function(n, mu = 0, b = 1) {
  u <- runif(n, -0.5, 0.5)
  mu - b * sign(u) * log(1 - 2 * abs(u))
}
```
Genera `n` valores de una distribución Laplace con centro `mu` y escala `b`.

La Laplace no tiene una función incorporada en R base, entonces se implementa manualmente usando el **método de inversión de la CDF**: si U es uniforme, entonces F⁻¹(U) sigue la distribución target. Para la Laplace, la función cuantil es `F⁻¹(u) = μ - b·sign(u)·log(1 - 2|u|)`.

Por qué `runif(n, -0.5, 0.5)` en lugar de `runif(n, 0, 1)`: la fórmula de inversión de la Laplace usa u centrado en 0 — es una convención matemática equivalente que evita tener que restar 0.5 en cada cálculo.

`sign(u)` devuelve +1 o -1 según el signo de u — determina si el valor generado cae a la derecha o a la izquierda del centro mu. `log(1 - 2*abs(u))` controla la magnitud del salto: cuando u está cerca de ±0.5 (los extremos del intervalo), el log se hace muy negativo y el valor generado queda lejos del centro. Esto produce las colas pesadas características de la Laplace.

Comparación con la Normal: la Normal decae como exp(-x²), la Laplace decae como exp(-|x|). La Laplace cae más lento — tiene más probabilidad en los extremos — lo que la hace útil como propuesta para parámetros que pueden alejarse bastante del centro.

```r
dlaplace <- function(x, mu = 0, b = 1, log = FALSE) {
  val <- -log(2 * b) - abs(x - mu) / b
  if (log) val else exp(val)
}
```
Densidad de la Laplace: `f(x) = (1/2b) * exp(-|x-μ|/b)`. Se calcula en escala logarítmica (`-log(2b) - |x-μ|/b`) para estabilidad numérica. El argumento `log = TRUE` la devuelve en log-escala, necesario para el ratio de M-H. Solo existe en `challenger_independent.r` porque el random walk usa propuestas simétricas que se cancelan en el ratio.

```r
log_lik <- function(a, b, datos) {
  p <- plogis(a + b * datos$temp)
  p <- pmax(pmin(p, 1 - 1e-10), 1e-10)
  sum(datos$oring * log(p) + (1 - datos$oring) * log(1 - p))
}
```
Calcula qué tan bien explica un par (a, b) los 23 lanzamientos observados. Devuelve un número negativo — más cercano a cero significa mejor ajuste.

**`p <- plogis(a + b * datos$temp)`**: para cada uno de los 23 lanzamientos calcula la probabilidad de falla predicha por el modelo. `plogis(x) = exp(x)/(1+exp(x))` es la función logística — convierte cualquier número real en una probabilidad entre 0 y 1. Con a=15 y b=-0.23, una temperatura de 53°F da p≈0.99 y una de 81°F da p≈0.01.

**`p <- pmax(pmin(p, 1-1e-10), 1e-10)`**: recorte de seguridad. Si p fuera exactamente 0 o 1, la línea siguiente calcularía log(0) = -Inf y el ratio del M-H devolvería NaN, rompiendo el algoritmo. `pmin` recorta por arriba (nada mayor que 1-1e-10) y `pmax` recorta por abajo (nada menor que 1e-10). Es una protección numérica, no un cambio en la lógica del modelo.

**`sum(datos$oring * log(p) + (1 - datos$oring) * log(1 - p))`**: log-verosimilitud de Bernoulli sumada sobre los 23 lanzamientos. Para cada lanzamiento i:
- Si hubo falla (`oring=1`): contribuye `log(p_i)` — qué tan probable era la falla según el modelo
- Si no hubo falla (`oring=0`): contribuye `log(1 - p_i)` — qué tan probable era que no fallara

El `datos$oring * log(p)` selecciona automáticamente el término correcto: cuando oring=1 el primer término vale log(p) y el segundo vale 0, y viceversa. Es una forma compacta de escribir el if/else para los dos casos de Bernoulli.

---

## Parte 2: Diferencia clave entre los dos archivos

### `challenger_independent.r` — Propuestas independientes

```r
mh_independent <- function(Nsim = 5000, datos, a0, b0, se_b) {
```
La función recibe el número de iteraciones, los datos, valores iniciales `a0` (α_MLE) y `b0` (β_MLE), y el SE de β. No recibe `se_a` porque el parámetro de la Exponencial se deriva directamente de `a0`.

```r
  rate_a  <- 1 / a0
  scale_b <- abs(se_b)
```
Parámetros que controlan las distribuciones de propuesta. `rate_a = 1/α_MLE` configura una Exponencial con media igual al MLE de α — si α_MLE=15, la Exponencial propone valores con media 15, centrados en la zona de alta verosimilitud. `scale_b = |SE_β|` configura una Laplace con dispersión calibrada al error estándar de β — valores más dispersos implican propuestas más alejadas del MLE.

```r
    a_star <- rexp(1, rate = rate_a)
    b_star <- rlaplace(1, mu = b0, b = scale_b)
```
Generación de los candidatos. `a_star` viene directamente de la Exponencial — siempre positivo, centrado en α_MLE. `b_star` viene de la Laplace centrada en β_MLE. Estas propuestas son **independientes del estado actual de la cadena** — no importa si alpha[t-1] es 5 o 50, la propuesta siempre parte del mismo lugar. Eso es lo que define al M-H independiente.

```r
    log_r <- log_lik(a_star, b_star, datos) - log_lik(alpha[t-1], beta[t-1], datos) +
             dexp(alpha[t-1],    rate = rate_a,  log = TRUE) - dexp(a_star, rate = rate_a,  log = TRUE) +
             dlaplace(beta[t-1], mu = b0, b = scale_b, log = TRUE) - dlaplace(b_star, mu = b0, b = scale_b, log = TRUE)
```
El ratio completo de M-H en escala logarítmica. Tiene tres partes:

- `log_lik(a_star, b_star) - log_lik(alpha[t-1], beta[t-1])`: diferencia de log-verosimilitudes — qué tan mejor o peor explica el candidato los datos versus el estado actual
- `dexp(alpha[t-1]) - dexp(a_star)`: corrección por la propuesta de α — penaliza candidatos en zonas de baja densidad exponencial
- `dlaplace(beta[t-1]) - dlaplace(b_star)`: corrección por la propuesta de β — penaliza candidatos alejados del MLE de β

Los términos de corrección aparecen en orden inverso (estado actual arriba, candidato abajo) porque en el ratio MH es g(X)/g(Y) — el estado actual en el numerador. En escala log eso se convierte en log g(X) - log g(Y). Con propuestas independientes estos términos **no se cancelan** porque g(X) ≠ g(Y) en general.

```r
    if (!is.nan(log_r) && !is.na(log_r) && log(runif(1)) < log_r) {
      alpha[t] <- a_star
      beta[t]  <- b_star
      acc      <- acc + 1
    } else {
      alpha[t] <- alpha[t-1]
      beta[t]  <- beta[t-1]
    }
```
Misma lógica de decisión que el random walk. La diferencia importante está en **qué contiene `log_r`**: en el independiente, `log_r` ya incluye los términos de corrección de las propuestas, así que el umbral de aceptación no es solo "¿mejora los datos?" sino "¿mejora los datos lo suficiente para compensar que la propuesta es más probable que el estado actual?".

En la práctica esto explica la baja tasa de aceptación (~3%): la Exponencial y la Laplace proponen valores a menudo en zonas de baja verosimilitud (valores de α muy distintos de 15, valores de β muy distintos de -0.23), y aunque el término de corrección g(X)/g(Y) ayuda a penalizar esas propuestas, la distribución posterior real es más concentrada que las propuestas — entonces muchos candidatos se rechazan de todas formas.

```r
  cat(sprintf("Tasa de aceptacion (independiente): %.3f\n", acc / (Nsim - 1)))
```
Mismo cálculo que el random walk. El ~3% contra el ~12% del random walk refleja que las propuestas independientes están peor calibradas para la forma de la posterior de este problema.

---

### `challenger_random_walk.r` — Random walk

```r
mh_random_walk <- function(Nsim = 5000, datos, a0, b0, se_a, se_b) {
```
Recibe también `se_a` (SE de α) para calibrar el tamaño del paso.

```r
  step_a <- se_a * 0.5
  step_b <- se_b * 0.5
```
Tamaños de paso para cada parámetro. El error estándar del MLE mide cuánta incertidumbre hay en cada parámetro — es una escala natural para los saltos. Con `se_a = 7.38`, `step_a = 3.69`: el paso típico para α es de ~3.7 unidades. Con `se_b = 0.108`, `step_b = 0.054`: el paso típico para β es de ~0.05 unidades. El factor 0.5 es empírico — pasos más chicos dan más aceptaciones pero exploración más lenta, pasos más grandes dan menos aceptaciones pero saltos más amplios.

```r
    eps_a  <- rexp(1, rate = 1 / step_a) * sample(c(-1, 1), 1)
    a_star <- alpha[t-1] + eps_a
```
Genera el candidato para α en dos pasos. Primero `rexp(1, rate = 1/step_a)` genera un número positivo con media `step_a` — el tamaño del salto. Después `sample(c(-1,1), 1)` elige aleatoriamente si ese salto va hacia arriba o hacia abajo. El producto `eps_a` es el incremento final, que se suma al estado actual `alpha[t-1]` para obtener el candidato `a_star`. La propuesta es simétrica: tiene igual probabilidad de subir que de bajar.

```r
    b_star <- rlaplace(1, mu = beta[t-1], b = step_b)
```
Paso Laplace centrado en el valor **actual** de β (no en el MLE). Esto es el random walk: la propuesta se mueve alrededor de donde está la cadena ahora.

```r
    if (a_star > 0) {
      log_r <- log_lik(a_star, b_star, datos) - log_lik(alpha[t-1], beta[t-1], datos)
    } else {
      log_r <- -Inf
    }
```
Con propuestas simétricas `q(θ*|θ) = q(θ|θ*)`, los términos candidatos se cancelan y el ratio se reduce solo a la diferencia de log-verosimilitudes. Si `α* ≤ 0` se rechaza automáticamente (`-Inf` garantiza rechazo porque `log(runif) > -Inf` siempre).

```r
    if (!is.nan(log_r) && !is.na(log_r) && log(runif(1)) < log_r) {
      alpha[t] <- a_star; beta[t] <- b_star; acc <- acc + 1
    } else {
      alpha[t] <- alpha[t-1]; beta[t] <- beta[t-1]
    }
```
El bloque de decisión. Primero los chequeos defensivos: `!is.nan(log_r)` y `!is.na(log_r)` atrapan los casos donde la log-verosimilitud devolvió algo inválido (NaN o NA) — si el candidato cae en una zona numéricamente problemática, se rechaza directamente en lugar de romper el algoritmo.

Después la decisión real: `log(runif(1)) < log_r`.

- `runif(1)` genera un número uniforme en (0,1) — la variable aleatoria de aceptación.
- `log(runif(1))` lo transforma al intervalo (-∞, 0) — esto es equivalente a generar `U ~ Uniforme(0,1)` y comparar `U < exp(log_r)`, pero en escala log evita calcular `exp(log_r)` que puede desbordarse si `log_r` es muy grande.
- Si `log_r ≥ 0` (el candidato es igual o mejor): `exp(log_r) ≥ 1`, por lo tanto `U < 1` siempre — aceptación segura.
- Si `log_r < 0` (el candidato es peor): `exp(log_r) ∈ (0,1)`, por lo tanto se acepta con probabilidad `exp(log_r)` — menos probable pero posible. Esto es lo que le permite al algoritmo escapar de óptimos locales.

Si se acepta: `alpha[t]` y `beta[t]` toman los valores candidatos, y `acc` suma 1 para el conteo de tasa de aceptación. Si se rechaza: la cadena **repite el estado anterior** — `alpha[t] = alpha[t-1]`. El paso no es "vacío": el valor se copia igual y eso cuenta como una iteración de la cadena. Los escalones en el trace plot son precisamente estos rechazos consecutivos.

```r
  cat(sprintf("Tasa de aceptacion (random walk): %.3f\n", acc / (Nsim - 1)))
```
Imprime la tasa de aceptación dividiendo por `Nsim - 1` (no `Nsim`) porque el loop va de `t=2` hasta `t=Nsim` — son `Nsim - 1` intentos, no `Nsim`. Una tasa de ~12% está en el rango razonable para random walk en 2D (el óptimo teórico para dimensión alta es ~23%).

---

## Sección común: Parte 3 — Gráficos

```r
set.seed(42)
chain <- mh_...(5000, challenger, ...)
```
`set.seed(42)` fija la semilla para reproducibilidad. La función retorna una lista con los vectores `alpha` y `beta` de longitud 5000.

```r
png("challenger/..._trace.png", width = 800, height = 500)
par(mfrow = c(2, 1), mar = c(4, 4, 2, 1))
```
Abre el dispositivo PNG para guardar. `mfrow = c(2,1)` divide la ventana en 2 filas, 1 columna. `mar` reduce los márgenes para aprovechar el espacio.

```r
plot(chain$alpha, type = "l", col = "steelblue", ...)
abline(h = alpha_mle, col = "red", lty = 2, lwd = 1.5)
```
Trace plot de α: cada iteración en el eje X, el valor de α en el eje Y. Una cadena bien mezclada oscila rápidamente alrededor del MLE (línea roja). El trace del independiente muestra escalones (se queda fijo muchas iteraciones), el random walk muestra deriva más continua.

```r
temps   <- seq(50, 85, by = 0.5)
p_mat   <- plogis(outer(chain$alpha, rep(1, length(temps))) + outer(chain$beta, temps))
```
Grilla de 71 temperaturas entre 50 y 85°F. `outer` calcula el producto externo: `p_mat[i,j] = plogis(alpha[i] + beta[i] * temps[j])`, resultando en una matriz de 5000×71 con la curva logística de cada iteración.

```r
p_mean  <- colMeans(p_mat)
p_lower <- apply(p_mat, 2, quantile, 0.025)
p_upper <- apply(p_mat, 2, quantile, 0.975)
```
Resumen posterior: media y percentiles 2.5%/97.5% por columna (por temperatura). Se usan para referencias numéricas aunque el gráfico principal usa curvas individuales.

```r
idx_last <- (length(chain$alpha) - 499):length(chain$alpha)
```
Índices de las últimas 500 iteraciones (de 4501 a 5000). Al igual que la Figura 6.6, se grafican las últimas 500 curvas para mostrar la variabilidad posterior sin burn-in.

```r
plot(temps, p_mat[idx_last[1], ], type = "l", col = "gray80", lwd = 0.5, ...)
for (i in idx_last[-1]) lines(temps, p_mat[i, ], col = "gray80", lwd = 0.5)
```
Dibuja la primera curva gris como base del plot, luego agrega las 499 restantes encima. Cada línea gris es una curva logística `p(x) = logistic(α^(i) + β^(i)·x)` de una iteración del chain. La dispersión de las curvas refleja la incertidumbre posterior.

```r
lines(temps, p_mean, col = "red", lwd = 2)
points(challenger$temp, challenger$oring, pch = 19, col = "black")
```
Dibuja la media posterior en rojo (equivalente a la curva oscura de la Fig. 6.6) y superpone los puntos observados. Los puntos van al final para que queden visibles encima de las curvas.

---

## Parte 4: Estimación puntual

```r
for (temp in c(60, 50, 40)) {
  p_vals <- plogis(chain$alpha + chain$beta * temp)
  cat(sprintf("T = %d F:  P(falla) = %.4f  +-  %.4f\n", temp, mean(p_vals), sd(p_vals)))
}
```
Para cada temperatura de interés, calcula el vector de 5000 probabilidades usando todos los pares `(α^(i), β^(i))` de la cadena. `mean(p_vals)` es la estimación puntual posterior y `sd(p_vals)` es el error estándar Monte Carlo. Cuanto mejor mezcle la cadena, más confiable es el estimado.

---

## Comparación de resultados

| | Independiente | Random Walk |
|---|---|---|
| Tasa aceptación | ~3% | ~12% |
| Trace plot | Escalones largos (se "pega") | Deriva continua |
| Curvas grises | Pocas curvas distintas (baja diversidad) | Muchas curvas distintas (mejor cobertura) |
| P(falla) 60°F | 0.749 ± 0.156 | 0.797 ± 0.148 |
| P(falla) 50°F | 0.938 ± 0.097 | 0.960 ± 0.070 |
| P(falla) 40°F | 0.980 ± 0.057 | 0.990 ± 0.033 |

El random walk explora mejor el espacio posterior → menores errores estándar y curvas más densas en el gráfico. El independiente tiene baja tasa de aceptación porque la exponencial propone valores lejos de la región de alta verosimilitud con frecuencia.
