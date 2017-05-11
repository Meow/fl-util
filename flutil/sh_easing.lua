--[[
	© 2016-2017 TeslaCloud Studios

	See license in LICENSE.txt.
--]]

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