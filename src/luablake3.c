// Copyright (c) 2021 Phil Leblanc -- License: MIT
//----------------------------------------------------------------------
/*

luablake3 - a Lua wrapper for the BLAKE3 cryptographic hash function

*/
//----------------------------------------------------------------------
// lua binding name, version

#define LIBNAME luablake3
#define VERSION "luablake3-0.1"


//----------------------------------------------------------------------
#include <assert.h>
#include <stdlib.h>
#include <string.h>	// memcpy()

#include "lua.h"
#include "lauxlib.h"

#include "blake3.h"



// compatibility with Lua 5.2  --and lua 5.3, added 150621
// (from roberto's lpeg 0.10.1 dated 101203)
//
#if (LUA_VERSION_NUM >= 502)

#undef lua_equal
#define lua_equal(L,idx1,idx2)  lua_compare(L,(idx1),(idx2),LUA_OPEQ)

#undef lua_getfenv
#define lua_getfenv	lua_getuservalue
#undef lua_setfenv
#define lua_setfenv	lua_setuservalue

#undef lua_objlen
#define lua_objlen	lua_rawlen

#undef luaL_register
#define luaL_register(L,n,f) \
	{ if ((n) == NULL) luaL_setfuncs(L,f,0); else luaL_newlib(L,f); }

#endif


//----------------------------------------------------------------------
// lua binding   (all lua library functions are prefixed with "ll_")


# define LERR(msg) return luaL_error(L, msg)

//----------------------------------------------------------------------

static int ll_init(lua_State *L) {
	// create a blake3 hasher object that will be used for 
	// subsequent operations
	// lua api:  init() => hasher object (userdata)
	size_t size = sizeof(blake3_hasher);
	blake3_hasher *p_hasher = lua_newuserdata(L, size);
	blake3_hasher_init(p_hasher);	
	return 1;
} 

static int ll_init_keyed(lua_State *L) {
	// create a blake3 hasher object that will be used for 
	// subsequent operations. 
	// Initialize it in keyed hashing mode (MAC)
	// lua api:  init_keyed(key) => hasher object (userdata)
	// key must be a 32-byte string
	size_t size = sizeof(blake3_hasher);
	size_t keyln = 0; 
	const char *key = luaL_checklstring(L, 1, &keyln);
	if (keyln > 64) LERR("bad key size");
	blake3_hasher *p_hasher = lua_newuserdata(L, size);
	blake3_hasher_init_keyed(p_hasher, key);	
	return 1;
} 

static int ll_init_derive_key(lua_State *L) {
	// create a blake3 hasher object. 
	// Initialize it in key derivation mode. 
	// lua api:  init_derive_key(context) => hasher object (userdata)
	// context is a string which should be hardcoded, globally 
	// unique, and application-specific (see the BLAKE3 paper)
	const char *context = luaL_checkstring(L, 1);
	size_t size = sizeof(blake3_hasher);
	blake3_hasher *p_hasher = lua_newuserdata(L, size);
	blake3_hasher_init_derive_key(p_hasher, context);	
	return 1;
} 

static int ll_update(lua_State *L) {
	// lua api: update(hasher, string)
	blake3_hasher *p_hasher = lua_touserdata(L, 1);
	if (p_hasher == 0) LERR("invalid hasher object");
	size_t sln;
	const char *s = luaL_checklstring(L,2,&sln);
	blake3_hasher_update(p_hasher, s, sln);
	return 0;
}

static int ll_final(lua_State *L) {
	// lua api: final(hasher [, digln])
	// digln defaults to 32
	blake3_hasher *p_hasher = lua_touserdata(L, 1);
	if (p_hasher == 0) LERR("invalid hasher object");
	int digln = luaL_optinteger(L, 2, 32);
	char *dig = lua_newuserdata(L, digln);
	blake3_hasher_finalize(p_hasher, dig, digln);
	lua_pushlstring (L, dig, digln); 
	return 1;	
}


//----------------------------------------------------------------------
// lua library declaration
//
static const struct luaL_Reg lllib[] = {
	//
	{"init", ll_init},
	{"init_keyed", ll_init_keyed},
	{"init_derive_key", ll_init_derive_key},
	{"update", ll_update},
	{"final", ll_final},
	//
	//~ {"hash", ll_hash},
	//
	{NULL, NULL},
};

//----------------------------------------------------------------------
// library registration

int luaopen_luablake3 (lua_State *L) {
	luaL_register (L, "luablake3", lllib);
	lua_pushliteral (L, "VERSION");
	lua_pushliteral (L, VERSION); 
	lua_settable (L, -3);
	return 1;
}
