%{
#include "local.h"
#include <stdio.h>
#include <string.h>
char tok[64];
%}
%include "rules.inc"
%%
[A-Za-z]+  {
             snprintf(tok, sizeof tok, "%.*s", yyleng, yytext);
             for (int i = 0; i < yyleng; i++) {
               putchar(yytext[i]);
             }
           }
.|\n       ;
%%
