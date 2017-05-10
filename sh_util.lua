--[[
	© 2016-2017 TeslaCloud Studios

	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in all
	copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
	SOFTWARE.
--]]

-- Avoid name conflicts.
local _file, _player = file, player

-- A function to get lowercase type of an object.
function typeof(obj)
	return string.lower(type(obj))
end

-- A nicer wrapper for pcall.
function Try(id, func, ...)
	id = id or "Try"
	local result = {pcall(func, ...)}
	local success = result[1]
	table.remove(result, 1)

	if (!success) then
		ErrorNoHalt("[Try:"..id.."] Failed to run the function!\n")
		ErrorNoHalt(unpack(result), "\n")
	elseif (result[1] != nil) then
		return unpack[result]
	end
end

do
	local tryCache = {}

	-- An even nicer wrapper for pcall.
	function try(tab)
		tryCache = {}
		tryCache.f = tab[1]

		local args = {}

		for k, v in ipairs(tab) do
			if (k != 1) then
				table.insert(args, v)
			end
		end

		tryCache.args = args
	end

	function catch(handler)
		local func = tryCache.f
		local args = tryCache.args or {}
		local result = {pcall(func, unpack(args))}
		local success = result[1]
		table.remove(result, 1)

		tryCache = {}

		if (!success) then
			if (isfunction(handler[1])) then
				handler[1](unpack(result))
			else
				ErrorNoHalt("[Try:Exception] Failed to run the function!\n")
				ErrorNoHalt(unpack(result), "\n")
			end
		elseif (result[1] != nil) then
			return unpack[result]
		end
	end

	--[[
		Please note that the try-catch block will only
		run if you put in the catch function.

		Example usage:

		try {
			function()
				print("Hello World")
			end
		} catch {
			function(exception)
				print(exception)
			end
		}

		try {
			function(arg1, arg2)
				print(arg1, arg2)
			end, {"arg1", "arg2"}
		} catch {
			function(exception)
				print(exception)
			end
		}
	--]]
end

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

		return str:utf8sub(1, str:utf8len() - strNeedle:utf8len())
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

		return str:utf8sub(strNeedle:utf8len() + 1, str:utf8len())
	else
		return str
	end
end

