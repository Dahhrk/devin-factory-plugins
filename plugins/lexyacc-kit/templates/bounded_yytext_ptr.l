%{
#include <stdio.h>
/* Boundary: walk yytext by index < yyleng; never raw char *p = yytext unbounded. */
%}
%%
[0-9]+  {
          for (int i = 0; i < yyleng; i++) {
            putchar(yytext[i]);
          }
        }
.|\n    ;
%%
