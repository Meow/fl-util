--[[
	© 2016-2017 TeslaCloud Studios

	See license in LICENSE.txt.
--]]

do
	local hexDigits = {"0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f"}

	-- A function to convert a single hexadecimal digit to decimal.
	function util.HexToDec(hex)
		if (isnumber(hex)) then
			return hex
		end

		hex = hex:lower()

		local negative = false

		if (hex:StartWith("-")) then
			hex = hex:sub(2, 2)
			negative = true
		end

		for k, v in ipairs(hexDigits) do
			if (v == hex) then
				if (!negative) then
					return k - 1
				else
					return -(k - 1)
				end
			end
		end

		ErrorNoHalt("[util.HexToDec] '"..hex.."' is not a hexadecimal number!")

		return 0
	end
end

-- A function to convert hexadecimal number to decimal.
function util.HexToDecimal(hex)
	if (isnumber(hex)) then return hex end

	local sum = 0
	local chars = table.Reverse(string.Explode("", hex))
	local idx = 1

	for i = 0, hex:len() - 1 do
		sum = sum + util.HexToDec(chars[idx]) * math.pow(16, i)
		idx = idx + 1
	end

	return sum
end