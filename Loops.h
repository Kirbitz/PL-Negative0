#ifndef LOOPS_H
#define LOOPS_H

extern int yylineno; /* from lexer */
void yyerror(char *s, ...);

struct flow {
  int nodetype; /* type F */
  struct ast *cond;
  struct ast *tl;
  struct ast *el;
};

struct ast *newcmp(int cmptype, struct ast *l, struct ast *r);
struct ast *newflow(int nodetype, struct ast *cond, struct ast *tl, struct ast *el);


#endif