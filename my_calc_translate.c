#include <stdio.h>
#include "my_calc.h"
#include "y.tab.h"

static int lbl;

char *NodeToString(nodeType *p){
    char* buffer = malloc(10);
    if (p->type == typeId){
        snprintf(buffer, sizeof(buffer), "id(%s)", iden_tab[p->id.i]);
    } 
    else if(p->type == typeCon){
        snprintf(buffer, sizeof(buffer), "%f", p->con.value);
    }
    else return 0;
    return buffer;
}

int ex(nodeType *p) {
    int lbl1, lbl2;

    if (!p) return 0;
    switch(p->type) {
    case typeCon:       
        printf("\tpush\t%f\n", p->con.value); 
        break;
    case typeId:        
        printf("\tpush\tid(%s)\n", iden_tab[p->id.i]); 
        break;
    case typeOpr:
        switch(p->opr.oper) {
        case PRINT:     
            ex(p->opr.op[0]);
            printf("\tpop\tres\n\tprint\tres\n");
            break;
        case '=':       
            ex(p->opr.op[1]);
            printf("\tpop\tid(%s)\n", iden_tab[p->opr.op[0]->id.i]);
            break;
        case UMINUS:    
            ex(p->opr.op[0]);
            printf("\tneg\n");
            break;
        default:
            ex(p->opr.op[1]);
            ex(p->opr.op[0]);

            switch(p->opr.oper) {
            case '+':   printf("\tadd\tres\tr0\tr1\n\tpush\tres\n"); break;
            case '-':   printf("\tsub\tres\tr0\tr1\n\tpush\tres\n"); break; 
            case '*':   printf("\tmul\tres\tr0\tr1\n\tpush\tres\n"); break;
            case '/':   printf("\tdiv\tres\tr0\tr1\n\tpush\tres\n"); break;
            case '<':   printf("\tcompLT\tres\tr0\tr1\n\tpush\tres\n"); break;
            case '>':   printf("\tcompGT\tres\tr0\tr1\n\tpush\tres\n"); break;
            case GE:    printf("\tcompGE\tres\tr0\tr1\n\tpush\tres\n"); break;
            case LE:    printf("\tcompLE\tres\tr0\tr1\n\tpush\tres\n"); break;
            case NE:    printf("\tcompNE\tres\tr0\tr1\n\tpush\tres\n"); break;
            case EQ:    printf("\tcompEQ\tres\tr0\tr1\n\tpush\tres\n"); break;
            }
        }
    }
    return 0;
}
