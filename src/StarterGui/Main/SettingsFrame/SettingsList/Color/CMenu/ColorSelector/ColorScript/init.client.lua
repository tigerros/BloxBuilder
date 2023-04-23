-- Credit goes to @EgoMoose
local dragger = require(script:WaitForChild("Dragger"))

local slider = script.Parent:WaitForChild("Slider")
local slide = slider:WaitForChild("Slide")

local wheel = script.Parent:WaitForChild("Wheel")
local ring = wheel:WaitForChild("Ring")

local colorDisplay = script.Parent:WaitForChild("ColorDisplay")
local color = require(script.Color)

local function toPolar(v)
	return math.atan2(v.y, v.x), v.magnitude
end

local function radToDeg(x)
	return ((x + math.pi) / (2 * math.pi)) * 360
end

local hue, saturation, value = 0, 0, 1

local function update()
	colorDisplay.BackgroundColor3 = color.hsv
	color.hsv = Color3.fromHSV(hue, saturation, value)
end

-- Dragger
local slideDrag = dragger.new(slide)
local ringDrag = dragger.new(ring)

function slideDrag:onDrag(guiElement, input, delta)
	local rY = input.Position.y - slider.AbsolutePosition.y
	local cY = math.clamp(rY, 0, slider.AbsoluteSize.y - slide.AbsoluteSize.y)
	guiElement.Position = UDim2.new(0.5, 0, 0, cY)
	
	value = 1 - (cY / (slider.AbsoluteSize.y - slide.AbsoluteSize.y))
	guiElement.BackgroundColor3 = Color3.fromHSV(0, 0, 1-value)
	
	update()
end

function ringDrag:onDrag(guiElement, input, delta)
	local r = wheel.AbsoluteSize.x/2
	local d = Vector2.new(input.Position.x, input.Position.y) - wheel.AbsolutePosition - wheel.AbsoluteSize/2

	if (d:Dot(d) > r*r) then
		d = d.unit * r
	end
	
	guiElement.Position = UDim2.new(0.5, d.x, 0.5, d.y)
	
	local phi, len = toPolar(d * Vector2.new(1, -1))
	hue, saturation = radToDeg(phi)/360, len / r
	slider.BackgroundColor3 = Color3.fromHSV(hue, saturation, 1)
	
	update()
end