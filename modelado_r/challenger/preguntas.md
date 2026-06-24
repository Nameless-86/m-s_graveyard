---
Preguntas básicas de concepto

"¿Qué es una cadena de Markov?"
Una secuencia de variables aleatorias donde la distribución de X^(t) dado el pasado depende solo de X^(t-1). El futuro es independiente del pasado dado el presente. Formalmente: P(X^(t+1) | X^(0),...,X^(t)) = K(X^(t), X^(t+1)).

"¿Qué es la distribución estacionaria?"
Una distribución f tal que si X^(t) ~ f entonces X^(t+1) ~ f. La cadena "no cambia de forma" una vez que llega ahí. Satisface ∫ K(x,y) f(x) dx = f(y).

"¿Qué es MCMC?"
Monte Carlo vía Cadenas de Markov. La idea es construir una cadena de Markov cuya distribución estacionaria sea la distribución que queremos samplear. En lugar de generar muestras independientes, generamos una secuencia correlacionada que a largo plazo se distribuye como la target.

"¿Por qué usar MCMC en lugar de Monte Carlo clásico?"
Monte Carlo clásico requiere samplear directamente de f, lo que muchas veces es imposible cuando f no tiene forma analítica conocida o es de alta dimensión. MCMC solo requiere evaluar f puntualmente — ni siquiera necesita la constante normalizadora.

"¿Qué es ergocidad?"
Propiedad de una cadena recurrente por la que el promedio temporal converge al promedio bajo la distribución estacionaria: (1/T) Σ h(X^(t)) → E_f[h(X)]. Es la justificación teórica de que las muestras MCMC sirven para estimar integrales.

---
Preguntas sobre MH

"¿Qué es la distribución instrumental/propuesta?"
La distribución q(y|x) desde la que se generan los candidatos en cada iteración. Solo necesita ser fácil de samplear y tener el mismo soporte que la target.

"¿Qué es la probabilidad de aceptación de MH?"
ρ(x,y) = min{1, [f(y)/f(x)] × [q(x|y)/q(y|x)]}. Si el candidato tiene mayor densidad que el estado actual se acepta siempre. Si tiene menor, se acepta con probabilidad proporcional al ratio.

"¿Qué es la condición de balance detallado?"
f(x) K(y|x) = f(y) K(x|y). Es la condición que garantiza que f es la distribución estacionaria del kernel K. El algoritmo MH satisface esta condición por construcción.

"¿Qué diferencia hay entre Metropolis y Metropolis-Hastings?"
Metropolis (1953) solo funciona con propuestas simétricas donde q(y|x) = q(x|y) — el segundo término del ratio vale 1 y desaparece. Hastings (1970) generalizó para cualquier propuesta asimétrica incluyendo el término de corrección q(x|y)/q(y|x).

---
Preguntas sobre las variantes

"¿Cuándo usar MH independiente vs random walk?"
Independiente cuando se puede construir una buena propuesta global — por ejemplo centrada en el MLE con varianza calibrada. Random walk cuando no se conoce bien la forma de la posterior o en dimensiones altas donde construir una propuesta global es difícil.

"¿Qué ventaja tiene el random walk sobre el independiente?"
No necesita conocer la forma global de la distribución — solo explora localmente. El ratio se simplifica porque la propuesta es simétrica. Desventaja: necesita calibrar el tamaño del paso.

"¿Qué es el algoritmo de Langevin?"
Una variante del random walk que agrega el gradiente de la log-densidad a la propuesta: Y = X^(t) + (σ²/2)·∇log f(X^(t)) + σ·ε. El gradiente empuja la propuesta hacia zonas de mayor densidad. Como la propuesta ya no es simétrica, el ratio de corrección no se cancela.

"¿Por qué Langevin no funciona bien en distribuciones multimodales?"
El gradiente refuerza la atracción al modo local — hace más difícil escapar a otros modos. El random walk sin gradiente tiene más chances de explorar toda la distribución aunque sea menos eficiente en cada modo.

---
Preguntas sobre diagnóstico

"¿Cómo se diagnostica la convergencia?"
Trace plots: la cadena debe oscilar rápidamente sin deriva ni escalones. También autocorrelación (acf), criterio de Gelman-Rubin con múltiples cadenas, y tamaño efectivo de muestra.

"¿Qué indica un trace plot con escalones largos?"
Baja tasa de aceptación — la cadena se queda en el mismo valor muchas iteraciones. Puede significar que la propuesta propone valores muy alejados de la región de alta densidad.

"¿Qué es el tamaño efectivo de muestra?"
Cuántas muestras iid equivaldrían a las N muestras correlacionadas de la cadena. Si la autocorrelación es alta, el tamaño efectivo es mucho menor que N — necesitás más iteraciones para la misma precisión.precisión?"
Porque las muestras están correlacionadas. La varianza del estimador depende no solo de N sino de la autocorrelación de la cadena.

---
Preguntas sobre el Ejemplo 6.2 (Cauchy)

"¿Por qué la propuesta Normal falla para la Cauchy?"
La Normal tiene colas más livianas que la Cauchy. Cuando la cadena llega a un valor extremo, la Normal casi nunca propone candidatos en esa zona — la cadena queda atrapada.

"¿Por qué la propuesta t(0.5) tampoco funciona bien?"
El problema opuesto: colas demasiado pesadas. Propone valores extremísimos que se aceptan y dominan toda la muestra.

---
