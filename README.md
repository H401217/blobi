# blobi
This is a recreation of "Pou" servers (app.pou.me) made with luarocks and LÖVE2D.

# Disclaimer
1. **This server is not designed for high traffic or large amounts of data**
2. **This server recreation is not meant to replace "Pou" servers, neither to make any profit**
3. **This server controller uses local ports, and it can cause a security risk on this server (e.g. external apps controlling server)**

# Requirements
Lua 5.4 (this uses `goto` keyword)
## Libraries
* MD5
* luasocket
* lua-cjson
* luafilesystem

# Installing (or setting up)
1. Download the repository and put the files in a separate folder.
2. Download and install [LÖVE2D](https://love2d.org/)
3. Download and install Lua and Luarocks
    * Include Lua and Luarocks folders in PATH (environment variable)
        * In `luasocket` installing you need a mingw compiler and also include in PATH.
4. Install the required libraries above.
5. Go to the repository folder (via explorer or cmd). And run `lua main.lua`.