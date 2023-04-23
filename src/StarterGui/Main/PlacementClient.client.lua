--[[ Description:
	Handles everything frontend (ui, preview, etc.)
]]

-- Variables
local repliStorage = game:GetService("ReplicatedStorage")
local runService = game:GetService("RunService")
local tweenService = game:GetService("TweenService")
local userInput = game:GetService("UserInputService")

local modules = repliStorage.Modules
local events = repliStorage.Events
	
local str = require(modules.ExtraStrings)
local color = require(script.Parent.SettingsFrame.SettingsList.Color.CMenu.ColorSelector.ColorScript.Color)
local fWait = require(modules.FasterWait)
local grid = require(modules.Grid)
local handles = require(game.ReplicatedStorage.Modules.BlockHandles)

local modeEvent = events.Mode
local clickEvent = events.Clicked
local placedBlocksEvent = events.GetPlacedBlocks

local modeChanged = script.ModeChanged

local plr = game.Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local mouse = plr:GetMouse()

local gui = script.Parent
local modesButton = gui.Modes
local settingsButton = gui.Settings
local settingsFrame = gui.SettingsFrame
local settingsList = settingsFrame.SettingsList

local dpButton = settingsList.DragPlace.DPButton
local amButton = settingsList.AdvancedMode.AMButton
local cButton = settingsList.Color.CButton
local cInput = settingsList.Color.CMenu.CInput
local mButton = settingsList.Material.MButton

local style = Enum.EasingStyle
local direction = Enum.EasingDirection

local crossImage = "rbxassetid://3944676352"
local checkImage = "rbxassetid://3944680095"

local ti = TweenInfo.new

local materialList = Enum.Material:GetEnumItems()

local freeMaterials = {
	"Plastic",
	"Wood",
	"Slate",
	"Concrete",
	"Grass",
	"Marble",
	"Granite",
	"Brick",
	"Pebble",
	"Sand",
	"Fabric",
	"SmoothPlastic",
	"Metal",
	"WoodPlanks",
	"Cobblestone"
}

local paidMaterials = { -- Not implemented yet
	"CorrodedMetal",
	"DiamondPlate",
	"Foil",
	"Ice",
	"ForceField",
	"Neon",
	"Glass"
}

local invalidMaterials = { -- These are materials used for terrain, therefore invalid for normal parts
	"Air",
	"Water",
	"Rock",
	"Glacier",
	"Snow",
	"Sandstone",
	"Mud",
	"Basalt",
	"Ground",
	"CrackedLava",
	"Asphalt",
	"LeafyGrass",
	"Salt",
	"Limestone",
	"Pavement"
}

local currentMaterial = Enum.Material.Plastic

local buildingMode = true
local destroyMode = false
local editMode = false

local placePreview 
local previewPart
local destroyPreview
local removeDestroyPreview

local selectionHover
local selectionHoverEnded
local selectionClick

local draggingOn = false
local dragBegan
local dragEnded
local dragLoop

local menus = {mMenu = settingsList.Material.MMenu, cMenu = settingsList.Color.CMenu}

local builder = {}
local effects = {}
local colors = {}
local material = {}
local openClose = {}

-------------------------- Effects --------------------------

function effects:autoTween(obj, tweenInfo, properties, callback)
	local requestedTween = tweenService:Create(obj, tweenInfo, properties)

	requestedTween:Play()
	
	if callback then
		requestedTween.Completed:Connect(callback)
	end
end

function effects.darken(color, percent)
	return Color3.new(percent*color.R, percent*color.G, percent*color.B)
end

function effects.lighten(color, percent)
	return Color3.new(percent + (1 - percent)*color.R, percent + (1 - percent)*color.G, percent + (1 - percent)*color.B)
end

function effects.darkenOnHover(obj)
	local origColor = obj.BackgroundColor3

	obj.MouseEnter:Connect(function()
		effects:autoTween(obj, ti(0.15), {BackgroundColor3 = effects.darken(obj.BackgroundColor3, 0.7)})
	end)

	obj.MouseLeave:Connect(function()
		effects:autoTween(obj, ti(0.15), {BackgroundColor3 = origColor})
	end)
