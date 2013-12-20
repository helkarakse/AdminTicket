--[[

Ticket (Admin)
Do not modify, copy or distribute without permission of author
Helkarakse 20131220

]]

-- Libraries
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
local serverId = string.sub(os.getComputerLabel(), 1, 1)