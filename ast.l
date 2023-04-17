%{

#include "y.tab.h"
#include "ast.h"
void yyerror(char *s, ...);

%}

digit [0-9]
real -?{digit}+\.?{digit}*
alpha [A-Za-z]

%%

"+"    { return ADD; }
"-"    { return SUB; }
"*"    { return MUL; }
"/"    { return DIV; }
"("    { return OpenP; }
")"    { return CloseP; }
"|"    { return PIPE; }
{real} { yylval.num = atof(yytext); return NUMBER; }
\n     { return EOL; }
[ \t]  { /* Ignore white space */ }
.      { yyerror("Unknown char %c\n", *yytext);  }

%%

int main() {
    printf("> ");
    return yyparse();
}

int yywrap(void)
{
   return 0;
}