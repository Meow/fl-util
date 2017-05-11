--[[
	© 2016-2017 TeslaCloud Studios

	See license in LICENSE.txt.
--]]

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
		local files, folders = file.Find(strDirectory.."*", "LUA", "namedesc")

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
		local files, _ = file.Find(strDirectory.."*.lua", "LUA", "namedesc")

		for k, v in ipairs(files) do
			util.Include(strDirectory..v)
		end
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
		return unpack(result)
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
			return unpack(result)
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
			end, "arg1", "arg2"
		} catch {
			function(exception)
				print(exception)
			end
		}
	--]]
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

-- A function to do C-style formatted prints.
function printf(str, ...)
	print(Format(str, ...))
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

function util.ToBool(value)
	return (tonumber(value) == 1 or value == true or value == "true")
end