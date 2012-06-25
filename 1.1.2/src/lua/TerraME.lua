-------------------------------------------------------------------------------------------
--TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
--Copyright © 2001-2010 INPE and TerraLAB/UFOP.
--
--This code is part of the TerraME framework.
--This framework is free software; you can redistribute it and/or
--modify it under the terms of the GNU Lesser General Public
--License as published by the Free Software Foundation; either
--version 2.1 of the License, or (at your option) any later version.
--
--You should have received a copy of the GNU Lesser General Public
--License along with this library.
--
--The authors reassure the license terms regarding the warranties.
--They specifically disclaim any warranties, including, but not limited to,
--the implied warranties of merchantability and fitness for a particular purpose.
--The framework provided hereunder is on an "as is" basis, and the authors have no
--obligation to provide maintenance, support, updates, enhancements, or modifications.
--In no event shall INPE and TerraLAB / UFOP be held liable to any party for direct,
--indirect, special, incidental, or consequential damages arising out of the use
--of this library and its documentation.
--
-- Authors: 
--      Tiago Garcia de Senna Carneiro (tiago@dpi.inpe.br)
--      Rodrigo Reis Pereira
--      Antonio Jose da Cunha Rodrigues

-------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------
TME_FOLDER = os.getenv("TME_PATH_1_1_2")
if(TME_FOLDER == nil or TME_FOLDER == "") then
    error("TME_PATH_1_1_2 environment variable should exist and point to TerraME installation folder.", 2);
end

-- UTIL FUNCTIONS
-- case function

--@RODRIGO
-- used only in unity tests for now
function switch(c)
  local swtbl = {
    casevar = c,
    caseof = function (self, code)
      local f
      if (self.casevar) then
        f = code[self.casevar] or code.default
      else
        f = code.missing or code.default
      end
      if f then
        if type(f)=="function" then
          return f(self.casevar,self)
        else
          error("case "..tostring(self.casevar).." not a function")
        end
      end
    end
  }
  return swtbl
end

--@PEDRO
function switch1(c, att)
	local swtbl = {
		casevar = c[att], --## Pedro: existe alguma situacao no TerraME em que o valor 
		                  --## do switch nao seja um atributo de uma tabela?
		caseof = function (self, code)
			local f
			if (self.casevar) then
				f = code[self.casevar] or code.default
			else
				f = code.missing or code.default
			end
			if f then
				--## Pedro: aqui, se a funcao switch for de uso interno do TerraME e 
				--## todo switch tiver apenas funcoes, nao precisa fazer esta verificacao.
				if type(f) == "function" then
					return f(self.casevar,self)
				else
					error("case "..tostring(self.casevar).." not a function")
				end
			else
				local distance = string.len(self.casevar)
				local word
				table.foreach(code, function(a)
					local d = levenshtein(a, self.casevar) 
					if d < distance then
						distance = d
						word = a
					end
				end)
				if distance < string.len(self.casevar) * 0.6 then
					word = "'. Do you mean '"..word.."'?"
				else
					word = "'. It must be one of "
					table.foreach(code, function(a)
						word = word.."'"..a.."', "
					end)
					word = string.sub(word, 0, string.len(word)-2).."."
				end
				error("Invalid value for parameter "..att..": '"..self.casevar..word, 3)
			end
		end
	}
	return swtbl
end

--## ADICIONADO PEDRO
type__ = type

--## ADICIONADO PEDRO
type = function(data)
    local t = type__(data)
    if t == "table" then
        if data.type_ ~= nil then
            return data.type_
        else
            return "table"
        end
    else
        return t
    end
end


dofile(TME_FOLDER .. "//Lua//legend.lua")
dofile(TME_FOLDER .. "//Lua//observers.lua")
dofile(TME_FOLDER .. "//Lua//abm.lua")

-- end case function

-------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------
-- KERNEL'S COMPONENTS 

--SPACE MODELS-----------------------------------------------------------------------------
dofile(TME_FOLDER .. "//Lua//Coord.lua")
dofile(TME_FOLDER .. "//Lua//Cell.lua")
dofile(TME_FOLDER .. "//Lua//CellularSpace.lua")
dofile(TME_FOLDER .. "//Lua//Neighborhood.lua")
--------------------------

--TIME MODELS-------------------------------------------------------------------------------
--cont__ = 0
-- The constructor Event, differently of the others, does not return a table.
-- Instead, it returns a C++ object TeEvent. This makes sense since there is 
-- no meaning on the modeller's command: ev.time = 1. This because any attribute of
-- a Event is controled by the C++ simulation engine, including the attribute ev.time.   

dofile(TME_FOLDER .. "//Lua//Event.lua")
dofile(TME_FOLDER .. "//Lua//Action.lua")
dofile(TME_FOLDER .. "//Lua//Timer.lua")

