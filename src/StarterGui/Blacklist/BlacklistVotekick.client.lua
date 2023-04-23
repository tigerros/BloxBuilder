-- Variables
local repliStorage = game:GetService("ReplicatedStorage")
local tweenService = game:GetService("TweenService")

local fWait = require(repliStorage.Modules.FasterWait)

local votekickEvent = repliStorage.Events.Votekick

local plrs = game.Players
local localPlr = plrs.LocalPlayer
local mouse = localPlr:GetMouse()

local openButton = script.Parent.OpenButton
local mainMenu = script.Parent.MainMenu

local blacklistMenu = mainMenu.Blacklist
local votekickMenu = mainMenu.VotekickList

local votekickButton = mainMenu.VotekickButton

local ti = TweenInfo.new

local blacklistFuncs = {}
local blacklistedPlayers = {}
local blacklistedBlocks = {}
local blacklistedConnections = {}

local votekickFuncs = {}

-- Functions
local function autoTween(obj, tweenInfo, properties, callback)
	local requestedTween = tweenService:Create(obj, tweenInfo, properties)

	requestedTween:Play()

	if callback then
		requestedTween.Completed:Connect(callback)
	end
end

local function lighten(color)
	return Color3.new(color.R*1.3, color.G*1.3, color.B*1.3)
end

local function flashEffect(obj)
	local origColor = obj.BackgroundColor3
	
	obj.MouseButton1Down:Connect(function()
		autoTween(obj, ti(0.15), {BackgroundColor3 = lighten(origColor)})
	end)

	obj.MouseButton1Up:Connect(function()
		autoTween(obj, ti(0.15), {BackgroundColor3 = origColor})
	end)
end

------------------------------------------------

local function createPlayerButtons()
	for _, plrButton in ipairs(votekickMenu:GetChildren()) do
		if plrButton:IsA("GuiButton") then
			plrButton:Destroy()
		end
	end
	
	if #game.Players:GetPlayers() == 2 then
		votekickButton.Text = "Not enough players"
	end
	
	for _, plr in ipairs(plrs:GetPlayers()) do
		if plr ~= localPlr and not blacklistMenu:FindFirstChild(plr.Name) then
			local plrButton = script.BlacklistPlayer:Clone()
			plrButton.Parent = blacklistMenu
			plrButton.Name = plr.Name
			plrButton.Text = plr.Name

			plrButton.MouseButton1Click:Connect(function()
				if plrButton:GetAttribute("selected") == false then
					autoTween(plrButton, ti(0.1), {BackgroundColor3 = Color3.fromRGB(231, 108, 91), TextColor3 = Color3.fromRGB(255, 255, 255)})
					plrButton:SetAttribute("selected", true)
					blacklistFuncs:selectPlayer(plrButton.Name)
				else
					autoTween(plrButton, ti(0.1), {BackgroundColor3 = Color3.fromRGB(255, 255, 255), TextColor3 = Color3.fromRGB(88, 88, 88)})
					plrButton:SetAttribute("selected", false)
					blacklistFuncs:deselectPlayer(plrButton.Name)
				end
			end)
		end
	end
	
	for _, plr in ipairs(plrs:GetPlayers()) do
		if plr ~= localPlr and not votekickMenu:FindFirstChild(plr.Name) then
			local plrButton = script.VotekickPlayer:Clone()
			plrButton.Parent = votekickMenu
			plrButton.Name = plr.Name
			plrButton.Text = plr.Name
			
			plrButton:SetAttribute("UserId", plr.UserId)
			
			plrButton.MouseButton1Down:Connect(function()
				if plrButton:GetAttribute("selected") == false then
					autoTween(plrButton, ti(0.1), {BackgroundColor3 = Color3.fromRGB(231, 108, 91), TextColor3 = Color3.fromRGB(255, 255, 255)})
					plrButton:SetAttribute("selected", true)
				else
					autoTween(plrButton, ti(0.1), {BackgroundColor3 = Color3.fromRGB(255, 255, 255), TextColor3 = Color3.fromRGB(88, 88, 88)})
					plrButton:SetAttribute("selected", false)
				end
				
				for _, otherButton in ipairs(votekickMenu:GetChildren()) do
					if otherButton:IsA("GuiButton") and otherButton ~= plrButton then
						otherButton:SetAttribute("selected", false)
						autoTween(otherButton, ti(0.1), {BackgroundColor3 = Color3.fromRGB(255, 255, 255), TextColor3 = Color3.fromRGB(88, 88, 88)})
					end
				end
			end)
		end
	end
