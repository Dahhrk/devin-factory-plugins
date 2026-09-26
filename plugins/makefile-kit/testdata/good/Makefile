# Good fixture: .PHONY, tab recipes, no $(shell), static include, no .ONESHELL/curl|bash.
include ok.mk
.PHONY: all build test clean
all: build
build:
	cc -o app main.c
test:
	./app --self-test
clean:
	rm -f app
