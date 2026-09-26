# Boundary: .PHONY for recursive / action targets (GNU Make Phony Targets).
.PHONY: subdirs $(SUBDIRS)
subdirs: $(SUBDIRS)
$(SUBDIRS):
	$(MAKE) -C $@
