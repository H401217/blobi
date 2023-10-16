return function(req)
	math.randomseed(math.floor(os.clock()+os.time()))
	local res = {}
	local id = http:decodePou(req)
	local keys = {}
	for k,v in pairs(databases.Users) do
		if k~=id then
			table.insert(keys,k)
		end
	end
	if #keys > 0 then
		local rng = keys[math.random(1,#keys)]
		local obj = databases.Users[rng]
		res.version = tonumber(obj.ver.v)
		res.revision = tonumber(obj.ver.r)
		res.state = obj.state
		res.i = tonumber(rng)
		res.n = obj.nickname
		res.nF = "0"
		res.nL = "0"
		res.iL = 0
		res.iM = 0
		res.ok = true
	else
		res = {error={type="ObjectNotFound"}}
	end
	return {body=json.encode(res),headers={}}
end