# -*- Makefile -*- for libvorbis

ifneq ($(findstring $(MAKEFLAGS),s),s)
ifndef V
        QUIET_CC       = @echo '   ' CC $@;
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
ARFLAGS ?= rcu
CC    ?= gcc
RANLIB?= ranlib
RM    ?= rm -f

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
LIBVORBIS_OBJECTS := $(patsubst %.c,%.o,$(LIBVORBIS_SOURCES))
LIBVORBISFILE_OBJECTS := $(patsubst %.c,%.o,$(LIBVORBISFILE_SOURCES))

CFLAGS ?= -O2
CFLAGS += -Iinclude -I$(prefix)/include

ifneq (,$(findstring CYGWIN,$(uname_S)))
CFLAGS += -D_WIN32
endif

.PHONY: install

all: $(LIBVORBIS) $(LIBVORBISFILE)

$(includedir)/%.h: include/vorbis/%.h
	-@if [ ! -d $(includedir)  ]; then mkdir -p $(includedir); fi
	$(QUIET_INSTALL)cp $< $@
	@chmod 0644 $@

$(libdir)/%.a: %.a
	-@if [ ! -d $(libdir)  ]; then mkdir -p $(libdir); fi
	$(QUIET_INSTALL)cp $< $@
	@chmod 0644 $@

install: $(HEADERS_INST) $(libdir)/$(LIBVORBIS) $(libdir)/$(LIBVORBISFILE)

clean:
	$(RM) $(LIBVORBIS_OBJECTS) $(LIBVORBISFILE_OBJECTS) $(LIBVORBIS) $(LIBVORBISFILE) .cflags

distclean: clean

$(LIBVORBIS): $(LIBVORBIS_OBJECTS)
	$(QUIET_AR)$(AR) $(ARFLAGS) $@ $^
	$(QUIET_RANLIB)$(RANLIB) $@

$(LIBVORBISFILE): $(LIBVORBISFILE_OBJECTS)
	$(QUIET_AR)$(AR) $(ARFLAGS) $@ $^
	$(QUIET_RANLIB)$(RANLIB) $@

%.o: %.c .cflags
	$(QUIET_CC)$(CC) $(CFLAGS) -o $@ -c $<

TRACK_CFLAGS = $(subst ','\'',$(CC) $(CFLAGS))

.cflags: .force-cflags
	@FLAGS='$(TRACK_CFLAGS)'; \
    if test x"$$FLAGS" != x"`cat .cflags 2>/dev/null`" ; then \
        echo "    * rebuilding libvorbis: new build flags or prefix"; \
        echo "$$FLAGS" > .cflags; \
    fi

.PHONY: .force-cflags
