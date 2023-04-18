%{

#include "y.tab.h"
int yyerror(char *errormsg);

%}

digit [0-9]
real -?{digit}+\.?{digit}*

%%

"+"    { return ADD; }
"-"    { return SUB; }
"*"    { return MUL; }
"/"    { return DIV; }
"("    { return OpenP; }
")"    { return CloseP; }
{real} { yylval.num = atof(yytext); return NUMBER; }
\n     { return EOL; }
[ \t]  { /* Ignore white space */ }
.      { yyerror("Unknown char");  }

%%

int main(int argc, char **argv)
{
  yyparse();

  return 0;
}

int yywrap(void)
{
   return 0;
}

int yyerror(char *errormsg)
{
    fprintf(stderr, "%s\n", errormsg);
    exit(1);
}