local socket = require("socket")
local json = require("json")


local client = socket.udp()
assert(client:setsockname("127.0.0.1",5347))
assert(client:setpeername("127.0.0.1",5346))
client:settimeout(0)
client:send('{"auth":"4df27f8875a1129e4db8917074e4965c","op":0}')--op 0 = ping op 1 = save

while true do
	local dat = client:receive()
	if dat then
		local _s,js = pcall(function() return json.decode(dat) end)
		if _s then
			local op = js.op
			if op == 0 then --ping response
				if js.success then
					print("Pong received!")
				end
			elseif op == 1 then
				--text id
				love.thread.getChannel("render64"):push(json.encode{op=0,text=js.text})
				local result = nil
				repeat
					result = love.thread.getChannel("render64R"):pop()
				until result
				print(#result)
				client:send(json.encode({id=js.id,img=result}))
			else print(dat)
			end
		end
	end
	local req = love.thread.getChannel("request"):pop()
	if req then
		local _s,js = pcall(function() return json.decode(req) end)
		if _s then
			local op = js.req
			if op == 1 then
				client:send(json.encode{auth="4df27f8875a1129e4db8917074e4965c",op=1,time=socket.gettime()})
				
			end
		end
	end
	socket.sleep(0.05)
end