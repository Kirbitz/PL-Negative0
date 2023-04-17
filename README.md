# Programming-Language
Programming language built for Formal Languages and Finite Automata

Also includes test implementations using Flex and Bison

To use compile.sh just run in bash using bash or ./

### Example

    ./compile.sh flex.l bison.y

or

    bash compile.sh flex.l bison.y


For compiling additional C files just include them as parameter 3 onwards

### Example
    ./compile.sh flex.l bison.y optional_c_file1.c optional_c_file2.c

or

    bash compile.sh flex.l bison.y optional_c_file1.c optional_c_file2.c

The bash command then produces program and program.exe select the appropriate one and run on your system

Linux:

    ./program

Windows:

    program.exe
