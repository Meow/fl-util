--[[
	© 2016-2017 TeslaCloud Studios

	See license in LICENSE.txt.
--]]

-- A function to select a random player.
function player.Random()
	local allPly = player.GetAll()

	if (#allPly > 0) then
		return allPly[math.random(1, #allPly)]
	end
end

-- A function to find player based on their name or steamID.
-- Returns playerObject if only one matching player was found.
-- Returns a table if multiple players were found.
function player.Find(name, bCaseSensitive, bReturnFirstHit)
	if (name == nil) then return end
	if (!isstring(name)) then return (IsValid(name) and name) or nil end

	local hits = {}

	for k, v in ipairs(player.GetAll()) do
		if (v:SteamID() == name) then
			table.insert(hits, v)
		elseif (v:Name():find(name)) then
			table.insert(hits, v)
		elseif (!bCaseSensitive and v:Name():lower():find(name:lower())) then
			table.insert(hits, v)
		end

		if (bReturnFirstHit and #hits > 0) then
			return hits[1]
		end
	end

	if (#hits > 1) then
		return hits
	else
		return hits[1]
	end
end