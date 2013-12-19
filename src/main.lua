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
local ticketArray = {}

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

-- returns the user's position, x, y, z
local function getUserPosition(username)
	local player = map.getPlayerByName(username)
	local entity = player.asEntity()
	return entity.getPosition()
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
							end
						end,
						["desc"] = function()
							-- check if a ticket for this user already exists
							if (hasTicket(username)) then
								-- update the ticket with the description
								if (args[3] ~= nil and args[3] ~= "") then
									local description = string.sub(stripSlash(message), string.len("ticket desc "))
									setTicketDescription(username, description)
									sendMessage(username, "Your ticket has been updated. Use //ticket submit to submit your ticket.")
								else
									sendMessage(username, "Please type a description to set.")
								end
							else
								sendMessage(username, data.lang.noTicket)
							end
						end,
						["show"] = function()
							if (hasTicket(username)) then
								-- display the user's ticket description
								local description = getTicketDescription(username)
								sendMessage(username, "Current active ticket: " .. description)
							else
								sendMessage(username, data.lang.noTicket)
							end
						end,
						["submit"] = function()
							-- check if a ticket for this user already exists
							if (hasTicket(username)) then

							else

							end
						end,
						["help"] = function()
							sendMessage(username, "Ticket help should go here.")
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