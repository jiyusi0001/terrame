function Event( attrTab )
    local cObj = TeEvent()

    if attrTab.time   == nil then attrTab.time   = cObj:getTime() end
    if attrTab.period == nil then attrTab.period = cObj:getPeriod() end
    if attrTab.priority == nil then attrTab.priority = cObj:getPriority() end
    --print(cont__, attrTab.time, attrTab.period, attrTab.priority)

    cObj:config(attrTab.time, attrTab.period, attrTab.priority)

    cObj:setReference(cObj);

    if attrTab.action ~= nil then
        return Pair{cObj, Action{attrTab.action}}
    else
        return cObj
    end
end
