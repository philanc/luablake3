![CI](https://github.com/philanc/lualblake3/workflows/CI/badge.svg)

# luablake3
Lua binding for the BLAKE3 cryptographic hash

[BLAKE3](https://blake3.io) is a very fast cryptographic hash function that can also be used as a MAC, key derivation function (KDF) and extendable-output function (XOF). See the [BLAKE3
paper](https://github.com/BLAKE3-team/BLAKE3-specs/blob/master/blake3.pdf). 

It has been designed by Jack O'Connor, Jean-Philippe Aumasson, Samuel Neves and Zooko Wilcox-O'Hearn.


## The Lua wrapper

It is based on the [C portable version](https://github.com/BLAKE3-team/BLAKE3/tree/master/c) of the original Blake3 implementation. 

All the required source code is included in the luablake3 repository.

Luablake3 API summary:

```
init() => hasher
	create and initialize a "hasher" object that will be used
	for subsequent operations
	The returned hasher object is a userdata.

update(hasher, string)
	process an input string. 
	This can be called any number of times.

final(hasher [,hashlen]) => hash
	finalize the hasher and return the hash of the previously
	processed input.
	The hash is returned as a binary string (no hex encoding)
	which contains 'hashlen' bytes.
	The default hash length is 32 bytes. Any length can be 
	requested. This allows to use it as an extendable-output 
	function (XOF).
	
	Note:  final() doesn't modify the hasher object itself so
	it is possible to finalize again after adding more input.

An example:
	local lb = require "luablake3"
	local s = "Hello, World!"
	local hasher = lb.init()
	lb.update(hasher, s)
	local hash = lb.final(hasher)
	-- here hash is a 32-byte string

Alternatives init functions are provided for other use cases:

init_keyed(key) => hasher
	create a hasher object that is initialized in keyed hashing
	mode (MAC).
	key must be a 32-byte string.
	the returned hashed object is used in the same way with
	the update() and final() functions.

init_derive_key(context) => hasher
	This is a variant of init() to provide a key derivation mode.
	context is an arbitrary string used as a domain separation 
	constant. It should be unique and application-specific (1)

```

(1) see section *Key derivation* in the the [BLAKE3 paper](https://github.com/BLAKE3-team/BLAKE3-specs/blob/master/blake3.pdf)

## Building 

Adjust the Makefile according to your Lua installation (set the LUADIR variable). 

Targets:
```
	make          -- build luablake3.so
	make test     -- build luablake3.so if needed, 
	                 then run test.lua
	make clean
```

An alternative Lua installation can be specified:
```
	make LUA=/path/to/lua LUAINC=/path/to/lua_include_dir test
```

## License

The original Blake3 source code is released into the public domain with CC0 1.0. Alternatively, it is licensed under the Apache License 2.0 - see src/BLAKE3-LICENSE.md

The luablake3 wrapper library is MIT-licensed.