-- A function to check whether all of the arguments in vararg are valid (via IsValid).
function util.Validate(...)
	local validate = {...}

	if (#validate <= 0) then return false end

	for k, v in ipairs(validate) do
		if (!IsValid(v)) then
			return false
		end
	end

	return true
end

-- A function to include a file based on it's prefix.
function util.Include(strFile)
	if (SERVER) then
		if (string.find(strFile, "sh_") or string.find(strFile, "shared.lua")) then
			AddCSLuaFile(strFile)

			return include(strFile)
		elseif (string.find(strFile, "cl_")) then
			AddCSLuaFile(strFile)
		elseif (string.find(strFile, "sv_") or string.find(strFile, "init.lua")) then
			return include(strFile)
		end
	else
		if (string.find(strFile, "sh_") or string.find(strFile, "cl_")
		or string.find(strFile, "shared.lua")) then
			return include(strFile)
		end
	end
end

-- A function to include all files in a directory.
function util.IncludeDirectory(strDirectory, strBase, bIsRecursive)
	if (isstring(strBase)) then
		if (!strBase:EndsWith("/")) then
			strBase = strBase.."/"
		end

		strDirectory = strBase..strDirectory
	end

	if (!strDirectory:EndsWith("/")) then
		strDirectory = strDirectory.."/"
	end

	if (bIsRecursive) then
		local files, folders = _file.Find(strDirectory.."*", "LUA", "namedesc")

		-- First include the files.
		for k, v in ipairs(files) do
			if (v:GetExtensionFromFilename() == "lua") then
				util.Include(strDirectory..v)
			end
		end

		-- Then include all directories.
		for k, v in ipairs(folders) do
			util.IncludeDirectory(strDirectory..v, bIsRecursive)
		end
	else
		local files, _ = _file.Find(strDirectory.."*.lua", "LUA", "namedesc")

		for k, v in ipairs(files) do
			util.Include(strDirectory..v)
		end
	end
end

do
	local materialCache = {}

	-- A function to get a material. It caches the material automatically.
	function util.GetMaterial(mat)
		if (!materialCache[mat]) then
			materialCache[mat] = Material(mat)
		end

		return materialCache[mat]
	end
end

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

-- A function to convert hexadecimal color to a color structure.
function util.HexToColor(hex)
	if (hex:StartWith("#")) then
		hex = hex:sub(2, hex:len())
	end

	if (hex:len() != 6 and hex:len() != 8) then
		return Color(255, 255, 255)
	end

	local hexColors = {}
	local initLen = hex:len() / 2

	for i = 1, hex:len() / 2 do
		table.insert(hexColors, hex:sub(1, 2))

		if (i != initLen) then
			hex = hex:sub(3, hex:len())
		end
	end

	local color = {}

	for k, v in ipairs(hexColors) do
		table.insert(color, util.HexToDecimal(v))
	end

	return Color(color[1], color[2], color[3], (color[4] or 255))
end

do
	local colors = {
		aliceblue 			= Color(240, 248, 255),
		antiquewhite 		= Color(250, 235, 215),
		aqua 				= Color(0, 255, 255),
		aquamarine 			= Color(127, 255, 212),
		azure		 		= Color(240, 255, 255),
		beige 				= Color(245, 245, 220),
		bisque 				= Color(255, 228, 196),
		black 				= Color(0, 0, 0),
		blanchedalmond 		= Color(255, 235, 205),
		blue 				= Color(0, 0, 255),
		blueviolet 			= Color(138, 43, 226),
		brown 				= Color(165, 42, 42),
		burlywood	 		= Color(222, 184, 135),
		cadetblue 			= Color(95, 158, 160),
		chartreuse 			= Color(127, 255, 0),
		chocolate 			= Color(210, 105, 30),
		coral				= Color(255, 127, 80),
		cornflowerblue 		= Color(100, 149, 237),
		cornsilk 			= Color(255, 248, 220),
		crimson 			= Color(220, 20, 60),
		cyan 				= Color(0, 255, 255),
		darkblue 			= Color(0, 0, 139),
		darkcyan 			= Color(0, 139, 139),
		darkgoldenrod 		= Color(184, 134, 11),
		darkgray 			= Color(169, 169, 169),
		darkgreen 			= Color(0, 100, 0),
		darkgrey 			= Color(169, 169, 169),
		darkkhaki 			= Color(189, 183, 107),
		darkmagenta 		= Color(139, 0, 139),
		darkolivegreen 		= Color(85, 107, 47),
		darkorange 			= Color(255, 140, 0),
		darkorchid 			= Color(153, 50, 204),
		darkred 			= Color(139, 0, 0),
		darksalmon 			= Color(233, 150, 122),
		darkseagreen 		= Color(143, 188, 143),
		darkslateblue 		= Color(72, 61, 139),
		darkslategray 		= Color(47, 79, 79),
		darkslategrey 		= Color(47, 79, 79),
		darkturquoise 		= Color(0, 206, 209),
		darkviolet 			= Color(148, 0, 211),
		deeppink 			= Color(255, 20, 147),
		deepskyblue 		= Color(0, 191, 255),
		dimgray 			= Color(105, 105, 105),
		dimgrey 			= Color(105, 105, 105),
		dodgerblue 			= Color(30, 144, 255),
		firebrick 			= Color(178, 34, 34),
		floralwhite 		= Color(255, 250, 240),
		forestgreen 		= Color(34, 139, 34),
		fuchsia 			= Color(255, 0, 255),
		gainsboro 			= Color(220, 220, 220),
		ghostwhite 			= Color(248, 248, 255),
		gold 				= Color(255, 215, 0),
		goldenrod 			= Color(218, 165, 32),
		gray 				= Color(128, 128, 128),
		grey 				= Color(128, 128, 128),
		green 				= Color(0, 128, 0),
		greenyellow 		= Color(173, 255, 47),
		honeydew 			= Color(240, 255, 240),
		hotpink 			= Color(255, 105, 180),
		indianred 			= Color(205, 92, 92),
		indigo 				= Color(75, 0, 130),
		ivory 				= Color(255, 255, 240),
		khaki 				= Color(240, 230, 140),
		lavender 			= Color(230, 230, 250),
		lavenderblush 		= Color(255, 240, 245),
		lawngreen 			= Color(124, 252, 0),
		lemonchiffon 		= Color(255, 250, 205),
		lightblue 			= Color(173, 216, 230),
		lightcoral 			= Color(240, 128, 128),
		lightcyan 			= Color(224, 255, 255),
		lightgoldenrodyellow = Color(250, 250, 210),
		lightgray 			= Color(211, 211, 211),
		lightgreen 			= Color(144, 238, 144),
		lightgrey 			= Color(211, 211, 211),
		lightpink 			= Color(255, 182, 193),
		lightsalmon 		= Color(255, 160, 122),
		lightseagreen 		= Color(32, 178, 170),
		lightskyblue 		= Color(135, 206, 250),
		lightslategray 		= Color(119, 136, 153),
		lightslategrey 		= Color(119, 136, 153),
		lightsteelblue 		= Color(176, 196, 222),
		lightyellow 		= Color(255, 255, 224),
		lime 				= Color(0, 255, 0),
		limegreen 			= Color(50, 205, 50),
		linen 				= Color(250, 240, 230),
		magenta 			= Color(255, 0, 255),
		maroon 				= Color(128, 0, 0),
		mediumaquamarine	= Color(102, 205, 170),
		mediumblue 			= Color(0, 0, 205),
		mediumorchid 		= Color(186, 85, 211),
		mediumpurple 		= Color(147, 112, 219),
		mediumseagreen 		= Color(60, 179, 113),
		mediumslateblue 	= Color(123, 104, 238),
		mediumspringgreen 	= Color(0, 250, 154),
		mediumturquoise 	= Color(72, 209, 204),
		mediumvioletred 	= Color(199, 21, 133),
		midnightblue 		= Color(25, 25, 112),
		mintcream 			= Color(245, 255, 250),
		mistyrose 			= Color(255, 228, 225),
		moccasin 			= Color(255, 228, 181),
		navajowhite 		= Color(255, 222, 173),
		navy			 	= Color(0, 0, 128),
		oldlace 			= Color(253, 245, 230),
		olive 				= Color(128, 128, 0),
		olivedrab 			= Color(107, 142, 35),
		orange 				= Color(255, 165, 0),
		orangered 			= Color(255, 69, 0),
		orchid 				= Color(218, 112, 214),
		palegoldenrod 		= Color(238, 232, 170),
		palegreen 			= Color(152, 251, 152),
		paleturquoise 		= Color(175, 238, 238),
		palevioletred 		= Color(219, 112, 147),
		papayawhip 			= Color(255, 239, 213),
		peachpuff 			= Color(255, 218, 185),
		peru 				= Color(205, 133, 63),
		pink 				= Color(255, 192, 203),
		plum 				= Color(221, 160, 221),
		powderblue 			= Color(176, 224, 230),
		purple 				= Color(128, 0, 128),
		red 				= Color(255, 0, 0),
		rosybrown 			= Color(188, 143, 143),
		royalblue 			= Color(65, 105, 225),
		saddlebrown 		= Color(139, 69, 19),
		salmon 				= Color(250, 128, 114),
		sandybrown 			= Color(244, 164, 96),
		seagreen 			= Color(46, 139, 87),
		seashell 			= Color(255, 245, 238),
		sienna 				= Color(160, 82, 45),
		silver 				= Color(192, 192, 192),
		skyblue 			= Color(135, 206, 235),
		slateblue 			= Color(106, 90, 205),
		slategray 			= Color(112, 128, 144),
		slategrey 			= Color(112, 128, 144),
		snow 				= Color(255, 250, 250),
		springgreen 		= Color(0, 255, 127),
		steelblue 			= Color(70, 130, 180),
		tan 				= Color(210, 180, 140),
		teal 				= Color(0, 128, 128),
		thistle				= Color(216, 191, 216),
		tomato 				= Color(255, 99, 71),
		turquoise 			= Color(64, 224, 208),
		violet 				= Color(238, 130, 238),
		wheat 				= Color(245, 222, 179),
		white 				= Color(255, 255, 255),
		whitesmoke 			= Color(245, 245, 245),
		yellow 				= Color(255, 255, 0),
		yellowgreen 		= Color(154, 205, 50)
	}

	local oldColor = util.oldColor or Color
	util.oldColor = oldColor

	function Color(r, g, b, a)
		if (isstring(r)) then
			if (r:StartWith("#")) then
				return util.HexToColor(r)
			elseif (colors[r:lower()]) then
				return colors[r:lower()]
			else
				return Color(255, 255, 255)
			end
		else
			return oldColor(r, g, b, a)
		end
	end
end

-- A function to do C-style formatted prints.
function printf(str, ...)
	print(Format(str, ...))
end

-- A function to select a random player.
function player.Random()
	local allPly = player.GetAll()

	if (#allPly > 0) then
		return allPly[math.random(1, #allPly)]
	end
end

-- A function to find player based on their name or steamID.
function player.Find(name, bCaseSensitive)
	if (name == nil) then return end
	if (!isstring(name)) then return (IsValid(name) and name) or nil; end

	for k, v in ipairs(_player.GetAll()) do
		if (v:Name(true):find(name)) then
			return v
		elseif (!bCaseSensitive and v:Name(true):utf8lower():find(name:utf8lower())) then
			return v
		elseif (v:SteamName():utf8lower():find(name:utf8lower())) then
			return v
		elseif (v:SteamID() == name) then
			return v
		end
	end
end

-- A function to check whether the string is full uppercase or not.
function string.IsUppercase(str)
	return string.utf8upper(str) == str
end

-- A function to check whether the string is full lowercase or not.
function string.IsLowercase(str)
	return string.utf8lower(str) == str
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

		table.insert(hits, {string.utf8sub(str, startPos, endPos), startPos, endPos})

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
		str = str:utf8lower()
		str = str:gsub(" ", "_")

		for k, v in ipairs(blockedChars) do
			str = str:Replace(v, "")
		end

		return str
	end
end

do
	local cache = {}

	function util.GetTextSize(text, font)
		font = font or "default"

		if (cache[text] and cache[text][font]) then
			local textSize = cache[text][font]

			return textSize[1], textSize[2]
		else
			surface.SetFont(font)

			cache[text] = {}
			cache[text][font] = {surface.GetTextSize(text)}

			return util.GetTextSize(text, font)
		end
	end
end

function util.GetTextWidth(text, font)
	return select(1, util.GetTextSize(text, font))
end

function util.GetTextHeight(text, font)
	return select(2, util.GetTextSize(text, font))
end

function util.GetFontSize(font)
	return util.GetTextSize("abg", font)
end

function util.GetFontHeight(font)
	return select(2, util.GetFontSize(font))
end

function util.GetPanelClass(panel)
	if (panel and panel.GetTable) then
		local pTable = panel:GetTable()

		if (pTable and pTable.ClassName) then
			return pTable.ClassName
		end
	end
end

-- Adjusts x, y to fit inside x2, y2 while keeping original aspect ratio.
function util.FitToAspect(x, y, x2, y2)
	local aspect = x / y

	if (x > x2) then
		x = x2
		y = x * aspect
	end

	if (y > y2) then
		y = y2
		x = y * aspect
	end

	return x, y
end

function util.ToBool(value)
	return (tonumber(value) == 1 or value == true or value == "true")
end

function util.CubicEaseIn(curStep, steps, from, to)
	return (to - from) * math.pow(curStep / steps, 3) + from
end

function util.CubicEaseOut(curStep, steps, from, to)
	return (to - from) * (math.pow(curStep / steps - 1, 3) + 1) + from
end

function util.CubicEaseInTable(steps, from, to)
	local result = {}

	for i = 1, steps do
		table.insert(result, util.CubicEaseIn(i, steps, from, to))
	end

	return result
end

function util.CubicEaseOutTable(steps, from, to)
	local result = {}

	for i = 1, steps do
		table.insert(result, util.CubicEaseOut(i, steps, from, to))
	end

	return result
end

function util.CubicEaseInOut(curStep, steps, from, to)
	if (curStep > (steps / 2)) then
		return util.CubicEaseOut(curStep - steps / 2, steps / 2, from, to)
	else
		return util.CubicEaseIn(curStep, steps, from, to)
	end
end

function util.CubicEaseInOutTable(steps, from, to)
	local result = {}

	for i = 1, steps do
		table.insert(result, util.CubicEaseInOut(i, steps, from, to))
	end

	return result
end

function util.WaitForEntity(entIndex, callback, delay, waitTime)
	local entity = Entity(entIndex)

	if (!IsValid(entity)) then
		local timerName = CurTime().."_EntWait"

		timer.Create(timerName, delay or 0, waitTime or 100, function()
			local entity = Entity(entIndex)

			if (IsValid(entity)) then
				callback(entity)

				timer.Remove(timerName)
			end
		end)
	else
		callback(entity)
	end
end

-- A function to determine whether vector from A to B intersects with a
-- vector from C to D.
function util.VectorsIntersect(vFrom, vTo, vFrom2, vTo2)
    local d1, d2, a1, a2, b1, b2, c1, c2

    a1 = vTo.y - vFrom.y
    b1 = vFrom.x - vTo.x
    c1 = (vTo.x * vFrom.y) - (vFrom.x * vTo.y)

    d1 = (a1 * vFrom2.x) + (b1 * vFrom2.y) + c1
    d2 = (a1 * vTo2.x) + (b1 * vTo2.y) + c1

    if (d1 > 0 and d2 > 0) then return false end
    if (d1 < 0 and d2 < 0) then return false end

    a2 = vTo2.y - vFrom2.y
    b2 = vFrom2.x - vTo2.x
    c2 = (vTo2.x * vFrom2.y) - (vFrom2.x * vTo2.y)

    d1 = (a2 * vFrom.x) + (b2 * vFrom.y) + c2
    d2 = (a2 * vTo.x) + (b2 * vTo.y) + c2

    if (d1 > 0 and d2 > 0) then return false end
    if (d1 < 0 and d2 < 0) then return false end

    -- Vectors are collinear or intersect.
    -- No need for further checks.
    return true
end

-- A function to determine whether a 2D point is inside of a 2D polygon.
function util.VectorIsInPoly(point, polyVertices)
	if (!isvector(point) or !istable(polyVertices) or !isvector(polyVertices[1])) then
		return
	end

	local intersections = 0

	for k, v in ipairs(polyVertices) do
		local nextVert

		if (k < #polyVertices) then
			nextVert = polyVertices[k + 1]
		elseif (k == #polyVertices) then
			nextVert = polyVertices[1]
		end

		if (nextVert and util.VectorsIntersect(point, Vector(99999, 99999, 0), v, nextVert)) then
			intersections = intersections + 1
		end
	end

	-- Check whether number of intersections is even or odd.
	-- If it's odd then the point is inside the polygon.
	if (intersections % 2 == 0) then
	    return false
	else
	    return true
	end
end

function table.SafeMerge(to, from)
	local oldIndex, oldIndex2 = to.__index, from.__index

	to.__index = nil
	from.__index = nil

	table.Merge(to, from)

	to.__index = oldIndex
	from.__index = oldIndex2
end

local colorMeta = FindMetaTable("Color")

function colorMeta:Darken(amt)
	return Color(
		math.Clamp(self.r - amt, 0, 255),
		math.Clamp(self.g - amt, 0, 255),
		math.Clamp(self.b - amt, 0, 255),
		self.a
	)
end

function colorMeta:Lighten(amt)
	return Color(
		math.Clamp(self.r + amt, 0, 255),
		math.Clamp(self.g + amt, 0, 255),
		math.Clamp(self.b + amt, 0, 255),
		self.a
	)
end