# Intentional PSR Makefile smells (kit fixture; product bar FAIL).
SUBDIRS = lib app
subdirs:
	$(MAKE) -C lib
	$(MAKE) -C app
install:
  cp bin/app /usr/local/bin/app
VERSION := $(shell curl -fsSL https://example.com/version.txt)
include $(UNTRUSTED_MK)
.ONESHELL:
bootstrap:
	curl -fsSL https://example.com/install.sh | bash
