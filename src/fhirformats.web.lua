package.preload['lunajson._str_lib'] = (function (...)
local inf = math.huge
local byte, char, sub = string.byte, string.char, string.sub
local setmetatable = setmetatable
local floor = math.floor

local _ENV = nil

local hextbl = {
	0x0, 0x1, 0x2, 0x3, 0x4, 0x5, 0x6, 0x7, 0x8, 0x9, inf, inf, inf, inf, inf, inf,
	inf, 0xA, 0xB, 0xC, 0xD, 0xE, 0xF, inf, inf, inf, inf, inf, inf, inf, inf, inf,
	inf, inf, inf, inf, inf, inf, inf, inf, inf, inf, inf, inf, inf, inf, inf, inf,
	inf, 0xA, 0xB, 0xC, 0xD, 0xE, 0xF, inf, inf, inf, inf, inf, inf, inf, inf, inf,
}
hextbl.__index = function()
	return inf
end
setmetatable(hextbl, hextbl)

return function(myerror)
	local escapetbl = {
		['"']  = '"',
		['\\'] = '\\',
		['/']  = '/',
		['b']  = '\b',
		['f']  = '\f',
		['n']  = '\n',
		['r']  = '\r',
		['t']  = '\t'
	}
	escapetbl.__index = function()
		myerror("invalid escape sequence")
	end
	setmetatable(escapetbl, escapetbl)

	local surrogateprev = 0

	local function subst(ch, rest)
		-- 0.000003814697265625 = 2^-18
		-- 0.000244140625 = 2^-12
		-- 0.015625 = 2^-6
		local u8
		if ch == 'u' then
			local c1, c2, c3, c4 = byte(rest, 1, 4)
			local ucode = hextbl[c1-47] * 0x1000 + hextbl[c2-47] * 0x100 + hextbl[c3-47] * 0x10 + hextbl[c4-47]
			if ucode == inf then
				myerror("invalid unicode charcode")
			end
			rest = sub(rest, 5)
			if ucode < 0x80 then -- 1byte
				u8 = char(ucode)
			elseif ucode < 0x800 then -- 2byte
				u8 = char(0xC0 + floor(ucode * 0.015625), 0x80 + ucode % 0x40)
			elseif ucode < 0xD800 or 0xE000 <= ucode then -- 3byte
				u8 = char(0xE0 + floor(ucode * 0.000244140625), 0x80 + floor(ucode * 0.015625) % 0x40, 0x80 + ucode % 0x40)
			elseif 0xD800 <= ucode and ucode < 0xDC00 then -- surrogate pair 1st
				if surrogateprev == 0 then
					surrogateprev = ucode
					if rest == '' then
						return ''
					end
				end
			else -- surrogate pair 2nd
				if surrogateprev == 0 then
					surrogateprev = 1
				else
					ucode = 0x10000 + (surrogateprev - 0xD800) * 0x400 + (ucode - 0xDC00)
					surrogateprev = 0
					u8 = char(0xF0 + floor(ucode * 0.000003814697265625), 0x80 + floor(ucode * 0.000244140625) % 0x40, 0x80 + floor(ucode * 0.015625) % 0x40, 0x80 + ucode % 0x40)
				end
			end
		end
		if surrogateprev ~= 0 then
			myerror("invalid surrogate pair")
		end
		return (u8 or escapetbl[ch]) .. rest
	end

	local function surrogateok()
		return surrogateprev == 0
	end

	return {
		subst = subst,
		surrogateok = surrogateok
	}
end
 end)
package.preload['lunajson.decoder'] = (function (...)
local error = error
local byte, char, find, gsub, match, sub = string.byte, string.char, string.find, string.gsub, string.match, string.sub
local tonumber = tonumber
local tostring, setmetatable = tostring, setmetatable

-- The function that interprets JSON strings is separated into another file so as to
-- use bitwise operation to speedup unicode codepoints processing on Lua 5.3.
local genstrlib
if _VERSION == "Lua 5.3" then
	genstrlib = require 'lunajson._str_lib_lua53'
else
	genstrlib = require 'lunajson._str_lib'
end

local _ENV = nil

local function newdecoder()
	local json, pos, nullv, arraylen

	-- `f` is the temporary for dispatcher[c] and
	-- the dummy for the first return value of `find`
	local dispatcher, f

	--[[
		Helper
	--]]
	local function decodeerror(errmsg)
		error("parse error at " .. pos .. ": " .. errmsg)
	end

	--[[
		Invalid
	--]]
	local function f_err()
		decodeerror('invalid value')
	end

	--[[
		Constants
	--]]
	-- null
	local function f_nul()
		if sub(json, pos, pos+2) == 'ull' then
			pos = pos+3
			return nullv
		end
		decodeerror('invalid value')
	end

	-- false
	local function f_fls()
		if sub(json, pos, pos+3) == 'alse' then
			pos = pos+4
			return false
		end
		decodeerror('invalid value')
	end

	-- true
	local function f_tru()
		if sub(json, pos, pos+2) == 'rue' then
			pos = pos+3
			return true
		end
		decodeerror('invalid value')
	end

	--[[
		Numbers
		Conceptually, the longest prefix that matches to `-?(0|[1-9][0-9]*)(\.[0-9]*)?([eE][+-]?[0-9]*)?`
		(in regexp) is captured as a number and its conformance to the JSON spec is checked.
	--]]
	-- deal with non-standard locales
	local radixmark = match(tostring(0.5), '[^0-9]')
	local fixedtonumber = tonumber
	if radixmark ~= '.' then
		if find(radixmark, '%W') then
			radixmark = '%' .. radixmark
		end
		fixedtonumber = function(s)
			return tonumber(gsub(s, '.', radixmark))
		end
	end

	local function error_number()
		decodeerror('invalid number')
	end

	-- `0(\.[0-9]*)?([eE][+-]?[0-9]*)?`
	local function f_zro(mns)
		local postmp = pos
		local num
		local c = byte(json, postmp)
		if not c then
			return error_number()
		end

		if c == 0x2E then -- is this `.`?
			num = match(json, '^.[0-9]*', pos) -- skipping 0
			local numlen = #num
			if numlen == 1 then
				return error_number()
			end
			postmp = pos + numlen
			c = byte(json, postmp)
		end

		if c == 0x45 or c == 0x65 then -- is this e or E?
			local numexp = match(json, '^[^eE]*[eE][-+]?[0-9]+', pos)
			if not numexp then
				return error_number()
			end
			if num then -- since `0e.*` is always 0.0, ignore those
				num = numexp
			end
			postmp = pos + #numexp
		end

		pos = postmp
		if num then
			num = fixedtonumber(num)
		else
			num = 0.0
		end
		if mns then
			num = -num
		end
		return num
	end

	-- `[1-9][0-9]*(\.[0-9]*)?([eE][+-]?[0-9]*)?`
	local function f_num(mns)
		pos = pos-1
		local num = match(json, '^.[0-9]*%.?[0-9]*', pos)
		if byte(num, -1) == 0x2E then
			return error_number()
		end
		local postmp = pos + #num
		local c = byte(json, postmp)

		if c == 0x45 or c == 0x65 then -- e or E?
			num = match(json, '^[^eE]*[eE][-+]?[0-9]+', pos)
			if not num then
				return error_number()
			end
			postmp = pos + #num
		end

		pos = postmp
		num = fixedtonumber(num)-0.0
		if mns then
			num = -num
		end
		return num
	end

	-- skip minus sign
	local function f_mns()
		local c = byte(json, pos)
		if c then
			pos = pos+1
			if c > 0x30 then
				if c < 0x3A then
					return f_num(true)
				end
			else
				if c > 0x2F then
					return f_zro(true)
				end
			end
		end
		decodeerror('invalid number')
	end

	--[[
		Strings
	--]]
	local f_str_lib = genstrlib(decodeerror)
	local f_str_surrogateok = f_str_lib.surrogateok -- whether codepoints for surrogate pair are correctly paired
	local f_str_subst = f_str_lib.subst -- the function passed to gsub that interprets escapes

	-- caching interpreted keys for speed
	local f_str_keycache = setmetatable({}, {__mode="v"})

	local function f_str(iskey)
		local newpos = pos-2
		local pos2 = pos
		local c1, c2
		repeat
			newpos = find(json, '"', pos2, true) -- search '"'
			if not newpos then
				decodeerror("unterminated string")
			end
			pos2 = newpos+1
			while true do -- skip preceding '\\'s
				c1, c2 = byte(json, newpos-2, newpos-1)
				if c2 ~= 0x5C or c1 ~= 0x5C then
					break
				end
				newpos = newpos-2
			end
		until c2 ~= 0x5C -- check '"' is not preceded by '\'

		local str = sub(json, pos, pos2-2)
		pos = pos2

		if iskey then -- check key cache
			local str2 = f_str_keycache[str]
			if str2 then
				return str2
			end
		end
		local str2 = str
		if find(str2, '\\', 1, true) then -- check if backslash occurs
			str2 = gsub(str2, '\\(.)([^\\]*)', f_str_subst) -- interpret escapes
			if not f_str_surrogateok() then
				decodeerror("invalid surrogate pair")
			end
		end
		if iskey then -- commit key cache
			f_str_keycache[str] = str2
		end
		return str2
	end

	--[[
		Arrays, Objects
	--]]
	-- array
	local function f_ary()
		local ary = {}

		f, pos = find(json, '^[ \n\r\t]*', pos)
		pos = pos+1

		local i = 0
		if byte(json, pos) ~= 0x5D then -- check closing bracket ']', that consists an empty array
			local newpos = pos-1
			repeat
				i = i+1
				f = dispatcher[byte(json,newpos+1)] -- parse value
				pos = newpos+2
				ary[i] = f()
				f, newpos = find(json, '^[ \n\r\t]*,[ \n\r\t]*', pos) -- check comma
			until not newpos

			f, newpos = find(json, '^[ \n\r\t]*%]', pos) -- check closing bracket
			if not newpos then
				decodeerror("no closing bracket of an array")
			end
			pos = newpos
		end

		pos = pos+1
		if arraylen then -- commit the length of the array if `arraylen` is set
			ary[0] = i
		end
		return ary
	end

	-- objects
	local function f_obj()
		local obj = {}

		f, pos = find(json, '^[ \n\r\t]*', pos)
		pos = pos+1
		if byte(json, pos) ~= 0x7D then -- check the closing bracket '}', that consists an empty object
			local newpos = pos-1

			repeat
				pos = newpos+1
				if byte(json, pos) ~= 0x22 then -- check '"'
					decodeerror("not key")
				end
				pos = pos+1
				local key = f_str(true) -- parse key

				-- optimized for compact json
				-- c1, c2 == ':', <the first char of the value> or
				-- c1, c2, c3 == ':', ' ', <the first char of the value>
				f = f_err
				do
					local c1, c2, c3  = byte(json, pos, pos+3)
					if c1 == 0x3A then
						newpos = pos
						if c2 == 0x20 then
							newpos = newpos+1
							c2 = c3
						end
						f = dispatcher[c2]
					end
				end
				if f == f_err then -- read a colon and arbitrary number of spaces
					f, newpos = find(json, '^[ \n\r\t]*:[ \n\r\t]*', pos)
					if not newpos then
						decodeerror("no colon after a key")
					end
				end
				f = dispatcher[byte(json, newpos+1)] -- parse value
				pos = newpos+2
				obj[key] = f()
				f, newpos = find(json, '^[ \n\r\t]*,[ \n\r\t]*', pos)
			until not newpos

			f, newpos = find(json, '^[ \n\r\t]*}', pos)
			if not newpos then
				decodeerror("no closing bracket of an object")
			end
			pos = newpos
		end

		pos = pos+1
		return obj
	end

	--[[
		The jump table to dispatch a parser for a value, indexed by the code of the value's first char.
		Nil key means the end of json.
	--]]
	dispatcher = {
		       f_err, f_err, f_err, f_err, f_err, f_err, f_err, f_err, f_err, f_err, f_err, f_err, f_err, f_err, f_err,
		f_err, f_err, f_err, f_err, f_err, f_err, f_err, f_err, f_err, f_err, f_err, f_err, f_err, f_err, f_err, f_err,
		f_err, f_err, f_str, f_err, f_err, f_err, f_err, f_err, f_err, f_err, f_err, f_err, f_err, f_mns, f_err, f_err,
		f_zro, f_num, f_num, f_num, f_num, f_num, f_num, f_num, f_num, f_num, f_err, f_err, f_err, f_err, f_err, f_err,
		f_err, f_err, f_err, f_err, f_err, f_err, f_err, f_err, f_err, f_err, f_err, f_err, f_err, f_err, f_err, f_err,
		f_err, f_err, f_err, f_err, f_err, f_err, f_err, f_err, f_err, f_err, f_err, f_ary, f_err, f_err, f_err, f_err,
		f_err, f_err, f_err, f_err, f_err, f_err, f_fls, f_err, f_err, f_err, f_err, f_err, f_err, f_err, f_nul, f_err,
		f_err, f_err, f_err, f_err, f_tru, f_err, f_err, f_err, f_err, f_err, f_err, f_obj, f_err, f_err, f_err, f_err,
	}
	dispatcher[0] = f_err
	dispatcher.__index = function()
		decodeerror("unexpected termination")
	end
	setmetatable(dispatcher, dispatcher)

	--[[
		run decoder
	--]]
	local function decode(json_, pos_, nullv_, arraylen_)
		json, pos, nullv, arraylen = json_, pos_, nullv_, arraylen_

		pos = pos or 1
		f, pos = find(json, '^[ \n\r\t]*', pos)
		pos = pos+1

		f = dispatcher[byte(json, pos)]
		pos = pos+1
		local v = f()

		if pos_ then
			return v, pos
		else
			f, pos = find(json, '^[ \n\r\t]*', pos)
			if pos ~= #json then
				error('json ended')
			end
			return v
		end
	end

	return decode
end

return newdecoder
 end)
package.preload['lunajson.encoder'] = (function (...)
local error = error
local byte, find, format, gsub, match = string.byte, string.find, string.format,  string.gsub, string.match
local concat = table.concat
local tostring = tostring
local pairs, type = pairs, type
local setmetatable = setmetatable
local huge, tiny = 1/0, -1/0

local f_string_pat
if _VERSION == "Lua 5.1" then
	-- use the cluttered pattern because lua 5.1 does not handle \0 in a pattern correctly
	f_string_pat = '[^ -!#-[%]^-\255]'
else
	f_string_pat = '[\0-\31"\\]'
end

local _ENV = nil

local function newencoder()
	local v, nullv
	local i, builder, visited

	local function f_tostring(v)
		builder[i] = tostring(v)
		i = i+1
	end

	local radixmark = match(tostring(0.5), '[^0-9]')
	local delimmark = match(tostring(12345.12345), '[^0-9' .. radixmark .. ']')
	if radixmark == '.' then
		radixmark = nil
	end

	local radixordelim
	if radixmark or delimmark then
		radixordelim = true
		if radixmark and find(radixmark, '%W') then
			radixmark = '%' .. radixmark
		end
		if delimmark and find(delimmark, '%W') then
			delimmark = '%' .. delimmark
		end
	end

	local f_number = function(n)
		if tiny < n and n < huge then
			local s = format("%.17g", n)
			if radixordelim then
				if delimmark then
					s = gsub(s, delimmark, '')
				end
				if radixmark then
					s = gsub(s, radixmark, '.')
				end
			end
			builder[i] = s
			i = i+1
			return
		end
		error('invalid number')
	end

	local doencode

	local f_string_subst = {
		['"'] = '\\"',
		['\\'] = '\\\\',
		['\b'] = '\\b',
		['\f'] = '\\f',
		['\n'] = '\\n',
		['\r'] = '\\r',
		['\t'] = '\\t',
		__index = function(_, c)
			return format('\\u00%02X', byte(c))
		end
	}
	setmetatable(f_string_subst, f_string_subst)

	local function f_string(s)
		builder[i] = '"'
		if find(s, f_string_pat) then
			s = gsub(s, f_string_pat, f_string_subst)
		end
		builder[i+1] = s
		builder[i+2] = '"'
		i = i+3
	end

	local function f_table(o)
		if visited[o] then
			error("loop detected")
		end
		visited[o] = true

		local tmp = o[0]
		if type(tmp) == 'number' then -- arraylen available
			builder[i] = '['
			i = i+1
			for j = 1, tmp do
				doencode(o[j])
				builder[i] = ','
				i = i+1
			end
			if tmp > 0 then
				i = i-1
			end
			builder[i] = ']'

		else
			tmp = o[1]
			if tmp ~= nil then -- detected as array
				builder[i] = '['
				i = i+1
				local j = 2
				repeat
					doencode(tmp)
					tmp = o[j]
					if tmp == nil then
						break
					end
					j = j+1
					builder[i] = ','
					i = i+1
				until false
				builder[i] = ']'

			else -- detected as object
				builder[i] = '{'
				i = i+1
				local tmp = i
				for k, v in pairs(o) do
					if type(k) ~= 'string' then
						error("non-string key")
					end
					f_string(k)
					builder[i] = ':'
					i = i+1
					doencode(v)
					builder[i] = ','
					i = i+1
				end
				if i > tmp then
					i = i-1
				end
				builder[i] = '}'
			end
		end

		i = i+1
		visited[o] = nil
	end

	local dispatcher = {
		boolean = f_tostring,
		number = f_number,
		string = f_string,
		table = f_table,
		__index = function()
			error("invalid type value")
		end
	}
	setmetatable(dispatcher, dispatcher)

	function doencode(v)
		if v == nullv then
			builder[i] = 'null'
			i = i+1
			return
		end
		return dispatcher[type(v)](v)
	end

	local function encode(v_, nullv_)
		v, nullv = v_, nullv_
		i, builder, visited = 1, {}, {}

		doencode(v)
		return concat(builder)
	end

	return encode
end

return newencoder
 end)
package.preload['lunajson.sax'] = (function (...)
local error = error
local byte, char, find, gsub, match, sub = string.byte, string.char, string.find, string.gsub, string.match, string.sub
local tonumber = tonumber
local tostring, type, unpack = tostring, type, table.unpack or unpack

-- The function that interprets JSON strings is separated into another file so as to
-- use bitwise operation to speedup unicode codepoints processing on Lua 5.3.
local genstrlib
if _VERSION == "Lua 5.3" then
	genstrlib = require 'lunajson._str_lib_lua53'
else
	genstrlib = require 'lunajson._str_lib'
end

local _ENV = nil

local function nop() end

local function newparser(src, saxtbl)
	local json, jsonnxt
	local jsonlen, pos, acc = 0, 1, 0

	-- `f` is the temporary for dispatcher[c] and
	-- the dummy for the first return value of `find`
	local dispatcher, f

	-- initialize
	if type(src) == 'string' then
		json = src
		jsonlen = #json
		jsonnxt = function()
			json = ''
			jsonlen = 0
			jsonnxt = nop
		end
	else
		jsonnxt = function()
			acc = acc + jsonlen
			pos = 1
			repeat
				json = src()
				if not json then
					json = ''
					jsonlen = 0
					jsonnxt = nop
					return
				end
				jsonlen = #json
			until jsonlen > 0
		end
		jsonnxt()
	end

	local sax_startobject = saxtbl.startobject or nop
	local sax_key = saxtbl.key or nop
	local sax_endobject = saxtbl.endobject or nop
	local sax_startarray = saxtbl.startarray or nop
	local sax_endarray = saxtbl.endarray or nop
	local sax_string = saxtbl.string or nop
	local sax_number = saxtbl.number or nop
	local sax_boolean = saxtbl.boolean or nop
	local sax_null = saxtbl.null or nop

	--[[
		Helper
	--]]
	local function tryc()
		local c = byte(json, pos)
		if not c then
			jsonnxt()
			c = byte(json, pos)
		end
		return c
	end

	local function parseerror(errmsg)
		error("parse error at " .. acc + pos .. ": " .. errmsg)
	end

	local function tellc()
		return tryc() or parseerror("unexpected termination")
	end

	local function spaces() -- skip spaces and prepare the next char
		while true do
			f, pos = find(json, '^[ \n\r\t]*', pos)
			if pos ~= jsonlen then
				pos = pos+1
				return
			end
			if jsonlen == 0 then
				parseerror("unexpected termination")
			end
			jsonnxt()
		end
	end

	--[[
		Invalid
	--]]
	local function f_err()
		parseerror('invalid value')
	end

	--[[
		Constants
	--]]
	-- fallback slow constants parser
	local function generic_constant(target, targetlen, ret, sax_f)
		for i = 1, targetlen do
			local c = tellc()
			if byte(target, i) ~= c then
				parseerror("invalid char")
			end
			pos = pos+1
		end
		return sax_f(ret)
	end

	-- null
	local function f_nul()
		if sub(json, pos, pos+2) == 'ull' then
			pos = pos+3
			return sax_null(nil)
		end
		return generic_constant('ull', 3, nil, sax_null)
	end

	-- false
	local function f_fls()
		if sub(json, pos, pos+3) == 'alse' then
			pos = pos+4
			return sax_boolean(false)
		end
		return generic_constant('alse', 4, false, sax_boolean)
	end

	-- true
	local function f_tru()
		if sub(json, pos, pos+2) == 'rue' then
			pos = pos+3
			return sax_boolean(true)
		end
		return generic_constant('rue', 3, true, sax_boolean)
	end

	--[[
		Numbers
		Conceptually, the longest prefix that matches to `(0|[1-9][0-9]*)(\.[0-9]*)?([eE][+-]?[0-9]*)?`
		(in regexp) is captured as a number and its conformance to the JSON spec is checked.
	--]]
	-- deal with non-standard locales
	local radixmark = match(tostring(0.5), '[^0-9]')
	local fixedtonumber = tonumber
	if radixmark ~= '.' then -- deals with non-standard locales
		if find(radixmark, '%W') then
			radixmark = '%' .. radixmark
		end
		fixedtonumber = function(s)
			return tonumber(gsub(s, '.', radixmark))
		end
	end

	-- fallback slow parser
	local function generic_number(mns)
		local buf = {}
		local i = 1

		local c = byte(json, pos)
		pos = pos+1

		local function nxt()
			buf[i] = c
			i = i+1
			c = tryc()
			pos = pos+1
		end

		if c == 0x30 then
			nxt()
		else
			repeat nxt() until not (c and 0x30 <= c and c < 0x3A)
		end
		if c == 0x2E then
			nxt()
			if not (c and 0x30 <= c and c < 0x3A) then
				parseerror('invalid number')
			end
			repeat nxt() until not (c and 0x30 <= c and c < 0x3A)
		end
		if c == 0x45 or c == 0x65 then
			nxt()
			if c == 0x2B or c == 0x2D then
				nxt()
			end
			if not (c and 0x30 <= c and c < 0x3A) then
				parseerror('invalid number')
			end
			repeat nxt() until not (c and 0x30 <= c and c < 0x3A)
		end
		pos = pos-1

		local num = char(unpack(buf))
		num = fixedtonumber(num)-0.0
		if mns then
			num = -num
		end
		return sax_number(num)
	end

	-- `0(\.[0-9]*)?([eE][+-]?[0-9]*)?`
	local function f_zro(mns)
		local postmp = pos
		local num
		local c = byte(json, postmp)

		if c == 0x2E then -- is this `.`?
			num = match(json, '^.[0-9]*', pos) -- skipping 0
			local numlen = #num
			if numlen == 1 then
				pos = pos-1
				return generic_number(mns)
			end
			postmp = pos + numlen
			c = byte(json, postmp)
		end

		if c == 0x45 or c == 0x65 then -- is this e or E?
			local numexp = match(json, '^[^eE]*[eE][-+]?[0-9]+', pos)
			if not numexp then
				pos = pos-1
				return generic_number(mns)
			end
			if num then -- since `0e.*` is always 0.0, ignore those
				num = numexp
			end
			postmp = pos + #numexp
		end

		if postmp > jsonlen then
			pos = pos-1
			return generic_number(mns)
		end
		pos = postmp
		if num then
			num = fixedtonumber(num)
		else
			num = 0.0
		end
		if mns then
			num = -num
		end
		return sax_number(num)
	end

	-- `[1-9][0-9]*(\.[0-9]*)?([eE][+-]?[0-9]*)?`
	local function f_num(mns)
		pos = pos-1
		local num = match(json, '^.[0-9]*%.?[0-9]*', pos)
		if byte(num, -1) == 0x2E then
			return generic_number(mns)
		end
		local postmp = pos + #num
		local c = byte(json, postmp)

		if c == 0x45 or c == 0x65 then -- e or E?
			num = match(json, '^[^eE]*[eE][-+]?[0-9]+', pos)
			if not num then
				return generic_number(mns)
			end
			postmp = pos + #num
		end

		if postmp > jsonlen then
			return generic_number(mns)
		end
		pos = postmp
		num = fixedtonumber(num)-0.0
		if mns then
			num = -num
		end
		return sax_number(num)
	end

	-- skip minus sign
	local function f_mns()
		local c = byte(json, pos) or tellc()
		if c then
			pos = pos+1
			if c > 0x30 then
				if c < 0x3A then
					return f_num(true)
				end
			else
				if c > 0x2F then
					return f_zro(true)
				end
			end
		end
		parseerror("invalid number")
	end

	--[[
		Strings
	--]]
	local f_str_lib = genstrlib(parseerror)
	local f_str_surrogateok = f_str_lib.surrogateok -- whether codepoints for surrogate pair are correctly paired
	local f_str_subst = f_str_lib.subst -- the function passed to gsub that interprets escapes

	local function f_str(iskey)
		local pos2 = pos
		local newpos
		local str = ''
		local bs
		while true do
			while true do -- search '\' or '"'
				newpos = find(json, '[\\"]', pos2)
				if newpos then
					break
				end
				str = str .. sub(json, pos, jsonlen)
				if pos2 == jsonlen+2 then
					pos2 = 2
				else
					pos2 = 1
				end
				jsonnxt()
			end
			if byte(json, newpos) == 0x22 then -- break if '"'
				break
			end
			pos2 = newpos+2 -- skip '\<char>'
			bs = true -- remember that backslash occurs
		end
		str = str .. sub(json, pos, newpos-1)
		pos = newpos+1

		if bs then -- check if backslash occurs
			str = gsub(str, '\\(.)([^\\]*)', f_str_subst) -- interpret escapes
			if not f_str_surrogateok() then
				parseerror("invalid surrogate pair")
			end
		end

		if iskey then
			return sax_key(str)
		end
		return sax_string(str)
	end

	--[[
		Arrays, Objects
	--]]
	-- arrays
	local function f_ary()
		sax_startarray()
		spaces()
		if byte(json, pos) ~= 0x5D then -- check the closing bracket ']', that consists an empty array
			local newpos
			while true do
				f = dispatcher[byte(json, pos)] -- parse value
				pos = pos+1
				f()
				f, newpos = find(json, '^[ \n\r\t]*,[ \n\r\t]*', pos) -- check comma
				if not newpos then
					f, newpos = find(json, '^[ \n\r\t]*%]', pos) -- check closing bracket
					if newpos then
						pos = newpos
						break
					end
					spaces() -- since the current chunk can be ended, skip spaces toward following chunks
					local c = byte(json, pos)
					if c == 0x2C then -- check comma again
						pos = pos+1
						spaces()
						newpos = pos-1
					elseif c == 0x5D then -- check closing bracket again
						break
					else
						parseerror("no closing bracket of an array")
					end
				end
				pos = newpos+1
				if pos > jsonlen then
					spaces()
				end
			end
		end
		pos = pos+1
		return sax_endarray()
	end

	-- objects
	local function f_obj()
		sax_startobject()
		spaces()
		if byte(json, pos) ~= 0x7D then -- check the closing bracket `}`, that consists an empty object
			local newpos
			while true do
				if byte(json, pos) ~= 0x22 then
					parseerror("not key")
				end
				pos = pos+1
				f_str(true)
				f, newpos = find(json, '^[ \n\r\t]*:[ \n\r\t]*', pos) -- check colon
				if not newpos then
					spaces() -- since the current chunk can be ended, skip spaces toward following chunks
					if byte(json, pos) ~= 0x3A then -- check colon again
						parseerror("no colon after a key")
					end
					pos = pos+1
					spaces()
					newpos = pos-1
				end
				pos = newpos+1
				if pos > jsonlen then
					spaces()
				end
				f = dispatcher[byte(json, pos)] -- parse value
				pos = pos+1
				f()
				f, newpos = find(json, '^[ \n\r\t]*,[ \n\r\t]*', pos) -- check comma
				if not newpos then
					f, newpos = find(json, '^[ \n\r\t]*}', pos) -- check closing bracket
					if newpos then
						pos = newpos
						break
					end
					spaces() -- since the current chunk can be ended, skip spaces toward following chunks
					local c = byte(json, pos)
					if c == 0x2C then -- check comma again
						pos = pos+1
						spaces()
						newpos = pos-1
					elseif c == 0x7D then -- check closing bracket again
						break
					else
						parseerror("no closing bracket of an object")
					end
				end
				pos = newpos+1
				if pos > jsonlen then
					spaces()
				end
			end
		end
		pos = pos+1
		return sax_endobject()
	end

	--[[
		The jump table to dispatch a parser for a value, indexed by the code of the value's first char.
		Key should be non-nil.
	--]]
	dispatcher = {
		       f_err, f_err, f_err, f_err, f_err, f_err, f_err, f_err, f_err, f_err, f_err, f_err, f_err, f_err, f_err,
		f_err, f_err, f_err, f_err, f_err, f_err, f_err, f_err, f_err, f_err, f_err, f_err, f_err, f_err, f_err, f_err,
		f_err, f_err, f_str, f_err, f_err, f_err, f_err, f_err, f_err, f_err, f_err, f_err, f_err, f_mns, f_err, f_err,
		f_zro, f_num, f_num, f_num, f_num, f_num, f_num, f_num, f_num, f_num, f_err, f_err, f_err, f_err, f_err, f_err,
		f_err, f_err, f_err, f_err, f_err, f_err, f_err, f_err, f_err, f_err, f_err, f_err, f_err, f_err, f_err, f_err,
		f_err, f_err, f_err, f_err, f_err, f_err, f_err, f_err, f_err, f_err, f_err, f_ary, f_err, f_err, f_err, f_err,
		f_err, f_err, f_err, f_err, f_err, f_err, f_fls, f_err, f_err, f_err, f_err, f_err, f_err, f_err, f_nul, f_err,
		f_err, f_err, f_err, f_err, f_tru, f_err, f_err, f_err, f_err, f_err, f_err, f_obj, f_err, f_err, f_err, f_err,
	}
	dispatcher[0] = f_err

	--[[
		public funcitons
	--]]
	local function run()
		spaces()
		f = dispatcher[byte(json, pos)]
		pos = pos+1
		f()
	end

	local function read(n)
		if n < 0 then
			error("the argument must be non-negative")
		end
		local pos2 = (pos-1) + n
		local str = sub(json, pos, pos2)
		while pos2 > jsonlen and jsonlen ~= 0 do
			jsonnxt()
			pos2 = pos2 - (jsonlen - (pos-1))
			str = str .. sub(json, pos, pos2)
		end
		if jsonlen ~= 0 then
			pos = pos2+1
		end
		return str
	end

	local function tellpos()
		return acc + pos
	end

	return {
		run = run,
		tryc = tryc,
		read = read,
		tellpos = tellpos,
	}
end

local function newfileparser(fn, saxtbl)
	local fp = io.open(fn)
	local function gen()
		local s
		if fp then
			s = fp:read(8192)
			if not s then
				fp:close()
				fp = nil
			end
		end
		return s
	end
	return newparser(gen, saxtbl)
end

return {
	newparser = newparser,
	newfileparser = newfileparser
}
 end)
package.preload['lunajson'] = (function (...)
local newdecoder = require 'lunajson.decoder'
local newencoder = require 'lunajson.encoder'
local sax = require 'lunajson.sax'
-- If you need multiple contexts of decoder and/or encoder,
-- you can require lunajson.decoder and/or lunajson.encoder directly.
return {
	decode = newdecoder(),
	encode = newencoder(),
	newparser = sax.newparser,
	newfileparser = sax.newfileparser,
}
 end)
package.preload['fhirformats-xml'] = (function (...)
-- Copyright (C) Marcin Kalicinski 2006, 2009, Gaspard Bucher 2014.

-- This software may be modified and distributed under the terms
-- of the MIT license.  See the LICENSE file for details.

-- this is a cannibalised XML encoding portion of https://github.com/lubyk/xml

local ipairs, pairs, insert, type,
      match, tostring =
      ipairs, pairs, table.insert, type,
      string.match, tostring

local function escape(v)
  if type(v) == 'boolean' then
    return v and 'true' or 'false'
  else
    return v:gsub('&','&amp;'):gsub('>','&gt;'):gsub('<','&lt;'):gsub("'",'&apos;')
  end
end

local function tagWithAttributes(data)
  local res = data.xml or 'table'
  for k,v in pairs(data) do
    if k ~= 'xml' and type(k) == 'string' then
      res = res .. ' ' .. k .. "='" .. escape(v) .. "'"
    end
  end
  return res
end

local function doDump(data, indent, output, last, depth, max_depth)
  if depth > max_depth then
    error(string.format("Could not dump table to XML. Maximal depth of %i reached.", max_depth))
  end

  if data[1] then
    insert(output, (last == 'n' and indent or '')..'<'..tagWithAttributes(data)..'>')
    last = 'n'
    local ind = indent..'  '
    for _, child in ipairs(data) do
      local typ = type(child)
      if typ == 'table' then
        doDump(child, ind, output, last, depth + 1, max_depth)
        last = 'n'
      elseif typ == 'number' then
        insert(output, tostring(child))
      else
        local s = escape(child)
        insert(output, s)
        last = 's'
      end
    end
    insert(output, (last == 'n' and indent or '')..'</'..(data.xml or 'table')..'>')
    last = 'n'
  else
    -- no children
    insert(output, (last == 'n' and indent or '')..'<'..tagWithAttributes(data)..'/>')
    last = 'n'
  end
end

local function dump(data, max_depth)
  local max_depth = max_depth or 3000
  local res = {}
  doDump(data, '\n', res, 's', 1, max_depth)
  return table.concat(res, '')
end

return {
  dump = dump
}
 end)
