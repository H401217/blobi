function love.load()
	json = require("json")
	thread = love.thread.newThread("thread.lua")
	thread:start()
	captcha = love.graphics.newCanvas(340,98)
	render64 = love.thread.getChannel("render64")
	render64R = love.thread.getChannel("render64R")
end
function love.update(dt)
	local d1 = render64:pop()
	if d1 then
		local js = json.decode(d1)
		if js.op == 0 then
			love.graphics.setCanvas(captcha)
			love.graphics.clear()
			love.graphics.setColor(0.2,0.2,0.2,1)
			love.graphics.rectangle("fill",0,0,340,98)
			love.graphics.setColor(1,1,1,1)
			love.graphics.print(js.text)
			love.graphics.setCanvas()
			local data = captcha:newImageData()
			dat=data:encode("png")
			local b64 = love.data.encode("string","base64",dat)
			b64 = b64:sub(1,10).."p"..b64:sub(11,#b64)
			data:release()
			dat:release()
			render64R:push(b64)
		end
	end
end
function love.draw()
	love.graphics.rectangle("fill",0,0,100,100)
end

function love.keypressed(key)
	print(key)
	if key == "s" then
		love.thread.getChannel("request"):push('{"req":1}')
	end
end