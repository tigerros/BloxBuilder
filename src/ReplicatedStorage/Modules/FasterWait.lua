--[[ Description:
	Alternative option to the default "wait()" function
]]

-- Variables
local runService = game:GetService("RunService")

-- Functions
local function fWait(n)
	local control = 0
	
	if n then
		while control < n do
			control = control + runService.Heartbeat:Wait()
		end
	else
		control = runService.Heartbeat:Wait()
	end
	
	return control
end

return fWait