package.preload['inspect'] = (function (...)
local inspect ={
  _VERSION = 'inspect.lua 3.0.3',
  _URL     = 'http://github.com/kikito/inspect.lua',
  _DESCRIPTION = 'human-readable representations of tables',
  _LICENSE = [[
    MIT LICENSE

    Copyright (c) 2013 Enrique García Cota

    Permission is hereby granted, free of charge, to any person obtaining a
    copy of this software and associated documentation files (the
    "Software"), to deal in the Software without restriction, including
    without limitation the rights to use, copy, modify, merge, publish,
    distribute, sublicense, and/or sell copies of the Software, and to
    permit persons to whom the Software is furnished to do so, subject to
    the following conditions:

    The above copyright notice and this permission notice shall be included
    in all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
    OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
    IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
    CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
    TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
    SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
  ]]
}

inspect.KEY       = setmetatable({}, {__tostring = function() return 'inspect.KEY' end})
inspect.METATABLE = setmetatable({}, {__tostring = function() return 'inspect.METATABLE' end})

-- Apostrophizes the string if it has quotes, but not aphostrophes
-- Otherwise, it returns a regular quoted string
local function smartQuote(str)
  if str:match('"') and not str:match("'") then
    return "'" .. str .. "'"
  end
  return '"' .. str:gsub('"', '\\"') .. '"'
end

local controlCharsTranslation = {
  ["\a"] = "\\a",  ["\b"] = "\\b", ["\f"] = "\\f",  ["\n"] = "\\n",
  ["\r"] = "\\r",  ["\t"] = "\\t", ["\v"] = "\\v"
}

local function escape(str)
  local result = str:gsub("\\", "\\\\"):gsub("(%c)", controlCharsTranslation)
  return result
end

local function isIdentifier(str)
  return type(str) == 'string' and str:match( "^[_%a][_%a%d]*$" )
end

local function isSequenceKey(k, sequenceLength)
  return type(k) == 'number'
     and 1 <= k
     and k <= sequenceLength
     and math.floor(k) == k
end

local defaultTypeOrders = {
  ['number']   = 1, ['boolean']  = 2, ['string'] = 3, ['table'] = 4,
  ['function'] = 5, ['userdata'] = 6, ['thread'] = 7
}

local function sortKeys(a, b)
  local ta, tb = type(a), type(b)

  -- strings and numbers are sorted numerically/alphabetically
  if ta == tb and (ta == 'string' or ta == 'number') then return a < b end

  local dta, dtb = defaultTypeOrders[ta], defaultTypeOrders[tb]
  -- Two default types are compared according to the defaultTypeOrders table
  if dta and dtb then return defaultTypeOrders[ta] < defaultTypeOrders[tb]
  elseif dta     then return true  -- default types before custom ones
  elseif dtb     then return false -- custom types after default ones
  end

  -- custom types are sorted out alphabetically
  return ta < tb
end

-- For implementation reasons, the behavior of rawlen & # is "undefined" when
-- tables aren't pure sequences. So we implement our own # operator.
local function getSequenceLength(t)
  local len = 1
  local v = rawget(t,len)
  while v ~= nil do
    len = len + 1
    v = rawget(t,len)
  end
  return len - 1
end

local function getNonSequentialKeys(t)
  local keys = {}
  local sequenceLength = getSequenceLength(t)
  for k,_ in pairs(t) do
    if not isSequenceKey(k, sequenceLength) then table.insert(keys, k) end
  end
  table.sort(keys, sortKeys)
  return keys, sequenceLength
end

local function getToStringResultSafely(t, mt)
  local __tostring = type(mt) == 'table' and rawget(mt, '__tostring')
  local str, ok
  if type(__tostring) == 'function' then
    ok, str = pcall(__tostring, t)
    str = ok and str or 'error: ' .. tostring(str)
  end
  if type(str) == 'string' and #str > 0 then return str end
end

local maxIdsMetaTable = {
  __index = function(self, typeName)
    rawset(self, typeName, 0)
    return 0
  end
}

local idsMetaTable = {
  __index = function (self, typeName)
    local col = {}
    rawset(self, typeName, col)
    return col
  end
}

local function countTableAppearances(t, tableAppearances)
  tableAppearances = tableAppearances or {}

  if type(t) == 'table' then
    if not tableAppearances[t] then
      tableAppearances[t] = 1
      for k,v in pairs(t) do
        countTableAppearances(k, tableAppearances)
        countTableAppearances(v, tableAppearances)
      end
      countTableAppearances(getmetatable(t), tableAppearances)
    else
      tableAppearances[t] = tableAppearances[t] + 1
    end
  end

  return tableAppearances
end

local copySequence = function(s)
  local copy, len = {}, #s
  for i=1, len do copy[i] = s[i] end
  return copy, len
end

local function makePath(path, ...)
  local keys = {...}
  local newPath, len = copySequence(path)
  for i=1, #keys do
    newPath[len + i] = keys[i]
  end
  return newPath
end

local function processRecursive(process, item, path)
  if item == nil then return nil end

  local processed = process(item, path)
  if type(processed) == 'table' then
    local processedCopy = {}
    local processedKey

    for k,v in pairs(processed) do
      processedKey = processRecursive(process, k, makePath(path, k, inspect.KEY))
      if processedKey ~= nil then
        processedCopy[processedKey] = processRecursive(process, v, makePath(path, processedKey))
      end
    end

    local mt  = processRecursive(process, getmetatable(processed), makePath(path, inspect.METATABLE))
    setmetatable(processedCopy, mt)
    processed = processedCopy
  end
  return processed
end


-------------------------------------------------------------------

local Inspector = {}
local Inspector_mt = {__index = Inspector}

function Inspector:puts(...)
  local args   = {...}
  local buffer = self.buffer
  local len    = #buffer
  for i=1, #args do
    len = len + 1
    buffer[len] = tostring(args[i])
  end
end

function Inspector:down(f)
  self.level = self.level + 1
  f()
  self.level = self.level - 1
end

function Inspector:tabify()
  self:puts(self.newline, string.rep(self.indent, self.level))
end

function Inspector:alreadyVisited(v)
  return self.ids[type(v)][v] ~= nil
end

function Inspector:getId(v)
  local tv = type(v)
  local id = self.ids[tv][v]
  if not id then
    id              = self.maxIds[tv] + 1
    self.maxIds[tv] = id
    self.ids[tv][v] = id
  end
  return id
end

function Inspector:putKey(k)
  if isIdentifier(k) then return self:puts(k) end
  self:puts("[")
  self:putValue(k)
  self:puts("]")
end

function Inspector:putTable(t)
  if t == inspect.KEY or t == inspect.METATABLE then
    self:puts(tostring(t))
  elseif self:alreadyVisited(t) then
    self:puts('<table ', self:getId(t), '>')
  elseif self.level >= self.depth then
    self:puts('{...}')
  else
    if self.tableAppearances[t] > 1 then self:puts('<', self:getId(t), '>') end

    local nonSequentialKeys, sequenceLength = getNonSequentialKeys(t)
    local mt                = getmetatable(t)
    local toStringResult    = getToStringResultSafely(t, mt)

    self:puts('{')
    self:down(function()
      if toStringResult then
        self:puts(' -- ', escape(toStringResult))
        if sequenceLength >= 1 then self:tabify() end
      end

      local count = 0
      for i=1, sequenceLength do
        if count > 0 then self:puts(',') end
        self:puts(' ')
        self:putValue(t[i])
        count = count + 1
      end

      for _,k in ipairs(nonSequentialKeys) do
        if count > 0 then self:puts(',') end
        self:tabify()
        self:putKey(k)
        self:puts(' = ')
        self:putValue(t[k])
        count = count + 1
      end

      if mt then
        if count > 0 then self:puts(',') end
        self:tabify()
        self:puts('<metatable> = ')
        self:putValue(mt)
      end
    end)

    if #nonSequentialKeys > 0 or mt then -- result is multi-lined. Justify closing }
      self:tabify()
    elseif sequenceLength > 0 then -- array tables have one extra space before closing }
      self:puts(' ')
    end

    self:puts('}')
  end
end

function Inspector:putValue(v)
  local tv = type(v)

  if tv == 'string' then
    self:puts(smartQuote(escape(v)))
  elseif tv == 'number' or tv == 'boolean' or tv == 'nil' then
    self:puts(tostring(v))
  elseif tv == 'table' then
    self:putTable(v)
  else
    self:puts('<',tv,' ',self:getId(v),'>')
  end
end

-------------------------------------------------------------------

function inspect.inspect(root, options)
  options       = options or {}

  local depth   = options.depth   or math.huge
  local newline = options.newline or '\n'
  local indent  = options.indent  or '  '
  local process = options.process

  if process then
    root = processRecursive(process, root, {})
  end

  local inspector = setmetatable({
    depth            = depth,
    buffer           = {},
    level            = 0,
    ids              = setmetatable({}, idsMetaTable),
    maxIds           = setmetatable({}, maxIdsMetaTable),
    newline          = newline,
    indent           = indent,
    tableAppearances = countTableAppearances(root)
  }, Inspector_mt)

  inspector:putValue(root)

  return table.concat(inspector.buffer)
end

setmetatable(inspect, { __call = function(_, ...) return inspect.inspect(...) end })

return inspect

 end)
