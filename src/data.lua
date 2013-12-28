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
lang.reboot = "System is rebooting. Please wait."

-- Errors
error = {}
error.submitFailed = "Error 10: Failed to send ticket. Notify a developer immediately."
error.apiFailed = "Error 11: API failed to return data. Notify a developer immediately."
error.commandNotFound = "Error 90: Command not found."
error.invalidAuthLevel = "Error 91: Invalid authentication level. This has been logged."
error.missingArgs = "Error 12: Arguments are missing. Please check your syntax."
error.noResults = "No results returned."
error.needAuth = "You are not authorised to run this command."

-- Misc
commandPrefix = "//"

local basePath = "http://dev.otegamers.com/helkarakse/index.php"

-- Functions
-- URL builder
local function buildUrl(controller, method)
	return basePath .. "?c=" .. controller .. "&m=" .. method
end

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
	return doPost(buildUrl("ticket", "add_ticket"), "creator=" .. textutils.urlEncode(creator) .. "&description=" .. textutils.urlEncode(description) .. "&position=" .. textutils.urlEncode(position))
end

function getMyTickets(username)
	return doGetPost(buildUrl("ticket", "get_user_tickets"), "name=" .. username)
end

function countMyTickets(username)
	return doGetPost(buildUrl("ticket", "get_user_ticket_count"), "name=" .. username)
end

-- Issues
function getIssues(authLevel)
	return doGetPost(buildUrl("ticket", "get_issues"), "auth_level=" .. authLevel)
end

function getIssuesByType(authLevel, status)
	return doGetPost(buildUrl("ticket", "get_issues"), "auth_level=" .. authLevel .. "&status=" .. status)
end

function getIssueDetails(authLevel, id)
	return doGetPost(buildUrl("ticket", "get_issue_details"), "auth_level=" .. authLevel .. "&id=" .. id, true)
end

-- Auth
-- Returns the auth level for a username
function getAuth(username)
	return doGetPost(buildUrl("auth", "get_auth"), "name=" .. username)
end

-- Returns a full list of the auth table
function getAuthArray()
	return doGet(buildUrl("auth", "get_auth_package"))
end

-- Sets the auth level of a username
function setAuth(username, level)
	return doGetPost(buildUrl("auth", "set_auth"), "name=" .. username .. "&level" .. level, true)
end

function delAuth(username)
	return doGetPost(buildUrl("auth", "delete_user"), "name=" .. username, true)
end

function addAuth(username, level)
	return doGetPost(buildUrl("auth", "add_user"), "name=" .. username .. "&level" .. level, true)
end