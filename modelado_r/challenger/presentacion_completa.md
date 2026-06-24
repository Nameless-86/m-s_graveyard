# Script completo — MCMC Metropolis-Hastings + Ejercicio Challenger
**Duración total: 45 minutos | Teoría: 30 min | Ejercicio: 15 min**

---

## ━━ BLOQUE TEÓRICO ━━ [0:00 – 30:00]

---

### [0:00 – 1:00] SLIDE 1 — Título

Buenas tardes a todos. Somos ABC del grupo 8. Hoy vamos a presentar uno de los algoritmos más importantes de la estadística computacional moderna: el algoritmo de Metropolis-Hastings 1973, generalizacion del algoritmo de metropolis 1953, que es la base de la familia de métodos conocida como MCMC — Monte Carlo vía Cadenas de Markov. Esto viene del libro introducing montecarlo methods with R 6

La presentación tiene dos partes. Primero vamos a desarrollar toda la teoría: qué es una cadena de Markov, qué es MCMC, y cómo funciona el algoritmo en sus distintas variantes. Después vamos a aplicar todo eso a un problema real — el accidente del transbordador Challenger de 1986.

---

### [1:00 – 2:00] SLIDE 2 — Contenidos

El recorrido de hoy tiene seis secciones. Arrancamos con el objetivo — por qué necesitamos estos métodos. Después presentamos las cadenas de Markov como herramienta matemática. Luego explicamos qué es MCMC y por qué es tan poderoso. La cuarta parte es el núcleo técnico: los tres algoritmos de Metropolis-Hastings — el genérico, el independiente, y el random walk. La quinta parte es el ejercicio del Challenger. Y cerramos con conclusiones.

---

### [2:00 – 5:00] SLIDE 3 — Objetivo

Antes de meternos con los algoritmos, necesitamos entender el problema que vienen a resolver.

Imaginense que tienen un modelo, modelo estadistico, no me refiero al area de ia.
De este modelo quiero saber algo, como por ejemplo el valor esperado de algun parametro o probabilidad de que un valor caiga en cierto rando.
Todas estas preguntas se responden muestreando la distribucion de este modelo, ponele que si tenes una normal, una uniforme, no hay problema, estas distribuciones vienen hasta en R.
En casos mas reales, puede pasar: que no se que distribucion es, capaz se llego a estos valores combinando datos, con algun otro modelo o suposicion. No hay funciones en la libreria estandar de R que se adapten a este problema.

Ese no es el unico problema, hay otro mas, de tus datos podes llegar a tener alguna funcion, pero para que una funcion pueda considerarse valida como distribucion de probailidad tiene que integrar a 1 sobre todo su dominio, esto es para mapear probabilidades, podemos saber cosas sobre el comportamiento de la funcion, extremos, cambios de concavidad, etc.
Pero no me puedo sacar de la galera el numero por el que tengo que multiplicar para que la integral sume 1. Ese factor se llama constante de normalizacion, en modelos con muchos parametors esta integral puede ser demasiado costosa computacionalmente hasta imposible.

Tengo varios problemas, pero ahora vamos a algo positivo.

El lado bueno es que tengo un problema en concreto, tengo una funcion, esta funcion representa lo que quiero muestrear, se su comportamiento, pero no se su constante de normalizacion, tampoco tengo un sampler directo de la funcion.

En base a esto traigo la solucion a los problemas, la respuesta es MCMC.

La pieza que hace que todo funcione es el Teorema Ergodico. Basicamente dice que si construis una cadena de markov de la manera correcta, el promedio de los valores que genera esa cadena termina convergiendo al promedio real de la distribucion que nos interesa, no hace falta una constante de normalizacion
El teorema ergodico puede sonar muy similar a algo que vimos anteriormente, es la version para cadenas de markov de la ley de los grandes numeros.

Entonces, que hacemos? En vez de generar de a un valor aleatorio, hacemos una secuencia, cada valor depende del anterior, una cadena, esta dependencia es el precio a pagar para poder muestrear distribuciones que antes no eran posibles.

---

### [5:00 – 9:00] SLIDES 4 y 5 — Cadenas de Markov