do local resources = {};
resources["fhir-data/fhir-elements.json"] = "[\
	{\
		\"path\": \"date\",\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"date.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"date.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"date.value\",\
		\"type_json\": \"string\",\
		\"type_xml\": \"xs:gYear, xs:gYearMonth, xs:date\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"dateTime\",\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"dateTime.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"dateTime.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"dateTime.value\",\
		\"type_json\": \"string\",\
		\"type_xml\": \"xs:gYear, xs:gYearMonth, xs:date, xs:dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"string\",\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"string.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"string.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"string.value\",\
		\"type_json\": \"string\",\
		\"type_xml\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"integer\",\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"integer.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"integer.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"integer.value\",\
		\"type_json\": \"number\",\
		\"type_xml\": \"int\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"uri\",\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"uri.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"uri.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"uri.value\",\
		\"type_json\": \"string\",\
		\"type_xml\": \"anyURI\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"instant\",\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"instant.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"instant.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"instant.value\",\
		\"type_json\": \"string\",\
		\"type_xml\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"boolean\",\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"boolean.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"boolean.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"boolean.value\",\
		\"type_json\": \"true | false\",\
		\"type_xml\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"base64Binary\",\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"base64Binary.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"base64Binary.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"base64Binary.value\",\
		\"type_json\": \"string\",\
		\"type_xml\": \"base64Binary\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"time\",\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"time.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"time.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"time.value\",\
		\"type_json\": \"string\",\
		\"type_xml\": \"time\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"decimal\",\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"decimal.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"decimal.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"decimal.value\",\
		\"type_json\": \"number\",\
		\"type_xml\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Identifier\",\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Identifier.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Identifier.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Identifier.use\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Identifier.type\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Identifier.system\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Identifier.value\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Identifier.period\",\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Identifier.assigner\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Coding\",\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Coding.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Coding.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Coding.system\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Coding.version\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Coding.code\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Coding.display\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Coding.userSelected\",\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Reference\",\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Reference.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Reference.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Reference.reference\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Reference.display\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Signature\",\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Signature.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Signature.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Signature.type\",\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Signature.when\",\
		\"type\": \"instant\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Signature.whoUri\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"path\": \"Signature.whoReference\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"Signature.whoReference\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"Signature.whoReference\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"Signature.whoReference\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"Signature.whoReference\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"Signature.contentType\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Signature.blob\",\
		\"type\": \"base64Binary\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SampledData\",\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"SampledData.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SampledData.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"SampledData.origin\",\
		\"type\": \"Quantity\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SampledData.period\",\
		\"type\": \"decimal\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SampledData.factor\",\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SampledData.lowerLimit\",\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SampledData.upperLimit\",\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SampledData.dimensions\",\
		\"type\": \"positiveInt\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SampledData.data\",\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Quantity\",\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Quantity.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Quantity.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Quantity.value\",\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Quantity.comparator\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Quantity.unit\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Quantity.system\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Quantity.code\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Period\",\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Period.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Period.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Period.start\",\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Period.end\",\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Attachment\",\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Attachment.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Attachment.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Attachment.contentType\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Attachment.language\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Attachment.data\",\
		\"type\": \"base64Binary\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Attachment.url\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Attachment.size\",\
		\"type\": \"unsignedInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Attachment.hash\",\
		\"type\": \"base64Binary\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Attachment.title\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Attachment.creation\",\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Ratio\",\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Ratio.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Ratio.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Ratio.numerator\",\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Ratio.denominator\",\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Range\",\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Range.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Range.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Range.low\",\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Range.high\",\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Annotation\",\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Annotation.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Annotation.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Annotation.authorReference\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"Annotation.authorReference\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"Annotation.authorReference\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"Annotation.authorString\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"string\"\
	},\
	{\
		\"path\": \"Annotation.time\",\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Annotation.text\",\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeableConcept\",\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CodeableConcept.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeableConcept.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CodeableConcept.coding\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CodeableConcept.text\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Extension\",\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Extension.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Extension.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Extension.url\",\
		\"type\": \"uri\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Extension.valueBoolean\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"path\": \"Extension.valueInteger\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"integer\"\
	},\
	{\
		\"path\": \"Extension.valueDecimal\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"path\": \"Extension.valueBase64Binary\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"base64Binary\"\
	},\
	{\
		\"path\": \"Extension.valueInstant\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"instant\"\
	},\
	{\
		\"path\": \"Extension.valueString\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"string\"\
	},\
	{\
		\"path\": \"Extension.valueUri\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"uri\"\
	},\
	{\
		\"path\": \"Extension.valueDate\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"date\"\
	},\
	{\
		\"path\": \"Extension.valueDateTime\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"path\": \"Extension.valueTime\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"time\"\
	},\
	{\
		\"path\": \"Extension.valueCode\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"code\"\
	},\
	{\
		\"path\": \"Extension.valueOid\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"oid\"\
	},\
	{\
		\"path\": \"Extension.valueId\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"id\"\
	},\
	{\
		\"path\": \"Extension.valueUnsignedInt\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"unsignedInt\"\
	},\
	{\
		\"path\": \"Extension.valuePositiveInt\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"path\": \"Extension.valueMarkdown\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"path\": \"Extension.valueAnnotation\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Annotation\"\
	},\
	{\
		\"path\": \"Extension.valueAttachment\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Attachment\"\
	},\
	{\
		\"path\": \"Extension.valueIdentifier\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"path\": \"Extension.valueCodeableConcept\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"path\": \"Extension.valueCoding\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"path\": \"Extension.valueQuantity\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"path\": \"Extension.valueRange\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Range\"\
	},\
	{\
		\"path\": \"Extension.valuePeriod\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Period\"\
	},\
	{\
		\"path\": \"Extension.valueRatio\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Ratio\"\
	},\
	{\
		\"path\": \"Extension.valueSampledData\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"SampledData\"\
	},\
	{\
		\"path\": \"Extension.valueSignature\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Signature\"\
	},\
	{\
		\"path\": \"Extension.valueHumanName\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"HumanName\"\
	},\
	{\
		\"path\": \"Extension.valueAddress\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Address\"\
	},\
	{\
		\"path\": \"Extension.valueContactPoint\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"ContactPoint\"\
	},\
	{\
		\"path\": \"Extension.valueTiming\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Timing\"\
	},\
	{\
		\"path\": \"Extension.valueReference\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"Extension.valueMeta\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"path\": \"BackboneElement\",\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"BackboneElement.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"BackboneElement.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"BackboneElement.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Narrative\",\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Narrative.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Narrative.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Narrative.status\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Narrative.div\",\
		\"type\": \"xhtml\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Element\",\
		\"derivations\": [\
			\"ActionDefinition\",\
			\"Address\",\
			\"Annotation\",\
			\"Attachment\",\
			\"BackboneElement\",\
			\"CodeableConcept\",\
			\"Coding\",\
			\"ContactPoint\",\
			\"DataRequirement\",\
			\"ElementDefinition\",\
			\"Extension\",\
			\"HumanName\",\
			\"Identifier\",\
			\"Meta\",\
			\"ModuleMetadata\",\
			\"Narrative\",\
			\"ParameterDefinition\",\
			\"Period\",\
			\"Quantity\",\
			\"Range\",\
			\"Ratio\",\
			\"Reference\",\
			\"SampledData\",\
			\"Signature\",\
			\"Timing\",\
			\"TriggerDefinition\",\
			\"base64Binary\",\
			\"boolean\",\
			\"date\",\
			\"dateTime\",\
			\"decimal\",\
			\"instant\",\
			\"integer\",\
			\"string\",\
			\"time\",\
			\"uri\"\
		],\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Element.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Element.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"HumanName\",\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"HumanName.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"HumanName.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"HumanName.use\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"HumanName.text\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"HumanName.family\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"HumanName.given\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"HumanName.prefix\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"HumanName.suffix\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"HumanName.period\",\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ContactPoint\",\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ContactPoint.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ContactPoint.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ContactPoint.system\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ContactPoint.value\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ContactPoint.use\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ContactPoint.rank\",\
		\"type\": \"positiveInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ContactPoint.period\",\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Meta\",\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Meta.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Meta.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Meta.versionId\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Meta.lastUpdated\",\
		\"type\": \"instant\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Meta.profile\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Meta.security\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Meta.tag\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Address\",\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Address.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Address.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Address.use\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Address.type\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Address.text\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Address.line\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Address.city\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Address.district\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Address.state\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Address.postalCode\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Address.country\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Address.period\",\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TriggerDefinition\",\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TriggerDefinition.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TriggerDefinition.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TriggerDefinition.type\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TriggerDefinition.eventName\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TriggerDefinition.eventTimingTiming\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Timing\"\
	},\
	{\
		\"path\": \"TriggerDefinition.eventTimingReference\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"TriggerDefinition.eventTimingDate\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"date\"\
	},\
	{\
		\"path\": \"TriggerDefinition.eventTimingDateTime\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"path\": \"TriggerDefinition.eventData\",\
		\"type\": \"DataRequirement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleMetadata\",\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ModuleMetadata.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleMetadata.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ModuleMetadata.url\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleMetadata.identifier\",\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ModuleMetadata.version\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleMetadata.name\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleMetadata.title\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleMetadata.type\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleMetadata.status\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleMetadata.experimental\",\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleMetadata.description\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleMetadata.purpose\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleMetadata.usage\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleMetadata.publicationDate\",\
		\"type\": \"date\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleMetadata.lastReviewDate\",\
		\"type\": \"date\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleMetadata.effectivePeriod\",\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleMetadata.coverage\",\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ModuleMetadata.coverage.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleMetadata.coverage.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ModuleMetadata.coverage.focus\",\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleMetadata.coverage.value\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleMetadata.topic\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ModuleMetadata.contributor\",\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ModuleMetadata.contributor.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleMetadata.contributor.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ModuleMetadata.contributor.type\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleMetadata.contributor.name\",\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleMetadata.contributor.contact\",\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ModuleMetadata.contributor.contact.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleMetadata.contributor.contact.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ModuleMetadata.contributor.contact.name\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleMetadata.contributor.contact.telecom\",\
		\"type\": \"ContactPoint\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ModuleMetadata.publisher\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleMetadata.contact\",\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ModuleMetadata.contact.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleMetadata.contact.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ModuleMetadata.contact.name\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleMetadata.contact.telecom\",\
		\"type\": \"ContactPoint\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ModuleMetadata.copyright\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleMetadata.relatedResource\",\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ModuleMetadata.relatedResource.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleMetadata.relatedResource.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ModuleMetadata.relatedResource.type\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleMetadata.relatedResource.document\",\
		\"type\": \"Attachment\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleMetadata.relatedResource.resource\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Timing\",\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Timing.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Timing.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Timing.event\",\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Timing.repeat\",\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Timing.repeat.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Timing.repeat.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Timing.repeat.boundsQuantity\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"path\": \"Timing.repeat.boundsRange\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Range\"\
	},\
	{\
		\"path\": \"Timing.repeat.boundsPeriod\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Period\"\
	},\
	{\
		\"path\": \"Timing.repeat.count\",\
		\"type\": \"integer\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Timing.repeat.countMax\",\
		\"type\": \"integer\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Timing.repeat.duration\",\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Timing.repeat.durationMax\",\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Timing.repeat.durationUnit\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Timing.repeat.frequency\",\
		\"type\": \"integer\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Timing.repeat.frequencyMax\",\
		\"type\": \"integer\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Timing.repeat.period\",\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Timing.repeat.periodMax\",\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Timing.repeat.periodUnit\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Timing.repeat.when\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Timing.repeat.offset\",\
		\"type\": \"unsignedInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Timing.code\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition\",\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ElementDefinition.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ElementDefinition.path\",\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.representation\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ElementDefinition.name\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.label\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.code\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ElementDefinition.slicing\",\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.slicing.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.slicing.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ElementDefinition.slicing.discriminator\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ElementDefinition.slicing.description\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.slicing.ordered\",\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.slicing.rules\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.short\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.definition\",\
		\"type\": \"markdown\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.comments\",\
		\"type\": \"markdown\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.requirements\",\
		\"type\": \"markdown\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.alias\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ElementDefinition.min\",\
		\"type\": \"integer\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.max\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.base\",\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.base.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.base.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ElementDefinition.base.path\",\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.base.min\",\
		\"type\": \"integer\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.base.max\",\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.contentReference\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.type\",\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ElementDefinition.type.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.type.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ElementDefinition.type.code\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.type.profile\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ElementDefinition.type.aggregation\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ElementDefinition.type.versioning\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.defaultValueBoolean\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"path\": \"ElementDefinition.defaultValueInteger\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"integer\"\
	},\
	{\
		\"path\": \"ElementDefinition.defaultValueDecimal\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"path\": \"ElementDefinition.defaultValueBase64Binary\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"base64Binary\"\
	},\
	{\
		\"path\": \"ElementDefinition.defaultValueInstant\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"instant\"\
	},\
	{\
		\"path\": \"ElementDefinition.defaultValueString\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"string\"\
	},\
	{\
		\"path\": \"ElementDefinition.defaultValueUri\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"uri\"\
	},\
	{\
		\"path\": \"ElementDefinition.defaultValueDate\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"date\"\
	},\
	{\
		\"path\": \"ElementDefinition.defaultValueDateTime\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"path\": \"ElementDefinition.defaultValueTime\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"time\"\
	},\
	{\
		\"path\": \"ElementDefinition.defaultValueCode\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"code\"\
	},\
	{\
		\"path\": \"ElementDefinition.defaultValueOid\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"oid\"\
	},\
	{\
		\"path\": \"ElementDefinition.defaultValueId\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"id\"\
	},\
	{\
		\"path\": \"ElementDefinition.defaultValueUnsignedInt\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"unsignedInt\"\
	},\
	{\
		\"path\": \"ElementDefinition.defaultValuePositiveInt\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"path\": \"ElementDefinition.defaultValueMarkdown\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"path\": \"ElementDefinition.defaultValueAnnotation\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Annotation\"\
	},\
	{\
		\"path\": \"ElementDefinition.defaultValueAttachment\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Attachment\"\
	},\
	{\
		\"path\": \"ElementDefinition.defaultValueIdentifier\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"path\": \"ElementDefinition.defaultValueCodeableConcept\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"path\": \"ElementDefinition.defaultValueCoding\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"path\": \"ElementDefinition.defaultValueQuantity\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"path\": \"ElementDefinition.defaultValueRange\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Range\"\
	},\
	{\
		\"path\": \"ElementDefinition.defaultValuePeriod\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Period\"\
	},\
	{\
		\"path\": \"ElementDefinition.defaultValueRatio\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Ratio\"\
	},\
	{\
		\"path\": \"ElementDefinition.defaultValueSampledData\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"SampledData\"\
	},\
	{\
		\"path\": \"ElementDefinition.defaultValueSignature\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Signature\"\
	},\
	{\
		\"path\": \"ElementDefinition.defaultValueHumanName\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"HumanName\"\
	},\
	{\
		\"path\": \"ElementDefinition.defaultValueAddress\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Address\"\
	},\
	{\
		\"path\": \"ElementDefinition.defaultValueContactPoint\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"ContactPoint\"\
	},\
	{\
		\"path\": \"ElementDefinition.defaultValueTiming\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Timing\"\
	},\
	{\
		\"path\": \"ElementDefinition.defaultValueReference\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"ElementDefinition.defaultValueMeta\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"path\": \"ElementDefinition.meaningWhenMissing\",\
		\"type\": \"markdown\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.fixedBoolean\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"path\": \"ElementDefinition.fixedInteger\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"integer\"\
	},\
	{\
		\"path\": \"ElementDefinition.fixedDecimal\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"path\": \"ElementDefinition.fixedBase64Binary\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"base64Binary\"\
	},\
	{\
		\"path\": \"ElementDefinition.fixedInstant\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"instant\"\
	},\
	{\
		\"path\": \"ElementDefinition.fixedString\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"string\"\
	},\
	{\
		\"path\": \"ElementDefinition.fixedUri\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"uri\"\
	},\
	{\
		\"path\": \"ElementDefinition.fixedDate\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"date\"\
	},\
	{\
		\"path\": \"ElementDefinition.fixedDateTime\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"path\": \"ElementDefinition.fixedTime\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"time\"\
	},\
	{\
		\"path\": \"ElementDefinition.fixedCode\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"code\"\
	},\
	{\
		\"path\": \"ElementDefinition.fixedOid\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"oid\"\
	},\
	{\
		\"path\": \"ElementDefinition.fixedId\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"id\"\
	},\
	{\
		\"path\": \"ElementDefinition.fixedUnsignedInt\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"unsignedInt\"\
	},\
	{\
		\"path\": \"ElementDefinition.fixedPositiveInt\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"path\": \"ElementDefinition.fixedMarkdown\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"path\": \"ElementDefinition.fixedAnnotation\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Annotation\"\
	},\
	{\
		\"path\": \"ElementDefinition.fixedAttachment\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Attachment\"\
	},\
	{\
		\"path\": \"ElementDefinition.fixedIdentifier\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"path\": \"ElementDefinition.fixedCodeableConcept\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"path\": \"ElementDefinition.fixedCoding\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"path\": \"ElementDefinition.fixedQuantity\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"path\": \"ElementDefinition.fixedRange\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Range\"\
	},\
	{\
		\"path\": \"ElementDefinition.fixedPeriod\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Period\"\
	},\
	{\
		\"path\": \"ElementDefinition.fixedRatio\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Ratio\"\
	},\
	{\
		\"path\": \"ElementDefinition.fixedSampledData\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"SampledData\"\
	},\
	{\
		\"path\": \"ElementDefinition.fixedSignature\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Signature\"\
	},\
	{\
		\"path\": \"ElementDefinition.fixedHumanName\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"HumanName\"\
	},\
	{\
		\"path\": \"ElementDefinition.fixedAddress\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Address\"\
	},\
	{\
		\"path\": \"ElementDefinition.fixedContactPoint\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"ContactPoint\"\
	},\
	{\
		\"path\": \"ElementDefinition.fixedTiming\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Timing\"\
	},\
	{\
		\"path\": \"ElementDefinition.fixedReference\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"ElementDefinition.fixedMeta\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"path\": \"ElementDefinition.patternBoolean\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"path\": \"ElementDefinition.patternInteger\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"integer\"\
	},\
	{\
		\"path\": \"ElementDefinition.patternDecimal\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"path\": \"ElementDefinition.patternBase64Binary\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"base64Binary\"\
	},\
	{\
		\"path\": \"ElementDefinition.patternInstant\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"instant\"\
	},\
	{\
		\"path\": \"ElementDefinition.patternString\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"string\"\
	},\
	{\
		\"path\": \"ElementDefinition.patternUri\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"uri\"\
	},\
	{\
		\"path\": \"ElementDefinition.patternDate\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"date\"\
	},\
	{\
		\"path\": \"ElementDefinition.patternDateTime\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"path\": \"ElementDefinition.patternTime\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"time\"\
	},\
	{\
		\"path\": \"ElementDefinition.patternCode\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"code\"\
	},\
	{\
		\"path\": \"ElementDefinition.patternOid\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"oid\"\
	},\
	{\
		\"path\": \"ElementDefinition.patternId\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"id\"\
	},\
	{\
		\"path\": \"ElementDefinition.patternUnsignedInt\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"unsignedInt\"\
	},\
	{\
		\"path\": \"ElementDefinition.patternPositiveInt\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"path\": \"ElementDefinition.patternMarkdown\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"path\": \"ElementDefinition.patternAnnotation\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Annotation\"\
	},\
	{\
		\"path\": \"ElementDefinition.patternAttachment\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Attachment\"\
	},\
	{\
		\"path\": \"ElementDefinition.patternIdentifier\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"path\": \"ElementDefinition.patternCodeableConcept\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"path\": \"ElementDefinition.patternCoding\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"path\": \"ElementDefinition.patternQuantity\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"path\": \"ElementDefinition.patternRange\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Range\"\
	},\
	{\
		\"path\": \"ElementDefinition.patternPeriod\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Period\"\
	},\
	{\
		\"path\": \"ElementDefinition.patternRatio\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Ratio\"\
	},\
	{\
		\"path\": \"ElementDefinition.patternSampledData\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"SampledData\"\
	},\
	{\
		\"path\": \"ElementDefinition.patternSignature\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Signature\"\
	},\
	{\
		\"path\": \"ElementDefinition.patternHumanName\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"HumanName\"\
	},\
	{\
		\"path\": \"ElementDefinition.patternAddress\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Address\"\
	},\
	{\
		\"path\": \"ElementDefinition.patternContactPoint\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"ContactPoint\"\
	},\
	{\
		\"path\": \"ElementDefinition.patternTiming\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Timing\"\
	},\
	{\
		\"path\": \"ElementDefinition.patternReference\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"ElementDefinition.patternMeta\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"path\": \"ElementDefinition.exampleBoolean\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"path\": \"ElementDefinition.exampleInteger\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"integer\"\
	},\
	{\
		\"path\": \"ElementDefinition.exampleDecimal\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"path\": \"ElementDefinition.exampleBase64Binary\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"base64Binary\"\
	},\
	{\
		\"path\": \"ElementDefinition.exampleInstant\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"instant\"\
	},\
	{\
		\"path\": \"ElementDefinition.exampleString\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"string\"\
	},\
	{\
		\"path\": \"ElementDefinition.exampleUri\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"uri\"\
	},\
	{\
		\"path\": \"ElementDefinition.exampleDate\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"date\"\
	},\
	{\
		\"path\": \"ElementDefinition.exampleDateTime\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"path\": \"ElementDefinition.exampleTime\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"time\"\
	},\
	{\
		\"path\": \"ElementDefinition.exampleCode\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"code\"\
	},\
	{\
		\"path\": \"ElementDefinition.exampleOid\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"oid\"\
	},\
	{\
		\"path\": \"ElementDefinition.exampleId\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"id\"\
	},\
	{\
		\"path\": \"ElementDefinition.exampleUnsignedInt\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"unsignedInt\"\
	},\
	{\
		\"path\": \"ElementDefinition.examplePositiveInt\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"path\": \"ElementDefinition.exampleMarkdown\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"path\": \"ElementDefinition.exampleAnnotation\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Annotation\"\
	},\
	{\
		\"path\": \"ElementDefinition.exampleAttachment\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Attachment\"\
	},\
	{\
		\"path\": \"ElementDefinition.exampleIdentifier\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"path\": \"ElementDefinition.exampleCodeableConcept\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"path\": \"ElementDefinition.exampleCoding\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"path\": \"ElementDefinition.exampleQuantity\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"path\": \"ElementDefinition.exampleRange\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Range\"\
	},\
	{\
		\"path\": \"ElementDefinition.examplePeriod\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Period\"\
	},\
	{\
		\"path\": \"ElementDefinition.exampleRatio\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Ratio\"\
	},\
	{\
		\"path\": \"ElementDefinition.exampleSampledData\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"SampledData\"\
	},\
	{\
		\"path\": \"ElementDefinition.exampleSignature\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Signature\"\
	},\
	{\
		\"path\": \"ElementDefinition.exampleHumanName\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"HumanName\"\
	},\
	{\
		\"path\": \"ElementDefinition.exampleAddress\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Address\"\
	},\
	{\
		\"path\": \"ElementDefinition.exampleContactPoint\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"ContactPoint\"\
	},\
	{\
		\"path\": \"ElementDefinition.exampleTiming\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Timing\"\
	},\
	{\
		\"path\": \"ElementDefinition.exampleReference\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"ElementDefinition.exampleMeta\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"path\": \"ElementDefinition.minValueBoolean\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"path\": \"ElementDefinition.minValueInteger\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"integer\"\
	},\
	{\
		\"path\": \"ElementDefinition.minValueDecimal\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"path\": \"ElementDefinition.minValueBase64Binary\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"base64Binary\"\
	},\
	{\
		\"path\": \"ElementDefinition.minValueInstant\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"instant\"\
	},\
	{\
		\"path\": \"ElementDefinition.minValueString\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"string\"\
	},\
	{\
		\"path\": \"ElementDefinition.minValueUri\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"uri\"\
	},\
	{\
		\"path\": \"ElementDefinition.minValueDate\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"date\"\
	},\
	{\
		\"path\": \"ElementDefinition.minValueDateTime\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"path\": \"ElementDefinition.minValueTime\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"time\"\
	},\
	{\
		\"path\": \"ElementDefinition.minValueCode\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"code\"\
	},\
	{\
		\"path\": \"ElementDefinition.minValueOid\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"oid\"\
	},\
	{\
		\"path\": \"ElementDefinition.minValueId\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"id\"\
	},\
	{\
		\"path\": \"ElementDefinition.minValueUnsignedInt\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"unsignedInt\"\
	},\
	{\
		\"path\": \"ElementDefinition.minValuePositiveInt\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"path\": \"ElementDefinition.minValueMarkdown\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"path\": \"ElementDefinition.minValueAnnotation\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Annotation\"\
	},\
	{\
		\"path\": \"ElementDefinition.minValueAttachment\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Attachment\"\
	},\
	{\
		\"path\": \"ElementDefinition.minValueIdentifier\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"path\": \"ElementDefinition.minValueCodeableConcept\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"path\": \"ElementDefinition.minValueCoding\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"path\": \"ElementDefinition.minValueQuantity\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"path\": \"ElementDefinition.minValueRange\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Range\"\
	},\
	{\
		\"path\": \"ElementDefinition.minValuePeriod\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Period\"\
	},\
	{\
		\"path\": \"ElementDefinition.minValueRatio\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Ratio\"\
	},\
	{\
		\"path\": \"ElementDefinition.minValueSampledData\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"SampledData\"\
	},\
	{\
		\"path\": \"ElementDefinition.minValueSignature\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Signature\"\
	},\
	{\
		\"path\": \"ElementDefinition.minValueHumanName\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"HumanName\"\
	},\
	{\
		\"path\": \"ElementDefinition.minValueAddress\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Address\"\
	},\
	{\
		\"path\": \"ElementDefinition.minValueContactPoint\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"ContactPoint\"\
	},\
	{\
		\"path\": \"ElementDefinition.minValueTiming\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Timing\"\
	},\
	{\
		\"path\": \"ElementDefinition.minValueReference\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"ElementDefinition.minValueMeta\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"path\": \"ElementDefinition.maxValueBoolean\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"path\": \"ElementDefinition.maxValueInteger\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"integer\"\
	},\
	{\
		\"path\": \"ElementDefinition.maxValueDecimal\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"path\": \"ElementDefinition.maxValueBase64Binary\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"base64Binary\"\
	},\
	{\
		\"path\": \"ElementDefinition.maxValueInstant\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"instant\"\
	},\
	{\
		\"path\": \"ElementDefinition.maxValueString\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"string\"\
	},\
	{\
		\"path\": \"ElementDefinition.maxValueUri\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"uri\"\
	},\
	{\
		\"path\": \"ElementDefinition.maxValueDate\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"date\"\
	},\
	{\
		\"path\": \"ElementDefinition.maxValueDateTime\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"path\": \"ElementDefinition.maxValueTime\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"time\"\
	},\
	{\
		\"path\": \"ElementDefinition.maxValueCode\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"code\"\
	},\
	{\
		\"path\": \"ElementDefinition.maxValueOid\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"oid\"\
	},\
	{\
		\"path\": \"ElementDefinition.maxValueId\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"id\"\
	},\
	{\
		\"path\": \"ElementDefinition.maxValueUnsignedInt\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"unsignedInt\"\
	},\
	{\
		\"path\": \"ElementDefinition.maxValuePositiveInt\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"path\": \"ElementDefinition.maxValueMarkdown\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"path\": \"ElementDefinition.maxValueAnnotation\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Annotation\"\
	},\
	{\
		\"path\": \"ElementDefinition.maxValueAttachment\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Attachment\"\
	},\
	{\
		\"path\": \"ElementDefinition.maxValueIdentifier\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"path\": \"ElementDefinition.maxValueCodeableConcept\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"path\": \"ElementDefinition.maxValueCoding\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"path\": \"ElementDefinition.maxValueQuantity\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"path\": \"ElementDefinition.maxValueRange\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Range\"\
	},\
	{\
		\"path\": \"ElementDefinition.maxValuePeriod\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Period\"\
	},\
	{\
		\"path\": \"ElementDefinition.maxValueRatio\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Ratio\"\
	},\
	{\
		\"path\": \"ElementDefinition.maxValueSampledData\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"SampledData\"\
	},\
	{\
		\"path\": \"ElementDefinition.maxValueSignature\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Signature\"\
	},\
	{\
		\"path\": \"ElementDefinition.maxValueHumanName\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"HumanName\"\
	},\
	{\
		\"path\": \"ElementDefinition.maxValueAddress\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Address\"\
	},\
	{\
		\"path\": \"ElementDefinition.maxValueContactPoint\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"ContactPoint\"\
	},\
	{\
		\"path\": \"ElementDefinition.maxValueTiming\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Timing\"\
	},\
	{\
		\"path\": \"ElementDefinition.maxValueReference\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"ElementDefinition.maxValueMeta\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"path\": \"ElementDefinition.maxLength\",\
		\"type\": \"integer\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.condition\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ElementDefinition.constraint\",\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ElementDefinition.constraint.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.constraint.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ElementDefinition.constraint.key\",\
		\"type\": \"id\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.constraint.requirements\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.constraint.severity\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.constraint.human\",\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.constraint.expression\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.constraint.xpath\",\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.mustSupport\",\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.isModifier\",\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.isSummary\",\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.binding\",\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.binding.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.binding.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ElementDefinition.binding.strength\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.binding.description\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.binding.valueSetUri\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"uri\"\
	},\
	{\
		\"path\": \"ElementDefinition.binding.valueSetReference\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"ElementDefinition.mapping\",\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ElementDefinition.mapping.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.mapping.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ElementDefinition.mapping.identity\",\
		\"type\": \"id\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.mapping.language\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ElementDefinition.mapping.map\",\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DataRequirement\",\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DataRequirement.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DataRequirement.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DataRequirement.type\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DataRequirement.profile\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DataRequirement.mustSupport\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DataRequirement.codeFilter\",\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DataRequirement.codeFilter.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DataRequirement.codeFilter.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DataRequirement.codeFilter.path\",\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DataRequirement.codeFilter.valueSetString\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"string\"\
	},\
	{\
		\"path\": \"DataRequirement.codeFilter.valueSetReference\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"DataRequirement.codeFilter.valueCode\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DataRequirement.codeFilter.valueCoding\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DataRequirement.codeFilter.valueCodeableConcept\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DataRequirement.dateFilter\",\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DataRequirement.dateFilter.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DataRequirement.dateFilter.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DataRequirement.dateFilter.path\",\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DataRequirement.dateFilter.valueDateTime\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"path\": \"DataRequirement.dateFilter.valuePeriod\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Period\"\
	},\
	{\
		\"path\": \"ActionDefinition\",\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ActionDefinition.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ActionDefinition.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ActionDefinition.actionIdentifier\",\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ActionDefinition.label\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ActionDefinition.title\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ActionDefinition.description\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ActionDefinition.textEquivalent\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ActionDefinition.concept\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ActionDefinition.supportingEvidence\",\
		\"type\": \"Attachment\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ActionDefinition.documentation\",\
		\"type\": \"Attachment\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ActionDefinition.relatedAction\",\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ActionDefinition.relatedAction.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ActionDefinition.relatedAction.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ActionDefinition.relatedAction.actionIdentifier\",\
		\"type\": \"Identifier\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ActionDefinition.relatedAction.relationship\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ActionDefinition.relatedAction.offsetQuantity\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"path\": \"ActionDefinition.relatedAction.offsetRange\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Range\"\
	},\
	{\
		\"path\": \"ActionDefinition.relatedAction.anchor\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ActionDefinition.participantType\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ActionDefinition.type\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ActionDefinition.behavior\",\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ActionDefinition.behavior.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ActionDefinition.behavior.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ActionDefinition.behavior.type\",\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ActionDefinition.behavior.value\",\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ActionDefinition.resource\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ActionDefinition.customization\",\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ActionDefinition.customization.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ActionDefinition.customization.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ActionDefinition.customization.path\",\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ActionDefinition.customization.expression\",\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ActionDefinition.action\",\
		\"type\": \"ActionDefinition\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ParameterDefinition\",\
		\"type\": \"Element\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ParameterDefinition.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ParameterDefinition.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ParameterDefinition.name\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ParameterDefinition.use\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ParameterDefinition.min\",\
		\"type\": \"integer\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ParameterDefinition.max\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ParameterDefinition.documentation\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ParameterDefinition.type\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ParameterDefinition.profile\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem\",\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CodeSystem.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.meta\",\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.implicitRules\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.language\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.text\",\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.contained\",\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CodeSystem.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CodeSystem.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CodeSystem.url\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.identifier\",\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.version\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.name\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.status\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.experimental\",\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.publisher\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.contact\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CodeSystem.contact.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.contact.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CodeSystem.contact.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CodeSystem.contact.name\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.contact.telecom\",\
		\"type\": \"ContactPoint\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CodeSystem.date\",\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.description\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.useContext\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CodeSystem.requirements\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.copyright\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.caseSensitive\",\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.valueSet\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.compositional\",\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.versionNeeded\",\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.content\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.count\",\
		\"type\": \"unsignedInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.filter\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CodeSystem.filter.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.filter.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CodeSystem.filter.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CodeSystem.filter.code\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.filter.description\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.filter.operator\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CodeSystem.filter.value\",\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.property\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CodeSystem.property.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.property.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CodeSystem.property.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CodeSystem.property.code\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.property.description\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.property.type\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.concept\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CodeSystem.concept.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.concept.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CodeSystem.concept.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CodeSystem.concept.code\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.concept.display\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.concept.definition\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.concept.designation\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CodeSystem.concept.designation.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.concept.designation.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CodeSystem.concept.designation.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CodeSystem.concept.designation.language\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.concept.designation.use\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.concept.designation.value\",\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.concept.property\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CodeSystem.concept.property.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.concept.property.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CodeSystem.concept.property.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CodeSystem.concept.property.code\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CodeSystem.concept.property.valueCode\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"path\": \"CodeSystem.concept.property.valueCoding\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"path\": \"CodeSystem.concept.property.valueString\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"path\": \"CodeSystem.concept.property.valueInteger\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"integer\"\
	},\
	{\
		\"path\": \"CodeSystem.concept.property.valueBoolean\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"path\": \"CodeSystem.concept.property.valueDateTime\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"path\": \"CodeSystem.concept.concept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ValueSet\",\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ValueSet.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.meta\",\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.implicitRules\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.language\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.text\",\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.contained\",\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ValueSet.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ValueSet.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ValueSet.url\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.identifier\",\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.version\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.name\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.status\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.experimental\",\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.publisher\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.contact\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ValueSet.contact.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.contact.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ValueSet.contact.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ValueSet.contact.name\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.contact.telecom\",\
		\"type\": \"ContactPoint\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ValueSet.date\",\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.lockedDate\",\
		\"type\": \"date\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.description\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.useContext\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ValueSet.immutable\",\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.requirements\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.copyright\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.extensible\",\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.compose\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.compose.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.compose.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ValueSet.compose.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ValueSet.compose.import\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ValueSet.compose.include\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ValueSet.compose.include.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.compose.include.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ValueSet.compose.include.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ValueSet.compose.include.system\",\
		\"type\": \"uri\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.compose.include.version\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.compose.include.concept\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ValueSet.compose.include.concept.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.compose.include.concept.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ValueSet.compose.include.concept.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ValueSet.compose.include.concept.code\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.compose.include.concept.display\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.compose.include.concept.designation\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ValueSet.compose.include.concept.designation.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.compose.include.concept.designation.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ValueSet.compose.include.concept.designation.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ValueSet.compose.include.concept.designation.language\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.compose.include.concept.designation.use\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.compose.include.concept.designation.value\",\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.compose.include.filter\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ValueSet.compose.include.filter.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.compose.include.filter.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ValueSet.compose.include.filter.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ValueSet.compose.include.filter.property\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.compose.include.filter.op\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.compose.include.filter.value\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.compose.exclude\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ValueSet.expansion\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.expansion.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.expansion.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ValueSet.expansion.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ValueSet.expansion.identifier\",\
		\"type\": \"uri\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.expansion.timestamp\",\
		\"type\": \"dateTime\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.expansion.total\",\
		\"type\": \"integer\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.expansion.offset\",\
		\"type\": \"integer\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.expansion.parameter\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ValueSet.expansion.parameter.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.expansion.parameter.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ValueSet.expansion.parameter.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ValueSet.expansion.parameter.name\",\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.expansion.parameter.valueString\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"string\"\
	},\
	{\
		\"path\": \"ValueSet.expansion.parameter.valueBoolean\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"path\": \"ValueSet.expansion.parameter.valueInteger\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"integer\"\
	},\
	{\
		\"path\": \"ValueSet.expansion.parameter.valueDecimal\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"path\": \"ValueSet.expansion.parameter.valueUri\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"uri\"\
	},\
	{\
		\"path\": \"ValueSet.expansion.parameter.valueCode\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"code\"\
	},\
	{\
		\"path\": \"ValueSet.expansion.contains\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ValueSet.expansion.contains.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.expansion.contains.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ValueSet.expansion.contains.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ValueSet.expansion.contains.system\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.expansion.contains.abstract\",\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.expansion.contains.version\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.expansion.contains.code\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.expansion.contains.display\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ValueSet.expansion.contains.contains\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DomainResource\",\
		\"derivations\": [\
			\"Account\",\
			\"AllergyIntolerance\",\
			\"Appointment\",\
			\"AppointmentResponse\",\
			\"AuditEvent\",\
			\"Basic\",\
			\"BodySite\",\
			\"CarePlan\",\
			\"CareTeam\",\
			\"Claim\",\
			\"ClaimResponse\",\
			\"ClinicalImpression\",\
			\"CodeSystem\",\
			\"Communication\",\
			\"CommunicationRequest\",\
			\"CompartmentDefinition\",\
			\"Composition\",\
			\"ConceptMap\",\
			\"Condition\",\
			\"Conformance\",\
			\"Contract\",\
			\"Coverage\",\
			\"DataElement\",\
			\"DecisionSupportRule\",\
			\"DecisionSupportServiceModule\",\
			\"DetectedIssue\",\
			\"Device\",\
			\"DeviceComponent\",\
			\"DeviceMetric\",\
			\"DeviceUseRequest\",\
			\"DeviceUseStatement\",\
			\"DiagnosticOrder\",\
			\"DiagnosticReport\",\
			\"DocumentManifest\",\
			\"DocumentReference\",\
			\"EligibilityRequest\",\
			\"EligibilityResponse\",\
			\"Encounter\",\
			\"Endpoint\",\
			\"EnrollmentRequest\",\
			\"EnrollmentResponse\",\
			\"EpisodeOfCare\",\
			\"ExpansionProfile\",\
			\"ExplanationOfBenefit\",\
			\"FamilyMemberHistory\",\
			\"Flag\",\
			\"Goal\",\
			\"Group\",\
			\"GuidanceResponse\",\
			\"HealthcareService\",\
			\"ImagingExcerpt\",\
			\"ImagingObjectSelection\",\
			\"ImagingStudy\",\
			\"Immunization\",\
			\"ImmunizationRecommendation\",\
			\"ImplementationGuide\",\
			\"Library\",\
			\"Linkage\",\
			\"List\",\
			\"Location\",\
			\"Measure\",\
			\"MeasureReport\",\
			\"Media\",\
			\"Medication\",\
			\"MedicationAdministration\",\
			\"MedicationDispense\",\
			\"MedicationOrder\",\
			\"MedicationStatement\",\
			\"MessageHeader\",\
			\"ModuleDefinition\",\
			\"NamingSystem\",\
			\"NutritionOrder\",\
			\"Observation\",\
			\"OperationDefinition\",\
			\"OperationOutcome\",\
			\"Order\",\
			\"OrderResponse\",\
			\"OrderSet\",\
			\"Organization\",\
			\"Patient\",\
			\"PaymentNotice\",\
			\"PaymentReconciliation\",\
			\"Person\",\
			\"Practitioner\",\
			\"PractitionerRole\",\
			\"Procedure\",\
			\"ProcedureRequest\",\
			\"ProcessRequest\",\
			\"ProcessResponse\",\
			\"Protocol\",\
			\"Provenance\",\
			\"Questionnaire\",\
			\"QuestionnaireResponse\",\
			\"ReferralRequest\",\
			\"RelatedPerson\",\
			\"RiskAssessment\",\
			\"Schedule\",\
			\"SearchParameter\",\
			\"Sequence\",\
			\"Slot\",\
			\"Specimen\",\
			\"StructureDefinition\",\
			\"StructureMap\",\
			\"Subscription\",\
			\"Substance\",\
			\"SupplyDelivery\",\
			\"SupplyRequest\",\
			\"Task\",\
			\"TestScript\",\
			\"ValueSet\",\
			\"VisionPrescription\"\
		],\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DomainResource.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DomainResource.meta\",\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DomainResource.implicitRules\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DomainResource.language\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DomainResource.text\",\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DomainResource.contained\",\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DomainResource.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DomainResource.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Parameters\",\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Parameters.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Parameters.meta\",\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Parameters.implicitRules\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Parameters.language\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Parameters.parameter\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Parameters.parameter.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Parameters.parameter.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Parameters.parameter.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Parameters.parameter.name\",\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Parameters.parameter.valueBoolean\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"path\": \"Parameters.parameter.valueInteger\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"integer\"\
	},\
	{\
		\"path\": \"Parameters.parameter.valueDecimal\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"path\": \"Parameters.parameter.valueBase64Binary\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"base64Binary\"\
	},\
	{\
		\"path\": \"Parameters.parameter.valueInstant\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"instant\"\
	},\
	{\
		\"path\": \"Parameters.parameter.valueString\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"string\"\
	},\
	{\
		\"path\": \"Parameters.parameter.valueUri\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"uri\"\
	},\
	{\
		\"path\": \"Parameters.parameter.valueDate\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"date\"\
	},\
	{\
		\"path\": \"Parameters.parameter.valueDateTime\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"path\": \"Parameters.parameter.valueTime\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"time\"\
	},\
	{\
		\"path\": \"Parameters.parameter.valueCode\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"code\"\
	},\
	{\
		\"path\": \"Parameters.parameter.valueOid\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"oid\"\
	},\
	{\
		\"path\": \"Parameters.parameter.valueId\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"id\"\
	},\
	{\
		\"path\": \"Parameters.parameter.valueUnsignedInt\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"unsignedInt\"\
	},\
	{\
		\"path\": \"Parameters.parameter.valuePositiveInt\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"path\": \"Parameters.parameter.valueMarkdown\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"path\": \"Parameters.parameter.valueAnnotation\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Annotation\"\
	},\
	{\
		\"path\": \"Parameters.parameter.valueAttachment\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Attachment\"\
	},\
	{\
		\"path\": \"Parameters.parameter.valueIdentifier\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"path\": \"Parameters.parameter.valueCodeableConcept\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"path\": \"Parameters.parameter.valueCoding\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"path\": \"Parameters.parameter.valueQuantity\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"path\": \"Parameters.parameter.valueRange\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Range\"\
	},\
	{\
		\"path\": \"Parameters.parameter.valuePeriod\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Period\"\
	},\
	{\
		\"path\": \"Parameters.parameter.valueRatio\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Ratio\"\
	},\
	{\
		\"path\": \"Parameters.parameter.valueSampledData\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"SampledData\"\
	},\
	{\
		\"path\": \"Parameters.parameter.valueSignature\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Signature\"\
	},\
	{\
		\"path\": \"Parameters.parameter.valueHumanName\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"HumanName\"\
	},\
	{\
		\"path\": \"Parameters.parameter.valueAddress\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Address\"\
	},\
	{\
		\"path\": \"Parameters.parameter.valueContactPoint\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"ContactPoint\"\
	},\
	{\
		\"path\": \"Parameters.parameter.valueTiming\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Timing\"\
	},\
	{\
		\"path\": \"Parameters.parameter.valueReference\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"Parameters.parameter.valueMeta\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"path\": \"Parameters.parameter.resource\",\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Parameters.parameter.part\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Resource\",\
		\"derivations\": [\
			\"Binary\",\
			\"Bundle\",\
			\"DomainResource\",\
			\"Parameters\"\
		],\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Resource.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Resource.meta\",\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Resource.implicitRules\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Resource.language\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Account\",\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Account.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Account.meta\",\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Account.implicitRules\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Account.language\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Account.text\",\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Account.contained\",\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Account.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Account.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Account.identifier\",\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Account.name\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Account.type\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Account.status\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Account.activePeriod\",\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Account.currency\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Account.balance\",\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Account.coveragePeriod\",\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Account.subject\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Account.owner\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Account.description\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AllergyIntolerance\",\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"AllergyIntolerance.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AllergyIntolerance.meta\",\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AllergyIntolerance.implicitRules\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AllergyIntolerance.language\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AllergyIntolerance.text\",\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AllergyIntolerance.contained\",\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"AllergyIntolerance.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"AllergyIntolerance.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"AllergyIntolerance.identifier\",\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"AllergyIntolerance.status\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AllergyIntolerance.type\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AllergyIntolerance.category\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AllergyIntolerance.criticality\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AllergyIntolerance.substance\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AllergyIntolerance.patient\",\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AllergyIntolerance.recordedDate\",\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AllergyIntolerance.recorder\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AllergyIntolerance.reporter\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AllergyIntolerance.onset\",\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AllergyIntolerance.lastOccurence\",\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AllergyIntolerance.note\",\
		\"type\": \"Annotation\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"AllergyIntolerance.reaction\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"AllergyIntolerance.reaction.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AllergyIntolerance.reaction.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"AllergyIntolerance.reaction.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"AllergyIntolerance.reaction.substance\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AllergyIntolerance.reaction.certainty\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AllergyIntolerance.reaction.manifestation\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"AllergyIntolerance.reaction.description\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AllergyIntolerance.reaction.onset\",\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AllergyIntolerance.reaction.severity\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AllergyIntolerance.reaction.exposureRoute\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AllergyIntolerance.reaction.note\",\
		\"type\": \"Annotation\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Appointment\",\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Appointment.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Appointment.meta\",\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Appointment.implicitRules\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Appointment.language\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Appointment.text\",\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Appointment.contained\",\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Appointment.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Appointment.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Appointment.identifier\",\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Appointment.status\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Appointment.serviceCategory\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Appointment.serviceType\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Appointment.specialty\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Appointment.appointmentType\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Appointment.reason\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Appointment.priority\",\
		\"type\": \"unsignedInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Appointment.description\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Appointment.start\",\
		\"type\": \"instant\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Appointment.end\",\
		\"type\": \"instant\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Appointment.minutesDuration\",\
		\"type\": \"positiveInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Appointment.slot\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Appointment.created\",\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Appointment.comment\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Appointment.participant\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Appointment.participant.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Appointment.participant.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Appointment.participant.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Appointment.participant.type\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Appointment.participant.actor\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Appointment.participant.required\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Appointment.participant.status\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AppointmentResponse\",\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"AppointmentResponse.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AppointmentResponse.meta\",\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AppointmentResponse.implicitRules\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AppointmentResponse.language\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AppointmentResponse.text\",\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AppointmentResponse.contained\",\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"AppointmentResponse.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"AppointmentResponse.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"AppointmentResponse.identifier\",\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"AppointmentResponse.appointment\",\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AppointmentResponse.start\",\
		\"type\": \"instant\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AppointmentResponse.end\",\
		\"type\": \"instant\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AppointmentResponse.participantType\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"AppointmentResponse.actor\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AppointmentResponse.participantStatus\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AppointmentResponse.comment\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AuditEvent\",\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"AuditEvent.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AuditEvent.meta\",\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AuditEvent.implicitRules\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AuditEvent.language\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AuditEvent.text\",\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AuditEvent.contained\",\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"AuditEvent.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"AuditEvent.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"AuditEvent.type\",\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AuditEvent.subtype\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"AuditEvent.action\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AuditEvent.recorded\",\
		\"type\": \"instant\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AuditEvent.outcome\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AuditEvent.outcomeDesc\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AuditEvent.purposeOfEvent\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"AuditEvent.agent\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"AuditEvent.agent.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AuditEvent.agent.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"AuditEvent.agent.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"AuditEvent.agent.role\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"AuditEvent.agent.reference\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AuditEvent.agent.userId\",\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AuditEvent.agent.altId\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AuditEvent.agent.name\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AuditEvent.agent.requestor\",\
		\"type\": \"boolean\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AuditEvent.agent.location\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AuditEvent.agent.policy\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"AuditEvent.agent.media\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AuditEvent.agent.network\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AuditEvent.agent.network.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AuditEvent.agent.network.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"AuditEvent.agent.network.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"AuditEvent.agent.network.address\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AuditEvent.agent.network.type\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AuditEvent.agent.purposeOfUse\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"AuditEvent.source\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AuditEvent.source.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AuditEvent.source.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"AuditEvent.source.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"AuditEvent.source.site\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AuditEvent.source.identifier\",\
		\"type\": \"Identifier\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AuditEvent.source.type\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"AuditEvent.entity\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"AuditEvent.entity.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AuditEvent.entity.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"AuditEvent.entity.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"AuditEvent.entity.identifier\",\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AuditEvent.entity.reference\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AuditEvent.entity.type\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AuditEvent.entity.role\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AuditEvent.entity.lifecycle\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AuditEvent.entity.securityLabel\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"AuditEvent.entity.name\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AuditEvent.entity.description\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AuditEvent.entity.query\",\
		\"type\": \"base64Binary\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AuditEvent.entity.detail\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"AuditEvent.entity.detail.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AuditEvent.entity.detail.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"AuditEvent.entity.detail.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"AuditEvent.entity.detail.type\",\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"AuditEvent.entity.detail.value\",\
		\"type\": \"base64Binary\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Basic\",\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Basic.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Basic.meta\",\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Basic.implicitRules\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Basic.language\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Basic.text\",\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Basic.contained\",\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Basic.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Basic.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Basic.identifier\",\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Basic.code\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Basic.subject\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Basic.created\",\
		\"type\": \"date\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Basic.author\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Binary\",\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Binary.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Binary.meta\",\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Binary.implicitRules\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Binary.language\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Binary.contentType\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Binary.content\",\
		\"type\": \"base64Binary\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"BodySite\",\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"BodySite.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"BodySite.meta\",\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"BodySite.implicitRules\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"BodySite.language\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"BodySite.text\",\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"BodySite.contained\",\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"BodySite.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"BodySite.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"BodySite.patient\",\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"BodySite.identifier\",\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"BodySite.code\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"BodySite.modifier\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"BodySite.description\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"BodySite.image\",\
		\"type\": \"Attachment\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Bundle\",\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Bundle.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Bundle.meta\",\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Bundle.implicitRules\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Bundle.language\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Bundle.type\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Bundle.total\",\
		\"type\": \"unsignedInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Bundle.link\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Bundle.link.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Bundle.link.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Bundle.link.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Bundle.link.relation\",\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Bundle.link.url\",\
		\"type\": \"uri\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Bundle.entry\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Bundle.entry.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Bundle.entry.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Bundle.entry.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Bundle.entry.link\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Bundle.entry.fullUrl\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Bundle.entry.resource\",\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Bundle.entry.search\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Bundle.entry.search.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Bundle.entry.search.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Bundle.entry.search.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Bundle.entry.search.mode\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Bundle.entry.search.score\",\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Bundle.entry.request\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Bundle.entry.request.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Bundle.entry.request.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Bundle.entry.request.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Bundle.entry.request.method\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Bundle.entry.request.url\",\
		\"type\": \"uri\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Bundle.entry.request.ifNoneMatch\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Bundle.entry.request.ifModifiedSince\",\
		\"type\": \"instant\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Bundle.entry.request.ifMatch\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Bundle.entry.request.ifNoneExist\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Bundle.entry.response\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Bundle.entry.response.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Bundle.entry.response.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Bundle.entry.response.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Bundle.entry.response.status\",\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Bundle.entry.response.location\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Bundle.entry.response.etag\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Bundle.entry.response.lastModified\",\
		\"type\": \"instant\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Bundle.signature\",\
		\"type\": \"Signature\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CarePlan\",\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CarePlan.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CarePlan.meta\",\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CarePlan.implicitRules\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CarePlan.language\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CarePlan.text\",\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CarePlan.contained\",\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CarePlan.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CarePlan.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CarePlan.identifier\",\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CarePlan.subject\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CarePlan.status\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CarePlan.context\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CarePlan.period\",\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CarePlan.author\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CarePlan.modified\",\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CarePlan.category\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CarePlan.description\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CarePlan.addresses\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CarePlan.support\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CarePlan.relatedPlan\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CarePlan.relatedPlan.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CarePlan.relatedPlan.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CarePlan.relatedPlan.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CarePlan.relatedPlan.code\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CarePlan.relatedPlan.plan\",\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CarePlan.participant\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CarePlan.participant.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CarePlan.participant.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CarePlan.participant.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CarePlan.participant.role\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CarePlan.participant.member\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CarePlan.goal\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CarePlan.activity\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CarePlan.activity.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CarePlan.activity.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CarePlan.activity.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CarePlan.activity.actionResulting\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CarePlan.activity.progress\",\
		\"type\": \"Annotation\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CarePlan.activity.reference\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CarePlan.activity.detail\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CarePlan.activity.detail.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CarePlan.activity.detail.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CarePlan.activity.detail.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CarePlan.activity.detail.category\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CarePlan.activity.detail.code\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CarePlan.activity.detail.reasonCode\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CarePlan.activity.detail.reasonReference\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CarePlan.activity.detail.goal\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CarePlan.activity.detail.status\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CarePlan.activity.detail.statusReason\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CarePlan.activity.detail.prohibited\",\
		\"type\": \"boolean\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CarePlan.activity.detail.scheduledTiming\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Timing\"\
	},\
	{\
		\"path\": \"CarePlan.activity.detail.scheduledPeriod\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Period\"\
	},\
	{\
		\"path\": \"CarePlan.activity.detail.scheduledString\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"string\"\
	},\
	{\
		\"path\": \"CarePlan.activity.detail.location\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CarePlan.activity.detail.performer\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CarePlan.activity.detail.productCodeableConcept\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"path\": \"CarePlan.activity.detail.productReference\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"CarePlan.activity.detail.productReference\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"CarePlan.activity.detail.dailyAmount\",\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CarePlan.activity.detail.quantity\",\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CarePlan.activity.detail.description\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CarePlan.note\",\
		\"type\": \"Annotation\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CareTeam\",\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CareTeam.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CareTeam.meta\",\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CareTeam.implicitRules\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CareTeam.language\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CareTeam.text\",\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CareTeam.contained\",\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CareTeam.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CareTeam.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CareTeam.identifier\",\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CareTeam.status\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CareTeam.type\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CareTeam.name\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CareTeam.subject\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CareTeam.period\",\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CareTeam.participant\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CareTeam.participant.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CareTeam.participant.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CareTeam.participant.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CareTeam.participant.role\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CareTeam.participant.member\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CareTeam.participant.period\",\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CareTeam.managingOrganization\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim\",\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.meta\",\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.implicitRules\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.language\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.text\",\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.contained\",\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.type\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.subType\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.identifier\",\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.ruleset\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.originalRuleset\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.created\",\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.billablePeriod\",\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.targetIdentifier\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"path\": \"Claim.targetReference\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"Claim.providerIdentifier\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"path\": \"Claim.providerReference\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"Claim.organizationIdentifier\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"path\": \"Claim.organizationReference\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"Claim.use\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.priority\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.fundsReserve\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.entererIdentifier\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"path\": \"Claim.entererReference\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"Claim.facilityIdentifier\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"path\": \"Claim.facilityReference\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"Claim.related\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.related.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.related.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.related.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.related.claimIdentifier\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"path\": \"Claim.related.claimReference\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"Claim.related.relationship\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.related.reference\",\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.prescriptionIdentifier\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"path\": \"Claim.prescriptionReference\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"Claim.prescriptionReference\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"Claim.originalPrescriptionIdentifier\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"path\": \"Claim.originalPrescriptionReference\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"Claim.payee\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.payee.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.payee.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.payee.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.payee.type\",\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.payee.partyIdentifier\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"path\": \"Claim.payee.partyReference\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"Claim.payee.partyReference\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"Claim.payee.partyReference\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"Claim.payee.partyReference\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"Claim.referralIdentifier\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"path\": \"Claim.referralReference\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"Claim.occurrenceCode\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.occurenceSpanCode\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.valueCode\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.diagnosis\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.diagnosis.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.diagnosis.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.diagnosis.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.diagnosis.sequence\",\
		\"type\": \"positiveInt\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.diagnosis.diagnosis\",\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.procedure\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.procedure.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.procedure.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.procedure.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.procedure.sequence\",\
		\"type\": \"positiveInt\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.procedure.date\",\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.procedure.procedureCoding\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"path\": \"Claim.procedure.procedureReference\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"Claim.specialCondition\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.patientIdentifier\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"path\": \"Claim.patientReference\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"Claim.coverage\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.coverage.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.coverage.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.coverage.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.coverage.sequence\",\
		\"type\": \"positiveInt\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.coverage.focal\",\
		\"type\": \"boolean\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.coverage.coverageIdentifier\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"path\": \"Claim.coverage.coverageReference\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"Claim.coverage.businessArrangement\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.coverage.preAuthRef\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.coverage.claimResponse\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.coverage.originalRuleset\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.accidentDate\",\
		\"type\": \"date\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.accidentType\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.accidentLocationAddress\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Address\"\
	},\
	{\
		\"path\": \"Claim.accidentLocationReference\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"Claim.interventionException\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.onset\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.onset.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.onset.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.onset.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.onset.timeDate\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"date\"\
	},\
	{\
		\"path\": \"Claim.onset.timePeriod\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Period\"\
	},\
	{\
		\"path\": \"Claim.onset.type\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.employmentImpacted\",\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.hospitalization\",\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.item.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.item.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.item.sequence\",\
		\"type\": \"positiveInt\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item.type\",\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item.providerIdentifier\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"path\": \"Claim.item.providerReference\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"Claim.item.supervisorIdentifier\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"path\": \"Claim.item.supervisorReference\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"Claim.item.providerQualification\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item.diagnosisLinkId\",\
		\"type\": \"positiveInt\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.item.service\",\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item.serviceModifier\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.item.modifier\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.item.programCode\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.item.servicedDate\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"date\"\
	},\
	{\
		\"path\": \"Claim.item.servicedPeriod\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Period\"\
	},\
	{\
		\"path\": \"Claim.item.place\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item.quantity\",\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item.unitPrice\",\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item.factor\",\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item.points\",\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item.net\",\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item.udi\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.item.bodySite\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item.subSite\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.item.detail\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.item.detail.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item.detail.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.item.detail.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.item.detail.sequence\",\
		\"type\": \"positiveInt\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item.detail.type\",\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item.detail.service\",\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item.detail.programCode\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.item.detail.quantity\",\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item.detail.unitPrice\",\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item.detail.factor\",\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item.detail.points\",\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item.detail.net\",\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item.detail.udi\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.item.detail.subDetail\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.item.detail.subDetail.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item.detail.subDetail.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.item.detail.subDetail.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.item.detail.subDetail.sequence\",\
		\"type\": \"positiveInt\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item.detail.subDetail.type\",\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item.detail.subDetail.service\",\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item.detail.subDetail.programCode\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.item.detail.subDetail.quantity\",\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item.detail.subDetail.unitPrice\",\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item.detail.subDetail.factor\",\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item.detail.subDetail.points\",\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item.detail.subDetail.net\",\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item.detail.subDetail.udi\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.item.prosthesis\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item.prosthesis.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item.prosthesis.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.item.prosthesis.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.item.prosthesis.initial\",\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item.prosthesis.priorDate\",\
		\"type\": \"date\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.item.prosthesis.priorMaterial\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.total\",\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.additionalMaterial\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.missingTeeth\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.missingTeeth.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.missingTeeth.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.missingTeeth.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Claim.missingTeeth.tooth\",\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.missingTeeth.reason\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Claim.missingTeeth.extractionDate\",\
		\"type\": \"date\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse\",\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.meta\",\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.implicitRules\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.language\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.text\",\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.contained\",\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.identifier\",\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.requestIdentifier\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"path\": \"ClaimResponse.requestReference\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"ClaimResponse.ruleset\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.originalRuleset\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.created\",\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.organizationIdentifier\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"path\": \"ClaimResponse.organizationReference\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"ClaimResponse.requestProviderIdentifier\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"path\": \"ClaimResponse.requestProviderReference\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"ClaimResponse.requestOrganizationIdentifier\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"path\": \"ClaimResponse.requestOrganizationReference\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"ClaimResponse.outcome\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.disposition\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.payeeType\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.item\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.item.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.item.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.item.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.item.sequenceLinkId\",\
		\"type\": \"positiveInt\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.item.noteNumber\",\
		\"type\": \"positiveInt\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.item.adjudication\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.item.adjudication.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.item.adjudication.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.item.adjudication.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.item.adjudication.category\",\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.item.adjudication.reason\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.item.adjudication.amount\",\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.item.adjudication.value\",\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.item.detail\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.item.detail.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.item.detail.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.item.detail.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.item.detail.sequenceLinkId\",\
		\"type\": \"positiveInt\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.item.detail.adjudication\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.item.detail.adjudication.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.item.detail.adjudication.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.item.detail.adjudication.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.item.detail.adjudication.category\",\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.item.detail.adjudication.reason\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.item.detail.adjudication.amount\",\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.item.detail.adjudication.value\",\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.item.detail.subDetail\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.item.detail.subDetail.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.item.detail.subDetail.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.item.detail.subDetail.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.item.detail.subDetail.sequenceLinkId\",\
		\"type\": \"positiveInt\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.item.detail.subDetail.adjudication\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.item.detail.subDetail.adjudication.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.item.detail.subDetail.adjudication.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.item.detail.subDetail.adjudication.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.item.detail.subDetail.adjudication.category\",\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.item.detail.subDetail.adjudication.reason\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.item.detail.subDetail.adjudication.amount\",\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.item.detail.subDetail.adjudication.value\",\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.addItem\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.addItem.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.addItem.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.addItem.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.addItem.sequenceLinkId\",\
		\"type\": \"positiveInt\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.addItem.service\",\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.addItem.fee\",\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.addItem.noteNumberLinkId\",\
		\"type\": \"positiveInt\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.addItem.adjudication\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.addItem.adjudication.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.addItem.adjudication.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.addItem.adjudication.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.addItem.adjudication.category\",\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.addItem.adjudication.reason\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.addItem.adjudication.amount\",\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.addItem.adjudication.value\",\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.addItem.detail\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.addItem.detail.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.addItem.detail.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.addItem.detail.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.addItem.detail.service\",\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.addItem.detail.fee\",\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.addItem.detail.adjudication\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.addItem.detail.adjudication.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.addItem.detail.adjudication.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.addItem.detail.adjudication.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.addItem.detail.adjudication.category\",\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.addItem.detail.adjudication.reason\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.addItem.detail.adjudication.amount\",\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.addItem.detail.adjudication.value\",\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.error\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.error.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.error.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.error.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.error.sequenceLinkId\",\
		\"type\": \"positiveInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.error.detailSequenceLinkId\",\
		\"type\": \"positiveInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.error.subdetailSequenceLinkId\",\
		\"type\": \"positiveInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.error.code\",\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.totalCost\",\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.unallocDeductable\",\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.totalBenefit\",\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.paymentAdjustment\",\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.paymentAdjustmentReason\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.paymentDate\",\
		\"type\": \"date\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.paymentAmount\",\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.paymentRef\",\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.reserved\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.form\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.note\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.note.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.note.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.note.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.note.number\",\
		\"type\": \"positiveInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.note.type\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.note.text\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.coverage\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.coverage.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.coverage.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.coverage.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.coverage.sequence\",\
		\"type\": \"positiveInt\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.coverage.focal\",\
		\"type\": \"boolean\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.coverage.coverageIdentifier\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"path\": \"ClaimResponse.coverage.coverageReference\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"ClaimResponse.coverage.businessArrangement\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClaimResponse.coverage.preAuthRef\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClaimResponse.coverage.claimResponse\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClinicalImpression\",\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClinicalImpression.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClinicalImpression.meta\",\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClinicalImpression.implicitRules\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClinicalImpression.language\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClinicalImpression.text\",\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClinicalImpression.contained\",\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClinicalImpression.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClinicalImpression.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClinicalImpression.patient\",\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClinicalImpression.assessor\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClinicalImpression.status\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClinicalImpression.date\",\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClinicalImpression.description\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClinicalImpression.previous\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClinicalImpression.problem\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClinicalImpression.triggerCodeableConcept\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"path\": \"ClinicalImpression.triggerReference\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"ClinicalImpression.investigations\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClinicalImpression.investigations.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClinicalImpression.investigations.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClinicalImpression.investigations.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClinicalImpression.investigations.code\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClinicalImpression.investigations.item\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClinicalImpression.protocol\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClinicalImpression.summary\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClinicalImpression.finding\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClinicalImpression.finding.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClinicalImpression.finding.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClinicalImpression.finding.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClinicalImpression.finding.item\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClinicalImpression.finding.cause\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClinicalImpression.resolved\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClinicalImpression.ruledOut\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClinicalImpression.ruledOut.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClinicalImpression.ruledOut.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClinicalImpression.ruledOut.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClinicalImpression.ruledOut.item\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClinicalImpression.ruledOut.reason\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClinicalImpression.prognosis\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ClinicalImpression.plan\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ClinicalImpression.action\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Communication\",\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Communication.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Communication.meta\",\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Communication.implicitRules\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Communication.language\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Communication.text\",\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Communication.contained\",\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Communication.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Communication.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Communication.identifier\",\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Communication.category\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Communication.sender\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Communication.recipient\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Communication.payload\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Communication.payload.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Communication.payload.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Communication.payload.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Communication.payload.contentString\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"path\": \"Communication.payload.contentAttachment\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"Attachment\"\
	},\
	{\
		\"path\": \"Communication.payload.contentReference\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"Communication.medium\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Communication.status\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Communication.encounter\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Communication.sent\",\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Communication.received\",\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Communication.reason\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Communication.subject\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Communication.requestDetail\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CommunicationRequest\",\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CommunicationRequest.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CommunicationRequest.meta\",\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CommunicationRequest.implicitRules\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CommunicationRequest.language\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CommunicationRequest.text\",\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CommunicationRequest.contained\",\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CommunicationRequest.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CommunicationRequest.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CommunicationRequest.identifier\",\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CommunicationRequest.category\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CommunicationRequest.sender\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CommunicationRequest.recipient\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CommunicationRequest.payload\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CommunicationRequest.payload.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CommunicationRequest.payload.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CommunicationRequest.payload.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CommunicationRequest.payload.contentString\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"path\": \"CommunicationRequest.payload.contentAttachment\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"Attachment\"\
	},\
	{\
		\"path\": \"CommunicationRequest.payload.contentReference\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"CommunicationRequest.medium\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CommunicationRequest.requester\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CommunicationRequest.status\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CommunicationRequest.encounter\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CommunicationRequest.scheduledDateTime\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"path\": \"CommunicationRequest.scheduledPeriod\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Period\"\
	},\
	{\
		\"path\": \"CommunicationRequest.reason\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CommunicationRequest.requestedOn\",\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CommunicationRequest.subject\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CommunicationRequest.priority\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CompartmentDefinition\",\
		\"type\": \"DomainResource\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CompartmentDefinition.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CompartmentDefinition.meta\",\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CompartmentDefinition.implicitRules\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CompartmentDefinition.language\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CompartmentDefinition.text\",\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CompartmentDefinition.contained\",\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CompartmentDefinition.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CompartmentDefinition.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CompartmentDefinition.url\",\
		\"type\": \"uri\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CompartmentDefinition.name\",\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CompartmentDefinition.status\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CompartmentDefinition.experimental\",\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CompartmentDefinition.publisher\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CompartmentDefinition.contact\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CompartmentDefinition.contact.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CompartmentDefinition.contact.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CompartmentDefinition.contact.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CompartmentDefinition.contact.name\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CompartmentDefinition.contact.telecom\",\
		\"type\": \"ContactPoint\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CompartmentDefinition.date\",\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CompartmentDefinition.description\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CompartmentDefinition.requirements\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CompartmentDefinition.code\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CompartmentDefinition.search\",\
		\"type\": \"boolean\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CompartmentDefinition.resource\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CompartmentDefinition.resource.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CompartmentDefinition.resource.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CompartmentDefinition.resource.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CompartmentDefinition.resource.code\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"CompartmentDefinition.resource.param\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"CompartmentDefinition.resource.documentation\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Composition\",\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Composition.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Composition.meta\",\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Composition.implicitRules\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Composition.language\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Composition.text\",\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Composition.contained\",\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Composition.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Composition.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Composition.identifier\",\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Composition.date\",\
		\"type\": \"dateTime\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Composition.type\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Composition.class\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Composition.title\",\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Composition.status\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Composition.confidentiality\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Composition.subject\",\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Composition.author\",\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Composition.attester\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Composition.attester.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Composition.attester.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Composition.attester.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Composition.attester.mode\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Composition.attester.time\",\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Composition.attester.party\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Composition.custodian\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Composition.event\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Composition.event.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Composition.event.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Composition.event.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Composition.event.code\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Composition.event.period\",\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Composition.event.detail\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Composition.encounter\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Composition.section\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Composition.section.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Composition.section.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Composition.section.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Composition.section.title\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Composition.section.code\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Composition.section.text\",\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Composition.section.mode\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Composition.section.orderedBy\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Composition.section.entry\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Composition.section.emptyReason\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Composition.section.section\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ConceptMap\",\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ConceptMap.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ConceptMap.meta\",\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ConceptMap.implicitRules\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ConceptMap.language\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ConceptMap.text\",\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ConceptMap.contained\",\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ConceptMap.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ConceptMap.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ConceptMap.url\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ConceptMap.identifier\",\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ConceptMap.version\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ConceptMap.name\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ConceptMap.status\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ConceptMap.experimental\",\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ConceptMap.publisher\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ConceptMap.contact\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ConceptMap.contact.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ConceptMap.contact.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ConceptMap.contact.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ConceptMap.contact.name\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ConceptMap.contact.telecom\",\
		\"type\": \"ContactPoint\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ConceptMap.date\",\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ConceptMap.description\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ConceptMap.useContext\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ConceptMap.requirements\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ConceptMap.copyright\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ConceptMap.sourceUri\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"path\": \"ConceptMap.sourceReference\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"ConceptMap.sourceReference\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"ConceptMap.targetUri\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"path\": \"ConceptMap.targetReference\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"ConceptMap.targetReference\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"ConceptMap.element\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ConceptMap.element.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ConceptMap.element.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ConceptMap.element.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ConceptMap.element.system\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ConceptMap.element.version\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ConceptMap.element.code\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ConceptMap.element.target\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ConceptMap.element.target.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ConceptMap.element.target.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ConceptMap.element.target.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ConceptMap.element.target.system\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ConceptMap.element.target.version\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ConceptMap.element.target.code\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ConceptMap.element.target.equivalence\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ConceptMap.element.target.comments\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ConceptMap.element.target.dependsOn\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ConceptMap.element.target.dependsOn.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ConceptMap.element.target.dependsOn.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ConceptMap.element.target.dependsOn.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ConceptMap.element.target.dependsOn.element\",\
		\"type\": \"uri\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ConceptMap.element.target.dependsOn.system\",\
		\"type\": \"uri\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ConceptMap.element.target.dependsOn.code\",\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ConceptMap.element.target.product\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Condition\",\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Condition.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Condition.meta\",\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Condition.implicitRules\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Condition.language\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Condition.text\",\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Condition.contained\",\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Condition.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Condition.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Condition.identifier\",\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Condition.patient\",\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Condition.encounter\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Condition.asserter\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Condition.dateRecorded\",\
		\"type\": \"date\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Condition.code\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Condition.category\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Condition.clinicalStatus\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Condition.verificationStatus\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Condition.severity\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Condition.onsetDateTime\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"path\": \"Condition.onsetQuantity\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"path\": \"Condition.onsetPeriod\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Period\"\
	},\
	{\
		\"path\": \"Condition.onsetRange\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Range\"\
	},\
	{\
		\"path\": \"Condition.onsetString\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"string\"\
	},\
	{\
		\"path\": \"Condition.abatementDateTime\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"path\": \"Condition.abatementQuantity\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"path\": \"Condition.abatementBoolean\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"path\": \"Condition.abatementPeriod\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Period\"\
	},\
	{\
		\"path\": \"Condition.abatementRange\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Range\"\
	},\
	{\
		\"path\": \"Condition.abatementString\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"string\"\
	},\
	{\
		\"path\": \"Condition.stage\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Condition.stage.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Condition.stage.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Condition.stage.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Condition.stage.summary\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Condition.stage.assessment\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Condition.evidence\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Condition.evidence.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Condition.evidence.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Condition.evidence.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Condition.evidence.code\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Condition.evidence.detail\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Condition.bodySite\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Condition.note\",\
		\"type\": \"Annotation\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance\",\
		\"type\": \"DomainResource\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.meta\",\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.implicitRules\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.language\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.text\",\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.contained\",\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.url\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.version\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.name\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.status\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.experimental\",\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.date\",\
		\"type\": \"dateTime\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.publisher\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.contact\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.contact.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.contact.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.contact.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.contact.name\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.contact.telecom\",\
		\"type\": \"ContactPoint\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.description\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.useContext\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.requirements\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.copyright\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.kind\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.software\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.software.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.software.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.software.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.software.name\",\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.software.version\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.software.releaseDate\",\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.implementation\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.implementation.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.implementation.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.implementation.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.implementation.description\",\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.implementation.url\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.fhirVersion\",\
		\"type\": \"id\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.acceptUnknown\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.format\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.profile\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.rest\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.rest.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.rest.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.rest.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.rest.mode\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.rest.documentation\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.rest.security\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.rest.security.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.rest.security.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.rest.security.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.rest.security.cors\",\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.rest.security.service\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.rest.security.description\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.rest.security.certificate\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.rest.security.certificate.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.rest.security.certificate.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.rest.security.certificate.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.rest.security.certificate.type\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.rest.security.certificate.blob\",\
		\"type\": \"base64Binary\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.rest.resource\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.rest.resource.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.rest.resource.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.rest.resource.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.rest.resource.type\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.rest.resource.profile\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.rest.resource.interaction\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.rest.resource.interaction.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.rest.resource.interaction.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.rest.resource.interaction.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.rest.resource.interaction.code\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.rest.resource.interaction.documentation\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.rest.resource.versioning\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.rest.resource.readHistory\",\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.rest.resource.updateCreate\",\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.rest.resource.conditionalCreate\",\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.rest.resource.conditionalUpdate\",\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.rest.resource.conditionalDelete\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.rest.resource.searchInclude\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.rest.resource.searchRevInclude\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.rest.resource.searchParam\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.rest.resource.searchParam.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.rest.resource.searchParam.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.rest.resource.searchParam.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.rest.resource.searchParam.name\",\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.rest.resource.searchParam.definition\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.rest.resource.searchParam.type\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.rest.resource.searchParam.documentation\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.rest.resource.searchParam.target\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.rest.resource.searchParam.modifier\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.rest.resource.searchParam.chain\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.rest.interaction\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.rest.interaction.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.rest.interaction.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.rest.interaction.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.rest.interaction.code\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.rest.interaction.documentation\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.rest.transactionMode\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.rest.searchParam\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.rest.operation\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.rest.operation.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.rest.operation.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.rest.operation.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.rest.operation.name\",\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.rest.operation.definition\",\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.rest.compartment\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.messaging\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.messaging.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.messaging.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.messaging.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.messaging.endpoint\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.messaging.endpoint.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.messaging.endpoint.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.messaging.endpoint.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.messaging.endpoint.protocol\",\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.messaging.endpoint.address\",\
		\"type\": \"uri\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.messaging.reliableCache\",\
		\"type\": \"unsignedInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.messaging.documentation\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.messaging.event\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.messaging.event.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.messaging.event.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.messaging.event.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.messaging.event.code\",\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.messaging.event.category\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.messaging.event.mode\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.messaging.event.focus\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.messaging.event.request\",\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.messaging.event.response\",\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.messaging.event.documentation\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.document\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.document.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.document.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.document.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Conformance.document.mode\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.document.documentation\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Conformance.document.profile\",\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract\",\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.meta\",\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.implicitRules\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.language\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.text\",\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.contained\",\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.identifier\",\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.issued\",\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.applies\",\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.subject\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.topic\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.authority\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.domain\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.type\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.subType\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.action\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.actionReason\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.agent\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.agent.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.agent.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.agent.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.agent.actor\",\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.agent.role\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.signer\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.signer.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.signer.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.signer.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.signer.type\",\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.signer.party\",\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.signer.signature\",\
		\"type\": \"Signature\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.valuedItem\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.valuedItem.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.valuedItem.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.valuedItem.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.valuedItem.entityCodeableConcept\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"path\": \"Contract.valuedItem.entityReference\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"Contract.valuedItem.identifier\",\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.valuedItem.effectiveTime\",\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.valuedItem.quantity\",\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.valuedItem.unitPrice\",\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.valuedItem.factor\",\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.valuedItem.points\",\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.valuedItem.net\",\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.term\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.term.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.term.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.term.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.term.identifier\",\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.term.issued\",\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.term.applies\",\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.term.type\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.term.subType\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.term.topic\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.term.action\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.term.actionReason\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.term.agent\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.term.agent.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.term.agent.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.term.agent.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.term.agent.actor\",\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.term.agent.role\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.term.text\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.term.valuedItem\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.term.valuedItem.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.term.valuedItem.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.term.valuedItem.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.term.valuedItem.entityCodeableConcept\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"path\": \"Contract.term.valuedItem.entityReference\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"Contract.term.valuedItem.identifier\",\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.term.valuedItem.effectiveTime\",\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.term.valuedItem.quantity\",\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.term.valuedItem.unitPrice\",\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.term.valuedItem.factor\",\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.term.valuedItem.points\",\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.term.valuedItem.net\",\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.term.group\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.bindingAttachment\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Attachment\"\
	},\
	{\
		\"path\": \"Contract.bindingReference\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"Contract.bindingReference\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"Contract.bindingReference\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"Contract.friendly\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.friendly.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.friendly.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.friendly.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.friendly.contentAttachment\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"Attachment\"\
	},\
	{\
		\"path\": \"Contract.friendly.contentReference\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"Contract.friendly.contentReference\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"Contract.friendly.contentReference\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"Contract.legal\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.legal.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.legal.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.legal.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.legal.contentAttachment\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"Attachment\"\
	},\
	{\
		\"path\": \"Contract.legal.contentReference\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"Contract.legal.contentReference\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"Contract.legal.contentReference\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"Contract.rule\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.rule.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Contract.rule.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.rule.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Contract.rule.contentAttachment\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"Attachment\"\
	},\
	{\
		\"path\": \"Contract.rule.contentReference\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"Coverage\",\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Coverage.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Coverage.meta\",\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Coverage.implicitRules\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Coverage.language\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Coverage.text\",\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Coverage.contained\",\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Coverage.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Coverage.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Coverage.issuerIdentifier\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"path\": \"Coverage.issuerReference\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"Coverage.bin\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Coverage.period\",\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Coverage.type\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Coverage.planholderIdentifier\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"path\": \"Coverage.planholderReference\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"Coverage.planholderReference\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"Coverage.beneficiaryIdentifier\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"path\": \"Coverage.beneficiaryReference\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"Coverage.relationship\",\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Coverage.identifier\",\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Coverage.group\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Coverage.plan\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Coverage.subPlan\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Coverage.dependent\",\
		\"type\": \"positiveInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Coverage.sequence\",\
		\"type\": \"positiveInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Coverage.exception\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Coverage.school\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Coverage.network\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Coverage.contract\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DataElement\",\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DataElement.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DataElement.meta\",\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DataElement.implicitRules\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DataElement.language\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DataElement.text\",\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DataElement.contained\",\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DataElement.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DataElement.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DataElement.url\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DataElement.identifier\",\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DataElement.version\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DataElement.status\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DataElement.experimental\",\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DataElement.publisher\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DataElement.date\",\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DataElement.name\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DataElement.contact\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DataElement.contact.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DataElement.contact.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DataElement.contact.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DataElement.contact.name\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DataElement.contact.telecom\",\
		\"type\": \"ContactPoint\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DataElement.useContext\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DataElement.copyright\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DataElement.stringency\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DataElement.mapping\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DataElement.mapping.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DataElement.mapping.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DataElement.mapping.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DataElement.mapping.identity\",\
		\"type\": \"id\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DataElement.mapping.uri\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DataElement.mapping.name\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DataElement.mapping.comment\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DataElement.element\",\
		\"type\": \"ElementDefinition\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DecisionSupportRule\",\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DecisionSupportRule.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DecisionSupportRule.meta\",\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DecisionSupportRule.implicitRules\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DecisionSupportRule.language\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DecisionSupportRule.text\",\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DecisionSupportRule.contained\",\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DecisionSupportRule.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DecisionSupportRule.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DecisionSupportRule.moduleMetadata\",\
		\"type\": \"ModuleMetadata\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DecisionSupportRule.library\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DecisionSupportRule.trigger\",\
		\"type\": \"TriggerDefinition\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DecisionSupportRule.condition\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DecisionSupportRule.action\",\
		\"type\": \"ActionDefinition\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DecisionSupportServiceModule\",\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DecisionSupportServiceModule.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DecisionSupportServiceModule.meta\",\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DecisionSupportServiceModule.implicitRules\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DecisionSupportServiceModule.language\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DecisionSupportServiceModule.text\",\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DecisionSupportServiceModule.contained\",\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DecisionSupportServiceModule.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DecisionSupportServiceModule.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DecisionSupportServiceModule.moduleMetadata\",\
		\"type\": \"ModuleMetadata\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DecisionSupportServiceModule.trigger\",\
		\"type\": \"TriggerDefinition\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DecisionSupportServiceModule.parameter\",\
		\"type\": \"ParameterDefinition\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DecisionSupportServiceModule.dataRequirement\",\
		\"type\": \"DataRequirement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DetectedIssue\",\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DetectedIssue.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DetectedIssue.meta\",\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DetectedIssue.implicitRules\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DetectedIssue.language\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DetectedIssue.text\",\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DetectedIssue.contained\",\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DetectedIssue.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DetectedIssue.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DetectedIssue.patient\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DetectedIssue.category\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DetectedIssue.severity\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DetectedIssue.implicated\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DetectedIssue.detail\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DetectedIssue.date\",\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DetectedIssue.author\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DetectedIssue.identifier\",\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DetectedIssue.reference\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DetectedIssue.mitigation\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DetectedIssue.mitigation.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DetectedIssue.mitigation.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DetectedIssue.mitigation.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DetectedIssue.mitigation.action\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DetectedIssue.mitigation.date\",\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DetectedIssue.mitigation.author\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Device\",\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Device.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Device.meta\",\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Device.implicitRules\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Device.language\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Device.text\",\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Device.contained\",\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Device.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Device.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Device.identifier\",\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Device.udiCarrier\",\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Device.status\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Device.type\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Device.lotNumber\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Device.manufacturer\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Device.manufactureDate\",\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Device.expirationDate\",\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Device.model\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Device.version\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Device.patient\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Device.owner\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Device.contact\",\
		\"type\": \"ContactPoint\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Device.location\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Device.url\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Device.note\",\
		\"type\": \"Annotation\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DeviceComponent\",\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DeviceComponent.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceComponent.meta\",\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceComponent.implicitRules\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceComponent.language\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceComponent.text\",\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceComponent.contained\",\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DeviceComponent.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DeviceComponent.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DeviceComponent.type\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceComponent.identifier\",\
		\"type\": \"Identifier\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceComponent.lastSystemChange\",\
		\"type\": \"instant\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceComponent.source\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceComponent.parent\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceComponent.operationalStatus\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DeviceComponent.parameterGroup\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceComponent.measurementPrinciple\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceComponent.productionSpecification\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DeviceComponent.productionSpecification.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceComponent.productionSpecification.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DeviceComponent.productionSpecification.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DeviceComponent.productionSpecification.specType\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceComponent.productionSpecification.componentId\",\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceComponent.productionSpecification.productionSpec\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceComponent.languageCode\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceMetric\",\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DeviceMetric.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceMetric.meta\",\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceMetric.implicitRules\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceMetric.language\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceMetric.text\",\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceMetric.contained\",\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DeviceMetric.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DeviceMetric.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DeviceMetric.type\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceMetric.identifier\",\
		\"type\": \"Identifier\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceMetric.unit\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceMetric.source\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceMetric.parent\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceMetric.operationalStatus\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceMetric.color\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceMetric.category\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceMetric.measurementPeriod\",\
		\"type\": \"Timing\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceMetric.calibration\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DeviceMetric.calibration.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceMetric.calibration.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DeviceMetric.calibration.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DeviceMetric.calibration.type\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceMetric.calibration.state\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceMetric.calibration.time\",\
		\"type\": \"instant\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceUseRequest\",\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DeviceUseRequest.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceUseRequest.meta\",\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceUseRequest.implicitRules\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceUseRequest.language\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceUseRequest.text\",\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceUseRequest.contained\",\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DeviceUseRequest.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DeviceUseRequest.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DeviceUseRequest.bodySiteCodeableConcept\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"path\": \"DeviceUseRequest.bodySiteReference\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"DeviceUseRequest.status\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceUseRequest.device\",\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceUseRequest.encounter\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceUseRequest.identifier\",\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DeviceUseRequest.indication\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DeviceUseRequest.notes\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DeviceUseRequest.prnReason\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DeviceUseRequest.orderedOn\",\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceUseRequest.recordedOn\",\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceUseRequest.subject\",\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceUseRequest.timingTiming\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Timing\"\
	},\
	{\
		\"path\": \"DeviceUseRequest.timingPeriod\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Period\"\
	},\
	{\
		\"path\": \"DeviceUseRequest.timingDateTime\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"path\": \"DeviceUseRequest.priority\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceUseStatement\",\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DeviceUseStatement.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceUseStatement.meta\",\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceUseStatement.implicitRules\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceUseStatement.language\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceUseStatement.text\",\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceUseStatement.contained\",\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DeviceUseStatement.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DeviceUseStatement.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DeviceUseStatement.bodySiteCodeableConcept\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"path\": \"DeviceUseStatement.bodySiteReference\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"DeviceUseStatement.whenUsed\",\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceUseStatement.device\",\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceUseStatement.identifier\",\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DeviceUseStatement.indication\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DeviceUseStatement.notes\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DeviceUseStatement.recordedOn\",\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceUseStatement.subject\",\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DeviceUseStatement.timingTiming\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Timing\"\
	},\
	{\
		\"path\": \"DeviceUseStatement.timingPeriod\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Period\"\
	},\
	{\
		\"path\": \"DeviceUseStatement.timingDateTime\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"path\": \"DiagnosticOrder\",\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DiagnosticOrder.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DiagnosticOrder.meta\",\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DiagnosticOrder.implicitRules\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DiagnosticOrder.language\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DiagnosticOrder.text\",\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DiagnosticOrder.contained\",\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DiagnosticOrder.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DiagnosticOrder.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DiagnosticOrder.identifier\",\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DiagnosticOrder.status\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DiagnosticOrder.priority\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DiagnosticOrder.subject\",\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DiagnosticOrder.encounter\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DiagnosticOrder.orderer\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DiagnosticOrder.reason\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DiagnosticOrder.supportingInformation\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DiagnosticOrder.specimen\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DiagnosticOrder.event\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DiagnosticOrder.event.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DiagnosticOrder.event.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DiagnosticOrder.event.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DiagnosticOrder.event.status\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DiagnosticOrder.event.description\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DiagnosticOrder.event.dateTime\",\
		\"type\": \"dateTime\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DiagnosticOrder.event.actor\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DiagnosticOrder.item\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DiagnosticOrder.item.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DiagnosticOrder.item.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DiagnosticOrder.item.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DiagnosticOrder.item.code\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DiagnosticOrder.item.specimen\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DiagnosticOrder.item.bodySite\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DiagnosticOrder.item.status\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DiagnosticOrder.item.event\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DiagnosticOrder.note\",\
		\"type\": \"Annotation\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DiagnosticReport\",\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DiagnosticReport.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DiagnosticReport.meta\",\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DiagnosticReport.implicitRules\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DiagnosticReport.language\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DiagnosticReport.text\",\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DiagnosticReport.contained\",\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DiagnosticReport.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DiagnosticReport.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DiagnosticReport.identifier\",\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DiagnosticReport.status\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DiagnosticReport.category\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DiagnosticReport.code\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DiagnosticReport.subject\",\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DiagnosticReport.encounter\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DiagnosticReport.effectiveDateTime\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"path\": \"DiagnosticReport.effectivePeriod\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"path\": \"DiagnosticReport.issued\",\
		\"type\": \"instant\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DiagnosticReport.performer\",\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DiagnosticReport.request\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DiagnosticReport.specimen\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DiagnosticReport.result\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DiagnosticReport.imagingStudy\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DiagnosticReport.image\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DiagnosticReport.image.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DiagnosticReport.image.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DiagnosticReport.image.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DiagnosticReport.image.comment\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DiagnosticReport.image.link\",\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DiagnosticReport.conclusion\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DiagnosticReport.codedDiagnosis\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DiagnosticReport.presentedForm\",\
		\"type\": \"Attachment\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DocumentManifest\",\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DocumentManifest.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentManifest.meta\",\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentManifest.implicitRules\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentManifest.language\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentManifest.text\",\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentManifest.contained\",\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DocumentManifest.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DocumentManifest.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DocumentManifest.masterIdentifier\",\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentManifest.identifier\",\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DocumentManifest.subject\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentManifest.recipient\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DocumentManifest.type\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentManifest.author\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DocumentManifest.created\",\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentManifest.source\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentManifest.status\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentManifest.description\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentManifest.content\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DocumentManifest.content.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentManifest.content.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DocumentManifest.content.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DocumentManifest.content.pAttachment\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"Attachment\"\
	},\
	{\
		\"path\": \"DocumentManifest.content.pReference\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"DocumentManifest.related\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DocumentManifest.related.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentManifest.related.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DocumentManifest.related.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DocumentManifest.related.identifier\",\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentManifest.related.ref\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentReference\",\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DocumentReference.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentReference.meta\",\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentReference.implicitRules\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentReference.language\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentReference.text\",\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentReference.contained\",\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DocumentReference.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DocumentReference.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DocumentReference.masterIdentifier\",\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentReference.identifier\",\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DocumentReference.subject\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentReference.type\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentReference.class\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentReference.author\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DocumentReference.custodian\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentReference.authenticator\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentReference.created\",\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentReference.indexed\",\
		\"type\": \"instant\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentReference.status\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentReference.docStatus\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentReference.relatesTo\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DocumentReference.relatesTo.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentReference.relatesTo.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DocumentReference.relatesTo.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DocumentReference.relatesTo.code\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentReference.relatesTo.target\",\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentReference.description\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentReference.securityLabel\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DocumentReference.content\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DocumentReference.content.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentReference.content.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DocumentReference.content.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DocumentReference.content.attachment\",\
		\"type\": \"Attachment\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentReference.content.format\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DocumentReference.context\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentReference.context.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentReference.context.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DocumentReference.context.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DocumentReference.context.encounter\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentReference.context.event\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DocumentReference.context.period\",\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentReference.context.facilityType\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentReference.context.practiceSetting\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentReference.context.sourcePatientInfo\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentReference.context.related\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DocumentReference.context.related.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentReference.context.related.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DocumentReference.context.related.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"DocumentReference.context.related.identifier\",\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"DocumentReference.context.related.ref\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityRequest\",\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"EligibilityRequest.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityRequest.meta\",\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityRequest.implicitRules\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityRequest.language\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityRequest.text\",\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityRequest.contained\",\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"EligibilityRequest.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"EligibilityRequest.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"EligibilityRequest.identifier\",\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"EligibilityRequest.ruleset\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityRequest.originalRuleset\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityRequest.created\",\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityRequest.targetIdentifier\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"path\": \"EligibilityRequest.targetReference\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"EligibilityRequest.providerIdentifier\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"path\": \"EligibilityRequest.providerReference\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"EligibilityRequest.organizationIdentifier\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"path\": \"EligibilityRequest.organizationReference\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"EligibilityRequest.priority\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityRequest.entererIdentifier\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"path\": \"EligibilityRequest.entererReference\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"EligibilityRequest.facilityIdentifier\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"path\": \"EligibilityRequest.facilityReference\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"EligibilityRequest.patientIdentifier\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"path\": \"EligibilityRequest.patientReference\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"EligibilityRequest.coverageIdentifier\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"path\": \"EligibilityRequest.coverageReference\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"EligibilityRequest.businessArrangement\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityRequest.servicedDate\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"date\"\
	},\
	{\
		\"path\": \"EligibilityRequest.servicedPeriod\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Period\"\
	},\
	{\
		\"path\": \"EligibilityRequest.benefitCategory\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityRequest.benefitSubCategory\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityResponse\",\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"EligibilityResponse.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityResponse.meta\",\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityResponse.implicitRules\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityResponse.language\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityResponse.text\",\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityResponse.contained\",\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"EligibilityResponse.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"EligibilityResponse.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"EligibilityResponse.identifier\",\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"EligibilityResponse.requestIdentifier\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"path\": \"EligibilityResponse.requestReference\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"EligibilityResponse.outcome\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityResponse.disposition\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityResponse.ruleset\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityResponse.originalRuleset\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityResponse.created\",\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityResponse.organizationIdentifier\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"path\": \"EligibilityResponse.organizationReference\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"EligibilityResponse.requestProviderIdentifier\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"path\": \"EligibilityResponse.requestProviderReference\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"EligibilityResponse.requestOrganizationIdentifier\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"path\": \"EligibilityResponse.requestOrganizationReference\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"EligibilityResponse.inforce\",\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityResponse.contract\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityResponse.form\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityResponse.benefitBalance\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"EligibilityResponse.benefitBalance.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityResponse.benefitBalance.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"EligibilityResponse.benefitBalance.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"EligibilityResponse.benefitBalance.category\",\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityResponse.benefitBalance.subCategory\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityResponse.benefitBalance.network\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityResponse.benefitBalance.unit\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityResponse.benefitBalance.term\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityResponse.benefitBalance.financial\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"EligibilityResponse.benefitBalance.financial.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityResponse.benefitBalance.financial.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"EligibilityResponse.benefitBalance.financial.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"EligibilityResponse.benefitBalance.financial.type\",\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityResponse.benefitBalance.financial.benefitUnsignedInt\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"unsignedInt\"\
	},\
	{\
		\"path\": \"EligibilityResponse.benefitBalance.financial.benefitQuantity\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"path\": \"EligibilityResponse.benefitBalance.financial.benefitUsedUnsignedInt\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"unsignedInt\"\
	},\
	{\
		\"path\": \"EligibilityResponse.benefitBalance.financial.benefitUsedQuantity\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"path\": \"EligibilityResponse.error\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"EligibilityResponse.error.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EligibilityResponse.error.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"EligibilityResponse.error.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"EligibilityResponse.error.code\",\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Encounter\",\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Encounter.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Encounter.meta\",\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Encounter.implicitRules\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Encounter.language\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Encounter.text\",\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Encounter.contained\",\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Encounter.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Encounter.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Encounter.identifier\",\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Encounter.status\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Encounter.statusHistory\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Encounter.statusHistory.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Encounter.statusHistory.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Encounter.statusHistory.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Encounter.statusHistory.status\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Encounter.statusHistory.period\",\
		\"type\": \"Period\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Encounter.class\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Encounter.type\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Encounter.priority\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Encounter.patient\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Encounter.episodeOfCare\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Encounter.incomingReferral\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Encounter.participant\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Encounter.participant.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Encounter.participant.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Encounter.participant.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Encounter.participant.type\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Encounter.participant.period\",\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Encounter.participant.individual\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Encounter.appointment\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Encounter.period\",\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Encounter.length\",\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Encounter.reason\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Encounter.indication\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Encounter.hospitalization\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Encounter.hospitalization.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Encounter.hospitalization.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Encounter.hospitalization.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Encounter.hospitalization.preAdmissionIdentifier\",\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Encounter.hospitalization.origin\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Encounter.hospitalization.admitSource\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Encounter.hospitalization.admittingDiagnosis\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Encounter.hospitalization.reAdmission\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Encounter.hospitalization.dietPreference\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Encounter.hospitalization.specialCourtesy\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Encounter.hospitalization.specialArrangement\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Encounter.hospitalization.destination\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Encounter.hospitalization.dischargeDisposition\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Encounter.hospitalization.dischargeDiagnosis\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Encounter.location\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Encounter.location.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Encounter.location.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Encounter.location.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Encounter.location.location\",\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Encounter.location.status\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Encounter.location.period\",\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Encounter.serviceProvider\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Encounter.partOf\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Endpoint\",\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Endpoint.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Endpoint.meta\",\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Endpoint.implicitRules\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Endpoint.language\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Endpoint.text\",\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Endpoint.contained\",\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Endpoint.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Endpoint.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Endpoint.status\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Endpoint.managingOrganization\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Endpoint.contact\",\
		\"type\": \"ContactPoint\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Endpoint.connectionType\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Endpoint.method\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Endpoint.period\",\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Endpoint.addressUri\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"uri\"\
	},\
	{\
		\"path\": \"Endpoint.addressString\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"string\"\
	},\
	{\
		\"path\": \"Endpoint.payloadFormat\",\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Endpoint.payloadType\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Endpoint.header\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Endpoint.publicKey\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EnrollmentRequest\",\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"EnrollmentRequest.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EnrollmentRequest.meta\",\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EnrollmentRequest.implicitRules\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EnrollmentRequest.language\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EnrollmentRequest.text\",\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EnrollmentRequest.contained\",\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"EnrollmentRequest.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"EnrollmentRequest.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"EnrollmentRequest.identifier\",\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"EnrollmentRequest.ruleset\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EnrollmentRequest.originalRuleset\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EnrollmentRequest.created\",\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EnrollmentRequest.target\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EnrollmentRequest.provider\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EnrollmentRequest.organization\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EnrollmentRequest.subject\",\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EnrollmentRequest.coverage\",\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EnrollmentRequest.relationship\",\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EnrollmentResponse\",\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"EnrollmentResponse.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EnrollmentResponse.meta\",\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EnrollmentResponse.implicitRules\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EnrollmentResponse.language\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EnrollmentResponse.text\",\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EnrollmentResponse.contained\",\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"EnrollmentResponse.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"EnrollmentResponse.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"EnrollmentResponse.identifier\",\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"EnrollmentResponse.request\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EnrollmentResponse.outcome\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EnrollmentResponse.disposition\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EnrollmentResponse.ruleset\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EnrollmentResponse.originalRuleset\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EnrollmentResponse.created\",\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EnrollmentResponse.organization\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EnrollmentResponse.requestProvider\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EnrollmentResponse.requestOrganization\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EpisodeOfCare\",\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"EpisodeOfCare.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EpisodeOfCare.meta\",\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EpisodeOfCare.implicitRules\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EpisodeOfCare.language\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EpisodeOfCare.text\",\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EpisodeOfCare.contained\",\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"EpisodeOfCare.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"EpisodeOfCare.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"EpisodeOfCare.identifier\",\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"EpisodeOfCare.status\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EpisodeOfCare.statusHistory\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"EpisodeOfCare.statusHistory.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EpisodeOfCare.statusHistory.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"EpisodeOfCare.statusHistory.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"EpisodeOfCare.statusHistory.status\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EpisodeOfCare.statusHistory.period\",\
		\"type\": \"Period\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EpisodeOfCare.type\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"EpisodeOfCare.condition\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"EpisodeOfCare.patient\",\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EpisodeOfCare.managingOrganization\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EpisodeOfCare.period\",\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EpisodeOfCare.referralRequest\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"EpisodeOfCare.careManager\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"EpisodeOfCare.team\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExpansionProfile\",\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExpansionProfile.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.meta\",\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.implicitRules\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.language\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.text\",\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.contained\",\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExpansionProfile.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExpansionProfile.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExpansionProfile.url\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.identifier\",\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.version\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.name\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.status\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.experimental\",\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.publisher\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.contact\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExpansionProfile.contact.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.contact.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExpansionProfile.contact.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExpansionProfile.contact.name\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.contact.telecom\",\
		\"type\": \"ContactPoint\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExpansionProfile.date\",\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.description\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.codeSystem\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.codeSystem.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.codeSystem.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExpansionProfile.codeSystem.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExpansionProfile.codeSystem.include\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.codeSystem.include.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.codeSystem.include.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExpansionProfile.codeSystem.include.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExpansionProfile.codeSystem.include.codeSystem\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExpansionProfile.codeSystem.include.codeSystem.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.codeSystem.include.codeSystem.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExpansionProfile.codeSystem.include.codeSystem.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExpansionProfile.codeSystem.include.codeSystem.system\",\
		\"type\": \"uri\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.codeSystem.include.codeSystem.version\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.codeSystem.exclude\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.codeSystem.exclude.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.codeSystem.exclude.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExpansionProfile.codeSystem.exclude.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExpansionProfile.codeSystem.exclude.codeSystem\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExpansionProfile.codeSystem.exclude.codeSystem.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.codeSystem.exclude.codeSystem.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExpansionProfile.codeSystem.exclude.codeSystem.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExpansionProfile.codeSystem.exclude.codeSystem.system\",\
		\"type\": \"uri\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.codeSystem.exclude.codeSystem.version\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.includeDesignations\",\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.designation\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.designation.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.designation.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExpansionProfile.designation.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExpansionProfile.designation.include\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.designation.include.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.designation.include.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExpansionProfile.designation.include.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExpansionProfile.designation.include.designation\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExpansionProfile.designation.include.designation.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.designation.include.designation.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExpansionProfile.designation.include.designation.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExpansionProfile.designation.include.designation.language\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.designation.include.designation.use\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.designation.exclude\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.designation.exclude.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.designation.exclude.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExpansionProfile.designation.exclude.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExpansionProfile.designation.exclude.designation\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExpansionProfile.designation.exclude.designation.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.designation.exclude.designation.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExpansionProfile.designation.exclude.designation.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExpansionProfile.designation.exclude.designation.language\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.designation.exclude.designation.use\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.includeDefinition\",\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.includeInactive\",\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.excludeNested\",\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.excludeNotForUI\",\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.excludePostCoordinated\",\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.displayLanguage\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExpansionProfile.limitedExpansion\",\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit\",\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.meta\",\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.implicitRules\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.language\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.text\",\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.contained\",\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.identifier\",\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.claimIdentifier\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.claimReference\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.claimResponseIdentifier\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.claimResponseReference\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.subType\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.ruleset\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.originalRuleset\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.created\",\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.billablePeriod\",\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.disposition\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.providerIdentifier\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.providerReference\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.organizationIdentifier\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.organizationReference\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.facilityIdentifier\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.facilityReference\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.related\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.related.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.related.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.related.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.related.claimIdentifier\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.related.claimReference\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.related.relationship\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.related.reference\",\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.prescriptionIdentifier\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.prescriptionReference\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.prescriptionReference\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.originalPrescriptionIdentifier\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.originalPrescriptionReference\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.payee\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.payee.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.payee.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.payee.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.payee.type\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.payee.partyIdentifier\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.payee.partyReference\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.payee.partyReference\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.payee.partyReference\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.payee.partyReference\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.referralIdentifier\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.referralReference\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.occurrenceCode\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.occurenceSpanCode\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.valueCode\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.diagnosis\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.diagnosis.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.diagnosis.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.diagnosis.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.diagnosis.sequence\",\
		\"type\": \"positiveInt\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.diagnosis.diagnosis\",\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.procedure\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.procedure.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.procedure.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.procedure.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.procedure.sequence\",\
		\"type\": \"positiveInt\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.procedure.date\",\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.procedure.procedureCoding\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.procedure.procedureReference\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.specialCondition\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.patientIdentifier\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.patientReference\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.precedence\",\
		\"type\": \"positiveInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.coverage\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.coverage.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.coverage.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.coverage.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.coverage.coverageIdentifier\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.coverage.coverageReference\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.coverage.preAuthRef\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.accidentDate\",\
		\"type\": \"date\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.accidentType\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.accidentLocationAddress\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Address\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.accidentLocationReference\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.interventionException\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.onset\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.onset.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.onset.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.onset.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.onset.timeDate\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"date\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.onset.timePeriod\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Period\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.onset.type\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.employmentImpacted\",\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.hospitalization\",\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.sequence\",\
		\"type\": \"positiveInt\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.type\",\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.providerIdentifier\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.providerReference\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.supervisorIdentifier\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.supervisorReference\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.providerQualification\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.diagnosisLinkId\",\
		\"type\": \"positiveInt\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.service\",\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.serviceModifier\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.modifier\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.programCode\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.servicedDate\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"date\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.servicedPeriod\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Period\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.place\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.quantity\",\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.unitPrice\",\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.factor\",\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.points\",\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.net\",\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.udi\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.bodySite\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.subSite\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.noteNumber\",\
		\"type\": \"positiveInt\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.adjudication\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.adjudication.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.adjudication.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.adjudication.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.adjudication.category\",\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.adjudication.reason\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.adjudication.amount\",\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.adjudication.value\",\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail.sequence\",\
		\"type\": \"positiveInt\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail.type\",\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail.service\",\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail.programCode\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail.quantity\",\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail.unitPrice\",\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail.factor\",\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail.points\",\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail.net\",\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail.udi\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail.adjudication\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail.adjudication.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail.adjudication.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail.adjudication.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail.adjudication.category\",\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail.adjudication.reason\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail.adjudication.amount\",\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail.adjudication.value\",\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail.subDetail\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail.subDetail.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail.subDetail.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail.subDetail.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail.subDetail.sequence\",\
		\"type\": \"positiveInt\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail.subDetail.type\",\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail.subDetail.service\",\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail.subDetail.programCode\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail.subDetail.quantity\",\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail.subDetail.unitPrice\",\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail.subDetail.factor\",\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail.subDetail.points\",\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail.subDetail.net\",\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail.subDetail.udi\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail.subDetail.adjudication\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail.subDetail.adjudication.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail.subDetail.adjudication.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail.subDetail.adjudication.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail.subDetail.adjudication.category\",\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail.subDetail.adjudication.reason\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail.subDetail.adjudication.amount\",\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.detail.subDetail.adjudication.value\",\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.prosthesis\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.prosthesis.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.prosthesis.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.prosthesis.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.prosthesis.initial\",\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.prosthesis.priorDate\",\
		\"type\": \"date\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.item.prosthesis.priorMaterial\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.addItem\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.addItem.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.addItem.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.addItem.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.addItem.sequenceLinkId\",\
		\"type\": \"positiveInt\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.addItem.service\",\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.addItem.fee\",\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.addItem.noteNumberLinkId\",\
		\"type\": \"positiveInt\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.addItem.adjudication\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.addItem.adjudication.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.addItem.adjudication.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.addItem.adjudication.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.addItem.adjudication.category\",\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.addItem.adjudication.reason\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.addItem.adjudication.amount\",\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.addItem.adjudication.value\",\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.addItem.detail\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.addItem.detail.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.addItem.detail.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.addItem.detail.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.addItem.detail.service\",\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.addItem.detail.fee\",\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.addItem.detail.adjudication\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.addItem.detail.adjudication.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.addItem.detail.adjudication.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.addItem.detail.adjudication.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.addItem.detail.adjudication.category\",\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.addItem.detail.adjudication.reason\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.addItem.detail.adjudication.amount\",\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.addItem.detail.adjudication.value\",\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.missingTeeth\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.missingTeeth.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.missingTeeth.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.missingTeeth.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.missingTeeth.tooth\",\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.missingTeeth.reason\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.missingTeeth.extractionDate\",\
		\"type\": \"date\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.totalCost\",\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.unallocDeductable\",\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.totalBenefit\",\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.paymentAdjustment\",\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.paymentAdjustmentReason\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.paymentDate\",\
		\"type\": \"date\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.paymentAmount\",\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.paymentRef\",\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.reserved\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.form\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.note\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.note.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.note.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.note.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.note.number\",\
		\"type\": \"positiveInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.note.type\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.note.text\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.benefitBalance\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.benefitBalance.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.benefitBalance.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.benefitBalance.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.benefitBalance.category\",\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.benefitBalance.subCategory\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.benefitBalance.network\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.benefitBalance.unit\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.benefitBalance.term\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.benefitBalance.financial\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.benefitBalance.financial.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.benefitBalance.financial.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.benefitBalance.financial.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.benefitBalance.financial.type\",\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.benefitBalance.financial.benefitUnsignedInt\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"unsignedInt\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.benefitBalance.financial.benefitQuantity\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.benefitBalance.financial.benefitUsedUnsignedInt\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"unsignedInt\"\
	},\
	{\
		\"path\": \"ExplanationOfBenefit.benefitBalance.financial.benefitUsedQuantity\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"path\": \"FamilyMemberHistory\",\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"FamilyMemberHistory.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"FamilyMemberHistory.meta\",\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"FamilyMemberHistory.implicitRules\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"FamilyMemberHistory.language\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"FamilyMemberHistory.text\",\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"FamilyMemberHistory.contained\",\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"FamilyMemberHistory.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"FamilyMemberHistory.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"FamilyMemberHistory.identifier\",\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"FamilyMemberHistory.patient\",\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"FamilyMemberHistory.date\",\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"FamilyMemberHistory.status\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"FamilyMemberHistory.name\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"FamilyMemberHistory.relationship\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"FamilyMemberHistory.gender\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"FamilyMemberHistory.bornPeriod\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Period\"\
	},\
	{\
		\"path\": \"FamilyMemberHistory.bornDate\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"date\"\
	},\
	{\
		\"path\": \"FamilyMemberHistory.bornString\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"string\"\
	},\
	{\
		\"path\": \"FamilyMemberHistory.ageQuantity\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"path\": \"FamilyMemberHistory.ageRange\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Range\"\
	},\
	{\
		\"path\": \"FamilyMemberHistory.ageString\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"string\"\
	},\
	{\
		\"path\": \"FamilyMemberHistory.deceasedBoolean\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"path\": \"FamilyMemberHistory.deceasedQuantity\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"path\": \"FamilyMemberHistory.deceasedRange\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Range\"\
	},\
	{\
		\"path\": \"FamilyMemberHistory.deceasedDate\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"date\"\
	},\
	{\
		\"path\": \"FamilyMemberHistory.deceasedString\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"string\"\
	},\
	{\
		\"path\": \"FamilyMemberHistory.note\",\
		\"type\": \"Annotation\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"FamilyMemberHistory.condition\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"FamilyMemberHistory.condition.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"FamilyMemberHistory.condition.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"FamilyMemberHistory.condition.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"FamilyMemberHistory.condition.code\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"FamilyMemberHistory.condition.outcome\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"FamilyMemberHistory.condition.onsetQuantity\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"path\": \"FamilyMemberHistory.condition.onsetRange\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Range\"\
	},\
	{\
		\"path\": \"FamilyMemberHistory.condition.onsetPeriod\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Period\"\
	},\
	{\
		\"path\": \"FamilyMemberHistory.condition.onsetString\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"string\"\
	},\
	{\
		\"path\": \"FamilyMemberHistory.condition.note\",\
		\"type\": \"Annotation\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Flag\",\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Flag.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Flag.meta\",\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Flag.implicitRules\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Flag.language\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Flag.text\",\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Flag.contained\",\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Flag.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Flag.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Flag.identifier\",\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Flag.category\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Flag.status\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Flag.period\",\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Flag.subject\",\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Flag.encounter\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Flag.author\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Flag.code\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Goal\",\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Goal.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Goal.meta\",\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Goal.implicitRules\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Goal.language\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Goal.text\",\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Goal.contained\",\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Goal.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Goal.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Goal.identifier\",\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Goal.subject\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Goal.startDate\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"date\"\
	},\
	{\
		\"path\": \"Goal.startCodeableConcept\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"path\": \"Goal.targetDate\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"date\"\
	},\
	{\
		\"path\": \"Goal.targetQuantity\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"path\": \"Goal.category\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Goal.description\",\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Goal.status\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Goal.statusDate\",\
		\"type\": \"date\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Goal.statusReason\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Goal.expressedBy\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Goal.priority\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Goal.addresses\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Goal.note\",\
		\"type\": \"Annotation\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Goal.outcome\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Goal.outcome.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Goal.outcome.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Goal.outcome.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Goal.outcome.resultCodeableConcept\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"path\": \"Goal.outcome.resultReference\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"Group\",\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Group.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Group.meta\",\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Group.implicitRules\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Group.language\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Group.text\",\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Group.contained\",\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Group.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Group.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Group.identifier\",\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Group.type\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Group.actual\",\
		\"type\": \"boolean\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Group.active\",\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Group.code\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Group.name\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Group.quantity\",\
		\"type\": \"unsignedInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Group.characteristic\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Group.characteristic.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Group.characteristic.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Group.characteristic.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Group.characteristic.code\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Group.characteristic.valueCodeableConcept\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"path\": \"Group.characteristic.valueBoolean\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"path\": \"Group.characteristic.valueQuantity\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"path\": \"Group.characteristic.valueRange\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"Range\"\
	},\
	{\
		\"path\": \"Group.characteristic.exclude\",\
		\"type\": \"boolean\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Group.characteristic.period\",\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Group.member\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Group.member.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Group.member.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Group.member.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Group.member.entity\",\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Group.member.period\",\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Group.member.inactive\",\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"GuidanceResponse\",\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"GuidanceResponse.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"GuidanceResponse.meta\",\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"GuidanceResponse.implicitRules\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"GuidanceResponse.language\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"GuidanceResponse.text\",\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"GuidanceResponse.contained\",\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"GuidanceResponse.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"GuidanceResponse.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"GuidanceResponse.requestId\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"GuidanceResponse.module\",\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"GuidanceResponse.status\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"GuidanceResponse.evaluationMessage\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"GuidanceResponse.outputParameters\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"GuidanceResponse.action\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"GuidanceResponse.action.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"GuidanceResponse.action.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"GuidanceResponse.action.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"GuidanceResponse.action.actionIdentifier\",\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"GuidanceResponse.action.label\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"GuidanceResponse.action.title\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"GuidanceResponse.action.description\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"GuidanceResponse.action.textEquivalent\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"GuidanceResponse.action.concept\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"GuidanceResponse.action.supportingEvidence\",\
		\"type\": \"Attachment\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"GuidanceResponse.action.relatedAction\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"GuidanceResponse.action.relatedAction.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"GuidanceResponse.action.relatedAction.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"GuidanceResponse.action.relatedAction.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"GuidanceResponse.action.relatedAction.actionIdentifier\",\
		\"type\": \"Identifier\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"GuidanceResponse.action.relatedAction.relationship\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"GuidanceResponse.action.relatedAction.offsetQuantity\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"path\": \"GuidanceResponse.action.relatedAction.offsetRange\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Range\"\
	},\
	{\
		\"path\": \"GuidanceResponse.action.relatedAction.anchor\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"GuidanceResponse.action.documentation\",\
		\"type\": \"Attachment\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"GuidanceResponse.action.participant\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"GuidanceResponse.action.type\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"GuidanceResponse.action.behavior\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"GuidanceResponse.action.behavior.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"GuidanceResponse.action.behavior.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"GuidanceResponse.action.behavior.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"GuidanceResponse.action.behavior.type\",\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"GuidanceResponse.action.behavior.value\",\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"GuidanceResponse.action.resource\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"GuidanceResponse.action.action\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"GuidanceResponse.dataRequirement\",\
		\"type\": \"DataRequirement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"HealthcareService\",\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"HealthcareService.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"HealthcareService.meta\",\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"HealthcareService.implicitRules\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"HealthcareService.language\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"HealthcareService.text\",\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"HealthcareService.contained\",\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"HealthcareService.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"HealthcareService.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"HealthcareService.identifier\",\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"HealthcareService.providedBy\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"HealthcareService.serviceCategory\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"HealthcareService.serviceType\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"HealthcareService.specialty\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"HealthcareService.location\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"HealthcareService.serviceName\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"HealthcareService.comment\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"HealthcareService.extraDetails\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"HealthcareService.photo\",\
		\"type\": \"Attachment\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"HealthcareService.telecom\",\
		\"type\": \"ContactPoint\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"HealthcareService.coverageArea\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"HealthcareService.serviceProvisionCode\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"HealthcareService.eligibility\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"HealthcareService.eligibilityNote\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"HealthcareService.programName\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"HealthcareService.characteristic\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"HealthcareService.referralMethod\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"HealthcareService.publicKey\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"HealthcareService.appointmentRequired\",\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"HealthcareService.availableTime\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"HealthcareService.availableTime.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"HealthcareService.availableTime.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"HealthcareService.availableTime.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"HealthcareService.availableTime.daysOfWeek\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"HealthcareService.availableTime.allDay\",\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"HealthcareService.availableTime.availableStartTime\",\
		\"type\": \"time\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"HealthcareService.availableTime.availableEndTime\",\
		\"type\": \"time\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"HealthcareService.notAvailable\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"HealthcareService.notAvailable.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"HealthcareService.notAvailable.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"HealthcareService.notAvailable.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"HealthcareService.notAvailable.description\",\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"HealthcareService.notAvailable.during\",\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"HealthcareService.availabilityExceptions\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingExcerpt\",\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.meta\",\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.implicitRules\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.language\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.text\",\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.contained\",\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.uid\",\
		\"type\": \"oid\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.patient\",\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.authoringTime\",\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.author\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.title\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.description\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.study\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.study.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.study.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.study.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.study.uid\",\
		\"type\": \"oid\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.study.imagingStudy\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.study.dicom\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.study.dicom.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.study.dicom.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.study.dicom.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.study.dicom.type\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.study.dicom.url\",\
		\"type\": \"uri\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.study.viewable\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.study.viewable.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.study.viewable.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.study.viewable.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.study.viewable.contentType\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.study.viewable.height\",\
		\"type\": \"positiveInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.study.viewable.width\",\
		\"type\": \"positiveInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.study.viewable.frames\",\
		\"type\": \"positiveInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.study.viewable.duration\",\
		\"type\": \"unsignedInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.study.viewable.size\",\
		\"type\": \"unsignedInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.study.viewable.title\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.study.viewable.url\",\
		\"type\": \"uri\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.study.series\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.study.series.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.study.series.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.study.series.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.study.series.uid\",\
		\"type\": \"oid\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.study.series.dicom\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.study.series.dicom.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.study.series.dicom.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.study.series.dicom.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.study.series.dicom.type\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.study.series.dicom.url\",\
		\"type\": \"uri\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.study.series.instance\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.study.series.instance.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.study.series.instance.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.study.series.instance.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.study.series.instance.sopClass\",\
		\"type\": \"oid\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.study.series.instance.uid\",\
		\"type\": \"oid\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.study.series.instance.dicom\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.study.series.instance.dicom.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.study.series.instance.dicom.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.study.series.instance.dicom.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.study.series.instance.dicom.type\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.study.series.instance.dicom.url\",\
		\"type\": \"uri\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingExcerpt.study.series.instance.frameNumbers\",\
		\"type\": \"unsignedInt\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingObjectSelection\",\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingObjectSelection.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingObjectSelection.meta\",\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingObjectSelection.implicitRules\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingObjectSelection.language\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingObjectSelection.text\",\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingObjectSelection.contained\",\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingObjectSelection.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingObjectSelection.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingObjectSelection.uid\",\
		\"type\": \"oid\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingObjectSelection.patient\",\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingObjectSelection.authoringTime\",\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingObjectSelection.author\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingObjectSelection.title\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingObjectSelection.description\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingObjectSelection.study\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingObjectSelection.study.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingObjectSelection.study.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingObjectSelection.study.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingObjectSelection.study.uid\",\
		\"type\": \"oid\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingObjectSelection.study.url\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingObjectSelection.study.imagingStudy\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingObjectSelection.study.series\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingObjectSelection.study.series.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingObjectSelection.study.series.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingObjectSelection.study.series.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingObjectSelection.study.series.uid\",\
		\"type\": \"oid\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingObjectSelection.study.series.url\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingObjectSelection.study.series.instance\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingObjectSelection.study.series.instance.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingObjectSelection.study.series.instance.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingObjectSelection.study.series.instance.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingObjectSelection.study.series.instance.sopClass\",\
		\"type\": \"oid\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingObjectSelection.study.series.instance.uid\",\
		\"type\": \"oid\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingObjectSelection.study.series.instance.url\",\
		\"type\": \"uri\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingObjectSelection.study.series.instance.frame\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingObjectSelection.study.series.instance.frame.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingObjectSelection.study.series.instance.frame.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingObjectSelection.study.series.instance.frame.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingObjectSelection.study.series.instance.frame.number\",\
		\"type\": \"unsignedInt\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingObjectSelection.study.series.instance.frame.url\",\
		\"type\": \"uri\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingStudy\",\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingStudy.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingStudy.meta\",\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingStudy.implicitRules\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingStudy.language\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingStudy.text\",\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingStudy.contained\",\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingStudy.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingStudy.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingStudy.uid\",\
		\"type\": \"oid\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingStudy.accession\",\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingStudy.identifier\",\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingStudy.availability\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingStudy.modalityList\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingStudy.patient\",\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingStudy.started\",\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingStudy.order\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingStudy.referrer\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingStudy.interpreter\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingStudy.url\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingStudy.numberOfSeries\",\
		\"type\": \"unsignedInt\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingStudy.numberOfInstances\",\
		\"type\": \"unsignedInt\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingStudy.procedure\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingStudy.description\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingStudy.series\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingStudy.series.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingStudy.series.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingStudy.series.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingStudy.series.uid\",\
		\"type\": \"oid\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingStudy.series.number\",\
		\"type\": \"unsignedInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingStudy.series.modality\",\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingStudy.series.description\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingStudy.series.numberOfInstances\",\
		\"type\": \"unsignedInt\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingStudy.series.availability\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingStudy.series.url\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingStudy.series.bodySite\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingStudy.series.laterality\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingStudy.series.started\",\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingStudy.series.instance\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingStudy.series.instance.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingStudy.series.instance.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingStudy.series.instance.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImagingStudy.series.instance.uid\",\
		\"type\": \"oid\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingStudy.series.instance.number\",\
		\"type\": \"unsignedInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingStudy.series.instance.sopClass\",\
		\"type\": \"oid\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingStudy.series.instance.type\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingStudy.series.instance.title\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImagingStudy.series.instance.content\",\
		\"type\": \"Attachment\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Immunization\",\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Immunization.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Immunization.meta\",\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Immunization.implicitRules\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Immunization.language\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Immunization.text\",\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Immunization.contained\",\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Immunization.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Immunization.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Immunization.identifier\",\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Immunization.status\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Immunization.date\",\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Immunization.vaccineCode\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Immunization.patient\",\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Immunization.wasNotGiven\",\
		\"type\": \"boolean\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Immunization.reported\",\
		\"type\": \"boolean\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Immunization.performer\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Immunization.requester\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Immunization.encounter\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Immunization.manufacturer\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Immunization.location\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Immunization.lotNumber\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Immunization.expirationDate\",\
		\"type\": \"date\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Immunization.site\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Immunization.route\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Immunization.doseQuantity\",\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Immunization.note\",\
		\"type\": \"Annotation\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Immunization.explanation\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Immunization.explanation.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Immunization.explanation.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Immunization.explanation.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Immunization.explanation.reason\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Immunization.explanation.reasonNotGiven\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Immunization.reaction\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Immunization.reaction.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Immunization.reaction.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Immunization.reaction.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Immunization.reaction.date\",\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Immunization.reaction.detail\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Immunization.reaction.reported\",\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Immunization.vaccinationProtocol\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Immunization.vaccinationProtocol.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Immunization.vaccinationProtocol.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Immunization.vaccinationProtocol.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Immunization.vaccinationProtocol.doseSequence\",\
		\"type\": \"positiveInt\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Immunization.vaccinationProtocol.description\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Immunization.vaccinationProtocol.authority\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Immunization.vaccinationProtocol.series\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Immunization.vaccinationProtocol.seriesDoses\",\
		\"type\": \"positiveInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Immunization.vaccinationProtocol.targetDisease\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Immunization.vaccinationProtocol.doseStatus\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Immunization.vaccinationProtocol.doseStatusReason\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImmunizationRecommendation\",\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImmunizationRecommendation.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImmunizationRecommendation.meta\",\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImmunizationRecommendation.implicitRules\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImmunizationRecommendation.language\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImmunizationRecommendation.text\",\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImmunizationRecommendation.contained\",\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImmunizationRecommendation.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImmunizationRecommendation.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImmunizationRecommendation.identifier\",\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImmunizationRecommendation.patient\",\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImmunizationRecommendation.recommendation\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImmunizationRecommendation.recommendation.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImmunizationRecommendation.recommendation.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImmunizationRecommendation.recommendation.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImmunizationRecommendation.recommendation.date\",\
		\"type\": \"dateTime\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImmunizationRecommendation.recommendation.vaccineCode\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImmunizationRecommendation.recommendation.doseNumber\",\
		\"type\": \"positiveInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImmunizationRecommendation.recommendation.forecastStatus\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImmunizationRecommendation.recommendation.dateCriterion\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImmunizationRecommendation.recommendation.dateCriterion.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImmunizationRecommendation.recommendation.dateCriterion.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImmunizationRecommendation.recommendation.dateCriterion.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImmunizationRecommendation.recommendation.dateCriterion.code\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImmunizationRecommendation.recommendation.dateCriterion.value\",\
		\"type\": \"dateTime\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImmunizationRecommendation.recommendation.protocol\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImmunizationRecommendation.recommendation.protocol.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImmunizationRecommendation.recommendation.protocol.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImmunizationRecommendation.recommendation.protocol.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImmunizationRecommendation.recommendation.protocol.doseSequence\",\
		\"type\": \"integer\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImmunizationRecommendation.recommendation.protocol.description\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImmunizationRecommendation.recommendation.protocol.authority\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImmunizationRecommendation.recommendation.protocol.series\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImmunizationRecommendation.recommendation.supportingImmunization\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImmunizationRecommendation.recommendation.supportingPatientInformation\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImplementationGuide\",\
		\"type\": \"DomainResource\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImplementationGuide.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImplementationGuide.meta\",\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImplementationGuide.implicitRules\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImplementationGuide.language\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImplementationGuide.text\",\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImplementationGuide.contained\",\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImplementationGuide.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImplementationGuide.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImplementationGuide.url\",\
		\"type\": \"uri\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImplementationGuide.version\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImplementationGuide.name\",\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImplementationGuide.status\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImplementationGuide.experimental\",\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImplementationGuide.publisher\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImplementationGuide.contact\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImplementationGuide.contact.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImplementationGuide.contact.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImplementationGuide.contact.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImplementationGuide.contact.name\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImplementationGuide.contact.telecom\",\
		\"type\": \"ContactPoint\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImplementationGuide.date\",\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImplementationGuide.description\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImplementationGuide.useContext\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImplementationGuide.copyright\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImplementationGuide.fhirVersion\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImplementationGuide.dependency\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImplementationGuide.dependency.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImplementationGuide.dependency.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImplementationGuide.dependency.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImplementationGuide.dependency.type\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImplementationGuide.dependency.uri\",\
		\"type\": \"uri\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImplementationGuide.package\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImplementationGuide.package.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImplementationGuide.package.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImplementationGuide.package.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImplementationGuide.package.name\",\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImplementationGuide.package.description\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImplementationGuide.package.resource\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImplementationGuide.package.resource.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImplementationGuide.package.resource.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImplementationGuide.package.resource.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImplementationGuide.package.resource.example\",\
		\"type\": \"boolean\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImplementationGuide.package.resource.name\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImplementationGuide.package.resource.description\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImplementationGuide.package.resource.acronym\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImplementationGuide.package.resource.sourceUri\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"path\": \"ImplementationGuide.package.resource.sourceReference\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"ImplementationGuide.package.resource.exampleFor\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImplementationGuide.global\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImplementationGuide.global.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImplementationGuide.global.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImplementationGuide.global.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImplementationGuide.global.type\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImplementationGuide.global.profile\",\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImplementationGuide.binary\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImplementationGuide.page\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImplementationGuide.page.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImplementationGuide.page.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImplementationGuide.page.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImplementationGuide.page.source\",\
		\"type\": \"uri\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImplementationGuide.page.name\",\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImplementationGuide.page.kind\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImplementationGuide.page.type\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImplementationGuide.page.package\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ImplementationGuide.page.format\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ImplementationGuide.page.page\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Library\",\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Library.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Library.meta\",\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Library.implicitRules\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Library.language\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Library.text\",\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Library.contained\",\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Library.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Library.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Library.moduleMetadata\",\
		\"type\": \"ModuleMetadata\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Library.model\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Library.model.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Library.model.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Library.model.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Library.model.name\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Library.model.identifier\",\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Library.model.version\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Library.library\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Library.library.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Library.library.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Library.library.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Library.library.name\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Library.library.identifier\",\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Library.library.version\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Library.library.documentAttachment\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Attachment\"\
	},\
	{\
		\"path\": \"Library.library.documentReference\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"Library.codeSystem\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Library.codeSystem.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Library.codeSystem.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Library.codeSystem.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Library.codeSystem.name\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Library.codeSystem.identifier\",\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Library.codeSystem.version\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Library.valueSet\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Library.valueSet.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Library.valueSet.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Library.valueSet.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Library.valueSet.name\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Library.valueSet.identifier\",\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Library.valueSet.version\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Library.valueSet.codeSystem\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Library.parameter\",\
		\"type\": \"ParameterDefinition\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Library.dataRequirement\",\
		\"type\": \"DataRequirement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Library.document\",\
		\"type\": \"Attachment\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Linkage\",\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Linkage.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Linkage.meta\",\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Linkage.implicitRules\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Linkage.language\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Linkage.text\",\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Linkage.contained\",\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Linkage.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Linkage.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Linkage.author\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Linkage.item\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Linkage.item.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Linkage.item.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Linkage.item.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Linkage.item.type\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Linkage.item.resource\",\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"List\",\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"List.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"List.meta\",\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"List.implicitRules\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"List.language\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"List.text\",\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"List.contained\",\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"List.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"List.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"List.identifier\",\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"List.status\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"List.mode\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"List.title\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"List.code\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"List.subject\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"List.encounter\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"List.date\",\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"List.source\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"List.orderedBy\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"List.note\",\
		\"type\": \"Annotation\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"List.entry\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"List.entry.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"List.entry.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"List.entry.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"List.entry.flag\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"List.entry.deleted\",\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"List.entry.date\",\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"List.entry.item\",\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"List.emptyReason\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Location\",\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Location.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Location.meta\",\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Location.implicitRules\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Location.language\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Location.text\",\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Location.contained\",\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Location.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Location.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Location.identifier\",\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Location.status\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Location.name\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Location.description\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Location.mode\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Location.type\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Location.telecom\",\
		\"type\": \"ContactPoint\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Location.address\",\
		\"type\": \"Address\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Location.physicalType\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Location.position\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Location.position.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Location.position.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Location.position.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Location.position.longitude\",\
		\"type\": \"decimal\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Location.position.latitude\",\
		\"type\": \"decimal\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Location.position.altitude\",\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Location.managingOrganization\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Location.partOf\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Measure\",\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Measure.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Measure.meta\",\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Measure.implicitRules\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Measure.language\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Measure.text\",\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Measure.contained\",\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Measure.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Measure.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Measure.moduleMetadata\",\
		\"type\": \"ModuleMetadata\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Measure.library\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Measure.disclaimer\",\
		\"type\": \"markdown\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Measure.scoring\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Measure.type\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Measure.riskAdjustment\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Measure.rateAggregation\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Measure.rationale\",\
		\"type\": \"markdown\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Measure.clinicalRecommendationStatement\",\
		\"type\": \"markdown\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Measure.improvementNotation\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Measure.definition\",\
		\"type\": \"markdown\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Measure.guidance\",\
		\"type\": \"markdown\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Measure.set\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Measure.group\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Measure.group.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Measure.group.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Measure.group.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Measure.group.identifier\",\
		\"type\": \"Identifier\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Measure.group.name\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Measure.group.description\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Measure.group.population\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Measure.group.population.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Measure.group.population.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Measure.group.population.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Measure.group.population.type\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Measure.group.population.identifier\",\
		\"type\": \"Identifier\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Measure.group.population.name\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Measure.group.population.description\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Measure.group.population.criteria\",\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Measure.group.stratifier\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Measure.group.stratifier.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Measure.group.stratifier.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Measure.group.stratifier.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Measure.group.stratifier.identifier\",\
		\"type\": \"Identifier\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Measure.group.stratifier.criteria\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Measure.group.stratifier.path\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Measure.supplementalData\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Measure.supplementalData.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Measure.supplementalData.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Measure.supplementalData.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Measure.supplementalData.identifier\",\
		\"type\": \"Identifier\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Measure.supplementalData.usage\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Measure.supplementalData.criteria\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Measure.supplementalData.path\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MeasureReport\",\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MeasureReport.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MeasureReport.meta\",\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MeasureReport.implicitRules\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MeasureReport.language\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MeasureReport.text\",\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MeasureReport.contained\",\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MeasureReport.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MeasureReport.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MeasureReport.measure\",\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MeasureReport.type\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MeasureReport.patient\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MeasureReport.period\",\
		\"type\": \"Period\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MeasureReport.status\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MeasureReport.date\",\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MeasureReport.reportingOrganization\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MeasureReport.group\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MeasureReport.group.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MeasureReport.group.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MeasureReport.group.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MeasureReport.group.identifier\",\
		\"type\": \"Identifier\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MeasureReport.group.population\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MeasureReport.group.population.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MeasureReport.group.population.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MeasureReport.group.population.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MeasureReport.group.population.type\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MeasureReport.group.population.count\",\
		\"type\": \"integer\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MeasureReport.group.population.patients\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MeasureReport.group.measureScore\",\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MeasureReport.group.stratifier\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MeasureReport.group.stratifier.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MeasureReport.group.stratifier.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MeasureReport.group.stratifier.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MeasureReport.group.stratifier.identifier\",\
		\"type\": \"Identifier\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MeasureReport.group.stratifier.group\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MeasureReport.group.stratifier.group.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MeasureReport.group.stratifier.group.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MeasureReport.group.stratifier.group.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MeasureReport.group.stratifier.group.value\",\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MeasureReport.group.stratifier.group.population\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MeasureReport.group.stratifier.group.population.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MeasureReport.group.stratifier.group.population.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MeasureReport.group.stratifier.group.population.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MeasureReport.group.stratifier.group.population.type\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MeasureReport.group.stratifier.group.population.count\",\
		\"type\": \"integer\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MeasureReport.group.stratifier.group.population.patients\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MeasureReport.group.stratifier.group.measureScore\",\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MeasureReport.group.supplementalData\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MeasureReport.group.supplementalData.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MeasureReport.group.supplementalData.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MeasureReport.group.supplementalData.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MeasureReport.group.supplementalData.identifier\",\
		\"type\": \"Identifier\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MeasureReport.group.supplementalData.group\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MeasureReport.group.supplementalData.group.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MeasureReport.group.supplementalData.group.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MeasureReport.group.supplementalData.group.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MeasureReport.group.supplementalData.group.value\",\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MeasureReport.group.supplementalData.group.count\",\
		\"type\": \"integer\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MeasureReport.group.supplementalData.group.patients\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MeasureReport.evaluatedResources\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Media\",\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Media.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Media.meta\",\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Media.implicitRules\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Media.language\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Media.text\",\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Media.contained\",\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Media.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Media.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Media.identifier\",\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Media.type\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Media.subtype\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Media.view\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Media.subject\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Media.operator\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Media.deviceName\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Media.height\",\
		\"type\": \"positiveInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Media.width\",\
		\"type\": \"positiveInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Media.frames\",\
		\"type\": \"positiveInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Media.duration\",\
		\"type\": \"unsignedInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Media.content\",\
		\"type\": \"Attachment\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Medication\",\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Medication.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Medication.meta\",\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Medication.implicitRules\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Medication.language\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Medication.text\",\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Medication.contained\",\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Medication.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Medication.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Medication.code\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Medication.isBrand\",\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Medication.manufacturer\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Medication.product\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Medication.product.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Medication.product.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Medication.product.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Medication.product.form\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Medication.product.ingredient\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Medication.product.ingredient.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Medication.product.ingredient.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Medication.product.ingredient.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Medication.product.ingredient.itemCodeableConcept\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"path\": \"Medication.product.ingredient.itemReference\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"Medication.product.ingredient.itemReference\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"Medication.product.ingredient.amount\",\
		\"type\": \"Ratio\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Medication.product.batch\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Medication.product.batch.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Medication.product.batch.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Medication.product.batch.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Medication.product.batch.lotNumber\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Medication.product.batch.expirationDate\",\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Medication.package\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Medication.package.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Medication.package.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Medication.package.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Medication.package.container\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Medication.package.content\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Medication.package.content.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Medication.package.content.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Medication.package.content.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Medication.package.content.itemCodeableConcept\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"path\": \"Medication.package.content.itemReference\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"Medication.package.content.amount\",\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationAdministration\",\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationAdministration.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationAdministration.meta\",\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationAdministration.implicitRules\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationAdministration.language\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationAdministration.text\",\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationAdministration.contained\",\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationAdministration.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationAdministration.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationAdministration.identifier\",\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationAdministration.status\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationAdministration.medicationCodeableConcept\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"path\": \"MedicationAdministration.medicationReference\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"MedicationAdministration.patient\",\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationAdministration.encounter\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationAdministration.effectiveTimeDateTime\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"path\": \"MedicationAdministration.effectiveTimePeriod\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"path\": \"MedicationAdministration.practitioner\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationAdministration.prescription\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationAdministration.wasNotGiven\",\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationAdministration.reasonNotGiven\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationAdministration.reasonGiven\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationAdministration.device\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationAdministration.note\",\
		\"type\": \"Annotation\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationAdministration.dosage\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationAdministration.dosage.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationAdministration.dosage.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationAdministration.dosage.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationAdministration.dosage.text\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationAdministration.dosage.siteCodeableConcept\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"path\": \"MedicationAdministration.dosage.siteReference\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"MedicationAdministration.dosage.route\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationAdministration.dosage.method\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationAdministration.dosage.quantity\",\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationAdministration.dosage.rateRatio\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Ratio\"\
	},\
	{\
		\"path\": \"MedicationAdministration.dosage.rateRange\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Range\"\
	},\
	{\
		\"path\": \"MedicationDispense\",\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationDispense.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationDispense.meta\",\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationDispense.implicitRules\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationDispense.language\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationDispense.text\",\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationDispense.contained\",\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationDispense.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationDispense.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationDispense.identifier\",\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationDispense.status\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationDispense.medicationCodeableConcept\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"path\": \"MedicationDispense.medicationReference\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"MedicationDispense.patient\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationDispense.dispenser\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationDispense.authorizingPrescription\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationDispense.type\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationDispense.quantity\",\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationDispense.daysSupply\",\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationDispense.whenPrepared\",\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationDispense.whenHandedOver\",\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationDispense.destination\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationDispense.receiver\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationDispense.note\",\
		\"type\": \"Annotation\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationDispense.dosageInstruction\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationDispense.dosageInstruction.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationDispense.dosageInstruction.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationDispense.dosageInstruction.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationDispense.dosageInstruction.text\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationDispense.dosageInstruction.additionalInstructions\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationDispense.dosageInstruction.timing\",\
		\"type\": \"Timing\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationDispense.dosageInstruction.asNeededBoolean\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"path\": \"MedicationDispense.dosageInstruction.asNeededCodeableConcept\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"path\": \"MedicationDispense.dosageInstruction.siteCodeableConcept\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"path\": \"MedicationDispense.dosageInstruction.siteReference\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"MedicationDispense.dosageInstruction.route\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationDispense.dosageInstruction.method\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationDispense.dosageInstruction.doseRange\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Range\"\
	},\
	{\
		\"path\": \"MedicationDispense.dosageInstruction.doseQuantity\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"path\": \"MedicationDispense.dosageInstruction.rateRatio\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Ratio\"\
	},\
	{\
		\"path\": \"MedicationDispense.dosageInstruction.rateRange\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Range\"\
	},\
	{\
		\"path\": \"MedicationDispense.dosageInstruction.maxDosePerPeriod\",\
		\"type\": \"Ratio\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationDispense.substitution\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationDispense.substitution.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationDispense.substitution.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationDispense.substitution.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationDispense.substitution.type\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationDispense.substitution.reason\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationDispense.substitution.responsibleParty\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationOrder\",\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationOrder.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationOrder.meta\",\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationOrder.implicitRules\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationOrder.language\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationOrder.text\",\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationOrder.contained\",\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationOrder.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationOrder.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationOrder.identifier\",\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationOrder.status\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationOrder.medicationCodeableConcept\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"path\": \"MedicationOrder.medicationReference\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"MedicationOrder.patient\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationOrder.encounter\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationOrder.dateWritten\",\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationOrder.prescriber\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationOrder.reasonCode\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationOrder.reasonReference\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationOrder.dateEnded\",\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationOrder.reasonEnded\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationOrder.note\",\
		\"type\": \"Annotation\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationOrder.dosageInstruction\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationOrder.dosageInstruction.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationOrder.dosageInstruction.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationOrder.dosageInstruction.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationOrder.dosageInstruction.text\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationOrder.dosageInstruction.additionalInstructions\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationOrder.dosageInstruction.timing\",\
		\"type\": \"Timing\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationOrder.dosageInstruction.asNeededBoolean\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"path\": \"MedicationOrder.dosageInstruction.asNeededCodeableConcept\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"path\": \"MedicationOrder.dosageInstruction.siteCodeableConcept\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"path\": \"MedicationOrder.dosageInstruction.siteReference\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"MedicationOrder.dosageInstruction.route\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationOrder.dosageInstruction.method\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationOrder.dosageInstruction.doseRange\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Range\"\
	},\
	{\
		\"path\": \"MedicationOrder.dosageInstruction.doseQuantity\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"path\": \"MedicationOrder.dosageInstruction.maxDosePerPeriod\",\
		\"type\": \"Ratio\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationOrder.dosageInstruction.maxDosePerAdministration\",\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationOrder.dosageInstruction.rateRatio\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Ratio\"\
	},\
	{\
		\"path\": \"MedicationOrder.dosageInstruction.rateRange\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Range\"\
	},\
	{\
		\"path\": \"MedicationOrder.dosageInstruction.rateQuantity\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"path\": \"MedicationOrder.dispenseRequest\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationOrder.dispenseRequest.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationOrder.dispenseRequest.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationOrder.dispenseRequest.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationOrder.dispenseRequest.medicationCodeableConcept\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"path\": \"MedicationOrder.dispenseRequest.medicationReference\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"MedicationOrder.dispenseRequest.validityPeriod\",\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationOrder.dispenseRequest.numberOfRepeatsAllowed\",\
		\"type\": \"positiveInt\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationOrder.dispenseRequest.quantity\",\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationOrder.dispenseRequest.expectedSupplyDuration\",\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationOrder.substitution\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationOrder.substitution.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationOrder.substitution.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationOrder.substitution.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationOrder.substitution.type\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationOrder.substitution.reason\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationOrder.priorPrescription\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationStatement\",\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationStatement.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationStatement.meta\",\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationStatement.implicitRules\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationStatement.language\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationStatement.text\",\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationStatement.contained\",\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationStatement.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationStatement.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationStatement.identifier\",\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationStatement.status\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationStatement.medicationCodeableConcept\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"path\": \"MedicationStatement.medicationReference\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"MedicationStatement.patient\",\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationStatement.effectiveDateTime\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"path\": \"MedicationStatement.effectivePeriod\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Period\"\
	},\
	{\
		\"path\": \"MedicationStatement.informationSource\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationStatement.supportingInformation\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationStatement.dateAsserted\",\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationStatement.wasNotTaken\",\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationStatement.reasonNotTaken\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationStatement.reasonForUseCode\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationStatement.reasonForUseReference\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationStatement.note\",\
		\"type\": \"Annotation\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationStatement.dosage\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationStatement.dosage.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationStatement.dosage.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationStatement.dosage.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MedicationStatement.dosage.text\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationStatement.dosage.timing\",\
		\"type\": \"Timing\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationStatement.dosage.asNeededBoolean\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"path\": \"MedicationStatement.dosage.asNeededCodeableConcept\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"path\": \"MedicationStatement.dosage.siteCodeableConcept\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"path\": \"MedicationStatement.dosage.siteReference\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"MedicationStatement.dosage.route\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationStatement.dosage.method\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MedicationStatement.dosage.quantityQuantity\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"path\": \"MedicationStatement.dosage.quantityRange\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Range\"\
	},\
	{\
		\"path\": \"MedicationStatement.dosage.rateRatio\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Ratio\"\
	},\
	{\
		\"path\": \"MedicationStatement.dosage.rateRange\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Range\"\
	},\
	{\
		\"path\": \"MedicationStatement.dosage.maxDosePerPeriod\",\
		\"type\": \"Ratio\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MessageHeader\",\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MessageHeader.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MessageHeader.meta\",\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MessageHeader.implicitRules\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MessageHeader.language\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MessageHeader.text\",\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MessageHeader.contained\",\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MessageHeader.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MessageHeader.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MessageHeader.timestamp\",\
		\"type\": \"instant\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MessageHeader.event\",\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MessageHeader.response\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MessageHeader.response.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MessageHeader.response.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MessageHeader.response.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MessageHeader.response.identifier\",\
		\"type\": \"id\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MessageHeader.response.code\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MessageHeader.response.details\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MessageHeader.source\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MessageHeader.source.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MessageHeader.source.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MessageHeader.source.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MessageHeader.source.name\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MessageHeader.source.software\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MessageHeader.source.version\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MessageHeader.source.contact\",\
		\"type\": \"ContactPoint\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MessageHeader.source.endpoint\",\
		\"type\": \"uri\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MessageHeader.destination\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MessageHeader.destination.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MessageHeader.destination.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MessageHeader.destination.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"MessageHeader.destination.name\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MessageHeader.destination.target\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MessageHeader.destination.endpoint\",\
		\"type\": \"uri\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MessageHeader.enterer\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MessageHeader.author\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MessageHeader.receiver\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MessageHeader.responsible\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MessageHeader.reason\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"MessageHeader.data\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ModuleDefinition\",\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ModuleDefinition.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleDefinition.meta\",\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleDefinition.implicitRules\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleDefinition.language\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleDefinition.text\",\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleDefinition.contained\",\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ModuleDefinition.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ModuleDefinition.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ModuleDefinition.identifier\",\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ModuleDefinition.version\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleDefinition.model\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ModuleDefinition.model.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleDefinition.model.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ModuleDefinition.model.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ModuleDefinition.model.name\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleDefinition.model.identifier\",\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleDefinition.model.version\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleDefinition.library\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ModuleDefinition.library.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleDefinition.library.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ModuleDefinition.library.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ModuleDefinition.library.name\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleDefinition.library.identifier\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleDefinition.library.version\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleDefinition.library.documentAttachment\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Attachment\"\
	},\
	{\
		\"path\": \"ModuleDefinition.library.documentReference\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"ModuleDefinition.codeSystem\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ModuleDefinition.codeSystem.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleDefinition.codeSystem.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ModuleDefinition.codeSystem.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ModuleDefinition.codeSystem.name\",\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleDefinition.codeSystem.identifier\",\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleDefinition.codeSystem.version\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleDefinition.valueSet\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ModuleDefinition.valueSet.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleDefinition.valueSet.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ModuleDefinition.valueSet.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ModuleDefinition.valueSet.name\",\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleDefinition.valueSet.identifier\",\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleDefinition.valueSet.version\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleDefinition.valueSet.codeSystem\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ModuleDefinition.parameter\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ModuleDefinition.parameter.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleDefinition.parameter.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ModuleDefinition.parameter.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ModuleDefinition.parameter.name\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleDefinition.parameter.use\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleDefinition.parameter.documentation\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleDefinition.parameter.type\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleDefinition.parameter.profile\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleDefinition.data\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ModuleDefinition.data.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleDefinition.data.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ModuleDefinition.data.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ModuleDefinition.data.type\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleDefinition.data.profile\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleDefinition.data.mustSupport\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ModuleDefinition.data.codeFilter\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ModuleDefinition.data.codeFilter.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleDefinition.data.codeFilter.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ModuleDefinition.data.codeFilter.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ModuleDefinition.data.codeFilter.path\",\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleDefinition.data.codeFilter.valueSetString\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"string\"\
	},\
	{\
		\"path\": \"ModuleDefinition.data.codeFilter.valueSetReference\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"ModuleDefinition.data.codeFilter.codeableConcept\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ModuleDefinition.data.dateFilter\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ModuleDefinition.data.dateFilter.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleDefinition.data.dateFilter.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ModuleDefinition.data.dateFilter.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ModuleDefinition.data.dateFilter.path\",\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ModuleDefinition.data.dateFilter.valueDateTime\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"path\": \"ModuleDefinition.data.dateFilter.valuePeriod\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Period\"\
	},\
	{\
		\"path\": \"NamingSystem\",\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"NamingSystem.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NamingSystem.meta\",\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NamingSystem.implicitRules\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NamingSystem.language\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NamingSystem.text\",\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NamingSystem.contained\",\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"NamingSystem.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"NamingSystem.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"NamingSystem.name\",\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NamingSystem.status\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NamingSystem.kind\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NamingSystem.date\",\
		\"type\": \"dateTime\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NamingSystem.publisher\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NamingSystem.contact\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"NamingSystem.contact.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NamingSystem.contact.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"NamingSystem.contact.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"NamingSystem.contact.name\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NamingSystem.contact.telecom\",\
		\"type\": \"ContactPoint\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"NamingSystem.responsible\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NamingSystem.type\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NamingSystem.description\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NamingSystem.useContext\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"NamingSystem.usage\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NamingSystem.uniqueId\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"NamingSystem.uniqueId.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NamingSystem.uniqueId.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"NamingSystem.uniqueId.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"NamingSystem.uniqueId.type\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NamingSystem.uniqueId.value\",\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NamingSystem.uniqueId.preferred\",\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NamingSystem.uniqueId.period\",\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NamingSystem.replacedBy\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NutritionOrder\",\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"NutritionOrder.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NutritionOrder.meta\",\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NutritionOrder.implicitRules\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NutritionOrder.language\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NutritionOrder.text\",\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NutritionOrder.contained\",\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"NutritionOrder.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"NutritionOrder.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"NutritionOrder.identifier\",\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"NutritionOrder.status\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NutritionOrder.patient\",\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NutritionOrder.encounter\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NutritionOrder.dateTime\",\
		\"type\": \"dateTime\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NutritionOrder.orderer\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NutritionOrder.allergyIntolerance\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"NutritionOrder.foodPreferenceModifier\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"NutritionOrder.excludeFoodModifier\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"NutritionOrder.oralDiet\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NutritionOrder.oralDiet.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NutritionOrder.oralDiet.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"NutritionOrder.oralDiet.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"NutritionOrder.oralDiet.type\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"NutritionOrder.oralDiet.schedule\",\
		\"type\": \"Timing\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"NutritionOrder.oralDiet.nutrient\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"NutritionOrder.oralDiet.nutrient.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NutritionOrder.oralDiet.nutrient.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"NutritionOrder.oralDiet.nutrient.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"NutritionOrder.oralDiet.nutrient.modifier\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NutritionOrder.oralDiet.nutrient.amount\",\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NutritionOrder.oralDiet.texture\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"NutritionOrder.oralDiet.texture.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NutritionOrder.oralDiet.texture.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"NutritionOrder.oralDiet.texture.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"NutritionOrder.oralDiet.texture.modifier\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NutritionOrder.oralDiet.texture.foodType\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NutritionOrder.oralDiet.fluidConsistencyType\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"NutritionOrder.oralDiet.instruction\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NutritionOrder.supplement\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"NutritionOrder.supplement.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NutritionOrder.supplement.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"NutritionOrder.supplement.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"NutritionOrder.supplement.type\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NutritionOrder.supplement.productName\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NutritionOrder.supplement.schedule\",\
		\"type\": \"Timing\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"NutritionOrder.supplement.quantity\",\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NutritionOrder.supplement.instruction\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NutritionOrder.enteralFormula\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NutritionOrder.enteralFormula.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NutritionOrder.enteralFormula.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"NutritionOrder.enteralFormula.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"NutritionOrder.enteralFormula.baseFormulaType\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NutritionOrder.enteralFormula.baseFormulaProductName\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NutritionOrder.enteralFormula.additiveType\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NutritionOrder.enteralFormula.additiveProductName\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NutritionOrder.enteralFormula.caloricDensity\",\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NutritionOrder.enteralFormula.routeofAdministration\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NutritionOrder.enteralFormula.administration\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"NutritionOrder.enteralFormula.administration.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NutritionOrder.enteralFormula.administration.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"NutritionOrder.enteralFormula.administration.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"NutritionOrder.enteralFormula.administration.schedule\",\
		\"type\": \"Timing\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NutritionOrder.enteralFormula.administration.quantity\",\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NutritionOrder.enteralFormula.administration.rateQuantity\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"path\": \"NutritionOrder.enteralFormula.administration.rateRatio\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Ratio\"\
	},\
	{\
		\"path\": \"NutritionOrder.enteralFormula.maxVolumeToDeliver\",\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"NutritionOrder.enteralFormula.administrationInstruction\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation\",\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Observation.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.meta\",\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.implicitRules\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.language\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.text\",\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.contained\",\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Observation.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Observation.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Observation.identifier\",\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Observation.status\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.category\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.code\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.subject\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.encounter\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.effectiveDateTime\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"path\": \"Observation.effectivePeriod\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Period\"\
	},\
	{\
		\"path\": \"Observation.issued\",\
		\"type\": \"instant\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.performer\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Observation.valueQuantity\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"path\": \"Observation.valueCodeableConcept\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"path\": \"Observation.valueString\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"string\"\
	},\
	{\
		\"path\": \"Observation.valueRange\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Range\"\
	},\
	{\
		\"path\": \"Observation.valueRatio\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Ratio\"\
	},\
	{\
		\"path\": \"Observation.valueSampledData\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"SampledData\"\
	},\
	{\
		\"path\": \"Observation.valueAttachment\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Attachment\"\
	},\
	{\
		\"path\": \"Observation.valueTime\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"time\"\
	},\
	{\
		\"path\": \"Observation.valueDateTime\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"path\": \"Observation.valuePeriod\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Period\"\
	},\
	{\
		\"path\": \"Observation.dataAbsentReason\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.interpretation\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.comment\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.bodySite\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.method\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.specimen\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.device\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.referenceRange\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Observation.referenceRange.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.referenceRange.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Observation.referenceRange.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Observation.referenceRange.low\",\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.referenceRange.high\",\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.referenceRange.meaning\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.referenceRange.age\",\
		\"type\": \"Range\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.referenceRange.text\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.related\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Observation.related.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.related.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Observation.related.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Observation.related.type\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.related.target\",\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.component\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Observation.component.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.component.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Observation.component.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Observation.component.code\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.component.valueQuantity\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"path\": \"Observation.component.valueCodeableConcept\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"path\": \"Observation.component.valueString\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"string\"\
	},\
	{\
		\"path\": \"Observation.component.valueRange\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Range\"\
	},\
	{\
		\"path\": \"Observation.component.valueRatio\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Ratio\"\
	},\
	{\
		\"path\": \"Observation.component.valueSampledData\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"SampledData\"\
	},\
	{\
		\"path\": \"Observation.component.valueAttachment\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Attachment\"\
	},\
	{\
		\"path\": \"Observation.component.valueTime\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"time\"\
	},\
	{\
		\"path\": \"Observation.component.valueDateTime\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"path\": \"Observation.component.valuePeriod\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Period\"\
	},\
	{\
		\"path\": \"Observation.component.dataAbsentReason\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Observation.component.referenceRange\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"OperationDefinition\",\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"OperationDefinition.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationDefinition.meta\",\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationDefinition.implicitRules\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationDefinition.language\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationDefinition.text\",\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationDefinition.contained\",\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"OperationDefinition.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"OperationDefinition.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"OperationDefinition.url\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationDefinition.version\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationDefinition.name\",\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationDefinition.status\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationDefinition.kind\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationDefinition.experimental\",\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationDefinition.date\",\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationDefinition.publisher\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationDefinition.contact\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"OperationDefinition.contact.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationDefinition.contact.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"OperationDefinition.contact.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"OperationDefinition.contact.name\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationDefinition.contact.telecom\",\
		\"type\": \"ContactPoint\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"OperationDefinition.description\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationDefinition.useContext\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"OperationDefinition.requirements\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationDefinition.idempotent\",\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationDefinition.code\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationDefinition.comment\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationDefinition.base\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationDefinition.system\",\
		\"type\": \"boolean\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationDefinition.type\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"OperationDefinition.instance\",\
		\"type\": \"boolean\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationDefinition.parameter\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"OperationDefinition.parameter.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationDefinition.parameter.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"OperationDefinition.parameter.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"OperationDefinition.parameter.name\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationDefinition.parameter.use\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationDefinition.parameter.min\",\
		\"type\": \"integer\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationDefinition.parameter.max\",\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationDefinition.parameter.documentation\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationDefinition.parameter.type\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationDefinition.parameter.searchType\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationDefinition.parameter.profile\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationDefinition.parameter.binding\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationDefinition.parameter.binding.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationDefinition.parameter.binding.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"OperationDefinition.parameter.binding.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"OperationDefinition.parameter.binding.strength\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationDefinition.parameter.binding.valueSetUri\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"path\": \"OperationDefinition.parameter.binding.valueSetReference\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"OperationDefinition.parameter.part\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"OperationOutcome\",\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"OperationOutcome.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationOutcome.meta\",\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationOutcome.implicitRules\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationOutcome.language\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationOutcome.text\",\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationOutcome.contained\",\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"OperationOutcome.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"OperationOutcome.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"OperationOutcome.issue\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"OperationOutcome.issue.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationOutcome.issue.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"OperationOutcome.issue.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"OperationOutcome.issue.severity\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationOutcome.issue.code\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationOutcome.issue.details\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationOutcome.issue.diagnostics\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OperationOutcome.issue.location\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"OperationOutcome.issue.expression\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Order\",\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Order.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Order.meta\",\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Order.implicitRules\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Order.language\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Order.text\",\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Order.contained\",\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Order.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Order.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Order.identifier\",\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Order.date\",\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Order.subject\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Order.source\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Order.target\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Order.reasonCodeableConcept\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"path\": \"Order.reasonReference\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"Order.when\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Order.when.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Order.when.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Order.when.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Order.when.code\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Order.when.schedule\",\
		\"type\": \"Timing\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Order.detail\",\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"OrderResponse\",\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"OrderResponse.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OrderResponse.meta\",\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OrderResponse.implicitRules\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OrderResponse.language\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OrderResponse.text\",\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OrderResponse.contained\",\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"OrderResponse.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"OrderResponse.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"OrderResponse.identifier\",\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"OrderResponse.request\",\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OrderResponse.date\",\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OrderResponse.who\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OrderResponse.orderStatus\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OrderResponse.description\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OrderResponse.fulfillment\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"OrderSet\",\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"OrderSet.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OrderSet.meta\",\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OrderSet.implicitRules\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OrderSet.language\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OrderSet.text\",\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OrderSet.contained\",\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"OrderSet.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"OrderSet.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"OrderSet.moduleMetadata\",\
		\"type\": \"ModuleMetadata\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"OrderSet.library\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"OrderSet.action\",\
		\"type\": \"ActionDefinition\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Organization\",\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Organization.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Organization.meta\",\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Organization.implicitRules\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Organization.language\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Organization.text\",\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Organization.contained\",\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Organization.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Organization.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Organization.identifier\",\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Organization.active\",\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Organization.type\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Organization.name\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Organization.telecom\",\
		\"type\": \"ContactPoint\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Organization.address\",\
		\"type\": \"Address\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Organization.partOf\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Organization.contact\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Organization.contact.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Organization.contact.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Organization.contact.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Organization.contact.purpose\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Organization.contact.name\",\
		\"type\": \"HumanName\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Organization.contact.telecom\",\
		\"type\": \"ContactPoint\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Organization.contact.address\",\
		\"type\": \"Address\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Patient\",\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Patient.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Patient.meta\",\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Patient.implicitRules\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Patient.language\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Patient.text\",\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Patient.contained\",\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Patient.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Patient.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Patient.identifier\",\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Patient.active\",\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Patient.name\",\
		\"type\": \"HumanName\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Patient.telecom\",\
		\"type\": \"ContactPoint\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Patient.gender\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Patient.birthDate\",\
		\"type\": \"date\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Patient.deceasedBoolean\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"path\": \"Patient.deceasedDateTime\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"path\": \"Patient.address\",\
		\"type\": \"Address\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Patient.maritalStatus\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Patient.multipleBirthBoolean\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"path\": \"Patient.multipleBirthInteger\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"integer\"\
	},\
	{\
		\"path\": \"Patient.photo\",\
		\"type\": \"Attachment\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Patient.contact\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Patient.contact.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Patient.contact.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Patient.contact.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Patient.contact.relationship\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Patient.contact.name\",\
		\"type\": \"HumanName\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Patient.contact.telecom\",\
		\"type\": \"ContactPoint\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Patient.contact.address\",\
		\"type\": \"Address\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Patient.contact.gender\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Patient.contact.organization\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Patient.contact.period\",\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Patient.animal\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Patient.animal.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Patient.animal.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Patient.animal.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Patient.animal.species\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Patient.animal.breed\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Patient.animal.genderStatus\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Patient.communication\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Patient.communication.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Patient.communication.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Patient.communication.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Patient.communication.language\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Patient.communication.preferred\",\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Patient.careProvider\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Patient.managingOrganization\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Patient.link\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Patient.link.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Patient.link.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Patient.link.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Patient.link.other\",\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Patient.link.type\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentNotice\",\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PaymentNotice.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentNotice.meta\",\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentNotice.implicitRules\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentNotice.language\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentNotice.text\",\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentNotice.contained\",\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PaymentNotice.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PaymentNotice.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PaymentNotice.identifier\",\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PaymentNotice.ruleset\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentNotice.originalRuleset\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentNotice.created\",\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentNotice.targetIdentifier\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"path\": \"PaymentNotice.targetReference\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"PaymentNotice.providerIdentifier\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"path\": \"PaymentNotice.providerReference\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"PaymentNotice.organizationIdentifier\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"path\": \"PaymentNotice.organizationReference\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"PaymentNotice.requestIdentifier\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"path\": \"PaymentNotice.requestReference\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"PaymentNotice.responseIdentifier\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"path\": \"PaymentNotice.responseReference\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"PaymentNotice.paymentStatus\",\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentNotice.statusDate\",\
		\"type\": \"date\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentReconciliation\",\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.meta\",\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.implicitRules\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.language\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.text\",\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.contained\",\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.identifier\",\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.requestIdentifier\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.requestReference\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.outcome\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.disposition\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.ruleset\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.originalRuleset\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.created\",\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.period\",\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.organizationIdentifier\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.organizationReference\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.requestProviderIdentifier\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.requestProviderReference\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.requestOrganizationIdentifier\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.requestOrganizationReference\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.detail\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.detail.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.detail.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.detail.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.detail.type\",\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.detail.requestIdentifier\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.detail.requestReference\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.detail.responceIdentifier\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.detail.responceReference\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.detail.submitterIdentifier\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.detail.submitterReference\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.detail.payeeIdentifier\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.detail.payeeReference\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.detail.date\",\
		\"type\": \"date\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.detail.amount\",\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.form\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.total\",\
		\"type\": \"Quantity\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.note\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.note.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.note.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.note.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.note.type\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PaymentReconciliation.note.text\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Person\",\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Person.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Person.meta\",\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Person.implicitRules\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Person.language\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Person.text\",\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Person.contained\",\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Person.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Person.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Person.identifier\",\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Person.name\",\
		\"type\": \"HumanName\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Person.telecom\",\
		\"type\": \"ContactPoint\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Person.gender\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Person.birthDate\",\
		\"type\": \"date\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Person.address\",\
		\"type\": \"Address\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Person.photo\",\
		\"type\": \"Attachment\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Person.managingOrganization\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Person.active\",\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Person.link\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Person.link.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Person.link.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Person.link.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Person.link.target\",\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Person.link.assurance\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Practitioner\",\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Practitioner.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Practitioner.meta\",\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Practitioner.implicitRules\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Practitioner.language\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Practitioner.text\",\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Practitioner.contained\",\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Practitioner.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Practitioner.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Practitioner.identifier\",\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Practitioner.active\",\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Practitioner.name\",\
		\"type\": \"HumanName\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Practitioner.telecom\",\
		\"type\": \"ContactPoint\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Practitioner.address\",\
		\"type\": \"Address\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Practitioner.gender\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Practitioner.birthDate\",\
		\"type\": \"date\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Practitioner.photo\",\
		\"type\": \"Attachment\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Practitioner.practitionerRole\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Practitioner.practitionerRole.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Practitioner.practitionerRole.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Practitioner.practitionerRole.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Practitioner.practitionerRole.organization\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Practitioner.practitionerRole.role\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Practitioner.practitionerRole.specialty\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Practitioner.practitionerRole.identifier\",\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Practitioner.practitionerRole.telecom\",\
		\"type\": \"ContactPoint\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Practitioner.practitionerRole.period\",\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Practitioner.practitionerRole.location\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Practitioner.practitionerRole.healthcareService\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Practitioner.qualification\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Practitioner.qualification.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Practitioner.qualification.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Practitioner.qualification.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Practitioner.qualification.identifier\",\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Practitioner.qualification.code\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Practitioner.qualification.period\",\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Practitioner.qualification.issuer\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Practitioner.communication\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PractitionerRole\",\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PractitionerRole.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PractitionerRole.meta\",\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PractitionerRole.implicitRules\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PractitionerRole.language\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PractitionerRole.text\",\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PractitionerRole.contained\",\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PractitionerRole.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PractitionerRole.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PractitionerRole.identifier\",\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PractitionerRole.active\",\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PractitionerRole.practitioner\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PractitionerRole.organization\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PractitionerRole.role\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PractitionerRole.specialty\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PractitionerRole.location\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PractitionerRole.healthcareService\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PractitionerRole.telecom\",\
		\"type\": \"ContactPoint\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PractitionerRole.period\",\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PractitionerRole.availableTime\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PractitionerRole.availableTime.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PractitionerRole.availableTime.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PractitionerRole.availableTime.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PractitionerRole.availableTime.daysOfWeek\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PractitionerRole.availableTime.allDay\",\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PractitionerRole.availableTime.availableStartTime\",\
		\"type\": \"time\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PractitionerRole.availableTime.availableEndTime\",\
		\"type\": \"time\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PractitionerRole.notAvailable\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PractitionerRole.notAvailable.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PractitionerRole.notAvailable.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PractitionerRole.notAvailable.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"PractitionerRole.notAvailable.description\",\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PractitionerRole.notAvailable.during\",\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"PractitionerRole.availabilityExceptions\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Procedure\",\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Procedure.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Procedure.meta\",\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Procedure.implicitRules\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Procedure.language\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Procedure.text\",\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Procedure.contained\",\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Procedure.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Procedure.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Procedure.identifier\",\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Procedure.subject\",\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Procedure.status\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Procedure.category\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Procedure.code\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Procedure.notPerformed\",\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Procedure.reasonNotPerformed\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Procedure.bodySite\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Procedure.reasonCodeableConcept\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"path\": \"Procedure.reasonReference\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"Procedure.performer\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Procedure.performer.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Procedure.performer.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Procedure.performer.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Procedure.performer.actor\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Procedure.performer.role\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Procedure.performedDateTime\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"path\": \"Procedure.performedPeriod\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Period\"\
	},\
	{\
		\"path\": \"Procedure.encounter\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Procedure.location\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Procedure.outcome\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Procedure.report\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Procedure.complication\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Procedure.followUp\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Procedure.request\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Procedure.notes\",\
		\"type\": \"Annotation\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Procedure.focalDevice\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Procedure.focalDevice.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Procedure.focalDevice.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Procedure.focalDevice.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Procedure.focalDevice.action\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Procedure.focalDevice.manipulated\",\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Procedure.used\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ProcedureRequest\",\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ProcedureRequest.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcedureRequest.meta\",\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcedureRequest.implicitRules\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcedureRequest.language\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcedureRequest.text\",\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcedureRequest.contained\",\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ProcedureRequest.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ProcedureRequest.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ProcedureRequest.identifier\",\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ProcedureRequest.subject\",\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcedureRequest.code\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcedureRequest.bodySite\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ProcedureRequest.reasonCodeableConcept\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"path\": \"ProcedureRequest.reasonReference\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"ProcedureRequest.scheduledDateTime\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"path\": \"ProcedureRequest.scheduledPeriod\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Period\"\
	},\
	{\
		\"path\": \"ProcedureRequest.scheduledTiming\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Timing\"\
	},\
	{\
		\"path\": \"ProcedureRequest.encounter\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcedureRequest.performer\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcedureRequest.status\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcedureRequest.notes\",\
		\"type\": \"Annotation\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ProcedureRequest.asNeededBoolean\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"path\": \"ProcedureRequest.asNeededCodeableConcept\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"path\": \"ProcedureRequest.orderedOn\",\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcedureRequest.orderer\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcedureRequest.priority\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessRequest\",\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ProcessRequest.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessRequest.meta\",\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessRequest.implicitRules\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessRequest.language\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessRequest.text\",\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessRequest.contained\",\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ProcessRequest.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ProcessRequest.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ProcessRequest.action\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessRequest.identifier\",\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ProcessRequest.ruleset\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessRequest.originalRuleset\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessRequest.created\",\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessRequest.targetIdentifier\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"path\": \"ProcessRequest.targetReference\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"ProcessRequest.providerIdentifier\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"path\": \"ProcessRequest.providerReference\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"ProcessRequest.organizationIdentifier\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"path\": \"ProcessRequest.organizationReference\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"ProcessRequest.requestIdentifier\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"path\": \"ProcessRequest.requestReference\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"ProcessRequest.responseIdentifier\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"path\": \"ProcessRequest.responseReference\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"ProcessRequest.nullify\",\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessRequest.reference\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessRequest.item\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ProcessRequest.item.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessRequest.item.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ProcessRequest.item.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ProcessRequest.item.sequenceLinkId\",\
		\"type\": \"integer\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessRequest.include\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ProcessRequest.exclude\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ProcessRequest.period\",\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessResponse\",\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ProcessResponse.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessResponse.meta\",\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessResponse.implicitRules\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessResponse.language\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessResponse.text\",\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessResponse.contained\",\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ProcessResponse.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ProcessResponse.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ProcessResponse.identifier\",\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ProcessResponse.requestIdentifier\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"path\": \"ProcessResponse.requestReference\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"ProcessResponse.outcome\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessResponse.disposition\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessResponse.ruleset\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessResponse.originalRuleset\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessResponse.created\",\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessResponse.organizationIdentifier\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"path\": \"ProcessResponse.organizationReference\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"ProcessResponse.requestProviderIdentifier\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"path\": \"ProcessResponse.requestProviderReference\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"ProcessResponse.requestOrganizationIdentifier\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"path\": \"ProcessResponse.requestOrganizationReference\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"ProcessResponse.form\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessResponse.notes\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ProcessResponse.notes.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessResponse.notes.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ProcessResponse.notes.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ProcessResponse.notes.type\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessResponse.notes.text\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ProcessResponse.error\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Protocol\",\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Protocol.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Protocol.meta\",\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Protocol.implicitRules\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Protocol.language\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Protocol.text\",\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Protocol.contained\",\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Protocol.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Protocol.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Protocol.identifier\",\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Protocol.title\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Protocol.status\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Protocol.type\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Protocol.subject\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Protocol.group\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Protocol.purpose\",\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Protocol.author\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Protocol.step\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Protocol.step.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Protocol.step.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Protocol.step.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Protocol.step.name\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Protocol.step.description\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Protocol.step.duration\",\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Protocol.step.precondition\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Protocol.step.precondition.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Protocol.step.precondition.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Protocol.step.precondition.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Protocol.step.precondition.description\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Protocol.step.precondition.condition\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Protocol.step.precondition.condition.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Protocol.step.precondition.condition.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Protocol.step.precondition.condition.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Protocol.step.precondition.condition.type\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Protocol.step.precondition.condition.valueCodeableConcept\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"path\": \"Protocol.step.precondition.condition.valueBoolean\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"path\": \"Protocol.step.precondition.condition.valueQuantity\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"path\": \"Protocol.step.precondition.condition.valueRange\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"Range\"\
	},\
	{\
		\"path\": \"Protocol.step.precondition.intersection\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Protocol.step.precondition.union\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Protocol.step.precondition.exclude\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Protocol.step.exit\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Protocol.step.firstActivity\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Protocol.step.activity\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Protocol.step.activity.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Protocol.step.activity.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Protocol.step.activity.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Protocol.step.activity.alternative\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Protocol.step.activity.component\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Protocol.step.activity.component.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Protocol.step.activity.component.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Protocol.step.activity.component.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Protocol.step.activity.component.sequence\",\
		\"type\": \"integer\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Protocol.step.activity.component.activity\",\
		\"type\": \"uri\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Protocol.step.activity.following\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Protocol.step.activity.wait\",\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Protocol.step.activity.detail\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Protocol.step.activity.detail.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Protocol.step.activity.detail.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Protocol.step.activity.detail.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Protocol.step.activity.detail.category\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Protocol.step.activity.detail.code\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Protocol.step.activity.detail.timingCodeableConcept\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"path\": \"Protocol.step.activity.detail.timingTiming\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Timing\"\
	},\
	{\
		\"path\": \"Protocol.step.activity.detail.location\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Protocol.step.activity.detail.performer\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Protocol.step.activity.detail.product\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Protocol.step.activity.detail.quantity\",\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Protocol.step.activity.detail.description\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Protocol.step.next\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Protocol.step.next.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Protocol.step.next.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Protocol.step.next.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Protocol.step.next.description\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Protocol.step.next.reference\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Protocol.step.next.condition\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Provenance\",\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Provenance.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Provenance.meta\",\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Provenance.implicitRules\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Provenance.language\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Provenance.text\",\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Provenance.contained\",\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Provenance.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Provenance.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Provenance.target\",\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Provenance.period\",\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Provenance.recorded\",\
		\"type\": \"instant\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Provenance.reason\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Provenance.activity\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Provenance.location\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Provenance.policy\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Provenance.agent\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Provenance.agent.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Provenance.agent.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Provenance.agent.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Provenance.agent.role\",\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Provenance.agent.actor\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Provenance.agent.userId\",\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Provenance.agent.relatedAgent\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Provenance.agent.relatedAgent.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Provenance.agent.relatedAgent.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Provenance.agent.relatedAgent.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Provenance.agent.relatedAgent.type\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Provenance.agent.relatedAgent.target\",\
		\"type\": \"uri\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Provenance.entity\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Provenance.entity.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Provenance.entity.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Provenance.entity.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Provenance.entity.role\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Provenance.entity.type\",\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Provenance.entity.reference\",\
		\"type\": \"uri\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Provenance.entity.display\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Provenance.entity.agent\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Provenance.signature\",\
		\"type\": \"Signature\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Questionnaire\",\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Questionnaire.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.meta\",\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.implicitRules\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.language\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.text\",\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.contained\",\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Questionnaire.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Questionnaire.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Questionnaire.url\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.identifier\",\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Questionnaire.version\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.status\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.date\",\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.publisher\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.telecom\",\
		\"type\": \"ContactPoint\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Questionnaire.useContext\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Questionnaire.title\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.concept\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Questionnaire.subjectType\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Questionnaire.item\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Questionnaire.item.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.item.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Questionnaire.item.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Questionnaire.item.linkId\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.item.concept\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Questionnaire.item.prefix\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.item.text\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.item.type\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.item.enableWhen\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Questionnaire.item.enableWhen.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.item.enableWhen.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Questionnaire.item.enableWhen.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Questionnaire.item.enableWhen.question\",\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.item.enableWhen.hasAnswer\",\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.item.enableWhen.answerBoolean\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"path\": \"Questionnaire.item.enableWhen.answerDecimal\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"path\": \"Questionnaire.item.enableWhen.answerInteger\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"integer\"\
	},\
	{\
		\"path\": \"Questionnaire.item.enableWhen.answerDate\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"date\"\
	},\
	{\
		\"path\": \"Questionnaire.item.enableWhen.answerDateTime\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"path\": \"Questionnaire.item.enableWhen.answerInstant\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"instant\"\
	},\
	{\
		\"path\": \"Questionnaire.item.enableWhen.answerTime\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"time\"\
	},\
	{\
		\"path\": \"Questionnaire.item.enableWhen.answerString\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"string\"\
	},\
	{\
		\"path\": \"Questionnaire.item.enableWhen.answerUri\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"uri\"\
	},\
	{\
		\"path\": \"Questionnaire.item.enableWhen.answerAttachment\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Attachment\"\
	},\
	{\
		\"path\": \"Questionnaire.item.enableWhen.answerCoding\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"path\": \"Questionnaire.item.enableWhen.answerQuantity\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"path\": \"Questionnaire.item.enableWhen.answerReference\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"Questionnaire.item.required\",\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.item.repeats\",\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.item.readOnly\",\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.item.maxLength\",\
		\"type\": \"integer\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.item.options\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.item.option\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Questionnaire.item.option.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Questionnaire.item.option.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Questionnaire.item.option.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Questionnaire.item.option.valueInteger\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"integer\"\
	},\
	{\
		\"path\": \"Questionnaire.item.option.valueDate\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"date\"\
	},\
	{\
		\"path\": \"Questionnaire.item.option.valueTime\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"time\"\
	},\
	{\
		\"path\": \"Questionnaire.item.option.valueString\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"path\": \"Questionnaire.item.option.valueCoding\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"path\": \"Questionnaire.item.initialBoolean\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"path\": \"Questionnaire.item.initialDecimal\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"path\": \"Questionnaire.item.initialInteger\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"integer\"\
	},\
	{\
		\"path\": \"Questionnaire.item.initialDate\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"date\"\
	},\
	{\
		\"path\": \"Questionnaire.item.initialDateTime\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"path\": \"Questionnaire.item.initialInstant\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"instant\"\
	},\
	{\
		\"path\": \"Questionnaire.item.initialTime\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"time\"\
	},\
	{\
		\"path\": \"Questionnaire.item.initialString\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"string\"\
	},\
	{\
		\"path\": \"Questionnaire.item.initialUri\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"uri\"\
	},\
	{\
		\"path\": \"Questionnaire.item.initialAttachment\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Attachment\"\
	},\
	{\
		\"path\": \"Questionnaire.item.initialCoding\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"path\": \"Questionnaire.item.initialQuantity\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"path\": \"Questionnaire.item.initialReference\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"Questionnaire.item.item\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse\",\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.meta\",\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.implicitRules\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.language\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.text\",\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.contained\",\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.identifier\",\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.questionnaire\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.status\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.subject\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.author\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.authored\",\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.source\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.encounter\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.item\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.item.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.item.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.item.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.item.linkId\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.item.text\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.item.subject\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.item.answer\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.item.answer.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.item.answer.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.item.answer.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.item.answer.valueBoolean\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.item.answer.valueDecimal\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.item.answer.valueInteger\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"integer\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.item.answer.valueDate\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"date\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.item.answer.valueDateTime\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.item.answer.valueInstant\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"instant\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.item.answer.valueTime\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"time\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.item.answer.valueString\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"string\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.item.answer.valueUri\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"uri\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.item.answer.valueAttachment\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Attachment\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.item.answer.valueCoding\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.item.answer.valueQuantity\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.item.answer.valueReference\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.item.answer.item\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"QuestionnaireResponse.item.item\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ReferralRequest\",\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ReferralRequest.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ReferralRequest.meta\",\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ReferralRequest.implicitRules\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ReferralRequest.language\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ReferralRequest.text\",\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ReferralRequest.contained\",\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ReferralRequest.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ReferralRequest.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ReferralRequest.identifier\",\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ReferralRequest.basedOn\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ReferralRequest.parent\",\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ReferralRequest.status\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ReferralRequest.category\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ReferralRequest.type\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ReferralRequest.priority\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ReferralRequest.patient\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ReferralRequest.context\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ReferralRequest.fulfillmentTime\",\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ReferralRequest.authored\",\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ReferralRequest.requester\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ReferralRequest.specialty\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ReferralRequest.recipient\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ReferralRequest.reason\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ReferralRequest.description\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"ReferralRequest.serviceRequested\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"ReferralRequest.supportingInformation\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"RelatedPerson\",\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"RelatedPerson.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"RelatedPerson.meta\",\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"RelatedPerson.implicitRules\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"RelatedPerson.language\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"RelatedPerson.text\",\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"RelatedPerson.contained\",\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"RelatedPerson.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"RelatedPerson.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"RelatedPerson.identifier\",\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"RelatedPerson.patient\",\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"RelatedPerson.relationship\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"RelatedPerson.name\",\
		\"type\": \"HumanName\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"RelatedPerson.telecom\",\
		\"type\": \"ContactPoint\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"RelatedPerson.gender\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"RelatedPerson.birthDate\",\
		\"type\": \"date\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"RelatedPerson.address\",\
		\"type\": \"Address\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"RelatedPerson.photo\",\
		\"type\": \"Attachment\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"RelatedPerson.period\",\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"RiskAssessment\",\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"RiskAssessment.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"RiskAssessment.meta\",\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"RiskAssessment.implicitRules\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"RiskAssessment.language\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"RiskAssessment.text\",\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"RiskAssessment.contained\",\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"RiskAssessment.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"RiskAssessment.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"RiskAssessment.subject\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"RiskAssessment.date\",\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"RiskAssessment.condition\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"RiskAssessment.encounter\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"RiskAssessment.performer\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"RiskAssessment.identifier\",\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"RiskAssessment.method\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"RiskAssessment.basis\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"RiskAssessment.prediction\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"RiskAssessment.prediction.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"RiskAssessment.prediction.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"RiskAssessment.prediction.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"RiskAssessment.prediction.outcome\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"RiskAssessment.prediction.probabilityDecimal\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"path\": \"RiskAssessment.prediction.probabilityRange\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Range\"\
	},\
	{\
		\"path\": \"RiskAssessment.prediction.probabilityCodeableConcept\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"path\": \"RiskAssessment.prediction.relativeRisk\",\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"RiskAssessment.prediction.whenPeriod\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Period\"\
	},\
	{\
		\"path\": \"RiskAssessment.prediction.whenRange\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Range\"\
	},\
	{\
		\"path\": \"RiskAssessment.prediction.rationale\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"RiskAssessment.mitigation\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Schedule\",\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Schedule.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Schedule.meta\",\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Schedule.implicitRules\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Schedule.language\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Schedule.text\",\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Schedule.contained\",\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Schedule.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Schedule.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Schedule.identifier\",\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Schedule.serviceCategory\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Schedule.serviceType\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Schedule.specialty\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Schedule.actor\",\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Schedule.planningHorizon\",\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Schedule.comment\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SearchParameter\",\
		\"type\": \"DomainResource\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SearchParameter.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SearchParameter.meta\",\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SearchParameter.implicitRules\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SearchParameter.language\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SearchParameter.text\",\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SearchParameter.contained\",\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"SearchParameter.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"SearchParameter.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"SearchParameter.url\",\
		\"type\": \"uri\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SearchParameter.name\",\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SearchParameter.status\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SearchParameter.experimental\",\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SearchParameter.date\",\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SearchParameter.publisher\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SearchParameter.contact\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"SearchParameter.contact.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SearchParameter.contact.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"SearchParameter.contact.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"SearchParameter.contact.name\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SearchParameter.contact.telecom\",\
		\"type\": \"ContactPoint\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"SearchParameter.useContext\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"SearchParameter.requirements\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SearchParameter.code\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SearchParameter.base\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SearchParameter.type\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SearchParameter.description\",\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SearchParameter.expression\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SearchParameter.xpath\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SearchParameter.xpathUsage\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SearchParameter.target\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Sequence\",\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Sequence.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.meta\",\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.implicitRules\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.language\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.text\",\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.contained\",\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Sequence.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Sequence.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Sequence.type\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.patient\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.specimen\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.device\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.quantity\",\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.species\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.referenceSeq\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Sequence.referenceSeq.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.referenceSeq.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Sequence.referenceSeq.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Sequence.referenceSeq.chromosome\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.referenceSeq.genomeBuild\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.referenceSeq.referenceSeqId\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.referenceSeq.referenceSeqPointer\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.referenceSeq.referenceSeqString\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.referenceSeq.windowStart\",\
		\"type\": \"integer\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.referenceSeq.windowEnd\",\
		\"type\": \"integer\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.variation\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.variation.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.variation.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Sequence.variation.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Sequence.variation.start\",\
		\"type\": \"integer\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.variation.end\",\
		\"type\": \"integer\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.variation.observedAllele\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.variation.referenceAllele\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.variation.cigar\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.quality\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Sequence.quality.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.quality.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Sequence.quality.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Sequence.quality.start\",\
		\"type\": \"integer\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.quality.end\",\
		\"type\": \"integer\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.quality.score\",\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.quality.method\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.allelicState\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.allelicFrequency\",\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.copyNumberEvent\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.readCoverage\",\
		\"type\": \"integer\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.repository\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Sequence.repository.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.repository.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Sequence.repository.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Sequence.repository.url\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.repository.name\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.repository.variantId\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.repository.readId\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.pointer\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Sequence.observedSeq\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.observation\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.structureVariation\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.structureVariation.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.structureVariation.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Sequence.structureVariation.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Sequence.structureVariation.precisionOfBoundaries\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.structureVariation.reportedaCGHRatio\",\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.structureVariation.length\",\
		\"type\": \"integer\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.structureVariation.outer\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.structureVariation.outer.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.structureVariation.outer.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Sequence.structureVariation.outer.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Sequence.structureVariation.outer.start\",\
		\"type\": \"integer\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.structureVariation.outer.end\",\
		\"type\": \"integer\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.structureVariation.inner\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.structureVariation.inner.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.structureVariation.inner.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Sequence.structureVariation.inner.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Sequence.structureVariation.inner.start\",\
		\"type\": \"integer\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Sequence.structureVariation.inner.end\",\
		\"type\": \"integer\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Slot\",\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Slot.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Slot.meta\",\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Slot.implicitRules\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Slot.language\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Slot.text\",\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Slot.contained\",\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Slot.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Slot.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Slot.identifier\",\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Slot.serviceCategory\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Slot.serviceType\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Slot.specialty\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Slot.appointmentType\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Slot.schedule\",\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Slot.status\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Slot.start\",\
		\"type\": \"instant\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Slot.end\",\
		\"type\": \"instant\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Slot.overbooked\",\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Slot.comment\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Specimen\",\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Specimen.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Specimen.meta\",\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Specimen.implicitRules\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Specimen.language\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Specimen.text\",\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Specimen.contained\",\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Specimen.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Specimen.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Specimen.identifier\",\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Specimen.accessionIdentifier\",\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Specimen.status\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Specimen.type\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Specimen.subject\",\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Specimen.receivedTime\",\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Specimen.parent\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Specimen.collection\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Specimen.collection.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Specimen.collection.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Specimen.collection.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Specimen.collection.collector\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Specimen.collection.comment\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Specimen.collection.collectedDateTime\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"path\": \"Specimen.collection.collectedPeriod\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Period\"\
	},\
	{\
		\"path\": \"Specimen.collection.quantity\",\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Specimen.collection.method\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Specimen.collection.bodySite\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Specimen.treatment\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Specimen.treatment.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Specimen.treatment.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Specimen.treatment.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Specimen.treatment.description\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Specimen.treatment.procedure\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Specimen.treatment.additive\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Specimen.container\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Specimen.container.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Specimen.container.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Specimen.container.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Specimen.container.identifier\",\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Specimen.container.description\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Specimen.container.type\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Specimen.container.capacity\",\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Specimen.container.specimenQuantity\",\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Specimen.container.additiveCodeableConcept\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"path\": \"Specimen.container.additiveReference\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"StructureDefinition\",\
		\"type\": \"DomainResource\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureDefinition.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureDefinition.meta\",\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureDefinition.implicitRules\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureDefinition.language\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureDefinition.text\",\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureDefinition.contained\",\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureDefinition.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureDefinition.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureDefinition.url\",\
		\"type\": \"uri\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureDefinition.identifier\",\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureDefinition.version\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureDefinition.name\",\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureDefinition.display\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureDefinition.status\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureDefinition.experimental\",\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureDefinition.publisher\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureDefinition.contact\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureDefinition.contact.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureDefinition.contact.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureDefinition.contact.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureDefinition.contact.name\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureDefinition.contact.telecom\",\
		\"type\": \"ContactPoint\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureDefinition.date\",\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureDefinition.description\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureDefinition.useContext\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureDefinition.requirements\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureDefinition.copyright\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureDefinition.code\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureDefinition.fhirVersion\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureDefinition.mapping\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureDefinition.mapping.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureDefinition.mapping.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureDefinition.mapping.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureDefinition.mapping.identity\",\
		\"type\": \"id\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureDefinition.mapping.uri\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureDefinition.mapping.name\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureDefinition.mapping.comments\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureDefinition.kind\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureDefinition.abstract\",\
		\"type\": \"boolean\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureDefinition.contextType\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureDefinition.context\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureDefinition.baseType\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureDefinition.baseDefinition\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureDefinition.derivation\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureDefinition.snapshot\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureDefinition.snapshot.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureDefinition.snapshot.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureDefinition.snapshot.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureDefinition.snapshot.element\",\
		\"type\": \"ElementDefinition\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureDefinition.differential\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureDefinition.differential.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureDefinition.differential.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureDefinition.differential.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureDefinition.differential.element\",\
		\"type\": \"ElementDefinition\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureMap\",\
		\"type\": \"DomainResource\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.meta\",\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.implicitRules\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.language\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.text\",\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.contained\",\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureMap.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureMap.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureMap.url\",\
		\"type\": \"uri\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.identifier\",\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureMap.version\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.name\",\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.status\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.experimental\",\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.publisher\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.contact\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureMap.contact.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.contact.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureMap.contact.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureMap.contact.name\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.contact.telecom\",\
		\"type\": \"ContactPoint\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureMap.date\",\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.description\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.useContext\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureMap.requirements\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.copyright\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.structure\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureMap.structure.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.structure.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureMap.structure.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureMap.structure.url\",\
		\"type\": \"uri\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.structure.mode\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.structure.documentation\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.import\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureMap.group\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureMap.group.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.group.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureMap.group.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureMap.group.name\",\
		\"type\": \"id\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.group.extends\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.group.documentation\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.group.input\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureMap.group.input.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.group.input.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureMap.group.input.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureMap.group.input.name\",\
		\"type\": \"id\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.group.input.type\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.group.input.mode\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.group.input.documentation\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.name\",\
		\"type\": \"id\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.source\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.source.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.source.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.source.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.source.required\",\
		\"type\": \"boolean\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.source.context\",\
		\"type\": \"id\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.source.contextType\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.source.element\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.source.listMode\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.source.variable\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.source.condition\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.source.check\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.target\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.target.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.target.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.target.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.target.context\",\
		\"type\": \"id\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.target.contextType\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.target.element\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.target.variable\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.target.listMode\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.target.listRuleId\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.target.transform\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.target.parameter\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.target.parameter.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.target.parameter.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.target.parameter.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.target.parameter.valueId\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.target.parameter.valueString\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.target.parameter.valueBoolean\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.target.parameter.valueInteger\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"integer\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.target.parameter.valueDecimal\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.rule\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.dependent\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.dependent.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.dependent.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.dependent.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.dependent.name\",\
		\"type\": \"id\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.dependent.variable\",\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"StructureMap.group.rule.documentation\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Subscription\",\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Subscription.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Subscription.meta\",\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Subscription.implicitRules\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Subscription.language\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Subscription.text\",\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Subscription.contained\",\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Subscription.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Subscription.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Subscription.criteria\",\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Subscription.contact\",\
		\"type\": \"ContactPoint\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Subscription.reason\",\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Subscription.status\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Subscription.error\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Subscription.channel\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Subscription.channel.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Subscription.channel.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Subscription.channel.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Subscription.channel.type\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Subscription.channel.endpoint\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Subscription.channel.payload\",\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Subscription.channel.header\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Subscription.end\",\
		\"type\": \"instant\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Subscription.tag\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Substance\",\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Substance.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Substance.meta\",\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Substance.implicitRules\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Substance.language\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Substance.text\",\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Substance.contained\",\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Substance.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Substance.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Substance.identifier\",\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Substance.category\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Substance.code\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Substance.description\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Substance.instance\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Substance.instance.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Substance.instance.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Substance.instance.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Substance.instance.identifier\",\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Substance.instance.expiry\",\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Substance.instance.quantity\",\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Substance.ingredient\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Substance.ingredient.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Substance.ingredient.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Substance.ingredient.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Substance.ingredient.quantity\",\
		\"type\": \"Ratio\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Substance.ingredient.substance\",\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SupplyDelivery\",\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"SupplyDelivery.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SupplyDelivery.meta\",\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SupplyDelivery.implicitRules\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SupplyDelivery.language\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SupplyDelivery.text\",\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SupplyDelivery.contained\",\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"SupplyDelivery.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"SupplyDelivery.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"SupplyDelivery.identifier\",\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SupplyDelivery.status\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SupplyDelivery.patient\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SupplyDelivery.type\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SupplyDelivery.quantity\",\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SupplyDelivery.suppliedItem\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SupplyDelivery.supplier\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SupplyDelivery.whenPrepared\",\
		\"type\": \"Period\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SupplyDelivery.time\",\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SupplyDelivery.destination\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SupplyDelivery.receiver\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"SupplyRequest\",\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"SupplyRequest.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SupplyRequest.meta\",\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SupplyRequest.implicitRules\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SupplyRequest.language\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SupplyRequest.text\",\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SupplyRequest.contained\",\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"SupplyRequest.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"SupplyRequest.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"SupplyRequest.patient\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SupplyRequest.source\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SupplyRequest.date\",\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SupplyRequest.identifier\",\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SupplyRequest.status\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SupplyRequest.kind\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SupplyRequest.orderedItem\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SupplyRequest.supplier\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"SupplyRequest.reasonCodeableConcept\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"path\": \"SupplyRequest.reasonReference\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"SupplyRequest.when\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SupplyRequest.when.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SupplyRequest.when.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"SupplyRequest.when.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"SupplyRequest.when.code\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"SupplyRequest.when.schedule\",\
		\"type\": \"Timing\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task\",\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Task.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.meta\",\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.implicitRules\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.language\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.text\",\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.contained\",\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Task.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Task.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Task.identifier\",\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.type\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.description\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.performerType\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Task.priority\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.status\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.failureReason\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.subject\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.for\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.definition\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.created\",\
		\"type\": \"dateTime\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.lastModified\",\
		\"type\": \"dateTime\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.creator\",\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.owner\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.parent\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.input\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Task.input.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.input.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Task.input.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Task.input.name\",\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.input.valueBoolean\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"path\": \"Task.input.valueInteger\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"integer\"\
	},\
	{\
		\"path\": \"Task.input.valueDecimal\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"path\": \"Task.input.valueBase64Binary\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"base64Binary\"\
	},\
	{\
		\"path\": \"Task.input.valueInstant\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"instant\"\
	},\
	{\
		\"path\": \"Task.input.valueString\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"path\": \"Task.input.valueUri\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"path\": \"Task.input.valueDate\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"date\"\
	},\
	{\
		\"path\": \"Task.input.valueDateTime\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"path\": \"Task.input.valueTime\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"time\"\
	},\
	{\
		\"path\": \"Task.input.valueCode\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"path\": \"Task.input.valueOid\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"oid\"\
	},\
	{\
		\"path\": \"Task.input.valueId\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"path\": \"Task.input.valueUnsignedInt\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"unsignedInt\"\
	},\
	{\
		\"path\": \"Task.input.valuePositiveInt\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"path\": \"Task.input.valueMarkdown\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"path\": \"Task.input.valueAnnotation\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"Annotation\"\
	},\
	{\
		\"path\": \"Task.input.valueAttachment\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"Attachment\"\
	},\
	{\
		\"path\": \"Task.input.valueIdentifier\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"path\": \"Task.input.valueCodeableConcept\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"path\": \"Task.input.valueCoding\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"path\": \"Task.input.valueQuantity\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"path\": \"Task.input.valueRange\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"Range\"\
	},\
	{\
		\"path\": \"Task.input.valuePeriod\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"path\": \"Task.input.valueRatio\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"Ratio\"\
	},\
	{\
		\"path\": \"Task.input.valueSampledData\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"SampledData\"\
	},\
	{\
		\"path\": \"Task.input.valueSignature\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"Signature\"\
	},\
	{\
		\"path\": \"Task.input.valueHumanName\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"HumanName\"\
	},\
	{\
		\"path\": \"Task.input.valueAddress\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"Address\"\
	},\
	{\
		\"path\": \"Task.input.valueContactPoint\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"ContactPoint\"\
	},\
	{\
		\"path\": \"Task.input.valueTiming\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"Timing\"\
	},\
	{\
		\"path\": \"Task.input.valueReference\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"Task.input.valueMeta\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"path\": \"Task.output\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Task.output.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.output.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Task.output.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"Task.output.name\",\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"Task.output.valueBoolean\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"boolean\"\
	},\
	{\
		\"path\": \"Task.output.valueInteger\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"integer\"\
	},\
	{\
		\"path\": \"Task.output.valueDecimal\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"decimal\"\
	},\
	{\
		\"path\": \"Task.output.valueBase64Binary\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"base64Binary\"\
	},\
	{\
		\"path\": \"Task.output.valueInstant\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"instant\"\
	},\
	{\
		\"path\": \"Task.output.valueString\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"string\"\
	},\
	{\
		\"path\": \"Task.output.valueUri\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"uri\"\
	},\
	{\
		\"path\": \"Task.output.valueDate\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"date\"\
	},\
	{\
		\"path\": \"Task.output.valueDateTime\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"dateTime\"\
	},\
	{\
		\"path\": \"Task.output.valueTime\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"time\"\
	},\
	{\
		\"path\": \"Task.output.valueCode\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"code\"\
	},\
	{\
		\"path\": \"Task.output.valueOid\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"oid\"\
	},\
	{\
		\"path\": \"Task.output.valueId\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"id\"\
	},\
	{\
		\"path\": \"Task.output.valueUnsignedInt\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"unsignedInt\"\
	},\
	{\
		\"path\": \"Task.output.valuePositiveInt\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"positiveInt\"\
	},\
	{\
		\"path\": \"Task.output.valueMarkdown\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"markdown\"\
	},\
	{\
		\"path\": \"Task.output.valueAnnotation\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"Annotation\"\
	},\
	{\
		\"path\": \"Task.output.valueAttachment\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"Attachment\"\
	},\
	{\
		\"path\": \"Task.output.valueIdentifier\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"Identifier\"\
	},\
	{\
		\"path\": \"Task.output.valueCodeableConcept\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"path\": \"Task.output.valueCoding\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"Coding\"\
	},\
	{\
		\"path\": \"Task.output.valueQuantity\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"Quantity\"\
	},\
	{\
		\"path\": \"Task.output.valueRange\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"Range\"\
	},\
	{\
		\"path\": \"Task.output.valuePeriod\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"Period\"\
	},\
	{\
		\"path\": \"Task.output.valueRatio\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"Ratio\"\
	},\
	{\
		\"path\": \"Task.output.valueSampledData\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"SampledData\"\
	},\
	{\
		\"path\": \"Task.output.valueSignature\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"Signature\"\
	},\
	{\
		\"path\": \"Task.output.valueHumanName\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"HumanName\"\
	},\
	{\
		\"path\": \"Task.output.valueAddress\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"Address\"\
	},\
	{\
		\"path\": \"Task.output.valueContactPoint\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"ContactPoint\"\
	},\
	{\
		\"path\": \"Task.output.valueTiming\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"Timing\"\
	},\
	{\
		\"path\": \"Task.output.valueReference\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"Task.output.valueMeta\",\
		\"max\": \"1\",\
		\"min\": \"1\",\
		\"type\": \"Meta\"\
	},\
	{\
		\"path\": \"TestScript\",\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.meta\",\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.implicitRules\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.language\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.text\",\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.contained\",\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.url\",\
		\"type\": \"uri\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.version\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.name\",\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.status\",\
		\"type\": \"code\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.identifier\",\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.experimental\",\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.publisher\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.contact\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.contact.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.contact.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.contact.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.contact.name\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.contact.telecom\",\
		\"type\": \"ContactPoint\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.date\",\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.description\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.useContext\",\
		\"type\": \"CodeableConcept\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.requirements\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.copyright\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.origin\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.origin.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.origin.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.origin.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.origin.index\",\
		\"type\": \"integer\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.origin.profile\",\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.destination\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.destination.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.destination.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.destination.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.destination.index\",\
		\"type\": \"integer\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.destination.profile\",\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.metadata\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.metadata.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.metadata.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.metadata.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.metadata.link\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.metadata.link.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.metadata.link.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.metadata.link.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.metadata.link.url\",\
		\"type\": \"uri\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.metadata.link.description\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.metadata.capability\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.metadata.capability.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.metadata.capability.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.metadata.capability.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.metadata.capability.required\",\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.metadata.capability.validated\",\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.metadata.capability.description\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.metadata.capability.origin\",\
		\"type\": \"integer\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.metadata.capability.destination\",\
		\"type\": \"integer\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.metadata.capability.link\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.metadata.capability.conformance\",\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.fixture\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.fixture.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.fixture.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.fixture.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.fixture.autocreate\",\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.fixture.autodelete\",\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.fixture.resource\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.profile\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.variable\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.variable.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.variable.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.variable.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.variable.name\",\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.variable.defaultValue\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.variable.headerField\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.variable.path\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.variable.sourceId\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.rule\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.rule.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.rule.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.rule.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.rule.resource\",\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.rule.param\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.rule.param.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.rule.param.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.rule.param.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.rule.param.name\",\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.rule.param.value\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.ruleset\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.ruleset.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.ruleset.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.ruleset.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.ruleset.resource\",\
		\"type\": \"Reference\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.ruleset.rule\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.ruleset.rule.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.ruleset.rule.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.ruleset.rule.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.ruleset.rule.param\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.ruleset.rule.param.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.ruleset.rule.param.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.ruleset.rule.param.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.ruleset.rule.param.name\",\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.ruleset.rule.param.value\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.setup.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.setup.metadata\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.operation\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.operation.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.operation.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.operation.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.operation.type\",\
		\"type\": \"Coding\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.operation.resource\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.operation.label\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.operation.description\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.operation.accept\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.operation.contentType\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.operation.destination\",\
		\"type\": \"integer\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.operation.encodeRequestUrl\",\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.operation.origin\",\
		\"type\": \"integer\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.operation.params\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.operation.requestHeader\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.operation.requestHeader.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.operation.requestHeader.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.operation.requestHeader.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.operation.requestHeader.field\",\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.operation.requestHeader.value\",\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.operation.responseId\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.operation.sourceId\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.operation.targetId\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.operation.url\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.label\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.description\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.direction\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.compareToSourceId\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.compareToSourcePath\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.contentType\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.headerField\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.minimumId\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.navigationLinks\",\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.operator\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.path\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.resource\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.response\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.responseCode\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.rule\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.rule.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.rule.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.rule.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.rule.param\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.rule.param.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.rule.param.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.rule.param.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.rule.param.name\",\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.rule.param.value\",\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.ruleset\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.ruleset.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.ruleset.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.ruleset.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.ruleset.rule\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.ruleset.rule.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.ruleset.rule.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.ruleset.rule.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.ruleset.rule.param\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.ruleset.rule.param.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.ruleset.rule.param.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.ruleset.rule.param.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.ruleset.rule.param.name\",\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.ruleset.rule.param.value\",\
		\"type\": \"string\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.sourceId\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.validateProfileId\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.value\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.setup.action.assert.warningOnly\",\
		\"type\": \"boolean\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.test\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.test.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.test.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.test.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.test.name\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.test.description\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.test.metadata\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.test.action\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.test.action.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.test.action.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.test.action.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.test.action.operation\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.test.action.assert\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.teardown\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.teardown.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.teardown.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.teardown.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.teardown.action\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"1\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.teardown.action.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"TestScript.teardown.action.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.teardown.action.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"TestScript.teardown.action.operation\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"VisionPrescription\",\
		\"type\": \"DomainResource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"VisionPrescription.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"VisionPrescription.meta\",\
		\"type\": \"Meta\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"VisionPrescription.implicitRules\",\
		\"type\": \"uri\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"VisionPrescription.language\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"VisionPrescription.text\",\
		\"type\": \"Narrative\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"VisionPrescription.contained\",\
		\"type\": \"Resource\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"VisionPrescription.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"VisionPrescription.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"VisionPrescription.identifier\",\
		\"type\": \"Identifier\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"VisionPrescription.dateWritten\",\
		\"type\": \"dateTime\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"VisionPrescription.patient\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"VisionPrescription.prescriber\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"VisionPrescription.encounter\",\
		\"type\": \"Reference\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"VisionPrescription.reasonCodeableConcept\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"CodeableConcept\"\
	},\
	{\
		\"path\": \"VisionPrescription.reasonReference\",\
		\"max\": \"1\",\
		\"min\": \"0\",\
		\"type\": \"Reference\"\
	},\
	{\
		\"path\": \"VisionPrescription.dispense\",\
		\"type\": \"BackboneElement\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"VisionPrescription.dispense.id\",\
		\"type\": \"id\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"VisionPrescription.dispense.extension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"VisionPrescription.dispense.modifierExtension\",\
		\"type\": \"Extension\",\
		\"min\": \"0\",\
		\"max\": \"*\"\
	},\
	{\
		\"path\": \"VisionPrescription.dispense.product\",\
		\"type\": \"Coding\",\
		\"min\": \"1\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"VisionPrescription.dispense.eye\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"VisionPrescription.dispense.sphere\",\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"VisionPrescription.dispense.cylinder\",\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"VisionPrescription.dispense.axis\",\
		\"type\": \"integer\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"VisionPrescription.dispense.prism\",\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"VisionPrescription.dispense.base\",\
		\"type\": \"code\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"VisionPrescription.dispense.add\",\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"VisionPrescription.dispense.power\",\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"VisionPrescription.dispense.backCurve\",\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"VisionPrescription.dispense.diameter\",\
		\"type\": \"decimal\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"VisionPrescription.dispense.duration\",\
		\"type\": \"Quantity\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"VisionPrescription.dispense.color\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"VisionPrescription.dispense.brand\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	},\
	{\
		\"path\": \"VisionPrescription.dispense.notes\",\
		\"type\": \"string\",\
		\"min\": \"0\",\
		\"max\": \"1\"\
	}\
]"function require_resource(name) return resources[name] or error("resource '"..tostring(name).."' not found"); end end --[[
  FHIR Formats

  Copyright (C) 2016 Vadim Peretokin

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
]]

