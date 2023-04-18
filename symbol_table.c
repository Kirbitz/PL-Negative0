#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#include "symbol_table.h"
#include "ast.h"

static unsigned symhash(char *sym) {
    unsigned int hash = 0;
    unsigned c;

    while(c = *sym++) {
        hash = hash*9 ^ c;
    }

    return hash;
}

struct symbol *lookup(char* sym) {
    struct symbol *sp = &symtab[symhash(sym)%NHASH];
    int scount = NHASH;

    while(--scount >= 0) {
        if(sp->name && !strcmp(sp->name, sym)) {
            return sp;
        }

        if(!sp->name) {
            sp->name = strdup(sym);
            sp->value = 0;
            sp->func = NULL;
            sp->syms = NULL;
            return sp;
        }

        if(strcmp(sp->name, sym)) {
            yyerror("Symbol Already Declared\n");
        }

        if(++sp >= symtab+NHASH) {
            sp = symtab;
        }
    }

    yyerror("Symbol table overflow\n");
    abort();
}

struct symlist *newsymlist(struct symbol *sym, struct symlist *next) {
    struct symlist *sl = malloc(sizeof(struct symlist));

    if(!sl) {
        yyerror("out of space");
        exit(2);
    }

    sl->sym = sym;
    sl->next = next;
    return sl;
}

void symlistfree(struct symlist *sl) {
    struct symlist *nextsml;

    while(sl) {
        nextsml = sl->next;
        free(sl);
        sl = nextsml;
    }
}

void dodef(struct symbol *name, struct symlist *syms, struct ast *func) {
    if(name->syms) {
        symlistfree(name->syms);
    }
    if(name->func) {
        treefree(name->func);
    }
    name->syms = syms;
    name->func = func;
}