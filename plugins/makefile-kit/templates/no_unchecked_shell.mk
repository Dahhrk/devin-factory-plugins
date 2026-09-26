# Boundary: prefer make natives over unchecked $(shell); set versions explicitly.
VERSION := 1.2.3
.PHONY: version
version:
	@echo $(VERSION)
