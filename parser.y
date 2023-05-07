%{

#include <stdio.h>
#include <stdlib.h>
#include "ast.h"
#include "symbol_table.h"
#include "function.h"
#include "Loops.h"
int yylex(void);

%}

%union {
  int fn;
  struct ast *a;
  double d;
  struct symbol *s;
  struct symlist *sl;
}

/* declare tokens TODO: insert new grammar for WHILE DO IF THEN ELSE*/
%token <d> NUMBER
%token <s> NAME
%token VAR PROCEDURE
%token WHILE IF ELSE
%token PRINT RETURN
%token '(' ')' '{' '}' '[' ']'
%token ';' ','
%nonassoc <fn> CMP
%left '+' '-'
%left '*' '/'
%left AND OR
%right NOT
%nonassoc '|' UMINUS
%type <a> exp explist statement_list statement print_statement assignment_statement if_statement while_statement comp_exp
%type <sl> symlist
%start program

%%

/* FIX: from here until the next breakline is my proposal for the grammar */

program: /* nothing */
        | program statement_list '.' {
          eval($2);
          treefree($2);
          printf("\e[1;31m>>> \e[0m");
        }
        | program PROCEDURE NAME '(' symlist ')' '{' statement_list '}' ';' {
          dodef($3, $5, $8);
          printf("Defined %s\n\e[1;31m>>> \e[0m", $3->name); 
        }
        | program error ';' { yyerrok; printf("\e[1;31m>>> \e[0m"); }
  ;

statement_list: /* nothing */ { $$ = NULL;}
              | statement ';' statement_list { /*Check for nullity*/
                                                  if ($3 == NULL) {
                                                    $$ = $1;
                                                  }
                                                  else{
                                                    $$ = newast('L', $1, $3);
                                                    }
                                                }
              | RETURN exp ';' { $$ = $2; }
              ;

statement : print_statement
          | assignment_statement
          | if_statement
          | while_statement
          | exp { $$ = $1; }
          ;

print_statement: PRINT '(' exp ')' { $$ = newprint($3); }
  ;

assignment_statement: VAR NAME '=' exp { $$ = newasgn($2, $4); }
  | VAR NAME { $$ = newasgn($2, newnum(0)); }
  ;

if_statement: IF '(' comp_exp ')' '{' statement_list '}' { $$ = newflow('I', $3, $6, NULL); }
  | IF '(' comp_exp ')' '{' statement_list '}' ELSE '{' statement_list '}' { $$ = newflow('I', $3, $6, $10); }
  ;

while_statement: WHILE '(' comp_exp ')' '{' statement_list '}' { $$ = newflow('W', $3, $6, NULL); }

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
        | comp_exp AND comp_exp { $$ = newast('A', $1, $3); }
        | comp_exp OR comp_exp { $$ = newast('O', $1, $3); }
        | NOT comp_exp { $$ = newast('!', $2, NULL); }
        ;



/*------------------------------------*/


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