end

function effects.darkenOnClick(obj)
	local origColor = obj.BackgroundColor3

	obj.MouseButton1Down:Connect(function()
		effects:autoTween(obj, ti(0.15), {BackgroundColor3 = effects.darken(obj.BackgroundColor3, 0.7)})
	end)

	obj.MouseButton1Up:Connect(function()
		effects:autoTween(obj, ti(0.15), {BackgroundColor3 = origColor})
	end)
end

function effects.wiggleOnClick(obj)
	obj.MouseButton1Click:Connect(function()
		effects:autoTween(obj, ti(0.1), {Rotation = 15}, function()
			effects:autoTween(obj, ti(0.1), {Rotation = -15}, function()
				effects:autoTween(obj, ti(0.1), {Rotation = 0})
			end)
		end)
	end)

	if obj.Parent:IsA("GuiButton") then -- Sometimes, I have to put an image button under another image button, so I can switch images, so I need this
		obj.MouseButton1Click:Connect(function()
			effects:autoTween(obj.Parent, ti(0.1), {Rotation = 15}, function()
				effects:autoTween(obj.Parent, ti(0.1), {Rotation = -15}, function()
					effects:autoTween(obj.Parent, ti(0.1), {Rotation = 0})
				end)
			end)
		end)
	end
end

function effects.circleRotate(obj)
	effects:autoTween(obj, ti(0.2), {Rotation = obj.Rotation + 360}, function()
		if obj.Rotation%360 ~= 0 then
			repeat
				obj.Rotation = obj.Rotation / 360
				
				fWait()
			until obj.Rotation%360 == 0
		end
	end)
end

function effects.biggerOnHover(obj, multiplier)
	local origSize = obj.Size

	local scalePattern = "^.+%,"
	local firstScale = str:remove(string.match(tostring(origSize.X), scalePattern), ",")
	local secondScale = str:remove(string.match(tostring(origSize.Y), scalePattern), ",")

	local biggerSize = UDim2.fromScale(firstScale*multiplier, secondScale*multiplier)

	obj.MouseEnter:Connect(function()
		obj:TweenSize(biggerSize, direction.InOut, style.Linear, 0.15, true)
	end)

	obj.MouseLeave:Connect(function()
		obj:TweenSize(origSize, direction.InOut, style.Linear, 0.15, true)
	end)
end

for _, obj in ipairs(settingsFrame:GetDescendants()) do
	if obj:IsA("TextButton") then
		obj.AutoButtonColor = false

		effects.biggerOnHover(obj, 1.08)
	elseif obj:IsA("ImageButton") then
		obj.AutoButtonColor = false

		if obj.Name == "Reset" then
			obj.MouseButton1Click:Connect(function()
				effects.circleRotate(obj)
			end)
		else
			effects.darkenOnClick(obj)			
		end
		
		effects.darkenOnHover(obj)
	end
end

-------------------------- Effects --------------------------

-------------------------- Building --------------------------

builder.preview = {}
builder.advancedMode = {}

function builder.placeBlock()
	clickEvent:FireServer(grid.position, mouse.Target, color.hsv, currentMaterial)
end

function builder.preview:create()
	previewPart = Instance.new("Part", workspace)

	previewPart.Name = plr.Name .. "|" .. "Preview"
	previewPart.Anchored = true
	previewPart.Position = Vector3.new(0, 10, 0)
	previewPart.Size = Vector3.new(2, 2, 2)
	previewPart.Material = currentMaterial
	previewPart.BrickColor = BrickColor.Green()
	previewPart.Transparency = 0.5
	previewPart.CanCollide = false

	mouse.TargetFilter = previewPart
end

function builder.preview:update()
	effects:autoTween(previewPart, ti(0.1), {Position = grid:getPosition(mouse.Hit.p, mouse.Target, mouse.TargetSurface, previewPart, char)})
end

