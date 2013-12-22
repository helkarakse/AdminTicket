--[[

Ticket (Data)
Do not modify, copy or distribute without permission of author
Helkarakse 20131219

]]

-- References
local functions = functions
local textutils = textutils
local http = http

-- Language
lang = {}
lang.noTicket = "You are not currently creating a ticket."
lang.oneTicket = "Only one ticket can be created at a time."
lang.noDesc = "No description set for ticket. This is mandatory!"
lang.submitSuccess = "Your ticket has been successfully submitted. A moderator will attend to it shortly."
lang.myTickets = "Displaying my currently active tickets:"
lang.noTicketsFound = "You have no active tickets at the moment."
lang.loginMessage = "Welcome to the OTEGamers Ticket System."

-- Errors
error = {}
error.submitFailed = "Error 10: Failed to send ticket. Notify a developer immediately."
error.apiFailed = "Error 11: API failed to return data. Notify a developer immediately."
error.commandNotFound = "Error 90: Command not found."

-- Misc
commandPrefix = "//"

local basePath = "http://dev.otegamers.com/helkarakse/ticket/"

-- Functions
-- HTTP
-- sends data to a url that requires post params
local function doPost(url, data, debug)
	local showDebug = debug or false
	local response = http.post(url, data)
	if (response) then
		local responseText = response.readAll()
		if (showDebug) then
			functions.info(responseText)
		end
		return responseText
	else
		functions.error("Warning: Failed to retrieve response from server")
		return false
	end
end

-- returns data from a url that requires get params
local function doGet(url, debug)
	local showDebug = debug or false
	local response = http.get(url)
	if (response) then
		local responseText = response.readAll()
		if (showDebug) then
			functions.info(responseText)
		end
		return responseText
	else
		functions.error("Warning: Failed to retrieve response from server")
	end
end

-- returns data from a url that requires post params
local function doGetPost(url, data, debug)
	local showDebug = debug or false
	local response = http.post(url, data)
	if (response) then
		local responseText = response.readAll()
		if (showDebug) then
			functions.info(responseText)
		end
		return responseText
	else
		functions.error("Warning: Failed to retrieve response from server")
	end
end

-- Ticket
function addTicket(creator, description, position)
	local url = basePath .. "ticket.php?cmd=add_ticket"
	return doPost(url, "creator=" .. textutils.urlEncode(creator) .. "&description=" .. textutils.urlEncode(description) .. "&position=" .. textutils.urlEncode(position))
end

function getMyTickets(username)
	local url = basePath .. "ticket.php?cmd=get_my_tickets"
	return doGetPost(url, "name=" .. username)
end

function countMyTickets(username)
	local url = basePath .. "ticket.php?cmd=get_my_ticket_count"
	return doGetPost(url, "name=" .. username)
end

-- Issues
function getIssues(authLevel)
	local url = basePath .. "ticket.php?cmd=get_issues"
	return doGetPost(url, "auth_level=" .. authLevel)
end

-- Auth
-- Returns the auth level for a username
function getAuth(username)
	local url = basePath .. "auth.php?cmd=get_auth"
	return doGetPost(url, "name=" .. username)
end

-- Returns a full list of the auth table
function getAuthArray()
	local url = basePath .. "auth.php?cmd=get_auth_array"
	return doGet(url)
end