¿Qué es formalmente una cadena de Markov?
Formalmente una cadena de markov es una secuencia de valores, X al tiempo 1, X al tiempo 2 y asi sucesivamente, no es si o si en funcion del tiempo, son distintos estados para generalizar.
Cada valor depende de su valor anterior, no del resto de la cadena, un ejemplo para ver que seria, el clima de mañana solo depende del clima de hoy, solamente de hoy

si hoy hay sol, mañana hay 80% de probabilida de sol y 20 de lluvia, si hoy llueve mañ hay 60% de prob de lluvia y 40% de sol
Mas o menos asi funciona una cadena de markov, los estados son soleado y lluvioso, las probabilidades de transicion dependen solo del estado actual

Para saber el clima del miercoles necesito solo el clima del martes, no importan los dias anteriores, ya que la informacion de los dias anteriores, el pasado, ya esta incluido en el estado actual.

Ahora bien, para que una cadena de Markov sea útil en el contexto de MCMC, necesitamos dos conceptos fundamentales.

El primero es la **distribución estacionaria**. Es el estado de equilibrio de la cadena. Si la cadena alcanza esta distribución f, se mantendrá en ella indefinidamente. Es decir, si en el tiempo t tengo una muestra de f, en el tiempo t+1 también voy a tener una muestra de f. La distribución no cambia. Esta es exactamente la distribución que queremos muestrear.

El segundo concepto son los **requisitos de estabilidad**. Para que la cadena sea útil y converja, necesita tener dos propiedades. Primero, ser **irreducible**: la cadena debe ser capaz de visitar cualquier región del espacio en un número finito de pasos. No puede quedar atrapada. Segundo, ser **ergódica**: la cadena debe poder olvidar su estado inicial y converger a la distribución de equilibrio, independientemente de dónde la hayamos iniciado.

Si la cadena satisface estas condiciones, el Teorema Ergódico nos garantiza que los promedios sobre la trayectoria convergen a los verdaderos promedios de la distribución objetivo. Esto es la base teórica de todo lo que sigue.

---

### [9:00 – 13:00] SLIDE 6 — ¿Qué es MCMC?

MCMC — Monte Carlo vía Cadenas de Markov — es exactamente eso: construir una cadena de Markov cuya distribución estacionaria sea la distribución que queremos muestrear. No partimos de una cadena y preguntamos a dónde converge. Hacemos lo inverso: sabemos a dónde queremos llegar, y diseñamos la cadena para que llegue ahí.

La clave práctica es que el algoritmo solo necesita evaluar ratios de la función objetivo — y en un ratio la constante de normalización aparece arriba y abajo y se cancela. No hay que calcularla nunca.

---

### [13:00 – 18:00] SLIDES 7, 8 y 9 — Metropolis-Hastings Genérico

Llegamos al núcleo de la presentación.

La idea del algoritmo es simple. En cada paso, la cadena está parada en algún punto — el estado actual. Proponemos movernos a otro punto — el candidato Y — usando una distribución que elijamos nosotros, que se llama distribución de propuesta q. Después decidimos si aceptamos el movimiento o nos quedamos donde estamos.

¿Cómo se decide? Comparando qué tan probable es el candidato Y versus el estado actual X bajo la distribución objetivo f. Si Y está en una zona más densa — lo aceptamos siempre. Si está en una zona menos densa — lo aceptamos con una probabilidad proporcional a cuánto menos probable es. Esto garantiza que la cadena pase más tiempo donde f tiene más masa.

En la diapositiva ven la fórmula del ratio de aceptación ρ. Tiene dos partes: el cociente de la distribución objetivo f evaluada en Y sobre X, y el cociente de la propuesta q en sentido inverso — ese segundo término es la corrección por el hecho de que la propuesta puede no ser simétrica.

`ρ(x, y) = min{ f(x)/f(y) · q(y|x)/q(x|y) , 1 }`

O escrito de otra forma: el cociente entre la densidad objetivo evaluada en el candidato, sobre la densidad objetivo en el estado actual, multiplicado por el cociente de las densidades candidatas en sentido inverso.

