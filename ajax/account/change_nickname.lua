return function(req)
	local err = false
	local id = http:decodePou(req)
	if not req.queries["n"] then err = true goto done end
	for k,v in pairs(databases.Users) do
		if v.nickname == req.queries["n"] and k~=id then
			err = true
			goto done
		end
	end
	::done::
	if err then
		return {body=templates:err("success",tostring(false)),headers={}}
	else
		databases.Users[id].nickname = req.queries["n"]
		return {body=templates:err("success",tostring(true)),headers={}}
	end
end