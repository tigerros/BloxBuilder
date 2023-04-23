-- Randomly made, might be useful
local function getScaleValues(udim2)
	
	local scalePattern = "^%{([%w%p%w]*)%,%s*[%w%p%w]*%}%,%s*%{([%w%p%w]*)%,"
	local xScale, yScale = string.match(tostring(udim2), scalePattern)
	
	return xScale, yScale
end

return getScaleValues