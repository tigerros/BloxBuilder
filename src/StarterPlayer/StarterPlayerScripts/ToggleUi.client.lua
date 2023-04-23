-- Variables
local userInput = game:GetService("UserInputService")
local plr = game.Players.LocalPlayer

-- Functions
userInput.InputBegan:Connect(function(input)
	local keyCode = input.KeyCode

	if keyCode == Enum.KeyCode.F10 then
		for _, gui in ipairs(plr.PlayerGui:GetChildren()) do
			if gui:IsA("ScreenGui") and gui.Name ~= "Loading" then
				if gui.Enabled == true then
					gui.Enabled = false
				else
					gui.Enabled = true
				end
			end
		end
	end
end)