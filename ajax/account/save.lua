return function(req)
	local res = {body="{}",headers={}}
	local cookie = http:decodeCookie(req.headers["cookie"] or "")["unn_session"] or ""

	local succeed = true

	if not (req.queries["c"]==md5.sumhexa("p@v_"..(req.body or "") ..cookie)) then
		succeed = false
		goto done
		return res
	end
	local _js = json.decode(req.body)
	
	local id = tostring(http:decodePou(req))
	
	if _js.state and _js.minInfo then
		if json.decode(_js.state) and json.decode(_js.minInfo) then
			databases.Users[id].state=_js.state databases.Users[id].minI=_js.minInfo; databases.Users[id].notifications = (databases.Users[id].notifications) or {}
			databases.Users[id].ver.v = req.queries["_v"] databases.Users[id].ver.r = req.queries["_r"]
		else succeed = false
		end
	end
	::done::
	res.body = json.encode{
		success = succeed,
		unclaimedNotifications = databases:unclaimedNotifications(id)
	}
	return res
end