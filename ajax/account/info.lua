return function(req)
	local id = http:decodePou(req)
	local obj = databases.Users[id]
	local res = {ok=false}
	if obj then
		res.ok = true
		res.i = id
		res.e = obj.email
		res.hP = (obj.password==md5.sumhexa("") or obj.password=="") and (false) or (true)
		res.n = obj.nickname
		res.t = ""
		res.l = ""
		res.nF = ""
		res.nL = ""
	end
	
	return {body=json.encode(res),headers={}}
end