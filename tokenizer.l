%{

#include "symbol_table.h"
#include "ast.h"
#include "y.tab.h"
void yyerror(char *s, ...);

%}

/* float exponent */
EXP ([Ee][-+]?[0-9]+)
alpha [a-zA-Z]
digit [0-9]
symbol_name {alpha}({alpha}|{digit})*

%%
"+" |
"-" |
"*" |
"/" |
"=" |
"|" |
"," |
"(" |
")" |
"}" |
"{" |
"[" |
"]" |
"." |
";"                                { return yytext[0]; }
">" { yylval.fn = 1; return CMP; }
"<" { yylval.fn = 2; return CMP; }
"!=" { yylval.fn = 3; return CMP; }
"==" { yylval.fn = 4; return CMP; }
">=" { yylval.fn = 5; return CMP; }
"<=" { yylval.fn = 6; return CMP; }
("print"|"PRINT")                  { return PRINT; }
("VAR"|"var")                      { return VAR; }
("PROCEDURE"|"procedure")          { return PROCEDURE; }
("RETURN"|"return")                { return RETURN; }
("IF"|"if")                        { return IF; }
("ELSE"|"else")                    { return ELSE; }
("WHILE"|"while")                  { return WHILE; }
("OR"|"or")                        { return OR; }
("AND"|"and")                      { return AND; }
("NOT"|"not")                      { return NOT; }
{symbol_name}                      { yylval.s = lookup(yytext); return NAME; }
[0-9]+"."[0-9]*{EXP}? |
"."?[0-9]+{EXP}?                   { yylval.d = atof(yytext); return NUMBER; }
[ \t\n] /* ignore whitespace */
.                                  { yyerror("Mystery character %c\n", *yytext); }

%%

int main() {
  printf("\e[1;31m>>> \e[0m");
  return yyparse();
}

int yywrap(void)
{
  return 0;
}
