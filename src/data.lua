--[[

AdminTicket Data
Do not modify, copy or distribute without permission of author
Helkarakse 20131216

]]

-- References
local functions = functions
local textutils = textutils
local http = http

-- Functions
local function doPost(url, data)
	local response = http.post(url, data)
	if (response) then
		local responseText = response.readAll()
		functions.debug(responseText)
		response.close()
	else
		functions.debug("Warning: Failed to retrieve response from server")
	end
end

function addTicket(creator, description, position)
	local url = "http://dev.otegamers.com/helkarakse/ticket/ticket.php?cmd=add_ticket"
	doPost(url, "creator=" .. textutils.urlEncode(creator) .. "&description=" .. textutils.urlEncode(description) .. "&position=" .. textutils.urlEncode(position))
end