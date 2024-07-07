function mysplit (inputstr, sep)
        if sep == nil then
                sep = "%s"
        end
        local t={}
        for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
                table.insert(t, str)
        end
        return t
end
--Hello
function string.starts(String,Start)
   return string.sub(String,1,string.len(Start))==Start
end

function table.starts(tab,val)
	for k,v in pairs(tab) do
		if string.starts(v,val) then
			return k
		end
	end
end

local http = {}

http.version = "HTTP/1.0"
http.heads = {
	[101]="Switching Protocol",
	[200]="OK",
	[204]="No Content",
	[301]="Moved Permanently",
	[400]="Bad Request",
	[401]="Unauthorized",
	[403]="Forbidden",
	[404]="Not Found",
	[411]="Length Required",
	[418]="I'm a teapot",
	[429]="Too Many Requests",
	[451]="Unavailable For Legal Reasons",
	[500]="Internal Server Error",
	[503]="Service Unavailable",
	[505]="HTTP Version Not Supported",
}

http.mime = {
	["html"] = "text/html",
	["txt"] = "text/plain",
	["js"] = "text/javascript",
	["css"] = "text/css",
	["ttf"] = "font/ttf",
	["png"] = "image/png",
	["jpg"] = "image/jpg",
	["json"] = "application/json",
	["octet"] = "application/octet-stream"
}

function http:write(status,headers,body,size)
	size = size or string.len(body or "")
	status = (body and status) or 204
	local str = self.version .. " "..status.." " .. self.heads[status] .."\n"
	for a,b in pairs(headers or {}) do
		str = str..a..":"..b.."\n"
	end
	str = str.."Server:lua\nContent-Length:"..size..(body and "\n\n" or "") .. (body or "")
	return str
end

function http:decodeRecord(str)
	local tab = {}
	local split = mysplit(str)
	if #split >=3 then
		tab.method = split[1]
		tab.version = split[3]
		tab.queries = {}
		local split2 = mysplit(split[2],"?")
		tab.path = split2[1] or "/"
		if split2[2] then
			for a,b in pairs(mysplit(split2[2],"&")) do
				local split3 = mysplit(b,"=")
				tab.queries[split3[1]]=UTIL.unescapeurl(split3[2] or "")
			end
		end
		return tab
	else return
	end
end

function http:decodeHeader(str)
	local split = mysplit(str,":")
	return string.lower(split[1]),(split[2] or "")
end

function http:decodeCookie(str)
	str = str or ""
	str = string.gsub(str," ","")
	local tab = {}
	local split1 = mysplit(str,";")
	for a,b in pairs(split1) do
		local split2 = mysplit(b,"=")
		if #split2 > 1 then
			tab[split2[1]] = split2[2]
		else
			tab[tonumber(a)]=split2[1]
		end
	end
	return tab
end

function http:decodePou(req) --gets ID
	local c = self:decodeCookie(req.headers["cookie"] or "")["unn_session"] or ""
	return tostring(tonumber(c:sub(0,c:find("-")-1),16))
end

function http:mimeExt(name) --MIME type by extension
	local split = mysplit(name,".")
	local fn = self.mime[split[#split]] or self.mime["octet"]
	print(fn,name,split[#split])
	return fn
end

function http:mimeAuto()

end

return http
