local UIS = game:GetService("UserInputService");

local dragger = {}
dragger.__index = dragger

function dragger.new(guiElement)
	local self = setmetatable({}, dragger)
	
	local isDragging = false
	local lastMousePosition = Vector3.new()

	self.events = {
		guiElement.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				isDragging = true
			end
		end),
		
		guiElement.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				isDragging = false
			end
		end),
		
		UIS.InputChanged:Connect(function(input, process)
			if input.UserInputType == Enum.UserInputType.MouseMovement then
				local delta = input.Position - lastMousePosition
				lastMousePosition = input.Position

				if isDragging and not process then
					self:onDrag(guiElement, input, delta)
				end
			end
		end)
	}
	
	return self
end

function dragger:onDrag(guiElement, input, delta)
	guiElement.Position = guiElement.Position + UDim2.new(0, delta.x, 0, delta.y)
end

function dragger:Destroy()
	for i = 1, #self.events do
		self.events[i]:Disconnect()
	end
	
	self.events = {}
end

return dragger