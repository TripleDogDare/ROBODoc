#!/bin/bash
# vi: ff=unix 
# $Id: do.sh,v 1.22 2008/06/17 11:49:26 gumpu Exp $

# If a ./do.sh under cygwin gives
#  : command not found
#  : command not found
#  : command not foundclocal
#
# Then this file has wrong line-endings (cr/lf).
# To fix it unzip the archive under cygwin with the
# option -a, so
#   unzip -a robodoc-xx-xx-xx.zip
#

rm -f *~
rm -f makefile.in
rm -f *.tar.gz *.zip
rm -f *.log aclocal.m4 config.cache
rm -fr autom4te.cache
rm -f install-sh
rm -f mkinstalldirs
rm -f missing makefile
rm -f configure config.status

#export CC=i586-mingw32msvc-gcc

# Obsolete
#aclocal
#automake -a
#autoconf

# autoreconf does a better job, and calls all needed autotools
# -f consider all autotool files obsolete
# -i copy missing auxiliary files
autoreconf -f -i

# run configure to guess configuration

# CFLAGS="-g -Wall -DDMALLOC -DMALLOC_FUNC_CHECK" LDFLAGS="-ldmalloc" ./configure
# CFLAGS="-g -Wall -O0 -std=gnu99 -pedantic -Wshadow -Wbad-function-cast -Wconversion -Wredundant-decls" ./configure
CFLAGS="-g -Wall -O0 -std=gnu99 -pedantic -Wshadow -Wbad-function-cast -Wredundant-decls" ./configure
#CFLAGS="-g -Wall" ./configure
#./configure

# distcheck creates all distribution packages and does some sanity checks on it
make distcheck

# Make clean and recompile
make clean
make

# cross-compile if all tools are found
(cd Source && make -f makefile.plain xcompiler-test) > /dev/null 2>&1
if [ "$?" = "0" ] ; then
	set -e
	rm -fr ./tmp$$
	cp -R ./Source ./tmp$$
	cd ./tmp$$
    make clean
	make -f makefile.plain xcompile
	cp -f *.zip ../
	cd ..
	rm -fr ./tmp$$
	set +e
fi

# Mac OS X package

if [ "`uname`" = "Darwin" ] ; then
	make -f rpm.mk osxpkg
fi

exit 0