function builder.preview:reset()
	if buildingMode == true then
		previewPart.Transparency = 0.5
		
		if destroyPreview then destroyPreview:Disconnect() end
		if removeDestroyPreview then removeDestroyPreview:Disconnect() end
		
		placePreview = runService.Heartbeat:Connect(function()
			builder.preview:update()
		end)
	elseif destroyMode == true then
		previewPart.Transparency = 1
		
		if placePreview then placePreview:Disconnect() end

		destroyPreview = mouse.Move:Connect(function()
			local hoverTarget = mouse.Target

			if hoverTarget and hoverTarget ~= workspace.Baseplate and hoverTarget.Parent == workspace then
				local previousColor = hoverTarget.Color
				local previousTransparency = hoverTarget.Transparency

				hoverTarget.BrickColor = BrickColor.Red()
				hoverTarget.Transparency = 0.5

				removeDestroyPreview = mouse.Move:Connect(function()
					local newTarget = mouse.Target
					
					if newTarget ~= hoverTarget then
						hoverTarget.Color = previousColor
						hoverTarget.Transparency = previousTransparency
					end
				end)
			end
		end)
	elseif editMode == true then
		previewPart.Transparency = 1
		
		if placePreview then placePreview:Disconnect() end
		if destroyPreview then destroyPreview:Disconnect() end
		if removeDestroyPreview then removeDestroyPreview:Disconnect() end
	end	
end

function builder.advancedMode:activate()
	local blocks = placedBlocksEvent:InvokeServer()

	if editMode == true then
		local sizeHandleOpen = false

		for _, block in ipairs(blocks) do
			handles.selectionBox:new(block)

			selectionHover, selectionHoverEnded = handles.selectionBox:onHover(block, function()
				handles.selectionBox:activate(block)
			end, function()
				handles.selectionBox:deactivate(block)
			end)

			selectionClick = handles.selectionBox:onClick(block, function()
				handles.sizeHandle:new(block)

				if sizeHandleOpen == false then
					sizeHandleOpen = true

					for _, otherBlock in ipairs(blocks) do
						if otherBlock ~= block then
							handles.sizeHandle:destroy(otherBlock)
						end
					end
				else
					sizeHandleOpen = false

					handles.sizeHandle:destroy(block)
				end
			end)
		end
	else		
		if selectionHover then selectionHover:Disconnect() end
		if selectionHoverEnded then selectionHoverEnded:Disconnect() end
		if selectionClick then selectionClick:Disconnect() end
		
		for _, block in ipairs(blocks) do
			handles.selectionBox:destroy(block)
			handles.sizeHandle:destroy(block)
		end
	end
end

function builder.switchModes()
	local placeRotation = 90
	local destroyRotation = 45
	local editRotation = 0
	
	local normalSize = UDim2.new(0.05, 0, 0.1, 0)
	local editSize = UDim2.new(0.04, 0, 0.8, 0)

	if modesButton.Rotation == placeRotation then
		modesButton.Image = "rbxassetid://3944675151"
		modesButton.Size = normalSize
		effects:autoTween(modesButton, ti(0.1), {Rotation = destroyRotation})

		buildingMode = false
		destroyMode = true
		editMode = false
		
		modeChanged:Fire()

		modeEvent:FireServer(buildingMode, destroyMode)
	elseif modesButton.Rotation == destroyRotation then
		modesButton.Image = "rbxassetid://4370186570"
		modesButton.Size = editSize
		effects:autoTween(modesButton, ti(0.1), {Rotation = editRotation})

		buildingMode = false
		destroyMode = false
		editMode = true
		
		modeChanged:Fire()
		
		modeEvent:FireServer()
	elseif modesButton.Rotation == editRotation then
		modesButton.Image = "rbxassetid://3944675151"
		modesButton.Size = normalSize
		effects:autoTween(modesButton, ti(0.1), {Rotation = placeRotation})

		buildingMode = true
		destroyMode = false
		editMode = false
		
		modeChanged:Fire()

		modeEvent:FireServer(buildingMode, destroyMode)
	end
end

