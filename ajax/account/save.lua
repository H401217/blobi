return function(req)
	local res = {body=json.encode({success=true --[[,unclaimedNotifications = {{i=666,t=33,oT=3,oI=0,a=984926965,u2I=0,o2I=0}}]]}),headers={}}
	local cookie = http:decodeCookie(req.headers["cookie"] or "")["unn_session"] or ""
	if not (req.queries["c"]==md5.sumhexa("p@v_"..(req.body or "") ..cookie)) then res.body = templates:err("success",tostring(false)) return res end
	local _js = json.decode(req.body)
	
	local id = tostring(tonumber(cookie:sub(0,cookie:find("-")-1),16))
	
	if _js.state and _js.minInfo then
		if json.decode(_js.state) and json.decode(_js.minInfo) then
			databases.Users[id].state=_js.state databases.Users[id].minI=_js.minInfo
			databases.Users[id].ver.v = req.queries["_v"] databases.Users[id].ver.r = req.queries["_r"]
		else res.body = templates:err("success",tostring(false))
		end
	end
	return res
end