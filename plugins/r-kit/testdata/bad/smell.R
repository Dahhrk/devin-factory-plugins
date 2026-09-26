# Intentional smells for r-rg-gate discrimination (not product code).
attach(mtcars)
use_flag <- T
skip_flag <- F
src <- "1 + 1"
result <- eval(parse(text = src))
