inventario(pollo, 1000).
inventario(arroz, 500).
inventario(mole, 300).
inventario(tortilla, 12).
inventario(queso, 200).
inventario(tomate, 4).
inventario(cebolla, 1).
inventario(carne_res, 0).

receta(mole_con_pollo, pollo, 500).
receta(mole_con_pollo, mole, 200).
receta(mole_con_pollo, arroz, 250).

receta(enchiladas, tortilla, 4).
receta(enchiladas, pollo, 150).
receta(enchiladas, queso, 100).
receta(enchiladas, tomate, 3).

receta(tacos_res, tortilla, 3).
receta(tacos_res, carne_res, 300).
receta(tacos_res, cebolla, 1).

obtener_disponible(Ingrediente, Disponible) :-
    inventario(Ingrediente, Disponible), !.
obtener_disponible(_, 0).

ingredientes_de(Platillo) :-
    receta(Platillo, _, _),
    format('--- Ingredientes para ~w ---~n', [Platillo]),
    receta(Platillo, Ingrediente, Cantidad),
    format('  * ~w: ~w~n', [Ingrediente, Cantidad]),
    fail.
ingredientes_de(Platillo) :-
    \+ receta(Platillo, _, _),
    format('El platillo "~w" no está en el menú.~n', [Platillo]), !.
ingredientes_de(_).

puede_prepararse(Platillo) :-
    receta(Platillo, _, _),
    \+ (
        receta(Platillo, Ingrediente, Req),
        obtener_disponible(Ingrediente, Disp),
        Disp < Req
    ).

ingredientes_faltantes(Platillo) :-
    receta(Platillo, _, _),
    format('--- Reporte de Faltantes para ~w ---~n', [Platillo]),
    findall(Ingrediente, (
        receta(Platillo, Ingrediente, Req),
        obtener_disponible(Ingrediente, Disp),
        Disp < Req,
        Faltante is Req - Disp,
        format('  -> Falta ~w: necesita ~w más (Disponibles: ~w)~n', [Ingrediente, Faltante, Disp])
    ), ListaFaltantes),
    (ListaFaltantes == [] -> format('  ¡Todo listo! No falta ningún ingrediente.~n', []) ; true), !.
ingredientes_faltantes(Platillo) :-
    \+ receta(Platillo, _, _),
    format('El platillo "~w" no está en el menú.~n', [Platillo]).

















