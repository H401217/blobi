return function(req)
	local res = {body = templates:err("success",false), headers = {}}
	local UserID = http:decodePou(req)
	local ID = req.queries["id"]
	local notif = databases.Notifications[tostring(ID)]

	if notif then
		if (notif.expire==-1 or os.time()<=notif.expire) then
			return res
		end
		local usernotifs = databases.Users[UserID].notifications
		if not usernotifs then
			usernotifs = databases.Users[UserID].notifications = {}
		end
		table.insert(usernotifs,tostring("ID"))
		res.body = templates:err("success",true)
	end
	
	return res
end