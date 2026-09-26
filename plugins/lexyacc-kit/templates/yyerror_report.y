%{
#include <stdio.h>
/* Boundary: yyerror must report; never empty/discard-only body. */
void yyerror(const char *msg) {
  fprintf(stderr, "%s\n", msg);
}
%}
%token NUM
%%
input: NUM ;
%%
