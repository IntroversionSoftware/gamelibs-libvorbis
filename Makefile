# -*- Makefile -*- for libvorbis

.SECONDEXPANSION:
.SUFFIXES:

ifneq ($(findstring $(MAKEFLAGS),s),s)
ifndef V
        QUIET          = @
        QUIET_CC       = @echo '   ' CC $<;
        QUIET_AR       = @echo '   ' AR $@;
        QUIET_RANLIB   = @echo '   ' RANLIB $@;
        QUIET_INSTALL  = @echo '   ' INSTALL $<;
        export V
endif
endif

uname_S ?= $(shell uname -s)

LIBVORBIS     = libvorbis.a
LIBVORBISFILE = libvorbisfile.a
AR    ?= ar
ARFLAGS ?= rc
CC    ?= gcc
RANLIB?= ranlib
RM    ?= rm -f

BUILD_DIR := build
BUILD_ID  ?= default-build-id
OBJ_DIR   := $(BUILD_DIR)/$(BUILD_ID)

ifeq (,$(BUILD_ID))
$(error BUILD_ID cannot be an empty string)
endif

prefix ?= /usr/local
libdir := $(prefix)/lib
includedir := $(prefix)/include/vorbis

HEADERS = include/vorbis/codec.h include/vorbis/vorbisfile.h include/vorbis/vorbisenc.h
LIBVORBIS_SOURCES =  lib/mdct.c lib/smallft.c lib/block.c lib/envelope.c \
    lib/window.c lib/lsp.c lib/lpc.c lib/analysis.c lib/synthesis.c lib/psy.c \
	lib/info.c lib/floor1.c lib/floor0.c lib/res0.c lib/mapping0.c lib/registry.c \
	lib/codebook.c lib/sharedbook.c lib/lookup.c lib/bitrate.c

LIBVORBISFILE_SOURCES = lib/vorbisfile.c

HEADERS_INST := $(patsubst include/vorbis/%,$(includedir)/%,$(HEADERS))
LIBVORBIS_OBJECTS := $(patsubst %.c,$(OBJ_DIR)/%.o,$(LIBVORBIS_SOURCES))
LIBVORBISFILE_OBJECTS := $(patsubst %.c,$(OBJ_DIR)/%.o,$(LIBVORBISFILE_SOURCES))

CFLAGS ?= -O2
CFLAGS += -Iinclude -I$(prefix)/include

ifneq (,$(findstring CYGWIN,$(uname_S)))
CFLAGS += -D_WIN32
endif

.PHONY: install

all: $(OBJ_DIR)/$(LIBVORBIS) $(OBJ_DIR)/$(LIBVORBISFILE)

$(includedir)/%.h: include/vorbis/%.h
	-@if [ ! -d $(includedir)  ]; then mkdir -p $(includedir); fi
	$(QUIET_INSTALL)cp $< $@
	@chmod 0644 $@

$(libdir)/%.a: $(OBJ_DIR)/%.a
	-@if [ ! -d $(libdir)  ]; then mkdir -p $(libdir); fi
	$(QUIET_INSTALL)cp $< $@
	@chmod 0644 $@

install: $(HEADERS_INST) $(libdir)/$(LIBVORBIS) $(libdir)/$(LIBVORBISFILE)

clean:
	$(RM) -r $(OBJ_DIR)

distclean:
	$(RM) -r $(BUILD_DIR)

$(OBJ_DIR)/$(LIBVORBIS): $(LIBVORBIS_OBJECTS) | $$(@D)/.
	$(QUIET_AR)$(AR) $(ARFLAGS) $@ $^
	$(QUIET_RANLIB)$(RANLIB) $@

$(OBJ_DIR)/$(LIBVORBISFILE): $(LIBVORBISFILE_OBJECTS) | $$(@D)/.
	$(QUIET_AR)$(AR) $(ARFLAGS) $@ $^
	$(QUIET_RANLIB)$(RANLIB) $@

$(OBJ_DIR)/%.o: %.c $(OBJ_DIR)/.cflags | $$(@D)/.
	$(QUIET_CC)$(CC) $(CFLAGS) -o $@ -c $<

.PRECIOUS: $(OBJ_DIR)/. $(OBJ_DIR)%/.

$(OBJ_DIR)/.:
	$(QUIET)mkdir -p $@

$(OBJ_DIR)%/.:
	$(QUIET)mkdir -p $@

TRACK_CFLAGS = $(subst ','\'',$(CC) $(CFLAGS))

$(OBJ_DIR)/.cflags: .force-cflags | $$(@D)/.
	@FLAGS='$(TRACK_CFLAGS)'; \
    if test x"$$FLAGS" != x"`cat $(OBJ_DIR)/.cflags 2>/dev/null`" ; then \
        echo "    * rebuilding libvorbis: new build flags or prefix"; \
        echo "$$FLAGS" > $(OBJ_DIR)/.cflags; \
    fi

.PHONY: .force-cflags
