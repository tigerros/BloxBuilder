local function rgb(...)
	return Color3.fromRGB(...)
end

local palette = {
	trueWhite = rgb(255, 255, 255),
	white = rgb(242, 242, 242),
	gray = rgb(88, 88, 88),
	slightyDarkGray = rgb(50,50,50),
	darkGray = rgb(30, 30, 30),
	whiteishBlue = rgb(143, 189, 238),
	lightBlue = rgb(89, 179, 238),
	darkBlue = rgb(73, 150, 197),
	yellow = rgb(255, 223, 107),
	gold = rgb(250, 195, 99),
	darkGold = rgb(202, 157, 80),
	red = rgb(255, 95, 84),
	darkRed = rgb(188, 68, 62),
	cyan = rgb(77, 225, 156),
	whiteishGreen = rgb(144, 203, 172),
	green = rgb(136, 221, 117),
	darkGreen = rgb(119, 194, 103)
}

return palette