Si ese ratio es mayor o igual a 1 — el candidato tiene más densidad que el estado actual — se acepta siempre. Si es menor que 1 — el candidato tiene menos densidad — se acepta con probabilidad igual a ese ratio. Si se rechaza, la cadena se queda donde está y se duplica el valor actual.

En código R esto es simplemente:

```r
y = geneq(x[t])                          # generar candidato
ratio = f(y)*q(x[t],y) / (f(x[t])*q(y,x[t]))  # calcular ratio
if (runif(1) < ratio) {
  x[t+1] = y       # aceptar
} else {
  x[t+1] = x[t]   # rechazar, duplicar
}
```

Hay un punto que parece trivial pero es fundamental: cuando se rechaza, el valor actual se **duplica**. No se descarta. La cadena avanza de todas formas, con el mismo valor. Esto es esencial para que la cadena represente correctamente la distribución objetivo. Si uno eliminara los duplicados, la muestra dejaría de ser representativa — estaría sesgada hacia regiones de alta aceptación.

---

### [18:00 – 22:00] SLIDES 10, 11, 12 y 13 — MH Independiente

La primera variante es el Metropolis-Hastings Independiente.

La diferencia con el genérico es simple: la propuesta g no depende de dónde está la cadena. Siempre propone desde la misma distribución fija, sin importar el estado actual X. El candidato Y sale siempre del mismo lugar.

Eso cambia el ratio. Como g no depende de X, hay que incluir los términos g(X) y g(Y) explícitamente — en la diapositiva ven la fórmula. No se cancelan porque g evaluada en el estado actual g(X) es distinta de g evaluada en el candidato g(Y).

El punto crítico de esta variante es la elección de la propuesta. Si g tiene colas más delgadas que f — si propone valores en un rango más acotado que donde vive la distribución objetivo — la cadena va a quedar atrapada en los extremos. El ejemplo del libro es intentar generar muestras de una Cauchy usando una Normal como propuesta. La Cauchy tiene colas muy pesadas, la Normal no. Cuando la cadena llega a un valor extremo, la Normal casi nunca propone candidatos en esa zona, y la cadena queda pegada ahí durante cientos de iteraciones. Lo van a ver en el trace plot del ejercicio.

---

### [22:00 – 27:00] SLIDES 14, 15, 16, 17 y 18 — MH Random Walk

La segunda variante es el Metropolis-Hastings Random Walk, o caminata aleatoria.

Acá la propuesta sí depende del estado actual. En lugar de proponer desde una distribución fija, el candidato Y se genera sumando un pequeño paso aleatorio — epsilon — al estado actual X. La cadena no salta a cualquier punto, sino que se mueve en el vecindario de donde está.

La ventaja es que si ese paso epsilon viene de una distribución simétrica — una Normal centrada en cero, una Uniforme centrada en cero — entonces proponer ir de X a Y es igual de probable que proponer ir de Y a X. Los términos de la propuesta q se cancelan en el ratio, y lo único que queda es el cociente de la distribución objetivo f evaluada en Y sobre X. En la diapositiva ven que el ratio se simplifica bastante respecto al independiente.

El desafío práctico es calibrar el tamaño del paso delta. Si es muy chico la cadena se mueve lentamente y tarda mucho en explorar. Si es muy grande propone saltos que casi siempre caen en zonas de baja densidad y se rechazan — la cadena también queda pegada, pero por la razón opuesta. En la Figura 6.7 del libro ven los tres casos con delta igual a 0.1, 1 y 10. La regla práctica de la literatura es apuntar a una tasa de aceptación de alrededor del 23% para un solo parámetro. En nuestro ejercicio con dos parámetros llegamos al 12% con el random walk, contra el 3% del independiente.

---

### [27:00 – 30:00] SLIDES 19 y 20 — Algoritmo de Langevin

La tercera variante es el algoritmo de Langevin. Es una mejora del random walk que agrega una brújula.

En el random walk el paso epsilon es completamente aleatorio — la cadena no sabe si está cerca o lejos de la moda, si debería moverse a la izquierda o a la derecha. Langevin le agrega un término de drift: antes de dar el paso aleatorio, primero se mueve un poco en la dirección donde la densidad f crece más rápido. Esa dirección la da el gradiente de log f evaluado en el estado actual.

