--[[

Ticket (Common)
Do not modify, copy or distribute without permission of author
Helkarakse 20131220

]]

-- Libraries
os.loadAPI("data")

-- References
local data = data
local string = string

-- Functions
-- sends a chat message to a player
function sendMessage(map, username, message)
	local player = map.getPlayerByName(username)
	player.sendChat(message)
end

function stripPrefix(message)
	return string.sub(message, string.len(data.commandPrefix) + 1)
end