%{
#include <stdio.h>
#include <string.h>
/* Boundary: copy yytext with snprintf/strncpy + yyleng; never strcpy/sprintf/strcat. */
char tok[64];
%}
%%
[A-Za-z]+  { snprintf(tok, sizeof tok, "%.*s", yyleng, yytext); }
.|\n       ;
%%
