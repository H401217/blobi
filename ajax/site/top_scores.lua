--TODO
return function(req)
	return {body="{}",headers={}}
    local game = req.queries["g"]
    local period = req.queries["d"]
    if period == "today" or period == "week" or period == "monthly" or period == "alltime" then
        
    end
end