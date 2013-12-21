--[[

MacroStartup Version 1.1
Do not modify, copy or distribute without permission of author
Helkarakse, 20130614
]]--

-- File array of Github links
local fileArray = {
	{link = "https://raw.github.com/helkarakse/LuaLibs/master/src/common/functions.lua", file = "functions"},
	-- {link = "https://raw.github.com/helkarakse/LuaLibs/master/src/libs/libJson.lua", file = "json"},
	{link = "https://raw.github.com/helkarakse/AdminTicket/develop/src/json.lua", file = "json"},
	{link = "https://raw.github.com/helkarakse/AdminTicket/develop/src/data.lua", file = "data"},
	{link = "https://raw.github.com/helkarakse/AdminTicket/develop/src/common.lua", file = "common"},
	{link = "https://raw.github.com/helkarakse/AdminTicket/develop/src/admin.lua", file = "admin"},
}

-- This filename is the file that will be executed
local indexFile = "admin"

-- Set to true to overwrite files
local overwrite = true

-- Helper function to pull latest file from server
local function getProgram(link, filename)
	print("Downloading '" .. filename .. "' file from server.")

	-- remove the file if override is true
	if (overwrite == true) then
		shell.run("rm " .. filename)
	end

	-- get the latest copy
	local data = http.get(link)
	if data then
		print("File '" .. filename .. "' download complete.")
		local file = fs.open(filename,"w")
		file.write(data.readAll())
		file.close()
	end
end

-- download and start program
for i = 1, #fileArray do
	getProgram(fileArray[i].link, fileArray[i].file)
end

shell.run(indexFile)