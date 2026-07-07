:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/http_json)).
:- use_module(library(http/http_parameters)).

materia(matematicas1, 1, ciencias_basicas, ninguna).
materia(matematicas2, 2, ciencias_basicas, matematicas1).
materia(programacion1, 1, sistemas, ninguna).
materia(programacion2, 2, sistemas, programacion1).
materia(fisica1, 2, ciencias_basicas, matematicas1).

curso(juan,matematicas1,[67,89]).
curso(juan,programacion1,[88]).
curso(yesid,matematicas1,[90]).
curso(yesid,programacion1,[98]).
curso(luis, matematicas1, [40, 55, 45]).
curso(luis, programacion1, [85]).


ultima_nota(Estudiante, Tema, Nota):-
  curso(Estudiante, Tema, Notas),
  last(Notas, Nota).

veces_que_curso(Estudiante, Tema, Veces):-
  curso(Estudiante, Tema, Notas),
  length(Notas, Veces).

calificaciones(Alumno, Materia, Nota) :-
    curso(Alumno, Materia, Nota).

aprobo(Alumno,Materia):-curso(Alumno, Materia, Notas),
  ultimaNota(Alumno,Materia,Nota),
  last(Notas, Nota), Nota >= 70.

puede_cursar(Alumno, Materia) :-
    !, aprobo(Alumno, Materia).
puede_cursar(Alumno, Materia) :-
    materia(Materia, _, _, Prerrequisito),
    (Prerrequisito == ninguna -> true ; aprobo(Alumno, Prerrequisito)).

baja(Alumno):-curso(Alumno,X,Notas),
  length(Notas,3),
  forall(member(N,Notas),N < 70).

promedio_general(Alumno, Promedio) :-
    findall(Ultima, (curso(Alumno, _, C), last(C, Ultima)), Ultimas),
    Ultimas \== [],
    sum_list(Ultimas, Suma),
    length(Ultimas, Cantidad),
    Promedio is Suma / Cantidad.

alto_rendimiento(Alumno) :-
    promedio_general(Alumno, Promedio),
    Promedio >= 90.

aspirantes_curso(Materia, ListaAspirantes) :-
    materia(Materia, _, _, Prerrequisito),
    findall(Alumno, (
        curso(Alumno, _, _),
        \+ aprobo(Alumno, Materia),
        (Prerrequisito == ninguna -> true ; aprobo(Alumno, Prerrequisito))
    ), ListaDuplicada),
    sort(ListaDuplicada, ListaAspirantes).

server(Port) :-
    http_server(http_dispatch, [port(Port)]),
    format('Servidor escolar corriendo en el puerto ~w~n', [Port]).

:- http_handler(root(alumno/historial), handle_historial, []).
:- http_handler(root(alumno/estado), handle_estado, []).
:- http_handler(root(alumnos/alto_rendimiento), handle_alto_rendimiento, []).
:- http_handler(root(materias/oferta), handle_oferta_academica, []).
:- http_handler(root(curso/aspirantes), handle_aspirantes, []).

handle_historial(Request) :-
    http_parameters(Request, [nombre(Alumno, [atom])]),
    findall(json([materia=M, intentos=Intentos, calificaciones=C]),
            (curso(Alumno, M, C), length(C, Intentos)),
            Historial),
    reply_json(json([alumno=Alumno, historial=Historial])).

handle_estado(Request) :-
    http_parameters(Request, [nombre(Alumno, [atom])]),
    (   curso(Alumno, _, _) ->
        (promedio_general(Alumno, Prom), ! ; Prom = 0),
        max_materias_permitidas(Alumno, Limite),
        (puede_cursar(Alumno, matematicas2) -> PuedeMat2 = true ; PuedeMat2 = false),
        (dado_de_baja(Alumno) -> Baja = true ; Baja = false),
        reply_json(json([
            alumno=Alumno, promedio=Prom,
            max_materias=Limite, puede_matematica2=PuedeMat2, dado_de_baja=Baja
        ]))
    ;   reply_json(json([error='Alumno no encontrado']), [status(404)])
    ).

handle_alto_rendimiento(_Request) :-
    findall(json([alumno=A, promedio=P]), alto_rendimiento(A, P), Lista),
    reply_json(json([alto_rendimiento=Lista])).

handle_oferta_academica(_Request) :-
    findall(json([materia=M, semestre=S, area=Area]), materia(M, S, Area, _), Materias),
    reply_json(json([materias=Materias])).

handle_aspirantes(Request) :-
    http_parameters(Request, [materia(Materia, [atom])]),
    (   materia(Materia, _, _, _) ->
        aspirantes_curso(Materia, Lista, Total),
        reply_json(json([materia=Materia, total_aspirantes=Total, alumnos=Lista]))
    ;   reply_json(json([error='Materia no existe']), [status(404)])
    ).








