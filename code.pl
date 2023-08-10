%Base de conocimiento:
anioActual(2015).


%festival(nombre, lugar, bandas, precioBase).

%lugar(nombre, capacidad).

festival(lulapaluza, lugar(hipodromo,40000), [miranda, paulMasCarne, muse], 500).

festival(mostrosDelRock, lugar(granRex, 10000), [kiss, judasPriest, blackSabbath], 1000).

festival(personalFest, lugar(geba, 5000), [tanBionica, miranda, muse, pharrellWilliams], 300).

festival(cosquinRock, lugar(aerodromo, 2500), [erucaSativa, laRenga], 400).


%banda(nombre, año, nacionalidad, popularidad).

banda(paulMasCarne,1960, uk, 70).

banda(muse,1994, uk, 45).

banda(kiss,1973, us, 63).

banda(erucaSativa,2007, ar, 60).

banda(judasPriest,1969, uk, 91).

banda(tanBionica,2012, ar, 71).

banda(miranda,2001, ar, 38).

banda(laRenga,1988, ar, 70).

banda(blackSabbath,1968, uk, 96).

banda(pharrellWilliams,2014, us, 85).


%entradasVendidas(nombreDelFestival, tipoDeEntrada, cantidadVendida).

% tipos de entrada: campo, plateaNumerada(numero de fila), plateaGeneral(zona).


entradasVendidas(lulapaluza,campo, 600).

entradasVendidas(lulapaluza,plateaGeneral(zona1), 200).

entradasVendidas(lulapaluza,plateaGeneral(zona2), 300).


entradasVendidas(mostrosDelRock,campo,20000).

entradasVendidas(mostrosDelRock,plateaNumerada(1),40).

entradasVendidas(mostrosDelRock,plateaNumerada(2),0).

% … y asi para todas las filas

entradasVendidas(mostrosDelRock,plateaNumerada(10),25).

entradasVendidas(mostrosDelRock,plateaGeneral(zona1),300).

entradasVendidas(mostrosDelRock,plateaGeneral(zona2),500).


plusZona(hipodromo, zona1, 55).

plusZona(hipodromo, zona2, 20).

plusZona(granRex, zona1, 45).

plusZona(granRex, zona2, 30).

plusZona(aerodromo, zona1, 25).

%Punto 1:
estaDeModa(UnaBanda):-
    esReciente(UnaBanda),
    popularidadMayorA(UnaBanda, 70).

esReciente(UnaBanda):-
    debutoHace(UnaBanda, Anios),
    Anios =< 5.

debutoHace(UnaBanda, Anios):-
    anioDeDebut(UnaBanda, AnioDeDebut),
    anioActual(AnioActual),
    Anios is AnioActual - AnioDeDebut.

popularidadMayorA(UnaBanda, LimiteDePopularidad):-
    popularidad(UnaBanda, Popularidad),
    Popularidad > LimiteDePopularidad.

popularidad(UnaBanda, Popularidad):-
    banda(UnaBanda,_,_,Popularidad).

%Punto 2:
esCareta(Festival):-
    participan2BandasDeModa(Festival).
esCareta(Festival):-
    entradasVendidas(Festival,_,_),
    not(entradaRazonable(_, Festival)).
esCareta(Festival):-
    toca(miranda,Festival).

participan2BandasDeModa(Festival):-
    participanteCareta(Festival, UnaBanda),
    participanteCareta(Festival, OtraBanda),
    UnaBanda \= OtraBanda.

participanteCareta(Festival, UnaBanda):-
    toca(UnaBanda, Festival),
    estaDeModa(UnaBanda).

toca(UnaBanda, Festival):-
    participantesDeFestival(Festival, Participantes),
    member(UnaBanda, Participantes).

participantesDeFestival(Festival, Participantes):-
    festival(Festival,_,Participantes,_).

%Punto 3:
entradaRazonable(Entrada, Festival):-
    precioYCantidadEntradaVendida(Festival, Entrada,_,Precio), %Preguntar sobre esta abstracción: *
    esRazonableSegunPrecio(Entrada, Festival ,Precio).

precioEntrada(Entrada, Festival, Precio):-
    festival(Festival,_,_,PrecioBase),
    precioSegunTipoDeEntrada(Entrada, Festival , PrecioBase, Precio).

