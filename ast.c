# include <stdio.h>
# include <stdlib.h>
# include <stdarg.h>
# include <string.h>
# include <math.h>
# include "ast.h"
#include "symbol_table.h"
#include "function.h"

struct ast *newast(int nodetype, struct ast *l, struct ast *r) {
    struct ast *a = malloc(sizeof(struct ast));
    if(!a) {
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
    if(!a) {
        yyerror("out of space");
        exit(0);
    }
    a->nodetype = 'K';
    a->number = d;
    return (struct ast *)a;
}
struct ast *newref(struct symbol *s) {
    struct symref *a = malloc(sizeof(struct symref));
    if(!a) {
        yyerror("out of space");
        exit(0);
    }
    a->nodetype = 'N';
    a->s = s;
    return (struct ast *)a;
}
struct ast *newasgn(struct symbol *s, struct ast *v) {
    struct symasgn *a = malloc(sizeof(struct symasgn));
    if(!a) {
    yyerror("out of space");
    exit(0);
    }
    a->nodetype = '=';
    a->s = s;
    a->v = v;
    return (struct ast *)a;
}
/* free a tree of ASTs */
void treefree(struct ast *a) {
    switch(a->nodetype) {
        /* two subtrees */
        case '+':
        case '-':
        case '*':
        case '/':
        case '1': case '2': case '3': case '4': case '5': case '6':
        case 'L':
            treefree(a->r);
        /* one subtree */
        case '|':
        case 'M': case 'C': case 'F':
            treefree(a->l);
        /* no subtree */
        case 'K': case 'N':
            break;
        case '=':
            free( ((struct symasgn *)a)->v);
            break;
        default: printf("internal error: free bad node %c\n", a->nodetype);
    }
    free(a); /* always free the node itself */
}

double eval(struct ast *a) {
    double v;
    if(!a) {
        yyerror("internal error, null eval");
        return 0.0;
    }
    switch(a->nodetype) {
        /* constant */
        case 'K': v = ((struct numval *)a)->number; break;
        /* name reference */
        case 'N': v = ((struct symref *)a)->s->value; break;
        /* assignment */
        case '=': v = ((struct symasgn *)a)->s->value =
            eval(((struct symasgn *)a)->v); break;
        /* expressions */
        case '+': v = eval(a->l) + eval(a->r); break;
        case '-': v = eval(a->l) - eval(a->r); break;
        case '*': v = eval(a->l) * eval(a->r); break;
        case '/': v = eval(a->l) / eval(a->r); break;
        case '|': v = fabs(eval(a->l)); break;
        case 'M': v = -eval(a->l); break;
        /* list of statements */
        case 'L': eval(a->l); v = eval(a->r); break;
        case 'C': v = calluserfunction((struct userfunction *)a); break;
        default: printf("internal error: bad node %c\n", a->nodetype);
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