La consecuencia práctica es que con el mismo tamaño de paso, Langevin acepta más y converge más rápido que el random walk puro, porque sus propuestas apuntan hacia zonas de mayor densidad en lugar de ser completamente ciegas.

El costo es doble. Primero, hay que calcular el gradiente de f en cada iteración — eso requiere que f sea diferenciable y que tengamos la derivada disponible, ya sea analítica o numéricamente. Segundo, como la propuesta apunta en una dirección, ya no es simétrica — proponer ir de X a Y no es igual de probable que proponer ir de Y a X. Por eso el ratio de aceptación vuelve a incluir los términos de la propuesta, como en el independiente, y no se simplifica.

Con esto cerramos el bloque teórico. Los tres algoritmos son el mismo principio — proponer, calcular el ratio, aceptar o rechazar — con distintas estrategias para generar el candidato Y.

---

## ━━ BLOQUE EJERCICIO ━━ [30:00 – 45:00]

---

### [30:00 – 31:30] SLIDE — Contexto histórico

El 28 de enero de 1986, el transbordador espacial Challenger explotó 73 segundos después del despegue. Los siete astronautas a bordo murieron. Fue uno de los accidentes más devastadores en la historia de la NASA.

La causa fue la falla de un O-ring: un aro de goma que sella las juntas del cohete. Ese día, la temperatura en el lugar de lanzamiento era de 31 grados Fahrenheit — alrededor de 0 grados Celsius. Era, por lejos, el día más frío en que se había intentado un lanzamiento.

Lo que hace a este caso especialmente significativo para nosotros es que los datos existían. La NASA tenía registros de 23 lanzamientos anteriores, con información sobre la temperatura y si había ocurrido o no una falla de O-ring. El ejercicio consiste en hacer, con las herramientas que acabamos de presentar, exactamente lo que no se hizo antes del desastre.

---

### [31:30 – 33:30] SLIDE — El dataset y el modelo

El dataset `challenger` del paquete `mcsm` de R tiene 23 observaciones y dos variables. La columna `oring` es un indicador binario: 1 si hubo falla de O-ring en ese lanzamiento, 0 si no hubo. La columna `temp` es la temperatura de lanzamiento en grados Fahrenheit.

La pregunta es: ¿cómo varía la probabilidad de falla con la temperatura?

Para responderla usamos una regresión logística. Este modelo es el apropiado cuando la variable respuesta es binaria y queremos modelar una probabilidad. La forma del modelo es:

`P(Yi = 1 | xi) = exp(α + β·xi) / (1 + exp(α + β·xi))`

Donde xi es la temperatura del lanzamiento i. Esta función — la función logística — toma cualquier valor real y lo transforma en una probabilidad entre 0 y 1. Los parámetros α y β son los que vamos a estimar.

---

### [33:30 – 36:00] SLIDE — Parte 1: Regresión logística y los MLEs

Arrancamos ajustando el modelo logístico con `glm`. Mientras corre el código — lo que nos devuelve son los estimados de α y β, que son los valores más probables de los parámetros dado los datos. α nos da el nivel base de la curva, y β es el que más nos importa: es negativo, lo que confirma que a menor temperatura mayor probabilidad de falla.

Pero fijense en el error estándar de α — es casi la mitad del valor estimado. Hay mucha incertidumbre. Eso es exactamente lo que vamos a explorar con el M-H: en lugar de quedarnos con un solo par de valores, vamos a generar miles de pares posibles y ver toda la distribución.

---

### [36:00 – 39:00] SLIDE — Parte 2: Metropolis-Hastings

Ahora aplicamos lo que vimos en la teoría. Corremos dos versiones del algoritmo para comparar.

Las dos necesitan la log-verosimilitud del modelo — es la función que dice qué tan bien explica cada par α, β los datos observados. Mientras corre el código voy explicando las decisiones que tomamos.