end

local function openMenu()
	local openSize = UDim2.new(0.5, 0, 0.78, 0)
	local openPos = UDim2.new(0.5, 0, 0.5, 0)
	
	local closedSize = UDim2.new(0.5, 0, 0, 0)
	local closedPos = UDim2.new(0.5, 0, 0.11, 0)
	
	if mainMenu.Size == closedSize then
		mainMenu.Visible = true
		autoTween(mainMenu, ti(0.2), {Position = openPos, Size = openSize})
	else
		autoTween(mainMenu, ti(0.2), {Position = closedPos, Size = closedSize}, function()
			mainMenu.Visible = false
		end)
	end
end

flashEffect(openButton)
flashEffect(votekickButton)

------------------------------------------------

function blacklistFuncs:selectPlayer(plrToBlacklist)
	if not table.find(blacklistedPlayers, plrToBlacklist) then
		table.insert(blacklistedPlayers, #blacklistedPlayers + 1, plrToBlacklist)
		table.insert(blacklistedConnections, #blacklistedConnections + 1, plrToBlacklist .. "blacklistedBlockAdded")
	end
	
	for _, blacklistedPlayer in ipairs(blacklistedPlayers) do
		blacklistedConnections[plrToBlacklist .. "blacklistedBlockAdded"] = workspace.DescendantAdded:Connect(function(newBlock)
			print(blacklistedPlayer, blacklistedPlayers)
			if string.find(newBlock.Name, tostring(blacklistedPlayer)) then
				newBlock.Parent = nil
				table.insert(blacklistedBlocks, #blacklistedBlocks + 1, newBlock)
			end
		end)

		for _, blacklistedPart in ipairs(workspace:GetDescendants()) do
			if string.find(blacklistedPart.Name, tostring(blacklistedPlayer)) and not blacklistedPart:FindFirstChild("Humanoid") then
				blacklistedPart.Parent = nil
				table.insert(blacklistedBlocks, #blacklistedBlocks + 1, blacklistedPart)
			end
		end
	end
end

function blacklistFuncs:deselectPlayer(plrToUnblacklist)
	if table.find(blacklistedPlayers, plrToUnblacklist) then
		table.remove(blacklistedPlayers, table.find(blacklistedPlayers, plrToUnblacklist))
		
		for _, blacklistedBlock in ipairs(blacklistedBlocks) do
			blacklistedBlock.Parent = workspace
		end
		
		blacklistedConnections[plrToUnblacklist .. "blacklistedBlockAdded"]:Disconnect()
		blacklistedConnections[plrToUnblacklist .. "blacklistedBlockAdded"] = nil
		table.remove(blacklistedConnections, table.find(blacklistedConnections, plrToUnblacklist .. "blacklistedBlockAdded"))
		
		print(blacklistedPlayers, blacklistedBlocks, blacklistedConnections)
	end
end

------------------------------------------------

function votekickFuncs:startVotekick()
	for _, selectedButton in ipairs(votekickMenu:GetChildren()) do
		if selectedButton:IsA("GuiButton") and selectedButton:GetAttribute("selected") == true then
			local plrToVotekick = game.Players:GetPlayerByUserId(selectedButton:GetAttribute("UserId"))
			
			votekickEvent:FireServer(plrToVotekick)
		end
	end
end

------------------------------------------------

openButton.MouseButton1Click:Connect(function() openMenu() end)
votekickButton.MouseButton1Click:Connect(votekickFuncs.startVotekick)
plrs.PlayerAdded:Connect(createPlayerButtons)
plrs.PlayerRemoving:Connect(createPlayerButtons)
createPlayerButtons()