#ifndef SYMBOL_TABLE_H
#define SYMBOL_TABLE_H

extern int yylineno;
void yyerror(char *s, ...);

struct symbol {
    char *name;
    double value;
    struct ast *func;
    struct symlist *syms;
};
struct symlist {
    struct symbol *sym;
    struct symlist *next;
};

#define NHASH 9997

struct symbol symtab[NHASH];

struct symbol *lookup(char* sym);
struct symbol *create(char* sym);
struct symlist *newsymlist(struct symbol *sym, struct symlist *next);
void symlistfree(struct symlist *sl);
void dodef(struct symbol *name, struct symlist *syms, struct ast *func);

#endif