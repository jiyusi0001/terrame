-------------------------------------------------------------------------------
--- Classe XDebug
-- @description Classe responsável por depurar objetos em Lua
----------------------------------

----------------------------------
-- Uso
--dofile("XDebug.lua")



function trace(event, line)
    local s = debug.getinfo(2).short_src
    print(s .. ": " .. line)
	io.flush()
end

--debug.sethook(trace, "l")

-- util function
function delay(delay_)
   delay_ = delay_ or 1
   local time_to = os.time() + delay_
   while os.time() < time_to do end
end


-------------------------------------------------------------------------------
--- Método de depuração imprime "qualquer" tipo de estrutura
-- de dados em Lua
--
-- @release Copiado do livro Lua Programming Gems pág: 31
-- 
-- @param value valor
-- @param depth profundidade
-- @param key chave
strdump = ""
function vardump(value, depth, key)
	local linePrefix = ""
	local spaces = ""
	
	if (key ~= nil) then
		linePrefix = "["..key.."] = "
	end
	
	if (depth == nil) then
		depth = 0
	else
		depth = depth + 1
		for i = 1, depth do
			spaces = spaces .. "  "
		end
	end
	
	if (type(value) == 'table') then
		mTable = getmetatable(value)
		if (mTable == nil) then
			print(spaces .. linePrefix.. "(table) ")
			strdump = strdump .. spaces .. linePrefix.. "(table)\n"
		else 
			print(spaces.. "(metatable) ")
			value = mTable
			strdump = strdump .. spaces.. "(metatable)\n"
		end
		for tableKey, tableValue in pairs(value) do
			vardump(tableValue, depth, tableKey)
		end
	elseif ((type(value) == 'function') or (type(value) == 'thread')
		or (type(value) == 'userdata') or (type(value) == nil))	then
		print(spaces ..tostring(value))
		strdump = strdump .. spaces ..tostring(value) .."\n"
	else 
		print(spaces..linePrefix.."("..type(value)..") "..tostring(value))
		strdump = strdump .. spaces..linePrefix.."("..type(value)..") "..tostring(value).."\n"
	end
	io.flush()
	return strdump
end

