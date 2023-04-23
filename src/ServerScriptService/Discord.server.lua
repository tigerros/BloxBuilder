-- Variables
local http = game:GetService("HttpService")

local announcementUrl = "https://discord.com/api/webhooks/811327049926443098/Ul61fJBsCql3Q09QfNvUNIkPSfzwv60uMxNoq4CLHx_EJTl1i21vMiWLlfkDTn1NsOpp" -- Announcement webhook
local joinUrl = "https://discord.com/api/webhooks/803620141593133066/pT6aTHAgiDiTTRYKrsACRdUmXg8kADi1W2oKZHbuq9R6riRFhFIPz-ruxP6hIbnFU1xH" -- Normal webhook (logs actual players)
local studioUrl = "https://discord.com/api/webhooks/803620388152016906/2lOBIabizmb56L6O-sNdQhO9rUK878GRuAUWNQdSbSe_wVipwA8WSuZo1tIjNzYVzUWO" -- Studio webhook (logs studio test)

local gameName = "BloxBuilder"

-- Functions
local function logPlayerJoin(plr)
	if not game:GetService("RunService"):IsStudio() then
		-- Player joined in game

		local date = os.date("!*t")
		local data = {
			["content"] = plr.Name .." joined " .. gameName .. " on " .. date.month .. "/" .. date.day .. "/" .. date.year
		}

		data = http:JSONEncode(data)
		http:PostAsync(joinUrl, data)
	else
		-- Player joined in studio

		local date = os.date("!*t")
		local data = {
			["content"] = plr.Name .." joined " .. gameName .. " (in studio) on " .. date.month .. "/" .. date.day .. "/" .. date.year
		}

		data = http:JSONEncode(data)
		http:PostAsync(studioUrl, data)
	end
end

local function postToDiscord(plr, text)
	http:PostAsync(announcementUrl, http:JSONDecode(text))
end

game:GetService("Players").PlayerAdded:Connect(logPlayerJoin)