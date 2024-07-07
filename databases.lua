local databases = {}

databases.folder = filesystem.currentdir() .."/database/"
databases.captcha = {}
function databases:generatePassword(len,seed,hashit)
	local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890"
	local pass = ""
	math.randomseed(seed)
	math.randomseed(math.floor(math.random(0,30)+len+(os.clock()*124)))

	for i= 1,len do
		local r1 = math.random(1,#chars)
		pass = pass..string.sub(chars,r1,r1)
	end
	return hashit and md5.sumhexa(pass) or pass
end

function databases:newCookie(ID,Time)
	return ("%X"):format(tonumber(ID)) .. "-" .. ("%X"):format(Time or os.time()) .."-".. self:generatePassword(20,os.time(),true)
end

function databases:load()
	local f1 = io.open(self.folder .."Users.json","r")
	databases.Users = json.decode(f1:read("*all"))
	f1:close()
	local f2 = io.open(self.folder .."Cookies.json","r")
	databases.Cookies = json.decode(f2:read("*all"))
	f2:close()
	local f3 = io.open(self.folder .."Games.json","r")
	databases.Games = json.decode(f3:read("*all"))
	f3:close()
	local f4 = io.open(self.folder .."Leaderboard.json","r")
	databases.Leaderboard = json.decode(f4:read("*all"))
	f4:close()
	local f5 = io.open(self.folder .."Notifications.json","r")
	databases.Notifications = json.decode(f5:read("*all"))
	f5:close()
end

function databases:save()
	local f1 = io.open(self.folder .."Users.json","w")
	f1:write(json.encode(databases.Users))
	f1:close()
	local f2 = io.open(self.folder .."Cookies.json","w")
	f2:write(json.encode(databases.Cookies))
	f2:close()
	local f3 = io.open(self.folder .."Games.json","w")
	f3:write(json.encode(databases.Games))
	f3:close()
	local f4 = io.open(self.folder .."Leaderboard.json","w")
	f4:write(json.encode(databases.Leaderboard))
	f4:close()
	local f5 = io.open(self.folder .."Notifications.json","w")
	f5:write(json.encode(databases.Notifications))
	f5:close()
end

function databases:newNotification(val,typ,expires) --val = value, typ = type (33 for coins), expires = unix for notification expire
	local id = ""
	repeat
		id = tostring(math.random(1,9999999))
	until not (databases.Notifications[id])
	databases.Notifications[id]={t=(typ or 33), a=val, oT=0, oI=0, u2I=0, o2T=0, expire=(expires or -1)}
end

return databases
