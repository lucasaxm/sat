:- dynamic variavel/1, true/1, false/1, clausula_tem_variavel/0.

sat(Formula, X) :-
    parse_formula(Formula, Y),
%    dpll(Y, X).
    sat_dpll(Y,X).

sat_dpll(Clausulas, S) :-
    dpll(Clausulas, S),
    S = 'S'.

sat_dpll(_, S) :-
    S = 'Unsat'.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               FUNÇÕES DE PARSE                               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%
% parse_formula(Formula, Clausulas)
%
parse_formula(Formula, Clausulas) :-
	retractall(variavel(_)),
	retractall(true(_)),
	retractall(false(_)),
	string_codes(Formula, FormulaLista),
	limpa_formula(FormulaLista, FormulaClean),
	parse_clausulas(FormulaClean, Clausulas).

%
% limpa_formula(Formula, Res)
%
%  Limpa Formula, removendo espaços e caracteres desnecessarios, armazenando o
%  resultao em Res.
%
limpa_formula([], []) :- !.

limpa_formula([35|T], Res) :- % operador de interseção (∧);
	limpa_formula(T, Res), !.

limpa_formula([40|T], Res) :- % abre parênteses
	limpa_formula(T, Res), !.

limpa_formula([41|T], Res) :- % fecha parênteses
	limpa_formula(T, Res), !.

limpa_formula([32|T], Res) :- % espaço em branco
	limpa_formula(T, Res), !.

limpa_formula([H|T], [H|Res]) :- % abre parênteses
	limpa_formula(T, Res).

%
% parse_clausulas(Formula, Clausulas)
%
%  Faz o parse das clausulas de uma formula. Ou seja, transforma a string
%  Formula em uma lista de clausulas.
%
parse_clausulas([], []) :- !.

parse_clausulas(Formula, [Clausula|T]) :-
	parse_literais(Formula, Clausula, RestoFormula),
	parse_clausulas(RestoFormula, T).

%
% parse_literais(FormulaParcial, Literais, RestoFormula)
%
%  Faz o parse de uma clausula da formula. Ou seja, varre a string Formula
%  até obter uma clausula completa, transforma em uma lista de literais
%  (retornando em Clausula) e também retorna o resto da formula que não foi
%  varrido em RestoFormula.
%
parse_literais([], [], []) :- !.

parse_literais([38|T], [], T) :- !.

parse_literais(Formula, [Literal|T], RestoFormula) :-
	parse_literal(Formula, Literal, RestoClausula),
	parse_literais(RestoClausula, T, RestoFormula), !.

%
% parse_literal(FormulaParcial, Literal, RestoFormula)
%
parse_literal([126|[120|T]], Literal, Resto) :-
	parse_numero(T, Variavel, Resto, _),
	define_variavel(Variavel),
	Literal is -Variavel.

parse_literal([120|T], Literal, Resto) :-
	parse_numero(T, Variavel, Resto, _),
	define_variavel(Variavel),
	Literal is Variavel.

%
% parse_numero(FormulaParcial, Numero, RestoFormula, Nivel)
%
parse_numero([Chr|T], X, Resto, N1) :-
	% 48 a 57 algarismos de "0" a "9" usados na continuação do nome de cada âtomo.
	Chr >= 48,
	Chr =< 57,
	Digito is Chr - 48,
	parse_numero(T, X1, Resto, N),
	N1 is N + 1,
	X is (Digito * (10^N)) + X1.

parse_numero([], 0, [], 0).

parse_numero([H|T], 0, [H|T], 0).

%
% define_variavel(Variavel)
%
define_variavel(Variavel) :-
	not(variavel(Variavel)),
	assertz(variavel(Variavel)).

define_variavel(_).

% tretas

mem(X, [X|_]).
mem(X, [_|Y]) :-
   mem(X, Y).

% sel(+Elem, +List, -List)
sel(X, [X|Y], Y).
sel(X, [Y|Z], [Y|T]) :-
   sel(X, Z, T).

% filter(+ListOfList, +Elem, +Elem, -ListOfList)
filter([], _, _, []).
filter([K|F], L, M, [J|G]) :-
   sel(M, K, J), !,
   J \== [],
   filter(F, L, M, G).
filter([K|F], L, M, G) :-
   mem(L, K), !,
   filter(F, L, M, G).
filter([K|F], L, M, [K|G]) :-
   filter(F, L, M, G).

% sat(+ListOfLists, -List)
dpll([[L|_]|F], [L|V]):-
   M is -L,
   filter(F, L, M, G),
   sat(G, V).
dpll([[L|K]|F], [M|V]):-
   K \== [],
   M is -L,
   filter(F, M, L, G),
   sat([K|G], V).
dpll([], []).