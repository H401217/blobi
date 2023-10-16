return function(req)
--[[
	req
		ip
		port
		queries
		version
		method
		path
		headers
		body
	]]
	local usercookie = http:decodeCookie(req.headers["cookie"] or "")["unn_session"] or ""
	local hash = md5.sumhexa("p@v_"..req.body..usercookie)
	
	local bod = {success=false}
	
	if req.queries["c"]==hash then
		local _s,js = json.decode(req.body)
		if _s then
			for k,v in pairs(js.scores) do
				--v --.gI,s
				
			end
		end
	end
	return {body=json.encode(bod),headers={}}
end