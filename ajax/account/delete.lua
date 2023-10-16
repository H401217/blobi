return function(req)
	local id = http:decodePou(req)
	local cookie = http:decodeCookie(req.headers["cookie"] or "")["unn_session"] or ""
	local c = req.queries["c"]
	if c == md5.sumhexa("p@v_"..cookie) then
		databases.Users[id] = nil
		return {body=templates:err("success",tostring(true)),headers={["Set-Cookie"]="unn_session=null;path=/"}}
	else
		return {body=templates:err("success",tostring(false)),headers={}}
	end
end