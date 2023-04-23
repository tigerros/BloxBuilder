-- Returns the Levenshtein distance between two strings [NOT MADE BY ME]
local function Levenshtein(string1, string2)
	-- Localize
	local utf8_len = utf8.len
	local utf8_codes = utf8.codes
	
	if string1 == string2 then
		return 0
	end

	local length1 = utf8_len(string1)
	local length2 = utf8_len(string2)

	if length1 == 0 then
		return length2
	elseif length2 == 0 then
		return length1
	end

	local matrix = {}
	
	for i = 0, length1 do
		matrix[i] = {[0] = i}
	end

	for i = 0, length2 do
		matrix[0][i] = i
	end

	local i = 1
	local iSub1
	
	for _, code1 in utf8_codes(string1) do
		local j = 1
		local jSub1

		for _, code2 in utf8_codes(string2) do
			local cost = code1 == code2 and 0 or 1
			
			iSub1 = i - 1
			jSub1 = j - 1

			matrix[i][j] = math.min(matrix[iSub1][j] + 1, matrix[i][jSub1] + 1, matrix[iSub1][jSub1] + cost)
			j += 1
		end

		i += 1
	end

	return matrix[length1][length2]
end

return Levenshtein