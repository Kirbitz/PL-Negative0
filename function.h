#ifndef FUNCTION_H
#define FUNCTION_H

extern int yylineno;
void yyerror(char *s, ...);

struct userfunction {
    int nodetype;
    struct ast *l;
    struct symbol *s;
};

struct ast *newuserfunction(struct symbol *s, struct ast *l);
double calluserfunction(struct userfunction *);

#endif