precioSegunTipoDeEntrada(campo,_,PrecioBase,PrecioBase).
precioSegunTipoDeEntrada(plateaGeneral(Zona), Festival, PrecioBase, Precio):-
    plusZonaSegunFestival(Festival, Zona, Plus),
    Precio is PrecioBase + Plus.
precioSegunTipoDeEntrada(plateaNumerada(NumeroFila),_,PrecioBase, Precio):-
    Precio is (PrecioBase + 200) / NumeroFila.


esRazonableSegunPrecio(campo, Festival, Precio):-
    popularidadTotalFestival(Festival, PopularidadTotal),
    Precio < PopularidadTotal.
esRazonableSegunPrecio(plateaGeneral(Zona), Festival,Precio):-
    plusZonaSegunFestival(Festival, Zona, Plus),
    Plus < Precio * 10 / 100.
esRazonableSegunPrecio(plateaNumerada(_),Festival, Precio):- %Preguntar si es mejor 1 sólo pattern matching y separar lo de adentro o dejarlo así.
    not(participanteCareta(Festival,_)),
    Precio < 750.
esRazonableSegunPrecio(plateaNumerada(_),Festival, Precio):-
    festival(Festival,lugar(_,Capacidad),_,_),
    participanteCareta(Festival,_),
    popularidadTotalFestival(Festival, PopularidadTotal),
    Precio < Capacidad / PopularidadTotal.

plusZonaSegunFestival(Festival, Zona, Plus):-
    festival(Festival,lugar(Lugar,_),_,_),
    plusZona(Lugar,Zona, Plus).

popularidadTotalFestival(Festival, PopularidadTotal):-
    findall(Popularidad, popularidadDeParticipante(Festival, Popularidad), Popularidades),
    sum_list(Popularidades, PopularidadTotal).

popularidadDeParticipante(Festival, Popularidad):-
    toca(Banda, Festival),
    popularidad(Banda, Popularidad).


%Punto 4:
nacanpop(Festival):-
    festival(Festival,_,_,_),
    forall(toca(Banda, Festival), esNacional(Banda)),
    entradaRazonable(_,Festival).

esNacional(Banda):-
    banda(Banda,_,ar,_).

%Punto 5:
recaudacion(Festival,Recaudacion):-
    festival(Festival,_,_,_),
    findall(ValorRecadadoPorTipoDeTicket,valorPorTipoDeTicket(Festival, ValorRecadadoPorTipoDeTicket), Valores),
    sum_list(Valores, Recaudacion).

valorPorTipoDeTicket(Festival, ValorRecadadoPorTipoDeTicket):-
    precioYCantidadEntradaVendida(Festival,_, Cantidad, Precio),
    ValorRecadadoPorTipoDeTicket is Precio * Cantidad.

precioYCantidadEntradaVendida(Festival, Entrada, Cantidad, Precio):-
    entradasVendidas(Festival, Entrada, Cantidad),
    precioEntrada(Entrada, Festival, Precio).

%Punto 6:
estaBienPlaneado(Festival):-
    festival(Festival,_,_,_),
    forall(toca(Banda,Festival), creceEnPopularidad(Banda)),
    ultimaBandaLegendaria(Festival).

ultimaBandaLegendaria(Festival):-
    ultimaBanda(Festival,Banda),
    legendaria(Banda).

ultimaBanda(Festival, Banda):-
    participantesDeFestival(Festival, Participantes),
    length(Participantes, Cantidad),
    nth0(Cantidad, Participantes, Banda).

legendaria(Banda):-
    anioDeDebut(Banda, AnioDebut),
    AnioDebut < 1980,
    not(esNacional(Banda)),
    laMasPopular(Banda).

anioDeDebut(Banda, AnioDebut):-
    banda(Banda,AnioDebut,_,_).

laMasPopular(Banda):-
    estaDeModa(BandaDeModa),
    not(esMasPopular(BandaDeModa, Banda)).

esMasPopular(UnaBanda,OtraBanda):-
    popularidad(OtraBanda, PopularidadOtraBanda),
    popularidadMayorA(UnaBanda, PopularidadOtraBanda).
/*
antes era:

entradasVendidas(Festival, Entrada,_),
precioEntrada(Entrada, Festival, Precio),

Pero en valorPorTipoDeTicket hacia algo muy parecido, pero necesitaba la cantidad.
Entonces, generé la abstracción:precioYCantidadEntradaVendida

Pero no sé si está bien.
 */
