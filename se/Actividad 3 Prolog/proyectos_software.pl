desarrollador(juan, junior).
desarrollador(yesid, junior).
desarrollador(luis, junior).
desarrollador(miguel, junior).
desarrollador(obed, avanzado).
desarrollador(laurel, avanzado).
desarrollador(avik, avanzado).
desarrollador(jose, senior).
desarrollador(champo, senior).
desarrollador(alex, senior).

proyecto(proyecto_A, bajo).
proyecto(proyecto_B, medio).
proyecto(proyecto_C, alto).
proyecto(proyecto_D, muy_alto).
proyecto(proyecto_E, bajo).
proyecto(proyecto_F, medio).
proyecto(proyecto_G, alto).
proyecto(proyecto_H, muy_alto).
proyecto(proyecto_I, bajo).
proyecto(proyecto_J, medio).

requerimiento(bajo,     0, 1, 1).
requerimiento(medio,    1, 1, 0).
requerimiento(alto,     1, 1, 1).
requerimiento(muy_alto, 1, 2, 2).

contar_disponibles(Nivel, Total) :-
    findall(Nom, desarrollador(Nom, Nivel), Lista),
    length(Lista, Total).

listar_desarrolladores :-
    write('--- Lista de Desarrolladores ---'), nl,
    desarrollador(Nombre, Nivel),
    format('Desarrollador: ~w | Nivel: ~w~n', [Nombre, Nivel]),
    fail.
listar_desarrolladores.

listar_proyectos :-
    write('--- Lista de Proyectos ---'), nl,
    proyecto(Nombre, Nivel),
    format('Proyecto: ~w | Nivel: ~w~n', [Nombre, Nivel]),
    fail.
listar_proyectos.

cumple_requerimientos(Proyecto) :-
    proyecto(Proyecto, NivelDificultad),
    requerimiento(NivelDificultad, ReqSenior, ReqAvanzado, ReqJunior),
    contar_disponibles(senior, DispSenior),
    contar_disponibles(avanzado, DispAvanzado),
    contar_disponibles(junior, DispJunior),
    DispSenior >= ReqSenior,
    DispAvanzado >= ReqAvanzado,
    DispJunior >= ReqJunior.


personal_faltante(Proyecto) :-
    proyecto(Proyecto, NivelDificultad),
    requerimiento(NivelDificultad, ReqSenior, ReqAvanzado, ReqJunior),
    contar_disponibles(senior, DispSenior),
    contar_disponibles(avanzado, DispAvanzado),
    contar_disponibles(junior, DispJunior),

    FaltaSenior is max(0, ReqSenior - DispSenior),
    FaltaAvanzado is max(0, ReqAvanzado - DispAvanzado),
    FaltaJunior is max(0, ReqJunior - DispJunior),

    format('Para el ~w (~w):~n', [Proyecto, NivelDificultad]),
    format('  Faltan Seniors: ~w~n', [FaltaSenior]),
    format('  Faltan Avanzados: ~w~n', [FaltaAvanzado]),
    format('  Faltan Juniors: ~w~n', [FaltaJunior]).