local status, xml = pcall(require, "xml")
if not status then
  xml = {}
  xml.dump = require("fhirformats-xml").dump
end

local status, cjson = pcall(require, "cjson")
if not status then cjson = nil end
local status, prettyjson = pcall(require, "resty.prettycjson")
if not status then prettyjson = nil end
local status, datafile = pcall(require, "datafile")
if not status then datafile = nil end
local lunajson = require("lunajson")

local ipairs, pairs, type, print, tonumber, gmatch, tremove, sformat
= ipairs, pairs, type, print, tonumber, string.gmatch, table.remove, string.format

local get_fhir_definition, read_fhir_data, getindex, map_fhir_data, fhir_typed
local get_json_datatype, print_data_for_node, convert_to_lua_from_xml, handle_div
local convert_to_json, file_exists, read_filecontent, read_file, make_json_datatype
local handle_json_recursively, print_simple_datatype, convert_to_lua_from_json
local convert_to_xml, print_complex_datatype

local fhir_data

local null_value
local json_decode, json_encode

if cjson then
  null_value = cjson.null
  json_decode, json_encode = cjson.decode, cjson.encode
elseif lunajson then
  null_value = math.huge * 0
  json_decode = function(data)
    return lunajson.decode(data, nil, null_value)
  end
  json_encode = function(data)
    return lunajson.encode(data, null_value)
  end
