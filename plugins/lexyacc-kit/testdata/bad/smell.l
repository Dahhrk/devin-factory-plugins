%{
#include </etc/passwd>
#include "../untrusted/secrets.h"
char gbuf[16];
%}
%%
[a-z]+  { strcpy(gbuf, yytext); char *p = yytext; while (*p) p++; }
.|\n    { }
%%
%include /tmp/evil.inc
%include https://example.com/rules.inc
