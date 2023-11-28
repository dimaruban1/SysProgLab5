%{
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include "my_calc.h"

nodeType *opr(int oper, int nops, ...);
nodeType *id(int i);
nodeType *con(double value);
void freeNode(nodeType *p);
int ex(nodeType *p);
int yylex(void);
char errors[10][100];
char reserved[3][10] = {"while", "if", "print"};
char iden_tab[100][50];
void yyerror(char *s);
double val_tab[100];
int sem_errors = 0;
char errors[10][100];
%}

%union {
    char *name;                    /* name of identifier */
    double Value;                 /* number value */
    int sIndex;                  /* symbol table index */
    nodeType *nPtr;             /* node pointer */
};

%token <Value> NUM
%token <sIndex> VARIABLE
%token WHILE IF PRINT
%nonassoc IFX
%nonassoc ELSE

%left GE LE EQ NE '>' '<'
%left '+' '-'
%left '*' '/'
%nonassoc UMINUS

%type <nPtr> stmt expr stmt_list

%%

program:
        function                { exit(0); }
        ;

function:
          function stmt         { ex($2); freeNode($2); }
        | /* NULL */
        ;

stmt:
          ';'                            { $$ = opr(';', 2, NULL, NULL); }
        | expr ';'                       { $$ = $1; }
        | PRINT expr ';'                 { $$ = opr(PRINT, 1, $2); }
        | VARIABLE '=' expr ';'          { $$ = opr('=', 2, id($1), $3); }
        | WHILE '(' expr ')' stmt        { $$ = opr(WHILE, 2, $3, $5); }
        | IF '(' expr ')' stmt %prec IFX { $$ = opr(IF, 2, $3, $5); }
        | IF '(' expr ')' stmt ELSE stmt { $$ = opr(IF, 3, $3, $5, $7); }
        | '{' stmt_list '}'              { $$ = $2; }
        ;

stmt_list:
          stmt                  { $$ = $1; }
        | stmt_list stmt        { $$ = opr(';', 2, $1, $2); }
        ;

expr:
          NUM                   { $$ = con($1); }
        | VARIABLE              { $$ = id($1); }
        | '-' expr %prec UMINUS { $$ = opr(UMINUS, 1, $2); }
        | expr '+' expr         { $$ = opr('+', 2, $1, $3); }
        | expr '-' expr         { $$ = opr('-', 2, $1, $3); }
        | expr '*' expr         { $$ = opr('*', 2, $1, $3); }
        | expr '/' expr         { $$ = opr('/', 2, $1, $3); }
        | expr '<' expr         { $$ = opr('<', 2, $1, $3); }
        | expr '>' expr         { $$ = opr('>', 2, $1, $3); }
        | expr GE expr          { $$ = opr(GE, 2, $1, $3); }
        | expr LE expr          { $$ = opr(LE, 2, $1, $3); }
        | expr NE expr          { $$ = opr(NE, 2, $1, $3); }
        | expr EQ expr          { $$ = opr(EQ, 2, $1, $3); }
        | '(' expr ')'          { $$ = $2; }
        ;

%%

#define SIZEOF_NODETYPE ((char *)&p->con - (char *)p)

//void checkOperator(nodeType *p, const char *operator) {
//    int nops = p->opr.nops;
//    
//    if (nops < 2) {
//		sprintf(errors[sem_errors], "wrong usage of operator %s, missing arguments\n", operator);
//		sem_errors++;
//    } else if (nops > 2) {
//		sprintf(errors[sem_errors], "wrong usage of operator %s, extra arguments\n", operator);
//		sem_errors++;
//    }
//}
//void checkOperatorc(nodeType *p, char operator) {
//    if (nops < 2) {
//		sprintf(errors[sem_errors], "wrong usage of operator %c, missing arguments\n", operator);
//		sem_errors++;
//    } else if (nops > 2) {
//		sprintf(errors[sem_errors], "wrong usage of operator %c, extra arguments\n", operator);
//		sem_errors++;
//    }
//}
//void checkNode(nodeType *p) {
//    switch(p->opr.oper) {
//        case '=':
//        case '+':
//        case '-':
//        case '*':
//        case '/':
//        case '<':
//        case '>':
//            checkOperatorc(p, p->opr.oper);
//            break;
//        case GE:
//            checkOperator(p, ">=");
//            break;
//        case LE:
//            checkOperator(p, "<=");
//            break;
//        case NE:
//            checkOperator(p, "!=");
//            break;
//        case EQ:
//            checkOperator(p, "==");
//            break;
//        default:
//            break;
//    }
//}

nodeType *con(double value) {
    nodeType *p;
    size_t nodeSize;

    /* allocate node */
    nodeSize = SIZEOF_NODETYPE + sizeof(conNodeType);
    if ((p = malloc(nodeSize)) == NULL)
        yyerror("out of memory");

    /* copy information */
    p->type = typeCon;
    p->con.value = value;

    return p;
}

nodeType *id(int i) {
    nodeType *p;
    size_t nodeSize;

    /* allocate node */
    nodeSize = SIZEOF_NODETYPE + sizeof(idNodeType);
    if ((p = malloc(nodeSize)) == NULL)
        yyerror("out of memory");

    /* copy information */
    p->type = typeId;
    p->id.i = i;

    return p;
}

nodeType *opr(int oper, int nops, ...) {
    va_list ap;
    nodeType *p;
    size_t nodeSize;
    int i;

    /* allocate node */
    nodeSize = SIZEOF_NODETYPE + sizeof(oprNodeType) +
        (nops - 1) * sizeof(nodeType*);
    if ((p = malloc(nodeSize)) == NULL)
        yyerror("out of memory");

    /* copy information */
    p->type = typeOpr;
    p->opr.oper = oper;
    p->opr.nops = nops;
    va_start(ap, nops);
    for (i = 0; i < nops; i++)
        p->opr.op[i] = va_arg(ap, nodeType*);
    va_end(ap);

    return p;
}

void freeNode(nodeType *p) {
    int i;

    if (!p) return;
    if (p->type == typeOpr) {
        for (i = 0; i < p->opr.nops; i++)
            freeNode(p->opr.op[i]);
    }
    free (p);
}

void yyerror(char *s) {
    fprintf(stdout, "%s\n", s);
//    fprintf(stdout, "%i\n", sem_errors);
//    for(int i = 0; i < sem_errors; i++){
//        fprintf(stdout, "%s\n", errors[i]);
//    } 
}

int main(void) {
    yyparse();
    return 0;
}
