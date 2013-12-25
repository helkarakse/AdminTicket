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

-- Variables
local dimArray = {
	{dimensionId = 0, dimensionName = "Overworld"},
	{dimensionId = -1, dimensionName = "Nether"},
	{dimensionId = 1, dimensionName = "The End"},
	{dimensionId = 4, dimensionName = "Public Mining"},
	{dimensionId = 7, dimensionName = "Twilight Forest"},
	{dimensionId = 8, dimensionName = "Silver Mining"},
	{dimensionId = 9, dimensionName = "Gold Mining"},
	{dimensionId = -31, dimensionName = "Secret Cow Level"},
	{dimensionId = -20, dimensionName = "Promised Lands"},
	{dimensionId = 100, dimensionName = "Deep Dark"},
}

-- Functions
-- sends a chat message to a player
function sendMessage(map, username, message)
	local player = map.getPlayerByName(username)
	player.sendChat(message)
end

function stripPrefix(message)
	return string.sub(message, string.len(data.commandPrefix) + 1)
end

function getDimension(dimId)
	for key, value in pairs(dimArray) do
		if (value.dimensionId == dimId) then
			return value.dimensionName
		end
	end
	return "Unknown"
end