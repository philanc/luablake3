
-- quick and dirty test of luablake3

lb = require"luablake3"

------------------------------------------------------------------------
-- some local definitions

local strf = string.format
local byte, char = string.byte, string.char
local spack, sunpack = string.pack, string.unpack

local app, concat = table.insert, table.concat

local function stohex(s, ln, sep)
	-- stohex(s [, ln [, sep]])
	-- return the hex encoding of string s
	-- ln: (optional) a newline is inserted after 'ln' bytes 
	--	ie. after 2*ln hex digits. Defaults to no newlines.
	-- sep: (optional) separator between bytes in the encoded string
	--	defaults to nothing (if ln is nil, sep is ignored)
	-- example: 
	--	stohex('abcdef', 4, ":") => '61:62:63:64\n65:66'
	--	stohex('abcdef') => '616263646566'
	--
	if #s == 0 then return "" end
	if not ln then -- no newline, no separator: do it the fast way!
		return (s:gsub('.', 
			function(c) return strf('%02x', byte(c)) end
			))
	end
	sep = sep or "" -- optional separator between each byte
	local t = {}
	for i = 1, #s - 1 do
		t[#t + 1] = strf("%02x%s", s:byte(i),
				(i % ln == 0) and '\n' or sep) 
	end
	-- last byte, without any sep appended
	t[#t + 1] = strf("%02x", s:byte(#s))
	return concat(t)	
end --stohex()

local function hextos(hs, unsafe)
	-- decode an hex encoded string. return the decoded string
	-- if optional parameter unsafe is defined, assume the hex
	-- string is well formed (no checks, no whitespace removal).
	-- Default is to remove white spaces (incl newlines)
	-- and check that the hex string is well formed
	local tonumber = tonumber
	if not unsafe then
		hs = string.gsub(hs, "%s+", "") -- remove whitespaces
		if string.find(hs, '[^0-9A-Za-z]') or #hs % 2 ~= 0 then
			error("invalid hex string")
		end
	end
	return (hs:gsub(	'(%x%x)', 
		function(c) return char(tonumber(c, 16)) end
		))
end -- hextos

local function px(s, msg) 
	print("--", msg or "")
	print(stohex(s, 16, " ")) 
end

------------------------------------------------------------------------
-- Blake3 test

print("------------------------------------------------------------")
print(_VERSION, lb.VERSION )
print("------------------------------------------------------------")

hr = lb.init()
lb.update(hr, "Hello, World!")
dig = lb.final(hr, 65)
assert(dig == hextos[[
	288a86a79f20a3d6dccdca7713beaed1
	78798296bdfa7913fa2a62d9727bf8f8
	d7f01a496647e626c0d07fa6a060cbe3
	8bf116e3a05f489a9720924b875f1677
	04
]])
lb.update(hr, "!!")
dig = lb.final(hr)
assert(dig == hextos[[
	ab04a6c9b4bbdfcb66dccef112d9e6f3
	99788de1bfe5005ef857756e7a4a5396
]])


------------------------------------------------------------------------
print("\ntest_luablake3", "ok\n")