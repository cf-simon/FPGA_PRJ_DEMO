# Targets
TARGETS:=

# Subdirectories
SUBDIRS = fpga
SUBDIRS_CLEAN = $(patsubst %,%.clean,$(SUBDIRS))
SUBDIRS_DISTCLEAN = $(patsubst %,%.distclean,$(SUBDIRS))

# Rules
.PHONY: all
all: $(SUBDIRS) $(TARGETS)

.PHONY: $(SUBDIRS)
$(SUBDIRS):
	cd $@ && $(MAKE)

.PHONY: $(SUBDIRS_CLEAN)
$(SUBDIRS_CLEAN):
	cd $(@:.clean=) && $(MAKE) clean

.PHONY: clean
clean: $(SUBDIRS_CLEAN)
	-rm -rf $(TARGETS)
	
.PHONY: $(SUBDIRS_DISTCLEAN)
$(SUBDIRS_DISTCLEAN):
	cd $(@:.distclean=) && $(MAKE) distclean

.PHONY: distclean
distclean: $(SUBDIRS_DISTCLEAN)
	-rm -rf $(TARGETS)

program:
	#djtgcfg prog -d Atlys --index 0 --file fpga/fpga.bit
