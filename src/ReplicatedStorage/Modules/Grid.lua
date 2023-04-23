--[[ Description:
	Returns the position on a custom sized grid of a given Vector3
]]

-- Variables
local gridPart = workspace.Baseplate
local gridSize = 0.5 -- In studs
local maxRange = 30

local grid = {}

grid.position = Vector3.new(0, 10.5, 0) -- Set the second value to the position right above the baseplate

-- Functions
function grid:getCharRange(char, axis, min)
	local rootPart = char:FindFirstChild("HumanoidRootPart")
	
	if rootPart then
		local xyz = {x = rootPart.Position.x, y = rootPart.Position.y, z = rootPart.Position.z}

		if min == true then
			xyz[axis] = xyz[axis] - maxRange
		else
			xyz[axis] = xyz[axis] + maxRange
		end

		return xyz[axis]
	else
		return 0
	end
end

function grid:getPosition(position, targetBlock, targetSurface, previewBlock, char)
	if gridSize ~= 0 then
		if position then
			if targetBlock then
				if targetBlock ~= gridPart then
					local surfaceVector = Vector3.fromNormalId(targetSurface)
					local xyz = {x = surfaceVector.x, y = surfaceVector.y, z = surfaceVector.z}

					for axis, axisValue in pairs(xyz) do
						if axisValue == 1 then
							xyz[axis] = (previewBlock.Size[axis] / 2) + (targetBlock.Size[axis] / 2) + targetBlock.Position[axis]
						elseif axisValue == -1 then
							xyz[axis] = -(previewBlock.Size[axis] / 2) - (targetBlock.Size[axis] / 2) + targetBlock.Position[axis]
						elseif axisValue == 0 then
							xyz[axis] = math.floor((position[axis] / gridSize) + 0.5)*gridSize
						end
					end

					grid.position = Vector3.new(math.clamp(xyz.x, grid:getCharRange(char, "x", true), grid:getCharRange(char, "x", false)), 
						xyz.y, math.clamp(xyz.z, grid:getCharRange(char, "z", true), grid:getCharRange(char, "z", false)))

					return grid.position
				else
					local x, y, z = position.x, position.y, position.z

					x, y, z = math.floor((x / gridSize) + 0.5)*gridSize, (previewBlock.Size.y / 2) + (gridPart.Size.y / 2), math.floor((z / gridSize) + 0.5)*gridSize

					grid.position = Vector3.new(math.clamp(x, grid:getCharRange(char, "x", true), grid:getCharRange(char, "x", false)), 
						y, math.clamp(z, grid:getCharRange(char, "z", true), grid:getCharRange(char, "z", false)))

					return grid.position
				end
			else
				local lastX, lastY, lastZ = grid.position.x, grid.position.y, grid.position.z

				local lastPosition = Vector3.new(math.clamp(lastX, grid:getCharRange(char, "x", true), grid:getCharRange(char, "x", false)), 
					lastY, math.clamp(lastZ, grid:getCharRange(char, "z", true), grid:getCharRange(char, "z", false)))
				
				return lastPosition
			end
		else
			return Vector3.new(0, -1000, 0)
		end
	else
		grid.position = position
		
		return position
	end
end

for _, gridTexture in ipairs(gridPart:GetChildren()) do
	if gridSize ~= 0 then
		gridTexture.StudsPerTileU, gridTexture.StudsPerTileV = 8*gridSize, 8*gridSize
	end
end

return grid