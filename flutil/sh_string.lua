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

-- A function to convers vararg to a string list.
function util.ListToString(callback, separator, ...)
	if (!isfunction(callback)) then
		callback = function(obj) return tostring(obj) end
	end

	if (!isstring(separator)) then
		separator = ", "
	end

	local list = {...}
	local result = ""

	for k, v in ipairs(list) do
		local text = callback(v)

		if (isstring(text)) then
			result = result..text
		end

		if (k < #list) then
			result = result..separator
		end
	end

	return result
end

-- A function to check whether a string is a number.
function string.IsNumber(char)
	return (tonumber(char) != nil)
end

-- A function to count character in a string.
function string.CountCharacter(str, char)
	local exploded = string.Explode("", str)
	local hits = 0

	for k, v in ipairs(exploded) do
		if (v == char) then
			if (char == "\"") then
				local prevChar = exploded[k - 1] or ""

				if (prevChar == "\\") then
					continue
				end
			end

			hits = hits + 1
		end
	end

	return hits
end

-- INTERNAL: used to remove all newlines from table that is passed to BuildTableFromString.
function util.SmartRemoveNewlines(str)
	local exploded = string.Explode("", str)
	local toReturn = ""
	local skip = ""

	for k, v in ipairs(exploded) do
		if (skip != "") then
			toReturn = toReturn..v

			if (v == skip) then
				skip = ""
			end

			continue
		end

		if (v == "\"") then
			skip = "\""

			toReturn = toReturn..v

			continue
		end

		if (v == "\n" or v == "\t") then
			continue
		end

		toReturn = toReturn..v
	end

	return toReturn
end

-- A function to build a table from string.
-- It has /almost/ the same syntax as Lua tables,
-- except key-values ONLY work like this {key = "value"},
-- so, NO {["key"] = "value"} or {[1] = value}, THOSE WON'T WORK.
-- This supports tables-inside-tables structure.
function util.BuildTableFromString(str)
	str = util.SmartRemoveNewlines(str)

	local exploded = string.Explode(",", str)
	local tab = {}

	for k, v in ipairs(exploded) do
		if (!isstring(v)) then continue end

		if (!string.find(v, "=")) then
			v = v:RemoveTextFromStart(" ", true)

			if (string.IsNumber(v)) then
				v = tonumber(v)
			elseif (string.find(v, "\"")) then
				v = v:RemoveTextFromStart("\""):RemoveTextFromEnd("\"")
			elseif (v:find("{")) then
				v = v:Replace("{", "")

				local lastKey = nil
				local buff = v

				for k2, v2 in ipairs(exploded) do
					if (k2 <= k) then continue end

					if (v2:find("}")) then
						buff = buff..","..v2:Replace("}", "")

						lastKey = k2

						break
					end

					buff = buff..","..v2
				end

				if (lastKey) then
					for i = k, lastKey do
						exploded[i] = nil
					end

					v = util.BuildTableFromString(buff)
				end
			else
				v = v:RemoveTextFromEnd("}")
			end

			table.insert(tab, v)
		else
			local parts = string.Explode("=", v)
			local key = parts[1]:RemoveTextFromEnd(" ", true):RemoveTextFromEnd("\t", true)
			local value = parts[2]:RemoveTextFromStart(" ", true):RemoveTextFromStart("\t", true)

			if (string.IsNumber(value)) then
				value = tonumber(value)
			elseif (value:find("{") and value:find("}")) then
				value = util.BuildTableFromString(value)
			else
				value = value:RemoveTextFromEnd("}")
			end

			tab[key] = value
		end
	end

	return tab
end