else
  error("neither cjson nor luajson libraries found for JSON parsing")
end

-- credit: http://stackoverflow.com/a/4991602/72944
file_exists = function(name)
  local f = io.open(name,"r")
  if f ~= nil then io.close(f) return true else return false end
end

read_fhir_data = function(filename)
  -- prefer the filename, but substitute the nil if not given
  local locations = {(filename or ""), "fhir-data/fhir-elements.json", "src/fhir-data/fhir-elements.json", "../src/fhir-data/fhir-elements.json", "fhir-data/fhir-elements.json"}
  local data

  for _, file in ipairs(locations) do
    if file_exists(file) then
      io.input(file)
      data = json_decode(io.read("*a"))
      break
    end
  end

  -- if installed as a LuaRock, try the data directory
  if not data and datafile then
    local file, err = datafile.open("src/fhir-data/fhir-elements.json", "r")
    data = json_decode(file:read("*a"))
  end

  if not data and require_resource then
    data = json_decode(require_resource("fhir-data/fhir-elements.json"))
  end

  assert(data, string.format("read_fhir_data: FHIR Schema could not be found in these locations:\n  %s.\n%s%s", table.concat(locations, " "), datafile and "Datafile could not find LuaRocks installation as well." or '', require_resource and "Embedded JSON data could not be found as well." or ''))
  return data
