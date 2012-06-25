function Jump(attrTab)
	local cObj = TeJump()
	local metaAttr = {rule = cObj}
	local metaTable = {__index = metaAttr}
	if type(attrTab[1]) == "function" then
		if attrTab.target ~= nil then cObj:setTargetControlModeName(attrTab.target)
		else error("Target State was not defined!", 2); end
	else 
		error("The first jump condition attribute must be a function of the form\n       \"boolean = function(event, automaton, cell) end\"", 2)
	end
	setmetatable(attrTab, metaTable)
	cObj:setReference(attrTab)
	return cObj
end
