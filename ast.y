%{

#include <stdio.h>
#include <stdlib.h>
#include "ast.h"
#include "symbol_table.h"
#include "function.h"
int yylex(void);

%}

%union {
        struct ast *a;
        double d;
        struct symbol *s;
        struct symlist *sl;
}
/* declare tokens */
%token <d> NUMBER
%token <s> NAME
%token EOL
%token VAR PROCEDURE
%token OPENP CLOSEP COMMA PRINT
%token START END CALL
%right ASSIGN
%left ADD SUB
%left MULT DIV
%nonassoc ABS UMINUS
%type <a> exp explist
%type <sl> symlist
%start calclist

%%

exp:  exp ADD exp { $$ = newast('+', $1,$3); }
        | exp SUB exp { $$ = newast('-', $1,$3);}
        | exp MULT exp { $$ = newast('*', $1,$3); }
        | exp DIV exp { $$ = newast('/', $1,$3); }
        | ABS exp ABS { $$ = newast('|', $2, NULL); }
        | OPENP exp CLOSEP { $$ = $2; }
        | SUB exp %prec UMINUS { $$ = newast('M', $2, NULL); }
        | NUMBER { $$ = newnum($1); }
        | NAME { $$ = newref($1); }
        | VAR NAME ASSIGN exp { $$ = newasgn($2, $4); }
        | CALL NAME OPENP explist CLOSEP { $$ = newuserfunction($2, $4); }
        ;

explist: exp
        | exp COMMA explist { $$ = newast('L', $1, $3); }
        ;

symlist: NAME { $$ = newsymlist($1, NULL); }
        | NAME COMMA symlist { $$ = newsymlist($1, $3); }
        ;

calclist: /* nothing */
        | calclist exp EOL {
                printf("\e[1;31m>>> \e[0m");
                eval($2);
                treefree($2);
        }
        | calclist PRINT OPENP exp CLOSEP EOL {
                printf("%4.4g\n\e[1;31m>>> \e[0m", eval($4));
                treefree($4);
        }
        | calclist PROCEDURE NAME OPENP symlist CLOSEP START exp END EOL {
                dodef($3, $5, $8);
                printf("Defined %s\n\e[1;31m>>> \e[0m", $3->name); 
        }
        | calclist error EOL { yyerrok; printf("\e[1;31m>>> \e[0m"); }
        ;

%%
