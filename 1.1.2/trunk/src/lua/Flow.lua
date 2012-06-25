function Flow(attrTab)
	local cObj = TeFlow()
	local metaAttr = {rule = cObj}
	local metaTable = {__index = metaAttr}
	if type(attrTab[1]) ~= "function" then 
		error("The first flow condition attribute must be a function of the form\n      \"boolean = function(event, automaton, cell) end\"", 2)
	end
	setmetatable(attrTab, metaTable)
	cObj:setReference(attrTab)
	
	return cObj
end
