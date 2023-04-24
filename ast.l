%{

#include "y.tab.h"
#include "ast.h"
#include "symbol_table.h"
void yyerror(char *s, ...);

%}

/* float exponent */
EXP ([Ee][-+]?[0-9]+)
alpha [a-zA-Z]
digit [0-9]
symbol_name {alpha}({alpha}|{digit})*

%%
"+"                                { return ADD; }
"-"                                { return SUB; }
"*"                                { return MULT; }
"/"                                { return DIV; }
":="                               { return ASSIGN; }
"|"                                { return ABS; }
","                                { return COMMA; }
"("                                { return OPENP; }
")"                                { return CLOSEP; }
("print"|"PRINT")                  { return PRINT; }
("VAR"|"var")                      { return VAR; }
("PROCEDURE"|"procedure")          { return PROCEDURE; }
"{"                                { return OCLP; }
"}"                                { return CCLP; }
("CALL"|"call")                    { return CALL; }
{symbol_name}                      { yylval.s = lookup(yytext); return NAME; }
[0-9]+"."[0-9]*{EXP}? |
"."?[0-9]+{EXP}?                   { yylval.d = atof(yytext); return NUMBER; }
[ \t\n] /* ignore whitespace */
";"                                { return EOL; }
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
