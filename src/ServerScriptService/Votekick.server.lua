-- Variables
local repliStorage = game:GetService("ReplicatedStorage")
local tweenService = game:GetService("TweenService")

local votekickEvent = repliStorage.Events.Votekick

local votekickPrompt = script.VotekickPrompt

local ti = TweenInfo.new

-- Functions
local function autoTween(obj, tweenInfo, properties, callback)
	local requestedTween = tweenService:Create(obj, tweenInfo, properties)

	requestedTween:Play()

	if callback then
		requestedTween.Completed:Connect(callback)
	end
end

local function votekick(plrWhoStarted, plrToVotekick)
	local votes = script.Votes
	local requiredVotes = math.floor((#game.Players:GetPlayers() / 2) + (#game.Players:GetPlayers() / 6))
	
	if requiredVotes ~= 1 then
		votes.Changed:Connect(function()
			if votes.Value >= requiredVotes then
				plrToVotekick:Kick()
				votes.Value = 1
			end
		end)

		for _, otherPlr in ipairs(game.Players:GetPlayers()) do
			if otherPlr.UserId ~= plrWhoStarted.UserId and otherPlr.UserId ~= plrToVotekick.UserId then
				local votekickPromptClone = votekickPrompt:Clone()
				local vote

				votekickPromptClone.Prompt.PromptText.Text = "Would you like to kick <i>" .. plrToVotekick.Name .. "</i>?"
				votekickPromptClone.Prompt.Note.Text = "<i>Votekick started by " .. plrWhoStarted.Name .. ".</i>"

				votekickPromptClone.Parent = otherPlr.PlayerGui
				autoTween(votekickPromptClone.Prompt, ti(1, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0.11, 0, 0.265, 0)})

				votekickPromptClone.Prompt.No.MouseButton1Click:Connect(function()
					autoTween(votekickPromptClone.Prompt, ti(1, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Position = UDim2.new(-0.1, 0, 0.265, 0)}, function()
						votekickPromptClone:Destroy()
					end)
				end)

				vote = votekickPromptClone.Prompt.Yes.MouseButton1Click:Connect(function()
					votes.Value += 1

					vote:Disconnect()

					autoTween(votekickPromptClone.Prompt, ti(1, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Position = UDim2.new(-0.1, 0, 0.265, 0)}, function()
						votekickPromptClone:Destroy()
					end)
				end)
			end
		end
	end
end

votekickEvent.OnServerEvent:Connect(votekick)