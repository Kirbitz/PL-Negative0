#!/bin/bash

tokenizer=$1
coderunner=$2
cfiles="${@:3}"

OS=$(uname -s)

flex $tokenizer
bison -dy $coderunner

if [[ $OS == "Linux" ]]; then
    gcc lex.yy.c y.tab.c $cfiles -o program -lm
else
    gcc lex.yy.c y.tab.c $cfiles -o program.exe
fi