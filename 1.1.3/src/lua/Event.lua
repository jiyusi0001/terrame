function Event(attrTab)
	local cObj = TeEvent()

	if attrTab.message ~= nil then error("Error: Parameter 'message' is deprecated, use 'action' instead.", 2) end

	if attrTab.time     == nil then attrTab.time     = 1 end
	if attrTab.period   == nil then attrTab.period   = 1 end
	if attrTab.priority == nil then attrTab.priority = 0 end

	cObj:config(attrTab.time, attrTab.period, attrTab.priority)
	cObj:setReference(cObj)

	if attrTab.action ~= nil then
		targettype = type(attrTab.action)
		if targettype == "function" then
			return Pair{cObj, Action{attrTab.action}}
		elseif targettype == "Society" then
			local func = function(event)
				attrTab.action:execute(event)
				attrTab.action:synchronize(event:getPeriod())
			end
			return Pair{cObj, Action{func}}
		elseif targettype == "Cell" then
			local func = function(event)
				attrTab.action:notify(event:getTime())
			end
			return Pair{cObj, Action{func}}
		elseif targettype == "CellularSpace" then
			local func = function(event)
				attrTab.action:synchronize()
				attrTab.action:notify(event:getTime())
			end
			return Pair{cObj, Action{func}}
		elseif targettype == "Agent" or targettype == "Automaton" then
			local func = function(event)
				attrTab.action:execute(event)
				--attrTab.target:synchronize() 
				--attrTab.target:notify(event:getTime())
				--TODO PEDRO: colocar o notify aqui!!
			end
			return Pair{cObj, Action{func}}
		elseif targettype == "Group" or targettype == "Trajectory" then
			local func = function(event)
				attrTab.action:rebuild()
			end
			return Pair{cObj, Action{func}}
		else
			error("Error: Unknown type: "..targettype, 2)
		end
	else
		return cObj
	end
end

