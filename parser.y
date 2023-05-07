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
%right CMP
%left '+' '-'
%left '*' '/'
%nonassoc '|' UMINUS
%type <a> exp explist list statement_list statement print_statement assignment_statement if_statement while_statement
%type <sl> symlist
%start program

%%

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


/* FIX: from here until the next breakline is my proposal for the grammar */

program: /* nothing */
        | program statement_list {
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

statement_list: /* nothing */
              | statement ';' { $$ = newast('L', $1, NULL);}
              | statement_list ';' statement ';'
              ;

statement : print_statement
          | assignment_statement
          | if_statement
          | while_statement
          | do_statement
          ;

print_statement: PRINT '(' exp ')' { $$ = newprint($3); }
  ;

assignment_statement: VAR NAME '=' exp { $$ = newasgn($2, $4); }
  | VAR NAME { $$ = newasgn($2, newnum(0)); }
  ;

if_statement: IF '(' exp ')' THEN '{' statement_list '}' { $$ = newflow('I', $3, $7, NULL); }
  | IF '(' exp ')' THEN '{' statement_list '}' ELSE '{' statement_list '}' { $$ = newflow('I', $3, $7, $11); }
  ;

while_statement: WHILE '(' comp_exp ')' DO '{' statement_list '}' { $$ = newflow('W', $3, $7, NULL); }

exp:  exp '+' exp { $$ = newast('+', $1,$3); }
  | exp '-' exp { $$ = newast('-', $1,$3);}
  | exp '*' exp { $$ = newast('*', $1,$3); }
  | exp '/' exp { $$ = newast('/', $1,$3); }
  | '|' exp '|' { $$ = newast('|', $2, NULL); }
  | '(' exp ')' { $$ = $2; }
  | '-' exp %prec UMINUS { $$ = newast('M', $2, NULL); }
  | NUMBER { $$ = newnum($1); }
  | NAME { $$ = newref($1); }
  | NAME '(' explist ')' { $$ = newuserfunction($1, $3); }
  ;

comp_exp: exp CMP exp { $$ = newcmp($2, $1, $3); }
        ;



/*------------------------------------*/

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

%%
