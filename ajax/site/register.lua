return function(req)
	local cI = req.queries["cI"]
	local cA = req.queries["cA"]
	local email = req.queries["e"]

	local res = {body="",headers={}}
	local body = {success=false}

	local obj = databases.captcha[cI]
	if obj and email then --CAPTCHA exists and provides e-mail
		if obj.answer == cA then --CAPTCHA answer is correct
			local id
			local tempid
			repeat
				local timems=socket.gettime()*1000
				timems=math.floor(timems)<<4
				local seq = 0
				repeat
					tempid = timems+seq
				until seq > 15 or (not databases.Users[tempid])
			until not databases.Users[tempid]
			id = math.floor(tempid)
			body.success=true
			body.i = id
			body.n = tostring(id)
			
			databases.Users[tostring(id)] = {nickname=body.n,state="{}",ver={v=tonumber(req.queries["_v"]) or 4,r=req.queries["_r"]},email=email,password=md5.sumhexa("")}
			local cookie = ("%X"):format(tonumber(body.i)) .. "-" .. ("%X"):format(os.time()) .."-".. databases:generatePassword(20,os.time(),true)
			table.insert(databases.Cookies,{token=cookie})
			res.headers["Set-Cookie"]="unn_session=".. cookie ..";path=/"
			print("\27[92mNEW COOKIE: ",cookie.."\27[0m")
		else
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
			
			controller:send(json.encode({op=1,text=capAns,id=rng}))
			controller:settimeout(.1)
			local _,_,dat = controller:receive()
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
	end
	res.body = json.encode(body)
	return res
end