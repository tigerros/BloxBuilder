-- Variables
local repliStorage = game:GetService("ReplicatedStorage")
local plrs = game.Players

local kickEvent = repliStorage.Events.Kick

local banTable = {"ThisGuyIsBanned"}

local dataStore = require(script.Parent.DataStore)
local banStore

local devRank = 255

local formattedPlrs

local low = string.lower

-- Functions
local function is_admin(plr)
	return plr:GetRankInGroup(6402255) >= devRank
end

local function playerAdded(plr)
	banStore = dataStore("banStore", plr)
	banStore:Set(banStore:Get(banTable))

	if plr.UserId ~= 223180856 and table.find(banStore:Get(), low(plr.Name)) or table.find(banTable, low(plr.Name)) then
		plr:Kick("Banned")
	end

	formattedPlrs = {}

	local count = 1

	for i, v in pairs(plrs:GetPlayers()) do
		formattedPlrs[low(plrs:GetPlayers()[count].Name)] = plrs:GetPlayers()[count].Name
		count += 1
	end
end

local function kick(plrKicking, kick, selectedPlrs, msg)
	if not is_admin(plrKicking) then return end

	if kick == true then -- Kicking
		if formattedPlrs[low(msg)] then -- If a player in the server matches with the message, its probably not a message, but instead the player kicking most likely didnt enter a message
			table.insert(selectedPlrs, msg)

			for _, plrToKick in ipairs(selectedPlrs) do
				plrs[formattedPlrs[low(selectedPlrs)]]:Kick("Kicked")
			end
		else
			for _, plrToKick in ipairs(selectedPlrs) do
				plrs[formattedPlrs[low(selectedPlrs)]]:Kick(msg)
			end
		end
	elseif kick == false and not selectedPlrs[plrKicking] then -- Banning
		if formattedPlrs[low(msg)] then
			table.insert(selectedPlrs, msg)

			for _, plrToBan in ipairs(selectedPlrs) do
				plrs[formattedPlrs[low(plrToBan)]]:Kick("Banned")

				table.insert(banTable, low(plrToBan))
			end
		else
			for _, plrToBan in ipairs(selectedPlrs) do
				plrs[formattedPlrs[low(plrToBan)]]:Kick(msg)

				table.insert(banTable, low(plrToBan))
			end
		end

		banStore:Set(banTable)
	end
end

kickEvent.OnServerEvent:Connect(kick)
plrs.PlayerAdded:Connect(playerAdded)
for _, plr in ipairs(plrs:GetPlayers()) do
	spawn(function() playerAdded(plr) end)
end