--[[
	© 2016-2017 TeslaCloud Studios

	See license in LICENSE.txt.
--]]

do
	local cache = {}

	function util.GetTextSize(text, font, bNoCache)
		font = font or "default"

		if (!bNoCache and cache[text] and cache[text][font]) then
			local textSize = cache[text][font]

			return textSize[1], textSize[2]
		else
			surface.SetFont(font)

			local result = {surface.GetTextSize(text)}

			if (!bNoCache) then
				cache[text] = {}
				cache[text][font] = result
			end

			return result[1], result[2]
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