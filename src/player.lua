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

-- Functions
-- strips preceding double slash
local function stripSlash(message)
	return string.sub(message, string.len(data.commandPrefix) + 1)
end

-- returns the user's position as a string
local function getUserPosition(username)
	local player = map.getPlayerByName(username)
	local entity = player.asEntity()
	local xPos, yPos, zPos = entity.getPosition()
	return xPos .. "," .. yPos .. "," .. zPos .. ":" .. entity.getWorldID()
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
				return "No description set yet."
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
	if (getTicketDescription(username) == nil or getTicketDescription(username) == "") then
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
		if (data.addTicket(ticket.creator, ticket.description, ticket.position)) then
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
			-- check if the user already has a ticket open
			if (hasTicket(username)) then
				common.sendMessage(username, data.lang.oneTicket)
			else
				-- create a new ticket for this user
				common.sendMessage(username, "New ticket created. Use //ticket desc <description> to set a description for this ticket.")
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
			-- check if a ticket for this user already exists
			if (hasTicket(username)) then
				-- update the ticket with the description
				if (args[3] ~= nil and args[3] ~= "") then
					-- extract the description from the message
					local description = string.sub(stripSlash(message), string.len("ticket") + 6)
					setTicketDescription(username, description)
					common.sendMessage(username, "Your ticket has been updated. Use //ticket submit to submit your ticket.")
					functions.info("Ticket description for", username,"set to", description)
				else
					common.sendMessage(username, "Please type a description to set.")
				end
			else
				common.sendMessage(username, data.lang.noTicket)
			end
		end,
		["show"] = function()
			if (hasTicket(username)) then
				-- display the user's ticket description
				local description = getTicketDescription(username)
				common.sendMessage(username, "Current active ticket: " .. description)
			else
				common.sendMessage(username, data.lang.noTicket)
			end
		end,
		["submit"] = function()
			-- check if a ticket for this user already exists
			if (hasTicket(username)) then
				-- check if the ticket is valid
				if (isValidTicket(username)) then
					-- deliver the ticket to the server
					if (doSubmitTicket(username)) then
						common.sendMessage(username, data.lang.submitSuccess)
						functions.info("Ticket submitted for", username)
					else
						common.sendMessage(username, data.error.submitFailed)
						functions.error("Failed to submit ticket for", username)
					end
				else
					common.sendMessage(username, data.lang.noDesc)
				end
			else
				common.sendMessage(username, data.lang.noTicket)
			end
		end,
		["cancel"] = function()
			if (hasTicket(username)) then
				removeTicket(username)
				common.sendMessage(username, "The ticket that is currently being created has been cancelled.")
				functions.info("Ticket cancelled by user", username)
			end
		end,
		["help"] = function()
			common.sendMessage(username, "Ticket help should go here.")
		end,
		default = function()
			-- respond that the command is not recognised
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
				local args = functions.explode("+", string.gsub(stripSlash(message), " ", "+"))
				if (args[1] ~= "" and args[1] == "ticket") then
					ticketHandler(username, message, args)
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