--Behavior MODEL-------------------------------------------------------------------------------
dofile(TME_FOLDER .. "//Lua//Jump.lua")
dofile(TME_FOLDER .. "//Lua//Flow.lua")
dofile(TME_FOLDER .. "//Lua//State.lua")
dofile(TME_FOLDER .. "//Lua//Automaton.lua")
dofile(TME_FOLDER .. "//Lua//Agent.lua")

--Evironment MODEL-------------------------------------------------------------------------------
dofile(TME_FOLDER .. "//Lua//Environment.lua")

--Spatial Iterator MODEL-------------------------------------------------------------------------------
dofile(TME_FOLDER .. "//Lua//Trajectory.lua")

--Auxiliary constructors------------------------------------------------
dofile(TME_FOLDER .. "//Lua//Pair.lua")

--Utilities functions---------------------------------------------------
function index2coord(idx, xMax) 
	local term = math.floor((idx-1)/(xMax+1))
	local y =(idx-1) - xMax*term
	local x = term
	return x, y
end

function coord2index(x, y, xMax)
	return (y + 1) + x * xMax 
end

-- Implements the Euler (Euler-Cauchy) Method for integrate ordinary differential equations
-- Parameters: 
-- 	df, is the differential equantion,
--	initCond, is the initial condition which must be satisfied
--	[a,b[, is a close defined interval,
--	delta, is the step of the independent variable
function integrationEuler(df, initCond, a, b, delta)
	local i = 0
	local y = initCond
	local x = a
	local bb = b - delta
	for x = a, bb, delta do
		y = y + delta * df(x, y)
	end
	return y
end

-- Format time of CPU utilization in (days:hours:minutes:seconds)
function performanceTime(time)
	local string = ""
	if time > 0 then
		local secondsPerDay = (3600 * 24)


		local days = math.floor(time /secondsPerDay)
		if (days > 0) then string = string .. days .. ":"; end
		time = time - days * secondsPerDay

		local hours = math.floor(time / 3600)
		string = string .. hours .. ":"
		time = time - hours * 3600

		local minutes = math.floor(time / 60)
		string = string .. minutes .. ":"
		time = time - minutes * 60

		string = string..time
	end
	return string
end

-- Implements the Heun (Euler Second Order) Method for integrate ordinary differential equations
-- Method of type Predictor-Corrector
-- Parameters: 
-- 	df, is the differential equantion, 
--	initCond, is the initial condition which must be satisfied
--	[a,b[, is a close defined interval,
--	delta, is the step of the independent variable
function integrationHeun(df, initCond, a, b, delta)
	local i = 0
	local x = a
	local y = initCond
	local y1 = 0
	local val = 0
	local bb = b - delta
	for x = a, bb, delta do
		val = df(x, y)
		y1 = y + delta * val
		y = y + 0.5 * delta * (val + df(x + delta, y1))
	end
	return y
end

-- Implements the Runge-Kutta Method (Forth Order) for integrate ordinary differential equations
-- Parameters: 
--  df, is the differential equantion, 
--  initCond, is the initial condition which must be satisfied
--  [a,b[, is a close defined interval,
--  delta, is the step of the independent variable
function integrationRungeKutta(df, initCond, a, b, delta)
	local i = 0
	local x = a
	local y = initCond
	local y1 = 0
	local y2 = 0
	local y3 = 0
	local y4 = 0
	local bb = b - delta
	local midDelta = 0.5 * delta
	for x = a, bb, delta do
		y1 = df(x, y)
		y2 = df(x + midDelta, y + midDelta * y1)
		y3 = df(x + midDelta, y + midDelta * y2)
		y4 = df(x + delta, y + delta* y3)
		y = y + delta * (y1 + 2 * y2 + 2 * y3 + y4)/6
	end
	return y
end

-- Global constante to define the used integration method & step size
INTEGRATION_METHOD = integrationEuler
DELTA = 0.2

-- Constructor for an ordinary differential equation
function d(attrTab)
	local result = 0
	local delta = DELTA

	if attrTab == nil then attrTab = {}; end

	local sizeAttrTab = table.getn(attrTab)
	if sizeAttrTab < 4 then 
	    local str = "Error: bad arguments in diferential equation constructor \"d{arguments}\"\n"..
			" - the first attribute of a differential equantion must be a function which return a number,\n"..
			" - the second one must be the initial condition value,\n"..
			" - the third one must be the lower integration limit value,\n"..
			" - the fourth one must be the upper integration limit value, and\n"..
			" - the fifth, OPTIONAL, must be the integration incretement value(default = "..DELTA.." ).\n"..
			" - the fifth, OPTIONAL, must be the integration incretement value(default = "..DELTA.." ).\n"
		error(str, 2)
	end
	if sizeAttrTab == 5 then
		delta = attrTab[5]
	end
	return INTEGRATION_METHOD(attrTab[1], attrTab[2], attrTab[3], attrTab[4], delta)
end
