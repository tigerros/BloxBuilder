--[[ Description:
	Manages the handles that resize/reposition (currently only resize) a given part.
]]

--[[ Scaling:
	Keeps the position of a part when resizing it, by actually changing it, but making it *look* like it hasnt been changed.
	
	Surfaces - X: Positive = Right, Negative = Left | Y: Positive = Top, Negative = Bottom | Z: Positive = Back, Negative = Front
	
	Any axis:
	
	Positive Surface:
	+x Size = +x/2 Position
	-x Size = -x/2 Position
	
	Negative Surface:
	+x Size = -x/2 Position
	-x Size = +x/2 Position
]]

-- Variables
local tweenService = game:GetService("TweenService")

local fWait = require(script.Parent.FasterWait)

local selectionBox = script.SelectionBox
local selectionDetector = script.SelectionDetector

local sizeHandles = script.SizeHandles

local gridSize = 0.5

local ti = TweenInfo.new

local handles = {}

handles.selectionBox = {}
handles.sizeHandle = {}

handles.sizeHandle.offset = 1

-- Functions
local function autoTween(obj, tweenInfo, properties, callback)
	local requestedTween = tweenService:Create(obj, tweenInfo, properties)

	requestedTween:Play()

	if callback then
		requestedTween.Completed:Connect(callback)
	end
end

local function positionAllHandles(part)
	for _, handleHitbox in ipairs(part:GetChildren()) do
		if handleHitbox:IsA("Model") then
			local handleAxis = string.match(handleHitbox.Name, "%-*%a$")
			local xyz = {x = part.Position.x, y = part.Position.y, z = part.Position.z}

			local lastOrientationX, lastOrientationY, lastOrientationZ = handleHitbox.PrimaryPart.CFrame:ToEulerAnglesXYZ()

			for otherAxis, _ in pairs(xyz) do
				if not string.find(otherAxis, handleAxis) then
					xyz[otherAxis] = part.Position[otherAxis]
				end
			end

			if string.find(handleAxis, "-") then
				handleAxis = handleAxis:gsub("-", "")

				xyz[handleAxis] = -(handleHitbox.PrimaryPart.Size[handleAxis] / 2) - (part.Size[handleAxis] / 2) + part.Position[handleAxis] - handles.sizeHandle.offset
			else
				xyz[handleAxis] = (handleHitbox.PrimaryPart.Size[handleAxis] / 2) + (part.Size[handleAxis] / 2) + part.Position[handleAxis] + handles.sizeHandle.offset
			end

			if handleHitbox:GetAttribute("used") == false then
				handleHitbox:SetPrimaryPartCFrame(CFrame.Angles(lastOrientationX, lastOrientationY, lastOrientationZ) + Vector3.new(xyz.x, xyz.y, xyz.z))
			else
				autoTween(handleHitbox.PrimaryPart, ti(0.1), {CFrame = CFrame.Angles(lastOrientationX, lastOrientationY, lastOrientationZ) + Vector3.new(xyz.x, xyz.y, xyz.z)})
			end
		end
	end
end

function handles.selectionBox:new(part)
	local selectionBoxClone = selectionBox:Clone()
	local selectionDetectorClone = selectionDetector:Clone()

	if not part:FindFirstChild("SelectionBox") and not part:FindFirstChild("SelectionDetector") then
		selectionBoxClone.Parent = part
		selectionBoxClone.Adornee = part
		selectionDetectorClone.Parent = part
	end
end

function handles.selectionBox:onHover(part, func, leaveFunc)
	local hover
	local hoverEnded

	hover = part:FindFirstChildOfClass("ClickDetector").MouseHoverEnter:Connect(func)
	hoverEnded = part:FindFirstChildOfClass("ClickDetector").MouseHoverLeave:Connect(leaveFunc)

	return hover, hoverEnded
end

function handles.selectionBox:onClick(part, func)
	local click

	click = part:FindFirstChildOfClass("ClickDetector").MouseClick:Connect(func)

	return click
end

function handles.selectionBox:activate(part)
	part:FindFirstChildOfClass("SelectionBox").Visible = true
end

function handles.selectionBox:deactivate(part)
	part:FindFirstChildOfClass("SelectionBox").Visible = false
end

function handles.selectionBox:destroy(part)
	if part then
		for _, child in ipairs(part:GetDescendants()) do
			if child:IsA("SelectionBox") or child:IsA("ClickDetector") then
				child:Destroy()
			end
		end
	end
end

function handles.sizeHandle:new(part)
	local clickDetectorTable = {}		

	for _, model in ipairs(sizeHandles:GetChildren()) do
		model = model:Clone()
		model.Parent = part

		local sizeHandle

		for _, hitbox in ipairs(model:GetChildren()) do
			if string.find(hitbox.Name, "SizeHandle") then
				sizeHandle = hitbox

				positionAllHandles(part)

				table.insert(clickDetectorTable, #clickDetectorTable + 1, sizeHandle.ClickDetector)
			end
		end

		model:SetAttribute("used", true)
	end

	for _, clickDetector in ipairs(clickDetectorTable) do
		clickDetector.MouseClick:Connect(function()
			local sizeHandle = clickDetector.Parent
			local part = sizeHandle.Parent.Parent
			local axis = string.match(sizeHandle.Name, "%-*%a$")
			local surface = string.match(sizeHandle.Parent.Name, "%-*%a$")
			local sizeXyz = {x = part.Size.x, y = part.Size.y, z = part.Size.z}
			local positionXyz = {x = part.Position.x, y = part.Position.y, z = part.Position.z}

			local function changeSize()
				positionAllHandles(part)

				autoTween(part, ti(0.1), {Position = Vector3.new(positionXyz.x, positionXyz.y, positionXyz.z)})
				autoTween(part, ti(0.1), {Size = Vector3.new(sizeXyz.x, sizeXyz.y, sizeXyz.z)})
			end

			if not string.find(surface, "-") then -- Positive Surface
				if not string.find(axis, "-") then -- Plus Axis
					sizeXyz[axis] = sizeXyz[axis] + gridSize
					positionXyz[axis] = positionXyz[axis] + gridSize / 2

					changeSize()
				else -- Minus Axis
					axis = axis:gsub("-", "")
					sizeXyz[axis] = sizeXyz[axis] - gridSize
					positionXyz[axis] = positionXyz[axis] - gridSize / 2

					changeSize()
				end
			else -- Negative Surface
				if not string.find(axis, "-") then -- Plus Axis
					sizeXyz[axis] = sizeXyz[axis] + gridSize
					positionXyz[axis] = positionXyz[axis] - gridSize / 2

					changeSize()
				else -- Minus Axis
					axis = axis:gsub("-", "")
					sizeXyz[axis] = sizeXyz[axis] - gridSize
					positionXyz[axis] = positionXyz[axis] + gridSize / 2

					changeSize()
				end
			end
		end)
	end
end

function handles.sizeHandle:destroy(part)
	if part then
		for _, sizeHandle in ipairs(part:GetDescendants()) do
			if string.find(sizeHandle.Name , "SizeHandle") then
				sizeHandle:Destroy()
			end
		end
	end
end

return handles