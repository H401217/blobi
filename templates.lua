local templates = {}

templates.path = filesystem.currentdir().."/"

function templates:load(filename,bin)
	local f = io.open(self.path .. filename, "r".. ((bin) and "b" or "") )
	if not f then return end
	local content = f:read("*all")
	local size = f:seek("end")
	if not bin then size = #content end
	f:close()
	local s1 = mysplit(filename,"/")
	local s2 = mysplit(s1[#s1],"\\")
	return content,size,s2[#s2]
end

function templates:redirect(path)
	return '<html><head><meta http-equiv="refresh" content="0; url='..path..'" /></head></html>'
end

function templates:mainPath(path)
	print(path)
	path = (path=="/") and "/index" or path
	print(path,"aaaa")
	return templates:load("pages"..path..".html")
end

function templates:err(...)
	local arg = {...}
	local str = templates.errors[arg[1]]
	if #arg > 1 then
		table.remove(arg,1)
		str = string.format(str,table.unpack(arg))
	end
	return str or '{"success":false}'
end

templates.errors={
	notlogged='{"error":{"type":"UserNotLoggedIn","message":"You need to login to continue."}}',
	update='{"error":{"type":"ClientOutdated","message":"Your client is too old. Please update.","diffClient":%s}}', --true if update needs to wait
	success='{"success":%s}',
	sitemaintenance='{"error":{"type":"FeatureMaintenance"}}',
	siteoffline='{"error":{"type":"SiteOffline"}}'
}

return templates
