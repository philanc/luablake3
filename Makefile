
# ----------------------------------------------------------------------
# adjust the following according to your Lua install
#
#	LUADIR can be defined. In that case, 
#   Lua binary and include files are to be found repectively in 
#   $(LUADIR)/bin and $(LUADIR)/include
#
#	Or LUA and LUAINC can be directly defined as the path of the 
#	Lua executable and the path of the Lua include directory,
#	respectively.

LUADIR ?= ../lua
LUA ?= $(LUADIR)/bin/lua
LUAINC ?= $(LUADIR)/include

# ----------------------------------------------------------------------

CC ?= gcc
AR ?= ar

DEFS= -DBLAKE3_NO_SSE2 -DBLAKE3_NO_SSE41 -DBLAKE3_NO_AVX2 -DBLAKE3_NO_AVX512

INCFLAGS= -I$(LUAINC)
CFLAGS= -Os -fPIC $(INCFLAGS) $(DEFS)

# link flags for linux
LDFLAGS= -shared -fPIC    

# link flags for OSX
# LDFLAGS=  -bundle -undefined dynamic_lookup -fPIC    

luablake3.so:  src/*.c src/*.h
	$(CC) -c $(CFLAGS) src/*.c
	$(CC)  $(LDFLAGS) -o luablake3.so *.o

test:  luablake3.so
	$(LUA) test_luablake3.lua
	
clean:
	rm -f *.o *.a *.so

.PHONY: clean test


