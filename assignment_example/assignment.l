%{

#include "y.tab.h"
int yyerror(char *errormsg);

%}

digit [0-9]

%%

":="                       { return ASSIGN; }
\n                         { return EOL; }
[ \t]                      {}
{digit}+                   { yylval.num = atoi(yytext); return NUMBER; }
[a-z]                      { yylval.val = yytext[0] - 'a'; return VARIABLE; }
[A-Z]                      { yylval.val = yytext[0] + 26 - 'A'; return VARIABLE; }
.                          { yyerror("Unknown Char"); }

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