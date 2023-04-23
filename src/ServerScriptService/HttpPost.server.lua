-- Variables
local http = game:GetService("HttpService")

local postEvent = game.ReplicatedStorage.Events.HttpPost

-- Functions
function postEvent.OnServerInvoke(_, url, data)
	local success, err = pcall(function()
		data = http:JSONEncode(data)
		http:PostAsync(url, data)
	end)
	
	if success then
		return "sent"
	else
		warn(err)
		return err
	end
end