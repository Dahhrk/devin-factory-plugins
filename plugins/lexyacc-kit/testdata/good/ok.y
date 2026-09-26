%{
#include <stdio.h>
void yyerror(const char *msg) {
  fprintf(stderr, "%s\n", msg);
}
int yylex(void);
%}
%token NUM
%%
input: NUM ;
%%
