return function(req)
	local err = true
	local id = http:decodePou(req)
	local old,new = req.queries["o"],req.queries["n"]
	
	if not (old and new) then
		goto done
	end
	
	if databases.Users[id].password == old then
		err = false
		goto done
	end
	
	::done::
	if err then
		return {body=templates:err("success",tostring(false)),headers={}}
	else
		databases.Users[id].password = new
		return {body=templates:err("success",tostring(true)),headers={}}
	end
end