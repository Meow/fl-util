--[[
	© 2016-2017 TeslaCloud Studios

	See license in LICENSE.txt.
--]]

do
	local vowels = {
		["a"] = true,
		["e"] = true,
		["o"] = true,
		["i"] = true,
		["u"] = true,
		["y"] = true,
	}

	-- A function to check whether character is vowel or not.
	function util.IsVowel(char)
		if (!isstring(char)) then return false end

		return vowels[char:lower()]
	end
end

-- A function to remove a substring from the end of the string.
function string.RemoveTextFromEnd(str, strNeedle, bAllOccurences)
	if (!strNeedle or strNeedle == "") then
		return str
	end

	if (str:EndsWith(strNeedle)) then
		if (bAllOccurences) then
			while (str:EndsWith(strNeedle)) do
				str = str:RemoveTextFromEnd(strNeedle)
			end

			return str
		end

		return str:sub(1, str:len() - strNeedle:len())
	else
		return str
	end
end

-- A function to remove a substring from the beginning of the string.
function string.RemoveTextFromStart(str, strNeedle, bAllOccurences)
	if (!strNeedle or strNeedle == "") then
		return str
	end

	if (str:StartWith(strNeedle)) then
		if (bAllOccurences) then
			while (str:StartWith(strNeedle)) do
				str = str:RemoveTextFromStart(strNeedle)
			end

			return str
		end

		return str:sub(strNeedle:len() + 1, str:len())
	else
		return str
	end
end

-- A function to check whether the string is full uppercase or not.
function string.IsUppercase(str)
	return string.upper(str) == str
end

-- A function to check whether the string is full lowercase or not.
function string.IsLowercase(str)
	return string.lower(str) == str
end

-- A function to find all occurences of a substring in a string.
function string.FindAll(str, pattern)
	if (!str or !pattern) then return end

	local hits = {}
	local lastPos = 1

	while (true) do
		local startPos, endPos = string.find(str, pattern, lastPos)

		if (!startPos) then
			break
		end

		table.insert(hits, {string.sub(str, startPos, endPos), startPos, endPos})

		lastPos = endPos + 1
	end

	return hits
end

-- A function to check if string is command or not.
function string.IsCommand(str)
	local prefixes = {"/"}

	if (fl) then
		prefixes = config.Get("command_prefixes")
	end

	for k, v in ipairs(prefixes) do
		if (str:StartWith(v)) then
			return true
		end
	end

	return false
end

do
	-- ID's should not have any of those characters.
	local blockedChars = {
		"'", "\"", "\\", "/", "^",
		":", ".", ";", "&", ",", "%"
	}

	function string.MakeID(str)
		str = str:lower()
		str = str:gsub(" ", "_")

		for k, v in ipairs(blockedChars) do
			str = str:Replace(v, "")
		end

		return str
	end
end