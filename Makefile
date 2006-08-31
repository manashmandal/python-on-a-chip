#
# Available arguments:
#     TARGET = [DESKTOP, ATMEGA103]
#
# Default values:
#     TARGET = DESKTOP
#

# Tools configuration
SHELL = /bin/sh
CP := cp
MKDIR := mkdir -p
TAGS := ctags
CSCOPE := cscope

VPATH := . src/vm src/lib docs/src

# Build configuration
TARGET := DESKTOP
SIZE := size
DEFS = -DTARGET_$(TARGET) -DHEAP_SIZE=$(HEAP_SIZE)
CFLAGS = -ansi -g -Os -Wall -gstabs -Wstrict-prototypes $(DEFS)
HEAP_SIZE = 0x10000
ARFLAGS := rcs

# Product configuration
PRODUCT_VM := libpmvm.a

# Changes for an embedded target
ifeq ($(TARGET), ATMEGA103)
	AR = /usr/local/bin/avr-ar
	CC = /usr/local/bin/avr-gcc
	CFLAGS += -mmcu=atmega103
	SIZE = /usr/local/bin/avr-size
	HEAP_SIZE = 0x0D00
endif

# Export config to child makefiles
export  AR ARFLAGS CC CFLAGS HEAP_SIZE PRODUCT_VM SIZE TARGET

.PHONY: all vm pmstdlib docs TAGS dist check clean

# TODO: Hopefully can uncomment when issue #2 is resolved
#all : vm pmstdlib
all : vm

vm :
	$(MAKE) -C src/vm

# TODO: Hopefully can uncomment when issue #2 is resolved
#pmstdlib :
#	$(MAKE) -C src/lib

html : docs/src/*.txt
	$(MKDIR) docs/html
	$(MAKE) -C docs/src

TAGS :
	$(TAGS) -R *
	$(CSCOPE) -b -c -R
	cd src/tools && pycscope.py -R *.py

dist : check docs
ifndef PYMITE_RELEASE
	$(error Must define PYMITE_RELEASE=RR)
else
	# TODO: issue #5
	# Make a script in tools/ that will:
	# 	- make fresh checkout,
	#   - build docs
	#   - make pymite-RR.tar.gz
	#	- create release tag in svn repos
endif

check : vm
	$(MAKE) -C src/tests

# Removes all files created during default make
clean :
	$(MAKE) -C src/vm clean
# TODO: Hopefully can uncomment when issue #2 is resolved
#	$(MAKE) -C src/lib clean

