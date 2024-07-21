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
	local userId = http:decodePou(req)
	local bod = {success=false}
	
	if req.queries["c"]==hash then
		local js = json.decode(req.body)
		if js then
			for k,v in pairs(js.scores) do
				local gId = tostring(v.gI)
				local score = v.s
				if tonumber(gId) >= 1 and tonumber(gId) <= 32 then
					databases.Leaderboard[gId] = (databases.Leaderboard[gId] or {})
					for datecounttype = 1,4 do
						local aeiou = {"today","week","month","alltime"}
						datatype = aeiou[datecounttype]
						print(databases.Leaderboard[gId],datatype,(databases.Leaderboard[gId][datatype]) or {})
						databases.Leaderboard[gId][datatype] = (databases.Leaderboard[gId][datatype]) or {} --checks if leaderboard is empty
						local index = 1
						local maxscore = 0
						local existingindex
						for _,i in pairs(databases.Leaderboard[gId][datatype]) do --check correct index and existing index
							if i.s then --note for the future editor: pls change this if to a system that removes empty score registers appropiately without skipping top number
								if i.s > score then
									index = _+1
								end
								if tostring(i.i) == tostring(userId) then
									maxscore = i.s
									existingindex = tostring(_)
								end
							end
						end
						if score > maxscore then --if score is less than current leaderboard then no
							if existingindex then -- check if it's already in top, and removes score
								databases.Leaderboard[gId][datatype][tostring(existingindex)]={}
							end
							if index ~= existingindex then --this orders the leaderboard, but if true then not necessary
								if existingindex then
									for count = existingindex+1,table.count(databases.Leaderboard[gId][datatype]),1 do --moves data towards existingindex (from less to top), rewriting it
										databases.Leaderboard[gId][datatype][tostring(count-1)]=databases.Leaderboard[gId][datatype][tostring(count)]
									end
									databases.Leaderboard[gId][datatype][tostring(table.count(databases.Leaderboard[gId][datatype]))] = nil --solution test
								end
								for count = table.count(databases.Leaderboard[gId][datatype]),index,-1 do --makes space for new data
									databases.Leaderboard[gId][datatype][tostring(count+1)]=databases.Leaderboard[gId][datatype][tostring(count)]
								end
								if table.count(databases.Leaderboard[gId][datatype]) == 0 then
									databases.Leaderboard[gId][datatype]["1"] = {}
								end
							end
							databases.Leaderboard[gId][datatype][tostring(index)] = {s = score, i = userId, timestamp = os.time()} --rewrites
							bod.success = true
						end
					end
				end
			end
		end
	end
	print(json.encode(databases.Leaderboard)) --debug
	return {body=json.encode(bod),headers={}}
end