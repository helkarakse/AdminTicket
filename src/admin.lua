--[[

Ticket (Admin)
Do not modify, copy or distribute without permission of author
Helkarakse 20131220

]]

-- Libraries
os.loadAPI("functions")
os.loadAPI("common")
os.loadAPI("data")
os.loadAPI("json")

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

local authArray = {}

-- Wrappers
-- send message wrapper
local function sendMessage(username, message)
	common.sendMessage(map, username, message)
end

-- Functions
-- Checks the local auth array for the username and returns the auth level
local function getAuthLevel(username)
	for i = 1, functions.getTableCount(authArray) do
		if (authArray[i].name == username) then
			return authArray[i].auth_level
		end
	end
	functions.info("Auth level not found for this username:", username)
	return 0
end

-- Command Handlers
local function issueHandler(username, message, args)
	local check = switch {
		["list"] = function()
			local jsonText = data.getIssues(getAuthLevel(username))
			local array = json.decode(jsonText)
			if (array.success) then
				sendMessage(username, "Listing available issues:")
				for i = 1, functions.getTableCount(array.result) do
					sendMessage(username, "[" ..array.result[i].id .. "]: " .. array.result[i].creator .. " [" .. array.result[i].create_date .. "]")
				end
			else
				sendMessage(username, data.error.apiFailed)
			end
		end,
		default = function()
			-- respond that the command is not found
			sendMessage(username, data.error.commandNotFound)
		end,
	}

	check:case(args[2])
end

-- Event Handlers
local chatEvent = function()
	while true do
		local _, username, message = os.pullEvent("chat_message")
		-- check if the message is prefixed with a double // and that the user has the right auth level
		if (message ~= nil) then
			functions.debug("Authentication level of", username, "is", getAuthLevel(username))
			if (string.sub(message, 1, string.len(data.commandPrefix)) == data.commandPrefix and getAuthLevel(username) > 0) then
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
		functions.info("Loading authentication package from server.")
		local jsonText = data.getAuthArray()
		local array = json.decode(jsonText)
		if (array.success) then
			authArray = array.result
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

	parallel.waitForAll(chatEvent, authLoop)
end