function builder.dragPlace()
	local mouseBtn1 = Enum.UserInputType.MouseButton1

	if draggingOn == false then
		draggingOn = true

		effects:autoTween(dpButton, ti(0.1), {ImageTransparency = 1}, function()
			effects:autoTween(dpButton.Check, ti(0.1), {ImageTransparency = 0})
		end)

		if editMode == false then
			dragBegan = userInput.InputBegan:Connect(function(input)
				local inputType = input.UserInputType

				if inputType == mouseBtn1 then
					dragLoop = runService.Heartbeat:Connect(function()
						builder.placeBlock()
					end)
				end
			end)

			dragEnded = userInput.InputEnded:Connect(function(input)
				local inputType = input.UserInputType

				if inputType == mouseBtn1 then
					if dragLoop then dragLoop:Disconnect() end
				end
			end)
		end
	else
		draggingOn = false

		effects:autoTween(dpButton.Check, ti(0.1), {ImageTransparency = 1}, function()
			effects:autoTween(dpButton, ti(0.1), {ImageTransparency = 0})
		end)

		dragBegan:Disconnect()
		dragEnded:Disconnect()
		dragLoop:Disconnect()
	end
end

builder.preview:create()
builder.preview:reset()
-------------------------- Building --------------------------

-------------------------- Colors --------------------------

function colors.change()
	local cMenu = settingsList.Color.CMenu
	
	function colors:hexToRgb(hexInput)
		local r, g, b

		pcall(function() -- pcall this because it will output errors before all the values are entered
			local hexPattern = "^%#*%w+"
			local hex = string.match(hexInput, hexPattern)

			if hex then
				-- Remove both "#" and "0x", as they are both hex code variations
				hex = hex:gsub("#", "")
				hex = hex:gsub("0x", "")

				if #hex == 6 then -- Check if the final hex code is 6 characters long
					r = tonumber("0x" .. hex:sub(1, 2))
					g = tonumber("0x" .. hex:sub(3, 4))
					b = tonumber("0x" .. hex:sub(5, 6))
				end
			end
		end)

		return r, g, b
	end

	function colors.getInput()
		local rgbPattern = "^(%d+)[%,%s]*(%d+)[%,%s]*(%d+)" -- (%d+) Digit variable -> #1(%d+) = r #2(%d+) = g and repeat | [%, - Comma | %s - Whitespace]* - A 0 or more Class
		local r, g, b = string.match(cInput.Text, rgbPattern)
		
		if cInput.Text ~= "" then
			if r and g and b then
				cInput.TextStrokeColor3 = Color3.fromRGB(r, g, b)
				color.hsv = Color3.fromHSV(Color3.toHSV(Color3.fromRGB(r, g, b)))
			else
				cInput.TextStrokeColor3 = Color3.fromRGB(colors:hexToRgb(cInput.Text))
				color.hsv = Color3.fromHSV(Color3.toHSV(Color3.fromRGB(colors:hexToRgb(cInput.Text))))
			end
		end
	end
	
	colors.getInput()
end

-------------------------- Colors --------------------------

-------------------------- Materials --------------------------

function material:switch(button)
	button.MouseButton1Click:Connect(function()
		currentMaterial = Enum.Material[button.Parent.Name]
	end)
end

function material:reset(button, dropdown)
	button.MouseButton1Click:Connect(function()
		currentMaterial = Enum.Material.Plastic
		dropdown.UIPageLayout:JumpTo(dropdown.Plastic)
	end)
end

