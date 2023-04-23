-- Simple functions really, but quite useful
-- Not a perfect name, since it doesnt just include functions for strings
-- lstring is just the string library but localized
local fWait = require(script.Parent.FasterWait)
local lstring = string

local extraStr = {}

function extraStr:replace(toProcess, toFind, toInsert)
	toProcess = tostring(toProcess)
	toFind = tostring(toFind)
	toInsert = tostring(toInsert)

	local startValue, endValue = lstring.find(toProcess, toFind)

	local firstString = lstring.sub(toProcess, 1, startValue - 1)
	local secondString = lstring.sub(toProcess, endValue + 1, lstring.len(toProcess))

	local finalString = firstString .. toInsert .. secondString
	
	return finalString
end

function extraStr:remove(toProcess, toRemove)
	toProcess = tostring(toProcess)
	toRemove = tostring(toRemove)
	
	local finalString = table.concat(lstring.split(toProcess, toRemove))

	if toProcess == finalString then
		pcall(function()
			finalString = table.concat(lstring.split(toProcess, lstring.match(toProcess, toRemove)))
		end)
	end
	
	--[[
		Why the concats and splits instead of a simple gsub(toProcess, toRemove, "")?
		Some characters cannot be removed, because they are used in string patterns (eg. "("), therefore Lua will try to pattern match with that character, not actually being a pattern
		This method will get rid of that problem, and functions just like a gsub (as far as I know)
	]]
	
	return finalString
end

function extraStr:splitIntoPairs(str, pairLen)
	local pairTab = {}
	local concat = table.concat
	local pairI = 1
	pairLen = pairLen or 2

	repeat
		local pair = str:sub(pairI, (pairI - 1) + pairLen)

		table.insert(pairTab, #pairTab + 1, pair)

		pairI += pairLen
		fWait()
	until #concat(pairTab, "") >= #str

	return pairTab
end

function extraStr:getLetter(str, pos)
	return lstring.sub(str, pos or 1, pos or 1)
end

function extraStr:getDigit(n, pos)
	return tonumber(lstring.sub(tostring(n), pos, pos))
end

function extraStr:keyCodeToString(keyCode)
	pcall(function()
		if keyCode ~= Enum.KeyCode.LeftShift then
			return lstring.char(keyCode.Value) 
		end
	end)
end

function extraStr.isUppercase(str, pos)
	if pos then
		if lstring.upper(extraStr:getLetter(str, pos)) == extraStr:getLetter(str, pos) then
			return true
		else
			return false
		end
	else
		if lstring.upper(str) == str then
			return true
		else
			return false
		end
	end
end

function extraStr:tableLen(tab)
	local count = 0 
	
	for _, v in pairs(tab) do
		count += 1
	end
	
	return count
end

function extraStr:convertDictionaryToArray(tab, indexOnly)
	local array = table.create(extraStr:tableLen(tab), 0)
	local count = 1
	
	if indexOnly == true then
		for i in pairs(tab) do
			array[count] = i
			count += 1
		end
	else
		for _, v in pairs(tab) do
			array[count] = v
			count += 1
		end
	end
	
	return array
end

function extraStr:reverseArray(tab)
	for i = 1, math.floor(#tab / 2) do
		local j = #tab - i + 1
		
		
		tab[i], tab[j] = tab[j], tab[i]
	end
end

return extraStr