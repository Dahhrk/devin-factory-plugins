# Boundary: recipe lines start with a real tab (never spaces).
.PHONY: build
build:
	cc -o app main.c