end

-- returns the index of the value in a list
getindex = function(list, value)
  if not list then return nil end

  for i = 1, #list do
    if list[i] == value then return i end
  end
end

-- returns a list as a key-value map, value can be a value
-- to assign or a function to evaluate before assignment.
-- Function will have the processed list value as first argument
list_to_map = function(list, value)
  if not list then return nil end

  local map = {}

  if type(value) == "function" then
    for i = 1, #list do
      local element = list[i]
      map[element] = value(element)
    end
  else
    for i = 1, #list do
      map[list[i]] = value
    end
  end

  return map
end

-- return a map with the path (as string) and an array or list for the JSON element to create
map_fhir_data = function(raw_fhir_data)
  fhir_data = {}
  local flatten_derivations, parse_element

  parse_element = function(element)
    local previouselement = fhir_data
    for word in gmatch(element.path, "([^%.]+)") do
      previouselement[word] = previouselement[word] or {}
      previouselement = previouselement[word]
    end
    previouselement._max = element.max
    previouselement._type = element.type
    previouselement._type_json = element.type_json
    previouselement._derivations = list_to_map(element.derivations, function(value) return fhir_data[value] end)
    flatten_derivations(previouselement)

    if type(fhir_data[element.type]) == "table" then
      previouselement[1] = fhir_data[element.type]
    end
  end

  flatten_derivations = function(root_element, nested_element)
    if not (root_element and root_element._derivations) then return end

    local derivations = nested_element and nested_element._derivations or root_element._derivations
    for derivation, data in pairs(derivations) do
      if data._derivations then
        for nested_derivation, nested_data in pairs(data._derivations) do
          if root_element ~= nested_data then
            root_element._derivations[nested_derivation] = nested_data

