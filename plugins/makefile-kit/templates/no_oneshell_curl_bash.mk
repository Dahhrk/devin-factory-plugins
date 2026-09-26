# Boundary: no .ONESHELL; no curl|bash. Prefer checked local install script.
.PHONY: bootstrap
bootstrap:
	./scripts/install.sh
