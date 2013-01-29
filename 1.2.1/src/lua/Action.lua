function Action(attrTab)
	local cObj = TeMessage()
	local metaAttr = {cObj_ = cObj}
	local metaTable = {__index = metaAttr}
	if (attrTab.id ~= nil) then cObj:config(attrTab.id) end
	setmetatable(attrTab, metaTable)
	cObj:setReference(attrTab)
	return attrTab
end

