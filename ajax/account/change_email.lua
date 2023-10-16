return function(req)
	local err = false
	local id = http:decodePou(req)
	if not req.queries["e"] then err = true goto done end
	for k,v in pairs(databases.Users) do
		if v.email == req.queries["e"] and k~=id then
			err = true
			goto done
		end
	end
	::done::
	if err then
		return {body=templates:err("success",tostring(false)),headers={}}
	else
		databases.Users[id].email = req.queries["e"]
		return {body=templates:err("success",tostring(true)),headers={}}
	end
end