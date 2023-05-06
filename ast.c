#include "ast.h"
#include "function.h"
#include "symbol_table.h"
#include "loops.h"
#include <math.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

struct ast *newast(int nodetype, struct ast *l, struct ast *r) {
  struct ast *a = malloc(sizeof(struct ast));
  if (!a) {
    yyerror("out of space");
    exit(0);
  }
  a->nodetype = nodetype;
  a->l = l;
  a->r = r;
  return a;
}
struct ast *newnum(double d) {
  struct numval *a = malloc(sizeof(struct numval));
  if (!a) {
    yyerror("out of space");
    exit(0);
  }
  a->nodetype = 'K';
  a->number = d;
  return (struct ast *)a;
}
struct ast *newref(struct symbol *s) {
  struct symref *a = malloc(sizeof(struct symref));
  if (!a) {
    yyerror("out of space");
    exit(0);
  }
  a->nodetype = 'N';
  a->s = s;
  return (struct ast *)a;
}
struct ast *newasgn(struct symbol *s, struct ast *v) {
  struct symasgn *a = malloc(sizeof(struct symasgn));
  if (!a) {
    yyerror("out of space");
    exit(0);
  }
  a->nodetype = '=';
  a->s = s;
  a->v = v;
  return (struct ast *)a;
}

struct ast *newprint(struct ast *v) {
  struct printref *a = malloc(sizeof(struct printref));
  if (!a) {
    yyerror("out of space");
    exit(0);
  }
  a->nodetype = 'P';
  a->v = v;
  return (struct ast *)a;
}
/* free a tree of ASTs */
void treefree(struct ast *a) {
  switch (a->nodetype) {
  /* two subtrees */
  case '+':
  case '-':
  case '*':
  case '/':
  case 'L':
    treefree(a->r);
  /* one subtree */
  case '|':
  case 'M':
  case 'C':
  case 'F':
    if (a->l) {
      treefree(a->l);
    }
  case 'P':
  /* no subtree */
  case 'K':
  case 'N':
    break;
  case '=':
    free(((struct symasgn *)a)->v);
    break;
  default:
    printf("internal error: free bad node %c\n", a->nodetype);
  }
  free(a); /* always free the node itself */
}

double eval(struct ast *a) {
  double v;
  if (!a) {
    yyerror("internal error, null eval");
    return 0.0;
  }
  switch (a->nodetype) {
  /* constant */
  case 'K':
    v = ((struct numval *)a)->number;
    break;
  /* name reference */
  case 'N':
    v = ((struct symref *)a)->s->value;
    break;
  /* assignment */
  case '=':
    v = ((struct symasgn *)a)->s->value = eval(((struct symasgn *)a)->v);
    break;
  /* expressions */
  case '+':
    v = eval(a->l) + eval(a->r);
    break;
  case '-':
    v = eval(a->l) - eval(a->r);
    break;
  case '*':
    v = eval(a->l) * eval(a->r);
    break;
  case '/':
    v = eval(a->l) / eval(a->r);
    break;
  case '|':
    v = fabs(eval(a->l));
    break;
  case 'M':
    v = -eval(a->l);
    break;
  /* list of statements */
  case 'L':
    eval(a->l);
    v = eval(a->r);
    break;
  case 'C':
    v = calluserfunction((struct userfunction *)a);
    break;
  case 'P':
    printf("%4.4g\n", eval(((struct printref *)a)->v));
    break;
  default:
    printf("internal error: bad node %c\n", a->nodetype);
  }
  return v;
}

void yyerror(char *s, ...) {
  va_list ap;
  va_start(ap, s);

  fprintf(stderr, "%d: error: ", yylineno);
  vfprintf(stderr, s, ap);
  fprintf(stderr, "\n");
}
