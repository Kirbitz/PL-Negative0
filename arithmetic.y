%{

#include <stdio.h>
#include <stdlib.h>
int yylex(void);
int yyerror(const char *s);

%}

%union {
    double num;
}

%token <num> NUMBER
%token ADD SUB MUL DIV
%token OpenP CloseP
%token EOL
%type <num> factor
%type <num> exp
%type <num> term

%%

calclist: /* nothing */
        | calclist exp EOL { printf("= %f\n", $2); }
        ;

exp: factor
        | exp ADD factor { $$ = $1 + $3; }
        | exp SUB factor { $$ = $1 - $3; }
        ;

factor: term
        | factor MUL term { $$ = $1 * $3; }
        | factor DIV term { $$ = $1 / $3; }
        ;

term: NUMBER
        | OpenP exp CloseP { $$ = ($2); }
        ;