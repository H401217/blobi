return function(req)
	local res = {body = "{}", headers = {}}
	if not req.queries["p"] or not req.queries["e"] then
		return res
	else print(req.queries["p"],req.queries["e"])
		for k,v in pairs(databases.Users) do
			if v.email == req.queries["e"] then
				local upass = (req.queries["browser"]=="1") and md5.sumhexa(req.queries["p"] or "") or req.queries["p"]
				print(upass)
				if (upass == v.password) then
				print("correct pass")
					local cookie = ("%X"):format(tonumber(k)) .. "-" .. ("%X"):format(os.time()) .."-".. databases:generatePassword(20,os.time(),true)
					table.insert(databases.Cookies,{token=cookie})
					res.headers["Set-Cookie"]="unn_session=".. cookie ..";path=/"
					print("\27[92mNEW COOKIE: ",cookie.."\27[0m")
					if req.queries["browser"]=="1" then
						res.body = templates:load("pages/loginsuccess.html")
					else
						local JS = {i=tonumber(k),n=v.nickname,t="",hP=not (v.password==nil), nF=0, nL=0, state=v.state,version=tonumber(v.ver.v),revision=tonumber(v.ver.r), success = true}
						
						res.body = json.encode(JS)
					end
				else res.body = "Incorrect Password"
				end
			end
		end
	end
	return res
end
