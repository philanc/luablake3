
-- quick and dirty test of luablake3

lb = require"luablake3"

------------------------------------------------------------------------
-- some local utilities

local strf = string.format
local byte, char = string.byte, string.char

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
	return table.concat(t)	
end --stohex()

local function hextos(hs)
	-- decode an hex encoded string. return the decoded string
	-- whitespace (space, tabs, CR, NL), is ignored
	-- hex string must be  well formed (only pairs of hex digits)
	hs = string.gsub(hs, "%s+", "") -- remove whitespaces
	if string.find(hs, '[^0-9A-Za-z]') or #hs % 2 ~= 0 then
			error("invalid hex string")
	end
	local tonumber = tonumber
	return (hs:gsub('(%x%x)', 
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
dig = lb.final(hr, 65) -- get a 65-byte hash
assert(dig == hextos[[
	288a86a79f20a3d6dccdca7713beaed1
	78798296bdfa7913fa2a62d9727bf8f8
	d7f01a496647e626c0d07fa6a060cbe3
	8bf116e3a05f489a9720924b875f1677
	04
]])
lb.update(hr, "!!")
dig = lb.final(hr) -- get a default, 32-byte hash
assert(dig == hextos[[
	ab04a6c9b4bbdfcb66dccef112d9e6f3
	99788de1bfe5005ef857756e7a4a5396
]])


------------------------------------------------------------------------
print("\ntest_luablake3", "ok\n")