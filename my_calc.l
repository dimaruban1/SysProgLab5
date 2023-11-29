%{
#include <stdlib.h>
#include "my_calc.h"
#include "y.tab.h"
#include <string.h>
void yyerror(char *);
int identifier_count = 0;
%}

DIGIT [0-9]+\.?|[0-9]*\.[0-9]+
LETTER [a-zA-Z_]
%%

{DIGIT} {
                yylval.Value = atof(yytext);
                return NUM;
            }

[-()<>=+*/;{}.] {
                return *yytext;
             }

">="            return GE;
"<="            return LE;
"=="            return EQ;
"!="            return NE;
"print"         return PRINT;

[ \t\n]+        ;

{LETTER}({LETTER}|{DIGIT})* {
    if (identifier_count > 100 || identifier_count == 0){
        identifier_count = 0;
    }
    for (int i = 0; i < identifier_count; i++){
        if (strcmp(iden_tab[i], yytext) == 0){
            yylval.sIndex = i;
            return VARIABLE;
        }
    }

    strcpy(iden_tab[identifier_count], yytext);
    yylval.sIndex = identifier_count;
    identifier_count++;
    return VARIABLE;
}

.               yyerror("Unknown character");
%%
int yywrap(void) {
    return 1;
}
