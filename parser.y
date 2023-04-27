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
%token VAR PROCEDURE
%token PRINT RETURN
%token '(' ')' '{' '}' '[' ']'
%token ';' ','
%right '='
%left '+' '-'
%left '*' '/'
%nonassoc '|' UMINUS
%type <a> exp explist list
%type <sl> symlist
%start calclist

%%

exp:  exp '+' exp { $$ = newast('+', $1,$3); }
  | exp '-' exp { $$ = newast('-', $1,$3);}
  | exp '*' exp { $$ = newast('*', $1,$3); }
  | exp '/' exp { $$ = newast('/', $1,$3); }
  | '|' exp '|' { $$ = newast('|', $2, NULL); }
  | '(' exp ')' { $$ = $2; }
  | '-' exp %prec UMINUS { $$ = newast('M', $2, NULL); }
  | NUMBER { $$ = newnum($1); }
  | NAME { $$ = newref($1); }
  | VAR NAME '=' exp { $$ = newasgn($2, $4); }
  | VAR NAME { $$ = newasgn($2, newnum(0)); }
  | NAME '(' explist ')' { $$ = newuserfunction($1, $3); }
  | PRINT '(' exp ')' { $$ = newprint($3); }
  ;

list: { $$ = NULL; }
  | exp ';' list { $$ = newast('L', $1, $3); }
  | RETURN exp ';' list { $$ = $2; }
  ;

explist: exp
  | exp ',' explist { $$ = newast('L', $1, $3); }
  | { $$ = NULL; }
  ;

symlist: { $$ = NULL; }
  | NAME { $$ = newsymlist($1, NULL); }
  | NAME ',' symlist {
    if ($3 == NULL) {
      $$ = newsymlist($1, NULL);
    } else {
      $$ = newsymlist($1, $3); 
    }
  }
  ;

calclist: /* nothing */
  | calclist exp ';' {
    eval($2);
    treefree($2);
    printf("\e[1;31m>>> \e[0m");
  }
  | calclist PROCEDURE NAME '(' symlist ')' '{' list '}' ';' {
    dodef($3, $5, $8);
    printf("Defined %s\n\e[1;31m>>> \e[0m", $3->name); 
  }
  | calclist error ';' { yyerrok; printf("\e[1;31m>>> \e[0m"); }
  ;

%%
