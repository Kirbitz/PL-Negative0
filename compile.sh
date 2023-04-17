#!/bin/bash

tokenizer=$1
coderunner=$2
cfiles="${@:3}"

flex $tokenizer
bison -dy $coderunner

gcc lex.yy.c y.tab.c $cfiles -o program
gcc lex.yy.c y.tab.c $cfiles -o program.exe