#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include "ast.h"

struct ast *newast(int nodetype, struct ast *l, struct ast *r) {
    struct ast *a = malloc(sizeof(struct ast));

    if(!a) {
        yyerror("out of space");
        exit(1);
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
        exit(1);
    }

    a->nodetype = 'K';
    a->number = d;
    return (struct ast *)a;
}

double eval(struct ast *a) {
    double result;

    switch(a->nodetype) {
        case 'K':
            result = ((struct numval *)a)->number;
            break;
        case '+':
            result = eval(a->l) + eval(a->r);
            break;
        case '-':
            result = eval(a->l) - eval(a->r);
            break;
        case '*':
            result = eval(a->l) * eval(a->r);
            break;
        case '/':
            result = eval(a->l) / eval(a->r);
            break;
        case '|':
            result = eval(a->l);
            if(result < 0) {
                result = -result;
            }
            break;
        case 'M':
            result = -eval(a->l);
            break;
        default:
            printf("internal error: bad node %c\n", a->nodetype);
    }
}

void treefree(struct ast *a) {
    switch(a->nodetype) {
        case '+':
        case '-':
        case '*':
        case '/':
            treefree(a->r);
        case 'M':
        case '|':
            treefree(a->l);
        case 'K':
            break;
        default:
            printf("internal error: bad node %c\n", a->nodetype);
    }
    free(a);
}

void yyerror(char *s, ...) {
    va_list ap;
    va_start(ap, s);

    fprintf(stderr, "%d: error: ", yylineno);
    vfprintf(stderr, s, ap);
    fprintf(stderr, "\n");
}