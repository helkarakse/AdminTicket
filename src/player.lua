--[[

Ticket (Player)
Do not modify, copy or distribute without permission of author
Helkarakse 20131219

]]

-- Libraries
os.loadAPI("functions")
os.loadAPI("data")
os.loadAPI("common")
os.loadAPI("json")

-- References
local functions = functions
local common = common
local data = data
local json = json
local string = string
local switch = functions.switch

-- Variables
local map
local ticketArray = {}
local serverId = string.sub(os.getComputerLabel(), 1, 1)

-- Wrappers
-- send message wrapper
local function sendMessage(username, message)
	common.sendMessage(map, username, message)
end

-- Functions
-- returns the user's position as a string
local function getUserPosition(username)
	local player = map.getPlayerByName(username)
	local entity = player.asEntity()
	local xPos, yPos, zPos = entity.getPosition()
	return xPos .. "," .. yPos .. "," .. zPos .. ":" .. entity.getWorldID() .. ":" .. serverId
end

-- checks if the user has a ticket that is being created
local function hasTicket(username)
	for key, value in pairs(ticketArray) do
		if (value.creator == username) then
			return true
		end
	end

	return false
end

-- returns the description of the user's currently active ticket
local function getTicketDescription(username)
	for key, value in pairs(ticketArray) do
		if (value.creator == username) then
			if (value.description ~= "") then
				return value.description
			else
				return ""
			end
		end
	end

	return data.lang.noTicket
end

-- sets the description of the user's currently active ticket
local function setTicketDescription(username, description)
	for key, value in pairs(ticketArray) do
		if (value.creator == username) then
			value.description = description
		end
	end

	return data.lang.noTicket
end

-- checks if the ticket is valid (ie has a description)
local function isValidTicket(username)
	local ticketDesc = getTicketDescription(username)
	if (ticketDesc == nil or ticketDesc == "") then
		return false
	else
		return true
	end
end

-- returns the ticket row from the ticket array for username, nil if failed
local function getTicket(username)
	for key, value in pairs(ticketArray) do
		if (value.creator == username) then
			return ticketArray[key]
		end
	end

	return nil
end

-- deletes a ticket from the array
local function removeTicket(username)
	local userKey
	for key, value in pairs(ticketArray) do
		if (value.creator == username) then
			userKey = key
		end
	end

	if (userKey ~= nil and userKey > 0) then
		table.remove(ticketArray, userKey)
	end
end

-- attempt to submit the ticket, return true if successful
local function doSubmitTicket(username)
	local ticket = getTicket(username)
	if (ticket ~= nil) then
		-- send the ticket
		local jsonText = data.addTicket(ticket.creator, ticket.description, ticket.position)
		local array = json.decode(jsonText)
		if (array.success) then
			-- delete the ticket from the ticket array
			removeTicket(username)
			return true
		else
			return false
		end
	else
		return false
	end
end

