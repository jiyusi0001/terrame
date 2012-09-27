function State(attrTab)
	local cObj = TeState()
	if attrTab.id ~= nil then
		cObj:config(attrTab.id)
	else
                error("Error: Attribute 'id' is missing.", 2)
	end
	for i, ud in pairs(attrTab) do
		if type(ud) == "table" then cObj:add(ud.cObj_); end
		if type(ud) == "userdata" then cObj:add(ud); end
	end
	return cObj
end

