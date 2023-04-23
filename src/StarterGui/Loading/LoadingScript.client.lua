game.ReplicatedFirst:RemoveDefaultLoadingScreen()

-- Variables
local runService = game:GetService("RunService")
local tweenService = game:GetService("TweenService")

local background = script.Parent.Background
local loadingBar = background.LoadingBar
local bar = loadingBar.Bar
local tip = background.Tip

local ti = TweenInfo.new

local lastPosition

local tips = {
	"Please report any bugs you find!",
	"Blacklist any trolls if you cant votekick them!",
	"Leave a like if you enjoyed your time",
	"To build, or not to build.",
	"You can change your block in the menu at the bottom right"
}

tip.Text = '“' .. tips[math.random(1, #tips)] .. '”'

-- Functions
local function getScaleValues(udim2)
	local scalePattern = "^%{([%w%p%w]*)%,%s*[%w%p%w]*%}%,%s*%{([%w%p%w]*)%,"
	local xScale, yScale = string.match(tostring(udim2), scalePattern)

	return xScale, yScale
end

local function autoTween(obj, tweenInfo, properties, callback)
	local requestedTween = tweenService:Create(obj, tweenInfo, properties)

	requestedTween:Play()

	if callback then
		requestedTween.Completed:Connect(callback)
	end
	
	return requestedTween
end

local barTween = autoTween(bar, ti(2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1, true), {Position = UDim2.new(1.25, 0, 0.5, 0)})

repeat
	-- Force some waits so it doesnt load immediately
	lastPosition = getScaleValues(bar.Position) wait(0.75)
	lastPosition = getScaleValues(bar.Position) wait(0.75)
until game:IsLoaded()

barTween:Cancel()

if lastPosition > getScaleValues(bar.Position) then
	autoTween(bar, ti(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {Position = bar.Position - UDim2.new(0.15625, 0, 0, 0)}, function()
		wait(0.5)

		bar:Destroy()

		for _, child in ipairs(background:GetChildren()) do
			if child:IsA("GuiObject") then
				autoTween(background, ti(1), {Transparency = 1, Size = background.Size - UDim2.new(0.1, 0, 0.1, 0)})
				autoTween(child, ti(1), {Transparency = 1, Size = child.Size - UDim2.new(0.1, 0, 0.1, 0)}, function()
					script.Parent:Destroy()
					script:Destroy()
				end)
			end
		end
	end)
else
	autoTween(bar, ti(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Position = bar.Position + UDim2.new(0.15625, 0, 0, 0)}, function()
		wait(0.5)

		bar:Destroy()

		for _, child in ipairs(background:GetChildren()) do
			if child:IsA("GuiObject") then
				autoTween(background, ti(1), {Transparency = 1, Size = background.Size - UDim2.new(0.1, 0, 0.1, 0)})
				autoTween(child, ti(1), {Transparency = 1, Size = child.Size - UDim2.new(0.1, 0, 0.1, 0)}, function()
					script.Parent:Destroy()
					script:Destroy()
				end)
			end
		end
	end)
end