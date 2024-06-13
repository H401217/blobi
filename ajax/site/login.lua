return function(req)
	local res = {body = "{}", headers = {}}
	if not req.queries["p"] or not req.queries["e"] then
		return res
	end --print(req.queries["p"],req.queries["e"])

	local app = (req.queries["_a"]=="1") --Is in Pou app?
	for id,v in pairs(databases.Users) do
		if v.email == req.queries["e"] then
			local upass = (not app) and (md5.sumhexa(req.queries["p"] or "")) or (req.queries["p"])
			if (upass == v.password) then
				local cookie = databases:newCookie(id)
				table.insert(databases.Cookies,{token = cookie})
				res.headers["Set-Cookie"]="unn_session=".. cookie ..";path=/"
				--print("\27[92mNEW COOKIE: ",cookie.."\27[0m")

				if not app then
					res.body = templates:redirect("/assets/pages/loginsuccess.html")
				else
					local JS = {
						i=tonumber(id),
						n=v.nickname,
						t="",
						hP=not (v.password==nil),
						nF=0, --Followers and Likes are disabled by the moment (TODO)
						nL=0,
						state=v.state,
						version=tonumber(v.ver.v),
						revision=tonumber(v.ver.r),
						success = true
					}
					
					res.body = json.encode(JS)
				end
			else res.body = "Incorrect Password"
			end
		end
	end
	return res
end
