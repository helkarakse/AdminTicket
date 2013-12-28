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
			return authArray[i].level
		end
	end
	functions.info("Auth level not found for this username:", username)
	return 0
end

local function roundNum(number)
	local returnString = ""
	local startPos, endPos = string.find(tostring(number), ".")
	if (startPos ~= nil and endPos ~= nil) then
		returnString = string.sub(tostring(number), startPos, endPos - 1)
	else
		returnString = tostring(number)
	end
	return returnString
end

-- Command Handlers
-- Issue handler
local function issueHandler(username, message, args)
	local check = switch {
		["list"] = function()
			local jsonText = ""
			local status = args[3]
			if (status ~= nil and status ~= "") then
				-- make sure that status is not nil and not empty
				if (status == "new" or status == "progress" or status == "complete" or status == "cancel") then
					-- check to see that status is of a type that will return data
					functions.debug("Retrieving issues by type.")
					jsonText = data.getIssuesByType(getAuthLevel(username), status)
				else
					sendMessage(username, "Invalid usage: status must be 'new', 'progress', 'complete' or 'cancel'")
				end
			else
				-- no status so retrieve it all
				functions.debug("Retrieving all issues.")
				jsonText = data.getIssues(getAuthLevel(username))
			end

			local array = json.decode(jsonText)
			if (array.success and functions.getTableCount(array.result) > 0) then
				sendMessage(username, "Listing available issues:")
				for i = 1, functions.getTableCount(array.result) do
					-- sample - #1: name - 5 hours ago
					sendMessage(username, "#" ..array.result[i].id .. ": " .. array.result[i].creator .. " - " .. array.result[i].time_ago)
				end
			else
				sendMessage(username, data.error.noResults)
			end
		end,
		["show"] = function()
			-- display details about a ticket
			local id = args[3]
			if (id ~= nil and id ~= "") then
				-- make sure id is not nil and not empty
				local jsonText = data.getIssueDetails(getAuthLevel(username), args[3])
				local array = json.decode(jsonText)
				if (array.success and functions.getTableCount(array.result) > 0) then
					sendMessage(username, "Displaying details for issue: #" .. args[3])
					local row = array.result[1]
					local xPos, yPos, zPos, dimId, serverId = string.match(row.position, "(.*)\,(.*)\,(.*)\:(.*)\:(.*)")
					sendMessage(username, "#" .. row.id .. " @ " .. functions.roundTo(xPos) .. ", " .. functions.roundTo(yPos) .. ", " .. functions.roundTo(zPos)
						.. " - " .. common.getDimension(dimId) .. "(" .. dimId .. ") - RR" .. serverId)
					sendMessage(username, "Created by: " .. row.creator .. " - " .. row.time_ago)
					sendMessage(username, "Description: " .. row.description)
					sendMessage(username, "Status: " .. row.status)

					-- display assigned to if status is progress
					if (row.status == "progress") then
						sendMessage(username, "Assigned to: " .. row.assigned)
					end
				else
					sendMessage(username, data.error.noResults)
				end
			else
				sendMessage(username, data.error.missingArgs)
			end
		end,
		["help"] = function()
			local helpArray = {
				data.commandPrefix .. "issue list - Lists all the currently available issues.",
				data.commandPrefix .. "issue list <type> - Lists all the tickets of type: new, progress, closed, cancelled",
				data.commandPrefix .. "issue show <id> - Displays detailed information of a ticket. Use the id from " .. data.commandPrefix .. "issue list"
			}

			sendMessage(username, "Displaying help for issue")
			for i = 1, #helpArray do
				sendMessage(username, helpArray[i])
			end
		end,
		["reboot"] = function()
			if (getAuthLevel(username) == 3) then
				sendMessage(username, data.lang.reboot)
				os.reboot()
			else
				sendMessage(username, data.error.needAuth)
			end
		end,
		default = function()
			-- respond that the command is not found
			sendMessage(username, data.error.commandNotFound)
		end,
	}

	check:case(args[2])
end

-- Authentication handler
local function authHandler(username, message, args)
	local check = switch {
		["list"] = function()
			functions.info("Listing authentication from server.")
			local jsonText = data.getAuthArray()
			local array = json.decode(jsonText)
			if (array.success and functions.getTableCount(array.result) > 0) then
				for i = 1, functions.getTableCount(array.result) do
					sendMessage(username, "#" .. array.result[i].rowid .. " - " .. array.result[i].name .. " [" .. array.result[i].rank .. " (" .. array.result[i].level .. ")]")
				end
			end
		end,
		["add"] = function()
			local name, level = args[3], args[4]
			if ((name ~= nil and name ~= "") and (level ~= nil and level ~= "")) then
				local jsonText = data.addAuth(name, level)
				local array = json.decode(jsonText)
				if (array.success) then
					sendMessage(username, "New user added to authentication table. Use //auth reload to reload the package.")
				else
					sendMessage(username, data.error.apiFailed)
				end
			end
		end,
		["set"] = function()
			local name, level = args[3], args[4]
			if ((name ~= nil and name ~= "") and (level ~= nil and level ~= "")) then
				local jsonText = data.setAuth(name, level)
				local array = json.decode(jsonText)
				if (array.success) then
					sendMessage(username, "User level updated. Use //auth reload to reload the package.")
				else
					sendMessage(username, data.error.apiFailed)
				end
			end
		end,
		["del"] = function()
			local name = args[3]
			if (name ~= nil and name ~= "") then
				local jsonText = data.delAuth(name)
				local array = json.decode(jsonText)
				if (array.success) then
					sendMessage(username, "User deleted. Use //auth reload to reload the package.")
				else
					sendMessage(username, data.error.apiFailed)
				end
			end
		end,
		["reload"] = function()
			functions.info("Loading authentication package from server.")
			local jsonText = data.getAuthArray()
			local array = json.decode(jsonText)
			if (array.success) then
				authArray = array.result
			end
		end,
		["help"] = function()
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
			if (string.sub(message, 1, string.len(data.commandPrefix)) == data.commandPrefix) then
				-- strip the slash off the message and explode for args
				-- replace spaces with + (spaces are not working for some reason)
				local args = functions.explode("+", string.gsub(common.stripPrefix(message), " ", "+"))
				if (args[1] ~= "" and args[1] == "issue") then
					if (getAuthLevel(username) >= 1) then
						issueHandler(username, message, args)
					else
						sendMessage(username, data.error.invalidAuthLevel)
					end
				elseif (args[1] ~= "" and args[1] == "auth") then
					if (getAuthLevel(username) >= 2) then
						authHandler(username, message, args)
					else
						sendMessage(username, data.error.invalidAuthLevel)
					end
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
		sleep(300)
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

main()
