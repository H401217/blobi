local socket = require("socket")
local client = socket.tcp()
--client:connect("127.0.0.1",3000) --replace with ip and port of server

--client:send("POST /ajax/site/login?_r=256&_v=4&_a=1&_c=1&e=a%40a.com&p=wasd HTTP/1.0\r\nContent-Length:10\r\n")
for c = 0,10 do
    local client = socket.tcp()
    client:connect("127.0.0.1",3000)
    client:send("POST /ajax/account/scores?_r=256&_v=4&_a=1&_c=1 HTTP/1.0\r\nContent-Length:32\r\n")
    client:settimeout(5)
    local s = c*1000
    client:send('\r\n{"scores":[{"gI":10,"s":'..s..'}]}\r\n')
    print(client:receive())
    client:close()
end