local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/' -- You will need this for encoding/decoding
-- encoding
function enc(data)
    return ((data:gsub('.', function(x) 
        local r,b='',x:byte()
        for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
        return r;
    end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if (#x < 6) then return '' end
        local c=0
        for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
        return b:sub(c+1,c+1)
    end)..({ '', '==', '=' })[#data%3+1])
end

local function en(str)
	str = string.gsub(str,"\n","")
	str = string.gsub(str," ","")
	local fin = ""
	for i=1,#str,2 do
		local h = string.sub(str,i,i+1)
		fin=fin..string.char(tonumber(h,16))
	end
	return enc(fin)
end





return function(req)
	local body = {registered=false}
	for k,v in pairs(databases.Users) do
		--print(v.email == req.queries["e"],v.email , req.queries["e"] )
		if v.email == req.queries["e"] then
			body.registered=true
			goto done1
		end
	end
	do
		local rng = math.random(1,1000000)
		
		for k,v in pairs(databases.captcha) do
			if os.time()-v.time>=20 then
				databases.captcha[k]=nil
			end
		end
		
		local capId
		repeat
			capId = databases:generatePassword(6,os.time())
		until not databases.captcha[capId]
		local capLen = 5
		local capAns = databases:generatePassword(capLen,os.time())
		
		clientmanager:send(json.encode({op=1,text=capAns,id=rng}))
		clientmanager:settimeout(.1)
		local dat = clientmanager:receive()
		clientmanager:settimeout(0)
		local i64 = ""
		print(dat)
		local _s, js = pcall(function() return json.decode(dat) end)
		if _s then
			if js.id == rng then
				i64 = js.img
			end
		end
		body.capId = capId
		body.capLen = capLen
		body.capImg = i64
		databases.captcha[capId]={answer=capAns,time=os.time()}
	end
	::done1::
	local res = {body=json.encode(body),headers={}}
	return res
end