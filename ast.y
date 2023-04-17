%{

#include <stdio.h>
#include <stdlib.h>
#include "ast.h"
int yylex(void);

%}

%union {
    double num;
    struct ast *a;
}

%token <num> NUMBER
%token ADD SUB MUL DIV
%token OpenP CloseP PIPE
%token EOL
%type <a> exp factor term

%%

calclist: /* nothing */
        | calclist exp EOL { printf("= %2.6g\n", eval($2)); treefree($2); printf("> "); }
        | calclist EOL { printf("> "); }
        ;

exp: factor
        | exp ADD factor { $$ = newast('+', $1, $3); }
        | exp SUB factor { $$ = newast('-', $1, $3); }
        ;

factor: term
        | factor MUL term { $$ = newast('*', $1, $3); }
        | factor DIV term { $$ = newast('/', $1, $3); }
        ;

term: NUMBER { $$ = newnum($1); }
        | PIPE exp PIPE { $$ = newast('|', $2, NULL); }
        | OpenP exp CloseP { $$ = ($2); }
        | SUB term { $$ = newast('M', $2, NULL); }
        ;

%%