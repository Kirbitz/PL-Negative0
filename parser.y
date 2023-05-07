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

/* declare tokens TODO: insert new grammar for WHILE DO IF THEN ELSE*/
%token <d> NUMBER
%token <s> NAME
%token VAR PROCEDURE
%token WHILE DO IF THEN ELSE
%token PRINT RETURN
%token '(' ')' '{' '}' '[' ']'
%token ';' ','
%right '='
%left '+' '-'
%left '*' '/'
%nonassoc '|' UMINUS
%type <a> exp explist list
%type <sl> symlist
%start program

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

program: /* nothing */
  | program exp ';' {
    eval($2);
    treefree($2);
    printf("\e[1;31m>>> \e[0m");
  }
  | program PROCEDURE NAME '(' symlist ')' '{' list '}' ';' {
    dodef($3, $5, $8);
    printf("Defined %s\n\e[1;31m>>> \e[0m", $3->name); 
  }
  | program error ';' { yyerrok; printf("\e[1;31m>>> \e[0m"); }
  ;

%%

/*

program: statement_list
        ;

statement_list: statement
               | statement_list EOL statement
                ;

statement: print_statement
         | assignment_statement
         | if_statement
         | while_statement
         | do_statement
         ;

print_statement: PRINT expr EOL
                { printf("%d\n", $2); }
                ;

assignment_statement: VARIABLE '=' expr EOL
                      { $1 = $3; }

if_statement: IF expr THEN statement_list else_statement EOL
              | IF expr THEN statement_list EOL

else_statement: ELSE statement_list
                | /* empty */
/*                ;

while_statement: WHILE expr DO statement_list EOL

do_statement: DO statement_list WHILE expr EOL

expr: INTEGER
    | VARIABLE
    | expr '+' expr
    | expr '-' expr
    | expr '*' expr
    | expr '/' expr
    | '(' expr ')'

%%

*/