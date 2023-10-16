return function(req)
print("ea")
	local res = {body=templates:err("success","true"),headers={["Set-Cookie"]="unn_session=null;path=/"}}
	print(res.body)
	return res
end