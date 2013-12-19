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
local string = string
local switch = functions.switch

-- Variables
local map

-- Functions
-- sends a chat message to a player
local function sendMessage(username, message)
	local player = map.getPlayerByName(username)
	player.sendChat(message)
end

-- strips preceding double slash
local function stripSlash(message)
	return string.sub(message, 3)
end

-- Event Handlers
local chatEvent = function()
	while true do
		local _, username, message = os.pullEvent("chat_message")
		-- check if the message is prefixed with a double //
		if (message ~= nil) then
			-- functions.debug("Message received by map peripheral: ", message)
			if (string.sub(message, 1, 2) == "//") then
				-- strip the slash off the message and explode for args
				-- replace spaces with + (spaces are not working for some reason)
				local args = functions.explode("+", string.gsub(stripSlash(message), " ", "+"))
				if (args[1] ~= "" and args[1] == "ticket") then
					local check = switch {
						["new"] = function()
							-- create a new ticket for this user
							sendMessage(username, "New ticket message here.")
						end,
						["desc"] = function()
							-- check if a ticket for this user already exists
							sendMessage(username, "Ticket desc message here.")
						end,
						default = function()
							-- respond that the command is not recognised
							sendMessage(username, "Command not recognised.")
						end,
					}

					check:case(args[2])
				end
			end
		end
	end
end

-- Main
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