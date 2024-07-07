local settings = {}

settings.ip = "127.0.0.1"		--The IP address for the server
settings.port = 3000				--The server port
settings.maxUsers = 5				--Maximum amount of clients that can connect
settings.speed = 2048               --bytes that server can receive every loop

settings.minVer = 1 --256			--Minimum client version

settings.CAPTCHA_T = 20				--CAPTCHA timeout in seconds
settings.CAPTCHA_L = 5				--CAPTCHA length

--LÖVE2D server controller settings
--Warning: It is recommended to use the controller because it allows the server to create CAPTCHAs and save manually the data.

settings.LOVE = ""					--LÖVE2D executable (if empty, open via PATH variable)
settings.LOVEauto = true			--Open LÖVE2D server controller upon server initiation

return settings