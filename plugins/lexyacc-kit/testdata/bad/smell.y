%{
#include <stdio.h>
void yyerror(const char *s) { }
%}
%token NUM
%%
input: NUM ;
%%
