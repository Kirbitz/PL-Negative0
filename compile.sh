#!/bin/bash

tokenizer=$1
coderunner=$2
output=$3

flex $tokenizer
bison -dy $coderunner

gcc lex.yy.c y.tab.c -o program
gcc lex.yy.c y.tab.c -o program.exe