function material:shuffle(button, dropdown)
	button.MouseButton1Click:Connect(function()
		local randomIndex = math.random(1, #dropdown:GetChildren())
		dropdown.UIPageLayout:JumpToIndex(randomIndex)
		currentMaterial = Enum.Material[dropdown.UIPageLayout.CurrentPage.Name]
	end)
end

local function createMaterialFrames()
	local count = 1
	
	local materialPattern = "%a+$"
	
	local function createPreview(preview, count)
		local part = Instance.new("Part", preview)
		local camera = Instance.new("Camera", preview)
		
		part.Material = materialList[count]
		
		part.Color = Color3.new(0.866667, 0.709804, 0.6)

		preview.CurrentCamera = camera
		preview.BackgroundTransparency = 1
		camera.CFrame = CFrame.new(Vector3.new(0, 2, 4), part.Position)
	end
	
	repeat
		local mFrame = repliStorage.MFrame:Clone()
		local mPreview = mFrame.Preview
		
		local materialName = string.match(tostring(materialList[count]), materialPattern)

		mFrame.Parent = menus.mMenu
		mFrame.Name = materialName
		mFrame.Material.Text = materialName

		createPreview(mPreview, count)
		material:switch(mFrame.Check)
		material:reset(mFrame.Reset, menus.mMenu)
		material:shuffle(mFrame.Shuffle, menus.mMenu)
		
		fWait()
		count = count + 1
	until count == #materialList + 1
	
	for _, mFrame in ipairs(menus.mMenu:GetChildren())  do
		if table.find(invalidMaterials, mFrame.Name) then
			mFrame:Destroy()
		end
	end
end

createMaterialFrames()
-------------------------- Materials --------------------------

-------------------------- Openings --------------------------

function menus.closeAllMenus(whitelistedMenu)
	for _, menu in pairs(menus) do
		if menu ~= whitelistedMenu and typeof(menu) ~= "function" and menu:GetAttribute("open") == true then
			local functionIndex = string.lower(menu.Name:sub(1, 1)) .. "Menu"
			
			openClose[functionIndex]()
		end
	end
end

function openClose.settings()
	local openSize = UDim2.new(0.21, 0, 0.65, 0)
	local openPos = UDim2.new(0.01, 0, 0.54, 0)
	
	local closedSize = UDim2.new(0.21, 0, 0, 0)
	local closedPos = UDim2.new(0.01, 0, 0.87, 0)
	
	if settingsFrame.Size == closedSize then
		settingsFrame.Visible = true
		effects:autoTween(settingsButton, ti(0.1), {Rotation = 90})
		settingsFrame:TweenSizeAndPosition(openSize, openPos, direction.Out, style.Sine, 0.2)
	else
		effects:autoTween(settingsButton, ti(0.1), {Rotation = 0})
		settingsFrame:TweenSizeAndPosition(closedSize, closedPos, direction.In, style.Sine, 0.2, true, function()
			settingsFrame.Visible = false
		end)
	end
end

function openClose.cMenu()
	local openPos = UDim2.new(2.188, 0, 1.96, 0)
	local closedPos = UDim2.new(1.01, 0, 1.96, 0)

	if menus.cMenu.Position == closedPos then
		menus.cMenu:SetAttribute("open", true)
		menus.cMenu:TweenPosition(openPos, direction.Out, style.Quad, 0.3)
		menus.closeAllMenus(menus.cMenu)
	else
		menus.cMenu:SetAttribute("open", false)
		menus.cMenu:TweenPosition(closedPos, direction.In, style.Quad, 0.3)
	end
end

function openClose.mMenu()
	local openPos = UDim2.new(2.05, 0, -1, 0)
	local closedPos = UDim2.new(1.01, 0, -1, 0)
	
	if menus.mMenu.Position == closedPos then
		menus.mMenu:TweenPosition(openPos, direction.Out, style.Quad, 0.3)
		menus.mMenu:SetAttribute("open", true)
		menus.closeAllMenus(menus.mMenu)
	else
		menus.mMenu:SetAttribute("open", false)
		menus.mMenu:TweenPosition(closedPos, direction.In, style.Quad, 0.3)
	end
end

-------------------------- Openings --------------------------

-- Events
mouse.Button1Down:Connect(builder.placeBlock)
modesButton.MouseButton1Click:Connect(builder.switchModes)
settingsButton.MouseButton1Click:Connect(openClose.settings)
dpButton.MouseButton1Click:Connect(builder.dragPlace)
dpButton.Check.MouseButton1Click:Connect(builder.dragPlace)
cButton.MouseButton1Click:Connect(openClose.cMenu)
mButton.MouseButton1Click:Connect(openClose.mMenu)
cInput.Changed:Connect(colors.change)

modeChanged.Event:Connect(function()
	builder.preview:reset()
	builder.advancedMode:activate()
end)

plr.CharacterAdded:Connect(function(newChar)
	char = newChar
end)