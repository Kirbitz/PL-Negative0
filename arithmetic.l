%{

#include "y.tab.h"
int yyerror(char *errormsg);

%}

%%

"+"    { return ADD; }
"-"    { return SUB; }
"*"    { return MUL; }
"/"    { return DIV; }
[0-9]+ { yylval.num = atoi(yytext); return NUMBER; }
\n     { return EOL; }
[ \t]  { /* Ignore white space */ }
.      { yyerror("Unknown char");  }

%%

int main(int argc, char **argv)
{
  printf("%d\n", yyparse());

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