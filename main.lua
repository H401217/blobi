MainSettings = require("settings")
md5 = require("md5")
json = require("json")
UTIL = require("utilities")



filesystem = require("lfs")
databases = require("databases")
databases:load()
print(databases.Cookies[1]["token"])
http = require("http")
templates = require("templates")

local console = {
	log = print,
	warn = function(...)
		local arg = {...}
		print("\27[92m")
		print(table.unpack(arg))
		print("\27[0m")
	end,
}


local MAX = MainSettings.maxUsers
local ACTIVE = 0

serversettings = {
	nologin={
		"/ajax/site/login",
		"/ajax/site/register",
		"/ajax/site/reset_password",
		"/ajax/site/check_email",
	}
}

socket = require("socket")
local server = socket.tcp()
clientmanager = socket.tcp() --This is a local client that will serve as Server Console when receiving dat
clientmanager:bind("127.0.0.1",5346)
clientmanager:settimeout(0.01)
clientmanager:listen(1)
assert(server:bind(MainSettings.ip,MainSettings.port),"Failed!") --change to your ip and port
os.execute("echo \27[92mStarting Server at "..server:getsockname().."\27[0m") --enables colored output (windows 10)
server:listen(MAX)

if MainSettings.LOVEauto == true then
	os.execute("start "..((MainSettings.LOVE=="") and "love" or MainSettings.LOVE).." "..filesystem.currentdir().."/controller")
end

function processdata(req)
	--[[
	req
		ip
		port
		queries
		version
		method
		path
		headers
		body
	]]
print(req.body)
	local status = 200
	local headers = {}
	local body = ""
	local size
	print(req.path,req.ip,req.port,#req.queries,req.version,req.method,#req.headers,req.body)
	if req.path == "/" then
		body,size = templates:load("pages/index.html")
	elseif req.path == "/login" then
		body,size = templates:load("pages/login.html")
	elseif req.path == "/myip" then
		body = req.ip..":"..req.port
	elseif string.starts(req.path,"/assets") then
		local bin = true
		local btype = "application/octet-stream"
		
		--[[if string.starts(req.path,"/assets/fonts") then
			btype = "application/x-font-ttf"
			bin = true
		elseif string.starts(req.path,"/assets/stylesheets") then
			btype = "text/css"
			bin = false
		elseif string.starts(req.path,"/assets/images") then
			btype = "image/png"
			bin = true
		end]]
		body,size,fname = templates:load(string.sub(req.path,2,#req.path),bin)	
		btype = http:mimeExt(fname or "")
		if not body and not size then
			status=404
			body = "Asset "..req.path.." not found"
			btype = "text/plain"
		else
			headers["Content-Type"] = btype
		end
	elseif string.starts(req.path,"/ajax") then
		if (tonumber(req.queries["_r"]) or 0) >= MainSettings.minVer then print("siu")
			local has_access = false
			local usercookie = http:decodeCookie(req.headers["cookie"] or "")["unn_session"]
			for a,b in pairs(databases.Cookies) do
				if b.token == usercookie then has_access = true break end
			end
			print(has_access,"myaccess")
			if has_access or table.starts(serversettings.nologin,req.path) then
				_s,res = pcall(function() return require(string.sub(req.path,2,999))(req) end)
				if _s then
					body = res.body
					for a,b in pairs(res.headers) do
						headers[a]=b
					end
				else body = templates:err("success",tostring(false)) print("\27[91mERROR:",res .."\27[0m")
				end
			else 
				body = templates:err("usernotloggedin")
			end
		else body = templates:err("clientoutdated") print("nooooooooooooooooooooo")
		end
	else
		status = 404
		body,size = templates:load("pages/404.html")
	end
	return http:write(status,headers,body,size)
end

function handlepeer(client)
--print(client)
	local initialclock = os.clock()
	client:settimeout(0.01)
	local line = 0
	local record = {}
	local headers = {}
	local body
	local cip,cport = client:getpeername()
	if not cip then return end
	while true do
		local chunk = client:receive("*l")
		if chunk then
			line = line + 1
			if line == 1 then
				record = http:decodeRecord(chunk)
			else
				if #chunk > 0 then
					local k,v = http:decodeHeader(chunk)
					headers[k] = v
				else
					if (headers["content-length"] or 0) ~= 0 then
						body = client:receive(headers["content-length"])
					end
					break
				end
			end
		else
			local diff = os.clock()-initialclock
			if diff >= 5 then
				client:send("HTTP 408 Request Timeout\nConnection:close\n\n")
				client:close()
				return
			end
		end
		coroutine.yield()
	end
	local send = processdata({ip = cip, port = cport, method = record.method, path = record.path, version = record.version, queries = record.queries ,headers = headers, body = body})
	client:send(send)
	client:close()
end


local threads = {}
server:settimeout(0.001)

controller = nil --Controller client object (tcp)

while true do
	local client = server:accept()
	if client then
		if ACTIVE >= MAX then
			client:close()
		else
			for i = 1,MAX do
				if threads[i] then
					if coroutine.status(threads[i]) == "suspended" then
						coroutine.resume(threads[i])
					elseif coroutine.status(threads[i]) == "dead" then
						threads[i] = coroutine.create(handlepeer)
						coroutine.resume(threads[i],client)
						break
					end
				else
					threads[i] = coroutine.create(handlepeer)
					coroutine.resume(threads[i],client)
					break
				end
			end
		end
	end

	for i = 1,MAX do
		if threads[i] then
			if coroutine.status(threads[i]) == "suspended" then
				coroutine.resume(threads[i])
			end
		end
	end

	if controller then
		local _,err = controller:settimeout(0.001)
		if err then
			controller:close()
			controller = nil
		end
		local dat,err,partial = controller:receive()
		dat = (dat=="" or dat==nil) and partial or dat
		if dat then
			local success,datjs = pcall(function() return json.decode(dat) end)
			if success and datjs then
				local auth = datjs.auth or ""
				if md5.sumhexa(auth) == "6a3f5243b0dbe0a38da23114f7ecd48c" then
					local op = datjs.op
					if op == 0 then --ping
						print("\27[92mPong!\27[0m")
						controller:send('{"op":0,"success":true}')
					elseif op == 1 then --save data
						local time = datjs.time
						local s,err = pcall(function() databases:save() end)
						controller:send(json.encode{op=2,success=tostring(s),time=socket.gettime()-time})
					end
				end
			end
		end
	else
		local object = clientmanager:accept()
		controller = object or controller
	end
end

os.execute("pause")
