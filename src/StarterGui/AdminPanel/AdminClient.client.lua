-- Variables
local repliStorage = game:GetService("ReplicatedStorage")
local userInput = game:GetService("UserInputService")
local events = repliStorage.Events

local plr = game.Players.LocalPlayer

local extraStr = require(repliStorage.Modules.ExtraStrings)
local fWait = require(repliStorage.Modules.FasterWait)
local levDiff = require(repliStorage.Modules.Levenshtein)

local kickEvent = events.Kick -- We use this for a ban as well

local util = {}

local cmdFrame = script.Parent.CommandFrame
local cmdField = cmdFrame.CommandField
local executeButton = cmdFrame.Execute

local output = cmdFrame.Output
local outputText = output.OutputList.OutputText

local prefix, batch = ";", ","

local commands = {}

local openKey = prefix

local textChanged
local executeConnection
local onExecuteButton = false

cmdField.PlaceholderText = prefix .. "help"

---------------------------------- Commands ----------------------------------

function commands:help()
	outputText.Text = 'Run command - <i>' .. prefix .. 'command(arg' .. batch .. 'arg2)</i>. See command description - <i>' .. prefix .. 'command</i>. Args are only used in some cases, eg. kick(hacker,hacker2), prefix(new prefix).'
end

function commands:cmds()
	outputText.Text = "Commands: " .. table.concat(extraStr:convertDictionaryToArray(commands, true), ", ")
end

function commands:prefix(execute, newPrefix)
	if execute == true then
		prefix = newPrefix[1]
		outputText.Text = "New prefix: " .. prefix
	else
		outputText.Text = 'The prefix is the key entered before a command, it can be removed by running prefix().'
	end
end

function commands:batch(execute, newBatch)
	if execute == true then
		batch = newBatch[1]
		outputText.Text = "New batch key: " .. batch
	else
		outputText.Text = 'The batch key is the separator between arguments, eg. to kick two hackers: kick(hacker,hacker2).'
	end
end

function commands:kick(execute, args)
	if execute == true then
		local msg = table.remove(args, #args)
		local plrsToKick = args

		kickEvent:FireServer(true, plrsToKick, msg)

		kickEvent.OnClientEvent:Connect(function(plrsKicked)
			outputText.Text = "Kicked: " .. table.concat(plrsKicked, ", ")
		end)
	else
		outputText.Text = 'Kicks a player/players from the server.'
	end
end

function commands:ban(execute, args)
	if execute == true then
		local msg = table.remove(args, #args)
		local plrsToKick = args

		kickEvent:FireServer(false, plrsToKick, msg)

		kickEvent.OnClientEvent:Connect(function(plrsBanned)
			outputText.Text = "Banned: " .. table.concat(plrsBanned, ", ")
		end)
	else
		outputText.Text = 'Bans a player/players from the game.'
	end
end

---------------------------------- Utility ----------------------------------

function util:recommendedCommands(text)
	text = extraStr:remove(text, prefix)

	if string.match(text, "%w+") then
		local pairDiffTab = {}
		local pairLen = 3

		for cmd in pairs(commands) do
			if extraStr:getLetter(text, 1) == extraStr:getLetter(cmd, 1) and levDiff(cmd, text) <= 4 then
				table.insert(pairDiffTab, levDiff(cmd, text) .. cmd)
			elseif levDiff(cmd, text) <= 4 then
				table.insert(pairDiffTab, levDiff(cmd, text) .. cmd)
			end
		end

		table.sort(pairDiffTab)

		for _, v in pairs(pairDiffTab) do
			pairDiffTab[table.find(pairDiffTab, v)] = extraStr:remove(v, "%d*")
		end

		return pairDiffTab
	else
		return {commands[1], commands[2], commands[3], commands[4]} -- 4 Main commands
	end
end

function util:execute()
	local cmd = extraStr:remove(cmdField.Text, prefix)

	if string.match(cmd, "%b()") then
		local args = string.split(string.match(cmd, "%b()"))

		args[1] = extraStr:remove(args[1], "("); args[#args] = extraStr:remove(args[#args], ")")

		cmd = string.match(cmd, "^%w*")

		if #args == 0 then
			if commands[cmd] then
				commands[cmd](false)
			end
		else
			if commands[cmd] then
				commands[cmd](true, true, args)
			end
		end
	else
		if commands[cmd] then
			commands[cmd](false)
		end
	end
end

---------------------------------- Others ----------------------------------

executeConnection = userInput.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 and onExecuteButton == true then
		util:execute()
	end

	if input.KeyCode == Enum.KeyCode.Return then
		util:execute()
	end
end)

textChanged = cmdField:GetPropertyChangedSignal("Text"):Connect(function()
	local firstLetter = extraStr:getLetter(cmdField.Text)

	if firstLetter == "" then
		cmdField.PlaceholderText = prefix .. "help"
	end

	if firstLetter ~= prefix and prefix ~= "" then
		outputText.Text = "| " .. firstLetter .. " | Prefix is not recognized, current prefix: | " .. prefix .. " |"
	else
		outputText.Text = table.concat(util:recommendedCommands(cmdField.Text), " | ")
	end
end)

-- Events
executeButton.MouseButton1Click:Connect(util.execute)
executeButton.MouseEnter:Connect(function() onExecuteButton = true end)
executeButton.MouseLeave:Connect(function() onExecuteButton = false end)
cmdFrame:GetPropertyChangedSignal("Visible"):Connect(function() if cmdFrame.Visible == false then textChanged:Disconnect() executeConnection:Disconnect() end end)

userInput.InputBegan:Connect(function(input)
	if cmdFrame.Visible == false and input.KeyCode == Enum.KeyCode.Backquote and plr:GetRankInGroup(6402255) >= 255 then
		cmdFrame.Visible = true
	elseif cmdFrame.Visible == true and input.KeyCode == Enum.KeyCode.Backquote then
		cmdFrame.Visible = false
	end
end)