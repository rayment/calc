#
# Makefile
#
# Author       : Finn Rayment <finn@rayment.fr>
# Date created : 21/07/2022
#

DEBUG?=0
VERSION:=1.0.0
BINARY:=calc

CC:=gcc
LEX:=lex
YACC:=yacc

CCFLAGS:=--std=c99
CXXFLAGS:=-Wall -Wextra -Wpedantic -Werror --pedantic-errors \
          -DVERSION=\"${VERSION}\" -D_POSIX_C_SOURCE \
		  -Wno-unused-function
LEXFLAGS:=
YACCFLAGS:=-d
LDFLAGS:=-lm

ifeq ($(DEBUG),1)
CXXFLAGS+=-ggdb -DDEBUG=1
else
CXXFLAGS+=-O3
endif

CSOURCES:=main.c lex.yy.c y.tab.c

DISTFILES:=COPYING Makefile main.c lex.l parse.y incl.h

all: clean lex yacc
	$(CC) $(CCFLAGS) $(CXXFLAGS) $(CSOURCES) $(LDFLAGS) -o $(BINARY)

lex:
	$(LEX) -t $(LEXFLAGS) lex.l > lex.yy.c

yacc:
	$(YACC) $(YACCFLAGS) parse.y -o y.tab.c

dist:
	rm -rf $(BINARY)-$(VERSION)
	mkdir -p $(BINARY)-$(VERSION)
	cp -R $(DISTFILES) $(DISTDIRS) $(BINARY)-$(VERSION)
	tar -cJf $(BINARY)-$(VERSION).tar.xz $(BINARY)-$(VERSION)
	rm -rf $(BINARY)-$(VERSION)

clean:
	rm -f $(BINARY) lex.yy.c y.tab.c y.tab.h

.PHONY: all lex yacc dist clean

