choose(100, 5) # n´umero de muestras posibles

choose(90, 5) # n° muestras con 5 chips en buen estado

choose(90, 5) / choose(100, 5) # P{X = 5}

choose(90, 4) * choose(10, 1) / choose(100, 5) # P{X = 4}

choose(90, 4:5) * choose(10, 1:0) / choose(100, 5) # P{X=4}, P{X=5}

sum(choose(90, 4:5) * choose(10, 1:0) / choose(100, 5)) # P{X>=4}

x = 0:5 # recorrido de X

px = choose(90, x) * choose(10, 5-x) / choose(100, 5); px # P{X=x}

round(px, 3) # redondeo a tres cifras

cbind(x, 'P{X=x}' = round(px, 3)) # formato tabla
# gr´afico de P{X = x}

plot(x, px, type = 'h', lwd = 5, ylim = c(0, 1),
main = 'Grafico de P{X=x}'); abline(h = 0)
# reconociendo la distribuci´on Hipergeom´etrica y utilizando la funci´on "dhyper()"

dhyper(0:5, 90, 10, 5)

cbind(x, 'P{X=x}' = round(px, 5), # comparaci´on
    'dhyper' = round(dhyper(0:5, 90, 10, 5), 5))

sum(x * px) # valor esperado de X