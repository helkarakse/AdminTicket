--[[

Ticket (Common)
Do not modify, copy or distribute without permission of author
Helkarakse 20131220

]]

-- sends a chat message to a player
function sendMessage(username, message)
	local player = map.getPlayerByName(username)
	player.sendChat(message)
end