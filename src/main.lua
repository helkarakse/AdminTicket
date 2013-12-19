--[[

AdminTicket Main
Do not modify, copy or distribute without permission of author
Helkarakse 20131216

]]

os.loadAPI("functions")
os.loadAPI("data")
os.loadAPI("json")

-- References
local functions = functions
local data = data
local json = json

-- Variables
local map

-- Event Handlers
local chatEvent = function()
	while true do
		local _, username, message = os.pullEvent("chat_message")
		-- check if the message is prefixed with a double //
		if (string.sub(message, 1, 2) == "//") then
			print("true");
		end
	end
end

-- Functions
local function init()
	local hasMap, mapDir = functions.locatePeripheral("adventure map interface")
	if (hasMap) then
		map = peripheral.wrap(mapDir)
		functions.debug("Map peripheral detected and wrapped.")
	else
		functions.debug("No map peripheral detected. This is required.")
		return
	end

	parallel.waitForAll(chatEvent)
end

init()