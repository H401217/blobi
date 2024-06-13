return function(req)
	local body = {registered=false}

	--print(req.queries["e"]) --Prints Email

	for k,v in pairs(databases.Users) do
		if (v.email == req.queries["e"]) then
			body.registered=true
			goto done1
		end
	end
	do --Generate CAPTCHA if not registered
		local rng = math.random(1,1000000)
		
		for k,v in pairs(databases.captcha) do
			if (os.time()-v.time >= MainSettings.CAPTCHA_T) then
				databases.captcha[k]=nil --Removes inactive CAPTCHAs
			end
		end
		
		local capId
		repeat
			capId = databases:generatePassword(6,os.time())
		until not databases.captcha[capId]

		local capLen = MainSettings.CAPTCHA_L
		local capAns = databases:generatePassword(capLen,os.time())
		
		controller:send(json.encode({op=1,text=capAns,id=rng})) --Request PNG to controller
		controller:settimeout(.3)
		local _,_,dat = controller:receive() --Get PNG from controller
		controller:settimeout(0.01)
		local i64 = ""
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