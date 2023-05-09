#include "Loops.h"
#include "ast.h"
#include <math.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

struct ast *newcmp(int cmptype, struct ast *l, struct ast *r) {
  struct ast *a = malloc(sizeof(struct ast));

  if (!a) {
    yyerror("out of space");
    exit(0);
  }
  a->nodetype = '0' + cmptype;
  a->l = l;
  a->r = r;
  return a;
}

struct ast *newflow(int nodetype, struct ast *cond, struct ast *tl,
                    struct ast *el) {
  struct flow *a = malloc(sizeof(struct flow));

  if (!a) {
    yyerror("out of space");
    exit(0);
  }
  a->nodetype = nodetype;
  a->cond = cond;
  a->tl = tl;
  a->el = el;
  return (struct ast *)a;
}