-- TODO: fix me to be recursive and not just one level down
--            flatten_derivations(root_element, nested_data)
          end
        end
      end
    end
  end

  -- parse once to ensure all datatypes are in
  for i = 1, #raw_fhir_data do
    local element = raw_fhir_data[i]
    parse_element(element)
  end

  -- parse again to ensure all resources are in
  for i = 1, #raw_fhir_data do
    local element = raw_fhir_data[i]
    parse_element(element)
  end

  return fhir_data
end

read_filecontent = function(filecontent, f)
  return f(filecontent)
end

read_file = function(filename, f)
  io.input(filename)
  local filecontent = io.read("*a")
  io.input():close()

  return f(filecontent)
end

-- returns FHIR JSON-typed version of the input
-- input: a node with an xml and a value key
-- output: JSON-typed node.value
fhir_typed = function(output_stack, node)
  local value = node.value

  local fhir_definition = get_fhir_definition(output_stack, node.xml)

  if not fhir_definition then
    print(string.format("Warning: %s is not a known FHIR element; couldn't check its FHIR type to decide the JSON type.", table.concat(output_stack, ".")))
    return value
  end

  local json_type = fhir_definition._type or fhir_definition._type_json

  if json_type == "boolean" then
    if node.value == "true" then return true
    elseif node.value == "false" then return false
    else
      print(string.format("Warning: %s.%s is of type %s in FHIR JSON - its XML value of %s is invalid.", table.concat(output_stack), node.xml, json_type, node.value))
    end
  elseif json_type == "number" then return tonumber(node.value)
  else return value
  end
