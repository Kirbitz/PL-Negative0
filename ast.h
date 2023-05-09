#ifndef AST_H
#define AST_H

extern int yylineno; /* from lexer */
void yyerror(char *s, ...);
/* nodes in the abstract syntax tree */
/* all have common initial nodetype */
struct ast {
  int nodetype;
  struct ast *l;
  struct ast *r;
};
struct numval {
  int nodetype; /* type K */
  double number;
};
struct symref {
  int nodetype; /* type N */
  struct symbol *s;
};
struct symasgn {
  int nodetype; /* type = */
  struct symbol *s;
  struct ast *v; /* value */
};
struct printref {
  int nodetype;
  struct ast *v;
};
/* build an AST */
struct ast *newast(int nodetype, struct ast *l, struct ast *r);
struct ast *newref(struct symbol *s);
struct ast *newasgn(struct symbol *s, struct ast *v);
struct ast *newnum(double d);
struct ast *newprint(struct ast *v);
/* evaluate an AST */
double eval(struct ast *);
/* delete and free an AST */
void treefree(struct ast *);

#endif
