--[[ Description:
	Listens for client events and places/destroys blocks
]]

-- Variables
local repliStorage = game:GetService("ReplicatedStorage")
local runService = game:GetService("RunService")
local tweenService = game:GetService("TweenService")

local modules = repliStorage.Modules
local events = repliStorage.Events

local alert = require(modules.Alert)
local grid = require(modules.Grid)
local fWait = require(modules.FasterWait)
local str = require(modules.ExtraStrings)

local modeEvent = events.Mode
local clickEvent = events.Clicked
local placedBlocksEvent = events.GetPlacedBlocks

local buildingMode = true
local destroyMode = false

local placedBlocks = {}

-- Functions
local function autoTween(obj, tweenInfo, properties, callback)
	local requestedTween = tweenService:Create(obj, tweenInfo, properties)

	requestedTween:Play()

	if callback then
		requestedTween.Completed:Connect(callback)
	end
end

local function playerAdded(plr)
	placedBlocks[plr.Name] = {}
end

function placedBlocksEvent.OnServerInvoke(plr)
	return placedBlocks[plr.Name]
end

local function blockHandler(plr, position, mouseTarget, color, material)
	local char = plr.Character or plr.CharactedAdded:Wait()
	
	if buildingMode == true then
		local block = Instance.new("Part", workspace)

		block.Position = Vector3.new(math.clamp(position.x, grid:getCharRange(char, "x", true), grid:getCharRange(char, "x", false)), 
			position.y, math.clamp(position.z, grid:getCharRange(char, "z", true), grid:getCharRange(char, "z", false)))
		
		block.Size = Vector3.new(2, 2, 2)
		
		block.Anchored = true
		block.Color = color
		block.Material = material

		block.Name = plr.Name .. "|" .. #workspace:GetChildren() + 1
		
		table.insert(placedBlocks[plr.Name], str:tableLen(placedBlocks[plr.Name]) + 1, block)
	elseif destroyMode == true then
		local destroyTarget = mouseTarget
		
		if destroyTarget and destroyTarget ~= workspace.Baseplate and destroyTarget.Parent == workspace then
			local ownPart = string.match(destroyTarget.Name, plr.Name .. "%|%d+")
			
			if destroyTarget.Name == ownPart then
				destroyTarget:Destroy()
			else
				alert:redAlert(plr, "Can't destroy someone else's blocks")
			end
		end
	else
		return
	end
end

local function switchModes(plr, buildingBool, destroyBool)
	if buildingBool ~= nil and destroyBool ~= nil then
		buildingMode, destroyMode = buildingBool, destroyBool
	else
		buildingMode, destroyMode = false, false
	end
end

modeEvent.OnServerEvent:Connect(switchModes)
clickEvent.OnServerEvent:Connect(blockHandler)
game.Players.PlayerAdded:Connect(playerAdded)
for _, plr in ipairs(game.Players:GetPlayers()) do
	spawn(function() playerAdded(plr) end)
end