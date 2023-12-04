#!/bin/bash
flex my_calc.l
bison -y -d my_calc.y
gcc -c y.tab.c lex.yy.c
gcc y.tab.o lex.yy.o my_calc_solve.c -o my_calc_solve.exe
echo "RESULT"
./my_calc_solve.exe < input.c
echo "ASSSEMBLY"
./my_calc_translate.exe < input.c
echo "AST"
./my_calc_draw.exe < input.c
