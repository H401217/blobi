return function(req)
	print("saving xdd")
    local f1 = io.open(filesystem.currentdir().."/pouthumbs/"..os.time()..".png","wb")
	f1:write(UTIL.b64.decode(req.body))
	f1:close()
	return {body='{"success":true,"url":""}',headers={}}
end