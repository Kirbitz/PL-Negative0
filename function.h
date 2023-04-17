#ifndef FUNCTION_H
#define FUNCTION_H

extern int yylineno;
void yyerror(char *s, ...);

struct symbol {
    char *name;
    double value;
    struct ast *func;
    struct symlist *syms;
};

#define NHASH 9997

struct symbol symtab[NHASH];

struct symbol *lookup(char*);

struct symlist {
    struct symbol *sym;
    struct symlist *next;
};

struct symlist *newsymlist(struct symbol *sym, struct symlist *next);
void symlistfree(struct symlist *sl);

struct userfunction {
    int nodetype;
    struct ast *l;
    struct symbol *s;
};



#endif