--spaghetti code
function love.load()
	json = require("json")
	thread = love.thread.newThread("thread.lua")
	thread:start()
	captcha = love.graphics.newCanvas(340,98)
	render64 = love.thread.getChannel("render64")
	render64R = love.thread.getChannel("render64R")

	datas = {dbs=0,imgs=0,pings=0} --Stats data

	fonts = {
		default = love.graphics.getFont(),
		big = love.graphics.newFont("SpicyRice.ttf",90)
	}
	function spacing(text,n)
		local t = ""
		for i=1,#text,1 do
			t=t..text:sub(i,i)..(" "):rep(n)
		end
		return t:sub(0,#t-1)
	end
end
function love.update(dt)
	local d1 = render64:pop()
	if d1 then
		local js = json.decode(d1)
		if js.op == 0 then
			love.graphics.setCanvas(captcha)
			love.graphics.clear()
			--love.graphics.setColor(0.2,0.2,0.2,0.1)
			--love.graphics.rectangle("fill",0,0,340,98)
			love.graphics.setColor(1,1,1,1)
			love.graphics.setFont(fonts.big)
			local text = spacing(js.text,1)
			love.graphics.print(text,
				340/2-fonts.big:getWidth(text)/2,
				98/2-fonts.big:getHeight(text)/2
			)
			love.graphics.setFont(fonts.default)
			love.graphics.setCanvas()
			local data = captcha:newImageData()
			dat=data:encode("png")
			local b64 = love.data.encode("string","base64",dat)
			b64 = b64:sub(1,10).."p"..b64:sub(11,#b64)
			render64R:push(b64)
			data:release()
			dat:release()
			datas.imgs=datas.imgs+1
		elseif js.op == 1 then
			datas.pings=datas.pings+1
		elseif js.op == 2 then
			datas.dbs=datas.dbs+1
		end
	end
end
function love.draw()
	love.graphics.print('Press "s" to save database and "p" to ping')
	love.graphics.print('Databases saved: '..datas.dbs,0,20)
	love.graphics.print('Images sent to server: '..datas.imgs,0,40)
	love.graphics.print('Received pings: '..datas.pings,0,60)
	love.graphics.print('Version 0.0.1',0,90)
end

function love.keypressed(key)
	if key == "s" then
		love.thread.getChannel("request"):push('{"req":1}')
	elseif key == "p" then
		love.thread.getChannel("pingreq"):push('abc')
	end
end