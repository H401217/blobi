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
	return url:gsub("%%(%x%x)", hex2char)
end

return UTIL