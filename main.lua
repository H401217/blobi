MainSettings = require("settings")
md5 = require("md5")
json = require("json")
UTIL = require("utilities")



filesystem = require("lfs")
databases = require("databases")
databases:load()
--print(databases.Cookies[1]["token"])
http = require("http")
templates = require("templates")


local MAX = MainSettings.maxUsers
local ACTIVE = 0

serversettings = {
	nologin={
		"/ajax/site/login",
		"/ajax/site/register",
		"/ajax/site/reset_password",
		"/ajax/site/check_email",
		"/ajax/site/top_likes",
		"/ajax/site/top_scores",
	}
}

socket = require("socket")
local server = socket.tcp()
clientmanager = socket.tcp() --This is a local client that will serve as Server Console when receiving dat
clientmanager:bind("127.0.0.1",5346)
clientmanager:settimeout(0.001)
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
	local status = 200
	local headers = {}
	local body = ""
	local size
	print(req.path,req.ip,req.port,#req.queries,req.version,req.method,#req.headers,req.body)

	if string.starts(req.path,"/assets") then
		local btype = "application/octet-stream"
		body,size,fname = templates:load(string.sub(req.path,2),true)	
		btype = http:mimeExt(fname or "")
		if not body and not size then
			status=404
			body = "Asset "..req.path.." not found"
			btype = "text/plain"
		else
			headers["Content-Type"] = btype
		end
	elseif string.starts(req.path,"/ajax") then
		if (tonumber(req.queries["_r"]) or 0) >= MainSettings.minVer then
			local has_access = false
			local usercookie = http:decodeCookie(req.headers["cookie"] or "")["unn_session"]
			for a,b in pairs(databases.Cookies) do
				if b.token == usercookie then has_access = true break end
			end
			if has_access or table.starts(serversettings.nologin,req.path) then
				_s,res = pcall(function() return require(string.sub(req.path,2,260))(req) end)
				if _s then
					body = res.body
					for a,b in pairs(res.headers) do
						headers[a]=b
					end
				else
					body = templates:err("success",false)
					UTIL.console.warn("INTERNAL ERROR:",res)
				end
			else 
				body = templates:err("notlogged")
			end
		else
			body = templates:err("update",false)
		end
	else
		local page,siz = templates:mainPath(req.path)
		if page then
			body,size = page,siz
		else
			status = 404
			body,size = templates:load("pages/404.html")
		end	
	end
	return http:write(status,headers,body,size)
end

function handlepeer(client) --Only supporting HTTP 1.0
	local initialclock = os.clock()
	client:settimeout(0.001)
	local line = 0
	local record = {}
	local headers = {}
	local body
	local cip,cport = client:getpeername()
	if not cip then return end
	print("an user called "..cip.."wants to connect invasor")
	while true do
		local data
		local extractingBody = false
		local ended = false
		local full,err,partial = client:receive(MainSettings.speed) --note2: tbd --note: STOP USING THIS SYSTEM, use a parser to be faster (franchesco virgolini) nota 3: q vrg hiciste no entiendo tu sugerencia
			print("data:::",full,err,partial)
		data = UTIL.empty(full) and partial or full
			local printablexd = string.gsub(data,"\n","\\n")
			printablexd = string.gsub(printablexd,"\r","\\r")
			print("printable::",printablexd)
		while true do
			local start = data:find("\n") --extrae una sola línea
			if start then
				local chunk = data:sub(0,start)
				data=data:sub(start+1) --eso demuestra que es un chunk que se come a pedazos
				chunk = chunk:sub(0,#chunk-1) --remove \n
				if chunk:sub(#chunk)=="\r" then
					chunk = chunk:sub(0,#chunk-1) --remove \r (who tf puts \n\r)
				end
				if chunk then
					line = line + 1
					if line == 1 then
						record = http:decodeRecord(chunk) --Gets HTTP version, path, queries and method
						print("extracted record ye")
					else
						if #chunk > 0 and (not extractingBody) then
							local k,v = http:decodeHeader(chunk) --Gets all headers
							headers[k] = v
							print("extracted header::: ".. k)
						else --Checks the newline between headers and body
							local expected_length
							if not extractingBody then
								expected_length = tonumber(headers["content-length"] or 0)
							else
								expected_length = tonumber(headers["content-length"] or 0) - #body
							end
								print("how did we got here, anyways the expected length is ".. expected_length)
								local printablexd = string.gsub(data,"\n","\\n")
								printablexd = string.gsub(printablexd,"\r","\\r")
								print("printable body::",printablexd)
							extractingBody = true
							if (expected_length or 0) >= 1 then
								body = data:sub(0,expected_length)
								data=data:sub(expected_length+1)
								while true do --stop please im begging
									if not (#body >= expected_length) then
										local rest,err,partrest = client:receive(expected_length-#body) --bru how do you expect to receive that PLEASE USE THE BANDWIDTH
										bodydat = UTIL.empty(rest) and partrest or rest
									--fixing bug, code is extracting from rest, but we cannot assure, so we extract from rest
										print("getting buggy body",rest,err,partrest)
										body=body..bodydat
									end
									if #body>=expected_length then
										ended = true
										break
									end
								end
							else ended = true
							end
							break
						end
					end
				else
					local diff = os.clock()-initialclock
					if diff >= 5 then
						print("got a timeout because the client is very lazy like me")
						client:send("HTTP 408 Request Timeout\nConnection:close\n\n")
						client:close()
						return
					end
				end
			elseif UTIL.empty(data) then
				print("no data but not closed")
				break
			end
		end
		if ended then
			print("closed: there is no more data available")
			break
		end
		coroutine.yield() --the laggy guy
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
			print("ERROR: sorry we're full xd")
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
						UTIL.console.warn("Pong!")
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
