-- Variables
local repliStorage = game:GetService("ReplicatedStorage")
local tweenService = game:GetService("TweenService")
local http = game:GetService("HttpService")

local fWait = require(repliStorage.Modules.FasterWait)
local getScaleValues = require(repliStorage.Modules.GetScaleValues)
local plr = game.Players.LocalPlayer

local postEvent = repliStorage.Events.HttpPost

local webhookUrl = "https://discord.com/api/webhooks/1086098528432046100/UZJzb85irSh16UTgSzlQ0tQdgwMirQDdvWnCRynWNlF1OXyvpNVqdl6-0IWGrlcWvpEt"

local bugMenu = script.Parent.BugMenu
local openButton = script.Parent.OpenButton
local fields = bugMenu.Fields
local fatalityButtons = bugMenu.FatalilityButtons
local sendButton = bugMenu.SendButton
local sendText = sendButton.SendText

local ti = TweenInfo.new

-- Functions
local function rgbToInt(rgb) --https://gist.github.com/marceloCodget/3862929
	local hexadecimal = '0x'

	for key, value in pairs(rgb) do
		local hex = ''

		while value > 0 do
			local index = math.fmod(value, 16) + 1
			value = math.floor(value / 16)
			hex = string.sub('0123456789ABCDEF', index, index) .. hex		
			fWait()
		end

		if string.len(hex) == 0 then
			hex = '00'

		elseif string.len(hex) == 1 then
			hex = '0' .. hex
		end

		hexadecimal = hexadecimal .. hex
	end

	return tonumber(hexadecimal)
end

local function autoTween(obj, tweenInfo, properties, callback)
	local requestedTween = tweenService:Create(obj, tweenInfo, properties)

	requestedTween:Play()

	if callback then
		requestedTween.Completed:Connect(callback)
	end

	return requestedTween
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

flashEffect(openButton)
flashEffect(sendButton)

------------------------------------------------

local function sendBug()
	local what = fields.What.Text
	local when = fields.When.Text

	local embedColor = 16226590

	if what == "" then
		what = "n/a"
	end

	if when == "" then
		when = "n/a"
	end

	for _, button in ipairs(fatalityButtons:GetChildren()) do
		if button:IsA("GuiButton") and button:GetAttribute("selected") == true then
			embedColor = rgbToInt({button.BackgroundColor3.R*255, button.BackgroundColor3.G*255, button.BackgroundColor3.B*255})
		end
	end

	local json = {
		username = plr.Name,
		embeds = {
			{
				title = plr.Name .. "'s bug report",
				description = "Reported on " .. os.date("!*t").day .. "/" .. os.date("!*t").month .. "/" .. os.date("!*t").year,
				color = embedColor,

				footer = {
					text = "Group - https://www.roblox.com/groups/6402255/Tigers-Basement-Studio",
					icon_url = "https://media.discordapp.net/attachments/656236825144328214/821014822928777216/a302b7c7-9ce8-4cbd-a979-6d689ff53a54_200x200.png"
				},

				fields = {
					{
						name = "What",
						value = "```" .. what .. "```",
						inline = true
					},

					{
						name = "When",
						value = "```" .. when .. "```",
						inline = true
					}
				}
			}
		},
	}

	sendText.Text = "Processing..."

	local response = postEvent:InvokeServer(webhookUrl, json, Enum.HttpContentType.ApplicationJson)

	if response == "sent" then
		sendText.Text = "Sent!"
		autoTween(sendButton, ti(0.1), {BackgroundColor3 = Color3.fromRGB(130, 170, 76)})
		fWait(2)
		sendText.Text = "Send"
		autoTween(sendButton, ti(0.1), {BackgroundColor3 = Color3.fromRGB(88, 88, 88)})
	else
		sendText.Text = response
		autoTween(sendButton, ti(0.1), {BackgroundColor3 = Color3.fromRGB(231, 108, 91)})
		fWait(2)
		sendText.Text = "Send"
		autoTween(sendButton, ti(0.1), {BackgroundColor3 = Color3.fromRGB(88, 88, 88)})
	end
end

local function openMenu()
	local openSize = UDim2.new(0.4, 0, 0.5, 0)
	local openPos = UDim2.new(0.5, 0, 0.45, 0)

	local closedSize = UDim2.new(0.4, 0, 0, 0)
	local closedPos = UDim2.new(0.5, 0, 0.2, 0)

	if bugMenu:GetAttribute("open") == false then
		bugMenu.Visible = true
		autoTween(bugMenu, ti(0.2), {Position = openPos, Size = openSize}, function()
			bugMenu:SetAttribute("open", true)
		end)
	else
		autoTween(bugMenu, ti(0.2), {Position = closedPos, Size = closedSize}, function()
			bugMenu.Visible = false
			bugMenu:SetAttribute("open", false)
		end)
	end
end

local function selectFatality()
	for _, button in ipairs(fatalityButtons:GetChildren()) do
		if button:IsA("GuiButton") then
			button:GetAttributeChangedSignal("selected"):Connect(function()
				local x = getScaleValues(button.Position)

				if button:GetAttribute("selected") == true then
					autoTween(button, ti(0.1), {Position = UDim2.fromScale(x, 0.35)})

					for _, otherButton in ipairs(fatalityButtons:GetChildren()) do
						if otherButton ~= button then
							otherButton:SetAttribute("selected", false)
						end
					end
				else
					autoTween(button, ti(0.1), {Position = UDim2.fromScale(x, 0.5)})
				end
			end)

			button.MouseEnter:Connect(function()
				local x = getScaleValues(button.Position)

				if button:GetAttribute("selected") == false then
					autoTween(button, ti(0.1), {Position = UDim2.fromScale(x, 0.35)})
				end
			end)

			button.MouseLeave:Connect(function()
				local x = getScaleValues(button.Position)

				if button:GetAttribute("selected") == false then
					autoTween(button, ti(0.1), {Position = UDim2.fromScale(x, 0.5)})
				end
			end)

			button.MouseButton1Click:Connect(function()
				local x = getScaleValues(button.Position)

				if button:GetAttribute("selected") == false then
					button:SetAttribute("selected", true)
				else
					button:SetAttribute("selected", false)
				end
			end)
		end
	end
end

selectFatality()

openButton.MouseButton1Click:Connect(openMenu)
sendButton.MouseButton1Click:Connect(sendBug)