--[[

Ticket (Admin)
Do not modify, copy or distribute without permission of author
Helkarakse 20131220

]]

-- Libraries
os.loadAPI("functions")
os.loadAPI("common")
os.loadAPI("data")

-- References
local common = common
local functions = functions
local data = data
local json = json
local string = string
local switch = functions.switch

-- Variables
local map
local serverId = string.sub(os.getComputerLabel(), 1, 1)

-- Wrappers
-- send message wrapper
local function sendMessage(username, message)
	common.sendMessage(map, username, message)
end

-- Command Handlers
local function issueHandler(username, message, args)
	local check = switch {
		["list"] = function()

		end,
		default = function()
			-- respond that the command is not found
			common.sendMessage(username, data.error.commandNotFound)
		end,
	}

	check:case(args[2])
end

-- Event Handlers
local chatEvent = function()
	while true do
		local _, username, message = os.pullEvent("chat_message")
		-- check if the message is prefixed with a double //
		if (message ~= nil) then
			-- functions.debug("Message received by map peripheral: ", message)
			if (string.sub(message, 1, string.len(data.commandPrefix)) == data.commandPrefix) then
				-- strip the slash off the message and explode for args
				-- replace spaces with + (spaces are not working for some reason)
				local args = functions.explode("+", string.gsub(common.stripPrefix(message), " ", "+"))
				if (args[1] ~= "" and args[1] == "issue") then
					issueHandler(username, message, args)
				end
			end
		end
	end
end

-- Loops
local authLoop = function()
	while true do
		local jsonText = data.getAuthArray()
		local array = json.decode(jsonText)
		if (array.success) then
			
		end
		sleep(60)
	end
end

-- Main
local function main()
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

main()