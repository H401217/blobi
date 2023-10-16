return function(req)
	local id = http:decodePou(req)
	local p = req.queries["p"]
	local res = '{"ok":"%s"}'
	if databases.Users[id].password==p then
		return {body=res:format(true),headers={}}
	else
		return {body=res:format(false),headers={}}
	end
end