end

-- given an element and a path to it, returns the FHIR definition from
-- the FHIR schema
get_fhir_definition = function (output_stack, element_to_check)
  local fhir_data_pointer

  if element_to_check == "id" and output_stack[#output_stack] == "Organization" then
    print()
  end

  -- +1 since element_to_checkk; isn't on the stack
  for i = 1, #output_stack+1 do
    local element = (output_stack[i] or element_to_check)

    if not fhir_data_pointer then
      fhir_data_pointer = fhir_data[element]
    elseif fhir_data_pointer[element] then
      fhir_data_pointer = fhir_data_pointer[element]
    elseif fhir_data_pointer[1] then
      fhir_data_pointer = fhir_data_pointer[1][element] or fhir_data_pointer[1]._derivations[element]
    else
      fhir_data_pointer = nil
      break -- bail out of the for loop if we didn't find the element we're looking for
    end
  end

  return fhir_data_pointer
end

make_json_datatype = function(output_stack, element_to_check)
  local newtable, pointer_inside_table

  local fhir_definition = get_fhir_definition(output_stack, element_to_check)

  if not fhir_definition then
    print(string.format("Warning: %s.%s is not a known FHIR element; couldn't check max cardinality for it to decide on a JSON object or array.", table.concat(output_stack, "."), element_to_check))
  end

  if fhir_definition and fhir_definition._max == "*" then
    newtable = {{}}
    pointer_inside_table = newtable[1]
  else
    newtable = {}
    pointer_inside_table = newtable
  end

  return newtable, pointer_inside_table
end


get_json_datatype = function(output_stack, element_to_check)
  local fhir_data_pointer = get_fhir_definition(output_stack, element_to_check)

  if fhir_data_pointer == nil then
    print(string.format("Warning: %s.%s is not a known FHIR element; couldn't check max cardinality for it to decide on a JSON object or array.", table.concat(output_stack, "."), element_to_check))
  end

  if fhir_data_pointer and fhir_data_pointer._max == "*" then
    return "array"
  end

  return "object"
end

print_data_for_node = function(node, level, output, output_levels, output_stack)
  assert(node.xml, "error from parsed xml: node.xml is missing")
  local previouslevel = level - 1

  -- in JSON, resource type is embedded within the object.resourceType,
  -- unlike at root level in FHIR XML
  if level == 1 then
    output.resourceType = node.xml
  elseif node.value then
    -- if we're processing a primitive value, add it to the right place
    -- in output{}. Right place is given to us by looking at the last
    -- place in the 2D stack
    if not output_levels[previouslevel][#output_levels[previouslevel]][node.xml] then
      output_levels[previouslevel][#output_levels[previouslevel]][node.xml] = (get_json_datatype(output_stack, node.xml) == "array" and {fhir_typed(output_stack, node)} or fhir_typed(output_stack, node))
    else -- if there's something there already, then that means we have more values for the array
      local existing_array = output_levels[previouslevel][#output_levels[previouslevel]][node.xml]

      existing_array[#existing_array+1] = fhir_typed(output_stack, node)

      -- add a null to the corresponding _ prefix if it's there
      local _value = output_levels[previouslevel][#output_levels[previouslevel]]["_"..node.xml]
      if _value then
        _value[#_value+1] = null_value
      end
    end
    -- elseif node.xmlns then
    -- no namespaces in JSON, for now just eat the value
  end

  -- embedded table - create a table in the output and add it to the right place
  -- in the output_stack, so when we're inserting the primitive values above,
  -- we know which table to add the value to
  if type(node[1]) == "table"
  and level ~= 1 then -- don't create another table for level 1, since in FHIR JSON the
    -- resource name is 'inside' as a resourceType property

    local newtable, pointer_inside_table

    -- if this is a recurring XML element, and not an embedded id or extension,
    -- create another array in an existing array for it (TODO: fix this mess with below)
    if type(output_levels[previouslevel][#output_levels[previouslevel]][node.xml]) == "table"
    and not (level ~= 1 and node[1] and (node[1].xml == "id" or node[1].xml == "extension")) then
      local existing_array = output_levels[previouslevel][#output_levels[previouslevel]][node.xml]
      existing_array[#existing_array+1] = {}
      pointer_inside_table = existing_array[#existing_array]
    elseif not output_levels[previouslevel][#output_levels[previouslevel]][node.xml] then
      -- create a new table in output using our stack pointer, if we
      -- haven't created already - could've been created by node.value above
      -- and what we're now looking at is an extension within
      newtable, pointer_inside_table = make_json_datatype(output_stack, node.xml)
      output_levels[previouslevel][#output_levels[previouslevel]][node.xml] = newtable
    end


    -- if it's an id or an extension element of a datatype, create a fix with a _ prefix for it
    if level ~= 1 and node[1] and (node.id or node[1].xml == "extension") then
      newtable, pointer_inside_table = make_json_datatype(output_stack, node.xml)
      output_levels[previouslevel][#output_levels[previouslevel]]['_'..node.xml] = newtable

      -- see if we need to pad the _value table out with null's in case we've got
      -- multiple values (https://hl7-fhir.github.io/json.html#primitive)
      local pos = getindex(output_levels[previouslevel][#output_levels[previouslevel]][node.xml], node.value)
      if pos and pos > 1 then
        newtable[1] = nil -- remove the first {} that json_object_or_array added, as we need to pre-pad
        for _ = 1, pos-1 do
          newtable[#newtable+1] = null_value
        end
        newtable[#newtable+1] = {} -- re-insert the first {} deleted earlier
        pointer_inside_table = newtable[#newtable]
      end
    end

    -- update stack with a pointer to the table we made above
    output_levels[level] = output_levels[level] or {}
    output_levels[level][#output_levels[level]+1] = pointer_inside_table
  end


  -- lastly, handle extension URLs by creating them not at the current level, but at the
  -- nested level down as FHIR JSON likes it
  if node.url then
    output_levels[level][#output_levels[level]].url = node.url
  end

  return output
end

handle_div = function(output_levels, node, level)
  output_levels[level][#output_levels[level]][node.xml] = xml.dump(node)
end

convert_to_lua_from_xml = function(xml_data, level, output, output_levels, output_stack)
  -- level is the nesting level inside raw xml_data from our xml parser
  level = (level and (level+1) or 1)

  output = print_data_for_node(xml_data, level, output, output_levels, output_stack)

  output_stack[#output_stack+1] = xml_data.xml
  for _, value in ipairs(xml_data) do
    if value.xml == "div" and value.xmlns == "http://www.w3.org/1999/xhtml" then
      handle_div(output_levels, value, level)
    else
      assert(type(value) == "table", string.format("unexpected type value encountered: %s (%s), expecting table", tostring(value), type(value)))
      convert_to_lua_from_xml(value, level, output, output_levels, output_stack)
    end
  end
  tremove(output_stack)

  return output
end

convert_to_json = function(data, options)
  fhir_data = fhir_data or map_fhir_data(read_fhir_data())

  assert(next(fhir_data), "convert_to_json: FHIR Schema could not be parsed in.")

  local xml_data
  if options and options.file then
    xml_data = read_file(data, xml.load)
  else
    xml_data = read_filecontent(data, xml.load)
  end

  local output = {}
  local output_levels = {[1] = {output}}
  local output_stack = {}

  local data_in_lua = convert_to_lua_from_xml(xml_data, nil, output, output_levels, output_stack)

  return (options and options.pretty) and prettyjson(data_in_lua)
  or json_encode(data_in_lua)
end

-- prints a simple datatype to the right place in the output table,
-- as indicated by the last pointer in the xml_output_level stack
print_simple_datatype = function(element, simple_type, xml_output_levels, extra_data)
  -- ignore if this is a _value, as those will be handled when handling their
  -- respective 'value' element
  if element:find("_", 1, true) then return end

  -- obtain pointer to the output table we're currently writing to
  local current_output_table = xml_output_levels[#xml_output_levels]

  -- divs are a special case - load the XML from JSON and place it inline
  if element == "div" then
    current_output_table[#current_output_table+1] = xml.load(simple_type)
  elseif element == "url" then -- some things are attributes: https://hl7-fhir.github.io/xml.html#1.17.1
    current_output_table.url = simple_type
  elseif type(simple_type) == "userdata" then -- only userdata possible is null_value, so don't show anything
    current_output_table[#current_output_table+1] = {xml = element}
  else
    current_output_table[#current_output_table+1] = {xml = element, value = tostring(simple_type)}
  end

  if extra_data then
    xml_output_levels[#xml_output_levels+1] = current_output_table[#current_output_table]
    handle_json_recursively(extra_data, xml_output_levels)
    tremove(xml_output_levels)
  end
end

-- prints a complex datatype to the right place in the output table,
-- as indicated by the last pointer in the xml_output_level stack,
-- and recurses down to handle more available values
print_complex_datatype = function(element, complex_type, xml_output_levels)
  -- ignore if this is a _value, as those will be handled when handling their
  -- respective 'value' element
  if element:find("_", 1, true) then return end

  -- obtain pointer to the output table we're currently writing to
  local current_output_table = xml_output_levels[#xml_output_levels]

  -- add new table within the said output table
  current_output_table[#current_output_table+1] = {xml = element}

  -- update our pointer to point to the newly-created table that we'll now be writing data to
  xml_output_levels[#xml_output_levels+1] = current_output_table[#current_output_table]

  -- recurse down to write any more complex or primitive values
  handle_json_recursively(complex_type, xml_output_levels)

  -- stepping back out, remove pointer from stack
  tremove(xml_output_levels)
end

print_contained_resource = function(json_data, xml_output_levels)
  local current_output_table = xml_output_levels[#xml_output_levels]
  current_output_table[#current_output_table+1] = {xml = json_data.resourceType, xmlns = "http://hl7.org/fhir"}
  xml_output_levels[#xml_output_levels+1] = current_output_table[#current_output_table]
  json_data.resourceType = nil
end

handle_json_recursively = function(json_data, xml_output_levels)
  -- handle contained resources
  local had_contained_resource
  if json_data.resourceType then
    print_contained_resource(json_data, xml_output_levels)
    had_contained_resource = true
  end

  -- use pairs since this is a JSON object with key-value pairs
  for element, data in pairs(json_data) do
    -- TODO: change type(data) to lua_data_type
    if type(data) == "table" then -- handle arrays with in-place expansion (one array is many xml pbjects)
      if type(data[1]) == "table" then -- array of resources/complex types
        for _, array_complex_element in ipairs(data) do
          if type(array_complex_element) ~= "userdata" then
            print_complex_datatype(element, array_complex_element, xml_output_levels)
          end
        end

      elseif data[1] and type(data[1]) ~= "table" then -- array of simple datatypes
        for i, array_primitive_element in ipairs(data) do
          -- handle extra values (id and extension) stored in _element by looking up
          -- the appropriate array, and if it exists, pass the correct value within
          -- the said array to print function
          local _array, _value = json_data[sformat("_%s", element)]
          if _array then
            _value = _array[i]
            -- don't process if it's JSON null
            if _value == null_value then _value = nil end
          end
          print_simple_datatype(element, array_primitive_element, xml_output_levels, _value)
        end
      elseif type(data) ~= "userdata" then
        print_complex_datatype(element, data, xml_output_levels)
      end
    elseif type(data) ~= "userdata" then -- not an array, handle object property
      print_simple_datatype(element, data, xml_output_levels, json_data[sformat("_%s", element)])
    end

    -- handle a special case: there is an '_element' in JSON but no corresponding 'element'
    if element:sub(1,1) == '_' and not json_data[element:sub(2)] then
      print_complex_datatype(element:sub(2), data, xml_output_levels)
    end
  end

  if had_contained_resource then
    tremove(xml_output_levels)
  end
end

-- entry point for converting from JSON to XML
convert_to_lua_from_json = function(json_data, output, xml_output_levels)
  -- strip out the root resourceType
  if json_data.resourceType then
    output.xmlns = "http://hl7.org/fhir"
    output.xml = json_data.resourceType
    json_data.resourceType = nil
  end

  -- continue processing rest of resource
  return handle_json_recursively(json_data, xml_output_levels)
end

convert_to_xml = function(data, options)
  fhir_data = fhir_data or map_fhir_data(read_fhir_data())

  assert(next(fhir_data), "convert_to_xml: FHIR Schema could not be parsed in.")

  local json_data
  if options and options.file then
    json_data = read_file(data, json_decode)
  else
    json_data = read_filecontent(data, json_decode)
  end

  local output = {}
  local xml_output_levels = {output}

  convert_to_lua_from_json(json_data, output, xml_output_levels)

  return xml.dump(output)
end

return {
  to_json = convert_to_json,
  to_xml = convert_to_xml
}
