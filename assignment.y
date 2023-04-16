%{

#include <stdio.h>
#include <stdlib.h>
int yylex(void);
int yyerror(const char *s);
int sym[52];

%}

%union {
    int num;
    int val;
}

%token <val> VARIABLE
%token <num> NUMBER
%token EOL ASSIGN
%type <num> term

%%

line:
    | line term EOL { printf("= %d\n", $2); }
    | line assignment EOL
    ;

term: NUMBER
    | VARIABLE { $$ = sym[$1]; }
    ;

assignment: 
    | VARIABLE ASSIGN NUMBER { sym[$1] = $3; }
    | VARIABLE ASSIGN VARIABLE { sym[$1] = sym[$3]; }
    ;