Para α elegimos una propuesta Exponencial porque α tiene que ser positivo — la Exponencial solo genera valores mayores que cero. Para β elegimos una Laplace porque β puede ser cualquier número real y la Laplace tiene colas más pesadas que la Normal, lo que ayuda a explorar mejor.

En la versión independiente las propuestas parten siempre desde los MLEs, sin importar dónde esté la cadena. En el random walk parten desde el estado actual. El resultado lo ven en la tasa de aceptación: 3% para el independiente, 12% para el random walk. El random walk explora más porque sus propuestas siempre están cerca de una zona razonable.

---

### [39:00 – 42:00] SLIDE — Parte 3: El gráfico

Después de las 5000 iteraciones tenemos 5000 pares de α y β. Cada par es una hipótesis posible sobre cómo se relaciona la temperatura con la falla. El gráfico que ven muestra exactamente eso — cada curva gris es uno de esos pares. La curva roja es el promedio de todas ellas.

Lo que más llama la atención es la dispersión entre 50 y 65 grados. Ahí las curvas se abren mucho. Eso no es un error — es incertidumbre real. En ese rango de temperaturas no hay casi ninguna observación, entonces el modelo no tiene datos para decidir con confianza dónde debe pasar la curva.

Los trace plots muestran cómo se movió la cadena. El independiente tiene escalones largos — períodos donde no se mueve. El random walk se mueve todo el tiempo pero tiene una deriva alrededor de la iteración 2000 donde α se va a valores muy altos. Con más iteraciones eso se estabiliza.

---

### [42:00 – 44:00] SLIDE — Parte 4: Probabilidades de falla

La pregunta final es concreta: ¿cuál era la probabilidad de falla el día del accidente?

Tomamos los 5000 pares de la cadena, calculamos la probabilidad de falla para cada temperatura de interés, y promediamos. Los resultados son claros: a 60 grados casi 80% de probabilidad, a 50 grados 96%, a 40 grados prácticamente certeza.

El día del accidente la temperatura era 31 grados — por debajo de todo lo que habían observado antes. El modelo estaría extrapolando, pero todas las curvas del gráfico convergen a probabilidad 1 en ese rango. La señal era inequívoca.

---

### [44:00 – 45:00] SLIDE — Conclusión

Con esto cerramos la presentación. Tres ideas para llevarse.

Primera: MCMC — y Metropolis-Hastings en particular — resuelve el problema de muestrear distribuciones complejas donde los métodos clásicos fallan, precisamente porque no necesita la constante de normalización.

Segunda: la elección del algoritmo y la calibración de la propuesta importan. Una tasa de aceptación del 3% versus el 12% no es un detalle técnico menor — afecta directamente la calidad de las estimaciones y la convergencia de la cadena.

Tercera: los trace plots y el diagnóstico de convergencia no son opcionales. Son parte del análisis, no un paso posterior.

Y sobre el Challenger: los datos estaban. El análisis era posible. La estadística hubiera dicho claramente que lanzar a 31 grados era extraordinariamente riesgoso. Este ejercicio es un recordatorio de que los modelos tienen valor solo si se usan en el momento en que importan.

Muchas gracias. Quedamos disponibles para preguntas.

---

*Fin — 45 minutos aproximados*

---

## Guía de tiempos rápida

| Minuto | Slide / Sección |
|---|---|
| 0:00 | Título y presentación del equipo |
| 1:00 | Contenidos |
| 2:00 | Objetivo — 4 motivaciones de MCMC |
| 5:00 | Qué es una Cadena de Markov |
| 7:00 | Distribución estacionaria y requisitos |
| 9:00 | Qué es MCMC |
| 13:00 | MH Genérico — fórmula y código |
| 18:00 | MH Independiente |
| 22:00 | MH Random Walk |
| 27:00 | Algoritmo de Langevin |
| 30:00 | Challenger — contexto histórico |
| 31:30 | Dataset y modelo logístico |
| 33:30 | Parte 1: GLM y MLEs |
| 36:00 | Parte 2: Implementación M-H |
| 39:00 | Parte 3: Gráfico y trace plots |
| 42:00 | Parte 4: Probabilidades |
| 44:00 | Conclusión |
