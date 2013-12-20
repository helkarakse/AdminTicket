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

-- Errors
error = {}
error.submitFailed = "Error 10: Failed to send ticket. Notify a developer immediately."
error.commandNotFound = "Error 90: Command not found."

-- Misc
commandPrefix = "//"

-- Functions
local function doPost(url, data)
  local response = http.post(url, data)
  if (response) then
    local responseText = response.readAll()
    functions.info(responseText)
    response.close()
    return true
  else
    functions.error("Warning: Failed to retrieve response from server")
    return false
  end
end

function addTicket(creator, description, position)
  local url = "http://dev.otegamers.com/helkarakse/ticket/ticket.php?cmd=add_ticket"
  return doPost(url, "creator=" .. textutils.urlEncode(creator) .. "&description=" .. textutils.urlEncode(description) .. "&position=" .. textutils.urlEncode(position))
end

function validateAuth(username)
end