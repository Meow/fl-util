--[[
	© 2016-2017 TeslaCloud Studios

	See license in LICENSE.txt.
--]]

-- A function to 'flatten' a numeric-indexed table (eliminate all tables-inside-tables).
function table.Flatten(tTable, tResult)
    local result = tResult or {}

    for k, v in ipairs(tTable) do
    	if (istable(v)) then
    		result = table.Flatten(v, result)
    	else
    		table.insert(result, v)
    	end
    end

	return result
end