%{
/* Boundary: static relative includes only; never absolute/URL/$VAR %include or #include. */
#include "local.h"
#include <stdio.h>
%}
%include "rules.inc"
%%
.|\n    ;
%%
