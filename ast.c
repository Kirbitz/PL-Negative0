#include "ast.h"
#include "function.h"
#include "symbol_table.h"
#include "Loops.h"
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
  case '1':
  case '2':
  case '3':
  case '4':
  case '5':
  case '6':
  case 'A':
  case 'O':
  case 'L':
    treefree(a->r);
  /* one subtree */
  case '|':
  case 'M':
  case 'C':
  case '!':
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
  case 'I': case 'W':
    free( ((struct flow *)a)->cond);
    if( ((struct flow *)a)->tl) treefree( ((struct flow *)a)->tl);
    if( ((struct flow *)a)->el) treefree( ((struct flow *)a)->el);
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
  case '1': 
    v = (eval(a->l) > eval(a->r))? 1 : 0; 
    break;
  case '2': 
    v = (eval(a->l) < eval(a->r))? 1 : 0; 
    break;
  case '3': 
    v = (eval(a->l) != eval(a->r))? 1 : 0; 
    break;
  case '4': 
    v = (eval(a->l) == eval(a->r))? 1 : 0; 
    break;
  case '5': 
    v = (eval(a->l) >= eval(a->r))? 1 : 0; 
    break;
  case '6': 
    v = (eval(a->l) <= eval(a->r))? 1 : 0; 
    break;

  case 'I':
    if( eval( ((struct flow *)a)->cond) != 0) { 
      if( ((struct flow *)a)->tl) { 
        v = eval( ((struct flow *)a)->tl);
      } else
        v = 0.0; /* a default value */
      } else {
        if( ((struct flow *)a)->el) { 
          v = eval(((struct flow *)a)->el);
        } else
          v = 0.0; /* a default value */
    }
    break;
  case 'W':
    v = 0.0; /* a default value */
    if( ((struct flow *)a)->tl) {
      while( eval(((struct flow *)a)->cond) != 0)
        v = eval(((struct flow *)a)->tl);
    }
    break; 
  case 'A':
    v = (eval(a->l) == 1 && eval(a->r) == 1) ? 1 : 0;
    break;
  case 'O':
    v = (eval(a->l) == 1 || eval(a->r) == 1) ? 1 : 0;
    break;
  case '!':
    v = (eval(a->l) == 1) ? 0 : 1;
    break;
  default:
    printf("internal error: bad node %c\n", a->nodetype);
  }
  return v;
}

void yyerror(char *s, ...) {
  va_list ap;
  va_start(ap, s);

  fprintf(stderr, "%d: error: "); //, yylineno);
  vfprintf(stderr, s, ap);
  fprintf(stderr, "\n");
}
