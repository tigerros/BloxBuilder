-- Variables
local runService = game:GetService("RunService")

local alertGui = script.Alert
local alertText = alertGui.AlertText
local alertText2 = alertGui.AlertText2

local colors = require(script.Parent.Colors)
local fWait = require(script.Parent.FasterWait)

local alerts = {}

local db = false
local db2 = false

-- Functions
local function alertVisibility()
	if alertText.Visible == true and db2 == false then
		alertText2.Visible = true
		db = true
		fWait(3)
		db = false
		alertText2.Visible = false
	end
	
	if db == false then
		alertText.Visible = true
		db = true
		fWait(3)
		db = false
		alertText.Visible = false
	end
end

function alerts:redAlert(plr, text)
	alertText.Text, alertText2.Text = tostring(text), tostring(text)
	alertText.BackgroundColor3, alertText2.BackgroundColor3 = colors.red, colors.red
	alertGui.Parent = plr.PlayerGui
	
	alertVisibility()
end

function alerts:greenAlert(plr, text)
	self:redAlert(plr, text)
	alertText.BackgroundColor3, alertText2.BackgroundColor3 = colors.green, colors.green
end

return alerts