-- Command Handlers
local function ticketHandler(username, message, args)
	local check = switch {
		["new"] = function()
			-- creates a new ticket for editing and submission
			-- check if the user already has a ticket open
			if (hasTicket(username)) then
				sendMessage(username, data.lang.oneTicket)
			else
				-- create a new ticket for this user
				sendMessage(username, "New ticket created. Use //ticket desc <description> to set a description for this ticket.")
				-- add the user to the ticket table
				local ticket = {}
				ticket.creator = username
				ticket.description = ""
				ticket.position = getUserPosition(username)

				table.insert(ticketArray, ticket)
				functions.info("New ticket created for", username)
			end
		end,
		["desc"] = function()
			-- adds a description to the ticket
			-- check if a ticket for this user already exists
			if (hasTicket(username)) then
				-- update the ticket with the description
				if (args[3] ~= nil and args[3] ~= "") then
					-- extract the description from the message
					local description = string.sub(common.stripPrefix(message), string.len("ticket") + 6)
					setTicketDescription(username, description)
					sendMessage(username, "Your ticket has been updated. Use //ticket submit to submit your ticket.")
					functions.info("Ticket description for", username,"set to", description)
				else
					sendMessage(username, "Please type a description to set.")
				end
			else
				sendMessage(username, data.lang.noTicket)
			end
		end,
		["show"] = function()
			-- show the ticket that is currently being created
			if (hasTicket(username)) then
				-- display the user's ticket description
				local description = getTicketDescription(username)
				sendMessage(username, "Current active ticket: " .. description)
			else
				sendMessage(username, data.lang.noTicket)
			end
		end,
		["submit"] = function()
			-- submit the ticket to the server
			-- check if a ticket for this user already exists
			if (hasTicket(username)) then
				-- check if the ticket is valid
				if (isValidTicket(username)) then
					-- deliver the ticket to the server
					if (doSubmitTicket(username)) then
						sendMessage(username, data.lang.submitSuccess)
						functions.info("Ticket submitted for", username)
					else
						sendMessage(username, data.error.submitFailed)
						functions.error("Failed to submit ticket for", username)
					end
				else
					sendMessage(username, data.lang.noDesc)
				end
			else
				sendMessage(username, data.lang.noTicket)
			end
		end,
		["cancel"] = function()
			-- cancels the currently active ticket
			if (hasTicket(username)) then
				removeTicket(username)
				sendMessage(username, "The ticket that is currently being created has been cancelled.")
				functions.info("Ticket cancelled by user", username)
			end
		end,
		["list"] = function()
			-- lists the tickets currently started by the user and are not completed
			local jsonText = data.getMyTickets(username)
			local array = json.decode(jsonText)
			if (array.success) then
				if (functions.getTableCount(array.result) > 0) then
					sendMessage(username, data.lang.myTickets)
					for i = 1, functions.getTableCount(array.result) do
						sendMessage(username, "["..i.."]: " .. array.result[i].description .. " [" .. string.upper(array.result[i].status) .. "]")
					end
				else
					sendMessage(username, data.lang.noTicketsFound)
				end
			else
				sendMessage(username, data.error.apiFailed)
			end
		end,
		["help"] = function()
			-- ticket based help
			sendMessage(username, "Ticket help should go here.")
		end,
		default = function()
			-- respond that the command is not recognized
			sendMessage(username, data.error.commandNotFound)
		end,
	}

	check:case(args[2])
end

-- Event Handlers
-- Chat handler
local chatEvent = function()
	while true do
		local _, username, message = os.pullEvent("chat_message")
		-- check if the message is prefixed with a double //
		if (message ~= nil) then
			-- functions.debug("Message received by map peripheral: ", message)
			if (string.sub(message, 1, string.len(data.commandPrefix)) == data.commandPrefix) then
				-- strip the slash off the message and explode for arguments
				-- replace spaces with + (spaces are not working for some reason)
				local args = functions.explode("+", string.gsub(common.stripPrefix(message), " ", "+"))
				if (args[1] ~= "" and args[1] == "ticket") then
					ticketHandler(username, message, args)
				end
			end
		end
	end
end

-- Login handler
local loginEvent = function()
	while true do
		local _, username = os.pullEvent("player_login")
		-- notify the user about tickets that are not currently completed
		functions.debug(username,"logged in.")
		local jsonText = data.countMyTickets(username)
		local array = json.decode(jsonText)
		if (array.success and functions.getTableCount(array.result) > 0) then
			-- only notify the user if there is some result to begin with
			local countNew, countOpen, countTotal = 0, 0, 0
			for i = 1, functions.getTableCount(array.result) do
				if (array.result[i].status == "new") then
					countNew = countNew + array.result[i].count
				elseif(array.result[i].status == "open") then
					countOpen = countOpen + array.result[i].count
				end
			end

			countTotal = countNew + countOpen

			-- notify user after a second's pause to let messages filter to the end
			sleep(1)
			sendMessage(username, data.lang.loginMessage)
			sendMessage(username, "You have ["..countTotal.."] tickets total. ["..countNew.."] are new, and ["..countOpen.."] are currently being processed.")
		end
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

	parallel.waitForAll(chatEvent, loginEvent)
end

main()