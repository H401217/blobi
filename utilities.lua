local UTIL = {}

--UTIL.b64 = require("base64")
UTIL.jsonloop = function(ft)
    local tab1 = json.decode(ft)
	local function dec(t)
		for a,b in pairs(t) do
			if type(b) == "string" then
				if string.sub(b,1,1) == "{" or string.sub(b,1,1) == "[" then
					t[a] = js.decode(t[a]) --string.sub(b,1,string.len(b))
					t[a] = dec(t[a])
				end
			end
		end
		return t
	end
	return dec(tab1)
end

UTIL.hex2char = function(x)
	return string.char(tonumber(x, 16))
end
UTIL.unescapeurl = function(url)
	return url:gsub("%%(%x%x)", UTIL.hex2char)
end

UTIL.console = {
	log = print,
	warn = function(...)
		local arg = {...}
		print("\27[92m")
		print(table.unpack(arg))
		print("\27[0m")
	end,
}

UTIL.empty = function(value)
	local empty = false
	if value == nil then
		empty = true
	elseif type(value)=="string" then
		empty = (#value == 0)
	end
	return empty
end

UTIL.split = function(inputstr, sep) --stackoverflow
	if sep == nil then
		sep = "%s"
	end
	local t = {}
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
		table.insert(t, str)
	end
	return t
end

table.find = function(tab, value)
	for k,v in ((#tab>=1) and ipairs(tab) or pairs(tab)) do
		if v==value then
			return k
		end
	end
end

table.count = function(tab)
	local count = 0
	for k,v in pairs(tab) do
		count=count+1
	end
	return count
end

return UTIL