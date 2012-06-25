-------------------------------------------------------------------------------------------
-- TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
-- Copyright © 2001-2012 INPE and TerraLAB/UFOP -- www.terrame.org
--
--  Legend Objects for TerraME
--  Last change: April/2012
--
-- This code is part of the TerraME framework.
-- This framework is free software; you can redistribute it and/or
-- modify it under the terms of the GNU Lesser General Public
-- License as published by the Free Software Foundation; either
-- version 2.1 of the License, or (at your option) any later version.
--
-- You should have received a copy of the GNU Lesser General Public
-- License along with this library.
--
-- The authors reassure the license terms regarding the warranties.
-- They specifically disclaim any warranties, including, but not limited to,
-- the implied warranties of merchantability and fitness for a particular purpose.
-- The framework provided hereunder is on an "as is" basis, and the authors have no
-- obligation to provide maintenance, support, updates, enhancements, or modifications.
-- In no event shall INPE and TerraLAB / UFOP be held liable to any party for direct,
-- indirect, special, incidental, or consequential damages arising out of the use
-- of this library and its documentation.
--
-- Authors:
--      Antonio Jose da Cunha Rodrigues
--      Rodrigo Reis Pereira
--      Henrique Cota Camêllo

-- Colors --------------------------------------------------------------------------
TME_LEGEND_COLOR = {
	RED    	= {255, 0, 0},
	GREEN  	= {0, 255, 0},
	BLUE   	= {0, 0, 255},
	WHITE  	= {255, 255, 255},
	BLACK  	= {0, 0, 0},
	YELLOW 	= {255, 255, 0},
	BROWN  	= {128, 64, 64},
	CYAN   	= {0, 255, 255},
	GRAY   	= {200, 200, 200},
	MAGENTA = {255, 85, 255}
}

TME_LEGEND_COLOR_USER = {
	["red"]  	= TME_LEGEND_COLOR.RED,
	["green"]  = TME_LEGEND_COLOR.GREEN,
	["blue"]   = TME_LEGEND_COLOR.BLUE,
	["white"]  	= TME_LEGEND_COLOR.WHITE,
	["black"]  	= TME_LEGEND_COLOR.BLACK,
	["yellow"] 	= TME_LEGEND_COLOR.YELLOW,
	["brown"]  	= TME_LEGEND_COLOR.BROWN,
	["cyan"]   	= TME_LEGEND_COLOR.CYAN,
	["gray"]   	= TME_LEGEND_COLOR.GRAY,
	["magenta"] = TME_LEGEND_COLOR.MAGENTA
}

-- Data Types --------------------------------------------------------------------------
TME_LEGEND_TYPE = {
	BOOL		= 0,
	NUMBER		= 1,
	DATETIME 	= 2,
	TEXT		= 3
}

TME_LEGEND_TYPE_USER = {
	["bool"]		= TME_LEGEND_TYPE.BOOL,
	["number"]	= TME_LEGEND_TYPE.NUMBER,
	["datetime"] 	= TME_LEGEND_TYPE.DATETIME,
	["string"]		= TME_LEGEND_TYPE.TEXT
}


-- Groupping Types --------------------------------------------------------------------
TME_LEGEND_GROUPING = {
	EQUALSTEPS		= 0,
	QUANTIL			= 1,
	STDDEVIATION	= 2,
	UNIQUEVALUE 	= 3
}

TME_LEGEND_GROUPING_USER = {
	["equalsteps"]	= TME_LEGEND_GROUPING.EQUALSTEPS,
	["quantil"]		= TME_LEGEND_GROUPING.QUANTIL,
	["stddeviation"]	= TME_LEGEND_GROUPING.STDDEVIATION,
	["uniquevalue"] 	= TME_LEGEND_GROUPING.UNIQUEVALUE	
}

-- Standard Deviation Types -----------------------------------------------------------
TME_LEGEND_STDDEVIATION = {
	NONE		= -1,
	FULL		=  0,
	HALF		=  1,
	QUARTER		=  2
}

TME_LEGEND_STDDEVIATION_USER = {
	["none"]		= TME_LEGEND_STDDEVIATION.NONE,
	["full"]		=  TME_LEGEND_STDDEVIATION.FULL,
	["half"]		=  TME_LEGEND_STDDEVIATION.HALF,
	["quarter"]	=  TME_LEGEND_STDDEVIATION.QUARTER
}

----------------------------------------------------------------------------------------------
-- LEGEND CREATION FUNCTIONS
local DEF_TYPE = TME_LEGEND_TYPE.NUMBER;
local DEF_GROUP = TME_LEGEND_GROUPING.EQUALSTEPS;
local DEF_SLICES = 2;
local DEF_PRECISION = 4
local DEF_STD_DEV = TME_LEGEND_STDDEVIATION.NONE;
local DEF_MAX = 100;
local DEF_MIN = 0;
local DEF_COLOR = { {color = TME_LEGEND_COLOR.WHITE, value = DEF_MIN }, {color = TME_LEGEND_COLOR.BLACK, value = DEF_MAX }}
local DEF_STD_COLOR = { {color = TME_LEGEND_COLOR.BLACK, value = DEF_MIN }, {color = TME_LEGEND_COLOR.WHITE, value = DEF_MAX }}
local DEF_FONT = "Symbol";
local DEF_FONT_SIZE = 12;
local DEF_FONT_SYMBOL = "®"; -- equivale a seta na fonte symbol

local function defaultBasicLegend()
	attrTab = {}
	attrTab.type = DEF_TYPE;
	attrTab.groupingMode = DEF_GROUP;
	attrTab.slices = DEF_SLICES;
	attrTab.precision = DEF_PRECISION;
	attrTab.stdDeviation = DEF_STD_DEV;
	attrTab.maximum = DEF_MAX;
	attrTab.minimum = DEF_MIN;
	attrTab.colorBar = DEF_COLOR;
	attrTab.stdColorBar = DEF_STD_COLOR;
	attrTab.font = DEF_FONT;
	attrTab.fontSize = DEF_FONT_SIZE;
	attrTab.symbol = DEF_FONT_SYMBOL;
	return attrTab
end

---------------------------------------------------------------------------------------------------
--- Convert the colorBar for a string
-- Output format:
--   colorBar = color; value; label; distance;#color; value; label; distance;

function colorBarToString(colorBar)
	local str = ""

	if ( type(colorBar) ~= "table" ) then
		str = DEF_COLOR
		return str
	end

	-- Constants for separating values
	local COMP_COLOR_SEP = ","
	local ITEM_SEP = ";"
	local ITEM_NULL = "?"
	local COLORS_SEP = "#"

	for _,item in pairs(colorBar) do
		if (type(item.color) == "table") then
			if (#item.color == 3) or (#item.color == 4) then
				str = str .. item.color[1] .. COMP_COLOR_SEP
				.. item.color[2] .. COMP_COLOR_SEP
				.. item.color[3]

				if (item.color[4] ~= nil) then
					str = str .. COMP_COLOR_SEP .. item.color[4] .. COMP_COLOR_SEP
				end

				str = str .. ITEM_SEP
			else
				error("The color informed in the colorBar is invalid!", 3)
			end
		end

		-- value
		if (item.value ~= nil) then
			str = str .. tostring(item.value) .. ITEM_SEP
		else
			str = str .. ITEM_NULL .. ITEM_SEP
		end

		-- label
		if (item.label ~= nil and type(item.label) == "string") then
			str = str .. item.label .. ITEM_SEP
		elseif (item.value ~= nil) then
			local val = ""
			if(type(item.value) == "boolean") then
				val = 0
				if(item.value == true) then val=1 end
			else
				val = item.value
			end
			
			str = str .. val .. ITEM_SEP
		else
			str = str .. ITEM_NULL .. ITEM_SEP
		end

		-- distance
		if (item.distance ~= nil and type(item.distance == "number")) then
			str = str .. item.distance .. ITEM_SEP
		else
			str = str .. ITEM_NULL .. ITEM_SEP
		end
		str = str .. COLORS_SEP
	end
	return str
end

-- Separator for color bars
local COLORBAR_SEP = "|"

-- Creates a new Legend to be used with observers -----------------------------------------------------------------------------
function Legend( attrTab )
	if(attrTab == nil) then
		attrTab = defaultBasicLegend()
		return attrTab
	else
		-- conversion of string values from user layer
		if(type(attrTab["type"]) == "string") then
			attrTab["type"] = TME_LEGEND_TYPE_USER[attrTab["type"]]
		end
		
		if(type(attrTab["groupingMode"]) == "string") then
			attrTab["groupingMode"] = TME_LEGEND_GROUPING_USER[attrTab["groupingMode"]]
		end
				
		if(type(attrTab["stdDeviation"]) == "string") then
			attrTab["stdDeviation"] = TME_LEGEND_STDDEVIATION_USER[attrTab["stdDeviation"]]
		end	

		--###############################################
		-- LEGEND PRE-SETUP
		if(not attrTab["colorBar"] or (type(attrTab["colorBar"]) == "table" and #attrTab["colorBar"] == 0)) then
			attrTab["colorBar"] = nil
			attrTab["stdColorBar"] = nil
		end

		if(attrTab["stdColorBar"] and type(attrTab["stdColorBar"]) == "table" and #attrTab["stdColorBar"] == 0) then
			attrTab["stdColorBar"] = nil
		end
		--###############################################


		--###############################################
		-- LEGEND PARAMETERS SETUP
		-- colorBar setup
		if(attrTab["colorBar"] == nil) then
			if(attrTab["type"] ~= nil) then
				if(attrTab["type"] == TME_LEGEND_TYPE.NUMBER) then
					local max, min = nil
					if(attrTab["maximum"] ~= nil) then max = attrTab["maximum"] end
					if(attrTab["minimum"] ~= nil) then min = attrTab["minimum"] end
					if(max == nil) then max = DEF_MAX end
					if(min == nil) then min = DEF_MIN end						
					attrTab["colorBar"] = { {color = TME_LEGEND_COLOR.RED, value = min}, {color = TME_LEGEND_COLOR.BLACK, value = max} }
				end

				if(attrTab["type"] == TME_LEGEND_TYPE.BOOL) then				
					attrTab["colorBar"] = { {color = TME_LEGEND_COLOR.BLACK, value = false}, {color = TME_LEGEND_COLOR.WHITE, value = true} }
                    attrTab["maximum"] = 1
                    attrTab["minimum"] = 0
                    attrTab["groupingMode"] = 3
				end

                if(attrTab["type"] == TME_LEGEND_TYPE.TEXT) then				
					attrTab["colorBar"] = { {color = TME_LEGEND_COLOR.BLACK, value = "BLACK"}, {color = TME_LEGEND_COLOR.WHITE, value = "WHITE"} }
				end

                if(attrTab["type"] == TME_LEGEND_TYPE.DATETIME) then				
					attrTab["colorBar"] = { {color = TME_LEGEND_COLOR.BLACK, value = "2012-01-01 00:00:00"}, {color = TME_LEGEND_COLOR.WHITE, value = "2012-01-31 00:00:00"} }
				end
			else
				--print("NÃO CONSIGO INFERIR 'colorBar'")
			end
		else
			for i=1,#attrTab["colorBar"] do
				if(type(attrTab["colorBar"][i]["color"]) == "string") then
					attrTab["colorBar"][i]["color"] = TME_LEGEND_COLOR_USER[attrTab["colorBar"][i]["color"]]
				end
			end		
		end

		-- stdColorBar setup
		if ( attrTab["stdColorBar"] == nil ) then			
			if( attrTab["groupingMode"] == TME_LEGEND_GROUPING.STDDEVIATION ) then
				attrTab["stdColorBar"] = DEF_STD_COLOR
			end
		else
			for i=1,#attrTab["stdColorBar"] do
				if(type(attrTab["stdColorBar"][i]["color"]) == "string") then
					attrTab["stdColorBar"][i]["color"] = TME_LEGEND_COLOR_USER[attrTab["stdColorBar"][i]["color"]]
				end
			end				
		end

		-- maximum setup
		if(attrTab["maximum"] == nil) then
			if(attrTab["colorBar"] ~= nil) then
		
				local colorBarValues = {}
				local t = type(attrTab["colorBar"][1]["value"])
				if(t == "number") then
					for i=1,#attrTab["colorBar"] do
						table.insert(colorBarValues, attrTab["colorBar"][i]["value"])
					end
	
					if(#colorBarValues > 0 and type(colorBarValues[1]) == "number") then
						attrTab["maximum"] = math.max(unpack(colorBarValues))
					else
						--print("NÃO CONSIGO INFERIR 'maximum'")
						attrTab["maximum"] = DEF_MAX
					end
				else
					attrTab["maximum"] = DEF_MAX
				end
			else
				--print("NÃO CONSIGO INFERIR 'maximum'")
				attrTab["maximum"] = DEF_MAX
			end
		end

		-- minimum setup
		if(attrTab["minimum"] == nil) then
			if(attrTab["colorBar"] ~= nil) then
				local colorBarValues = {}
				for i=1,#attrTab["colorBar"] do
					table.insert(colorBarValues,attrTab["colorBar"][i]["value"])
				end

				if(#colorBarValues > 0 and type(colorBarValues[1]) == "number") then
					attrTab["minimum"] = math.min(unpack(colorBarValues))
				else
					--print("NÃO CONSIGO INFERIR 'minimum'")
					attrTab["minimum"] = DEF_MIN
				end
			else
				--print("NÃO CONSIGO INFERIR 'minimum'")
				attrTab["minimum"] = DEF_MIN
			end
		end

		-- type setup
		if(attrTab["type"] == nil) then
			if(attrTab["colorBar"] ~= nil) then
				local colorBarValues = {}
				--[[for i=1,#attrTab["colorBar"] do
					local strPrecision = ""
					if(type(attrTab["colorBar"][i]["value"]) == "number") then
						strPrecision = attrTab["colorBar"][i]["value"]
					else
						strPrecision = tostring(attrTab["colorBar"][i]["value"])
					end
					table.insert(colorBarValues, #strPrecision)
				end--]]
                for i=1,#attrTab["colorBar"] do
                    --print("===============",attrTab["colorBar"][i]["value"])
					table.insert(colorBarValues,attrTab["colorBar"][i]["value"])
				end
				local allSameType = true
				local theType = nil
				for i=1,#colorBarValues do
					if(theType == nil) then
						theType = type(colorBarValues[i])
					else
						if(type(colorBarValues[i]) ~= theType) then
							allSameType = false
							break
						end
					end
				end

				if(allSameType) then
					if(theType == "number") then attrTab["type"] = TME_LEGEND_TYPE.NUMBER end
					if(theType == "string") then attrTab["type"] = TME_LEGEND_TYPE.TEXT end
					if(theType == "boolean") then attrTab["type"] = TME_LEGEND_TYPE.BOOL end
					if(theType == "date") then attrTab["type"] = TME_LEGEND_TYPE.DATETIME end
				end
			end
			--print("NÃO CONSIGO INFERIR 'type'")
			attrTab["type"] = DEF_TYPE
		--else
		end

		-- stdDeviation setup
		if(attrTab["stdDeviation"] == nil) then
			--print("NÃO CONSIGO INFERIR 'stdDeviation'")
			attrTab["stdDeviation"] = DEF_STD_DEV
		end

		-- groupingMode setup
		if(attrTab["groupingMode"] == nil) then
			if((attrTab["colorBar"] ~= nil and #attrTab["colorBar"] > 2) or
			((attrTab["type"] ~= nil) and (attrTab["type"] == TME_LEGEND_TYPE.TEXT))) then
				attrTab["groupingMode"] = TME_LEGEND_GROUPING.UNIQUEVALUE
			end

			if(attrTab["stdColorBar"] ~= nil) then
				attrTab["groupingMode"] = TME_LEGEND_GROUPING.STDDEVIATION
			end

			if(attrTab["groupingMode"] == nil) then attrTab["groupingMode"] = DEF_GROUP end
		end

		-- slices setup
		if(attrTab["slices"] == nil) then
			if(attrTab["groupingMode"] == TME_LEGEND_GROUPING.UNIQUEVALUE) then
				if(attrTab["colorBar"] ~= nil) then attrTab["slices"] = #attrTab["colorBar"] end
            end
			if(attrTab["slices"] == nil) then
				attrTab["slices"] = DEF_SLICES
			end
		end

		-- precision setup
		if(attrTab["precision"] == nil) then
			if(attrTab["colorBar"] ~= nil) then
				local colorBarValues = {}
				local t = type(attrTab["colorBar"][1]["value"])
				if(t == "number") then
					for i=1,#attrTab["colorBar"] do
						table.insert(colorBarValues,attrTab["colorBar"][i]["value"])
					end
	
					-- find max precision using colorBar values
					local precisions = {}				
					for i=1,#colorBarValues do
						local strValue = "".. colorBarValues[i]
						local beginI,endI = string.find(strValue, "%.")
	
						if(beginI ~= nil) then
							local subStrValue = string.sub(strValue,beginI+1)
							table.insert(precisions,#subStrValue)
						end 
					end
					if (#precisions > 0) then
						attrTab["precision"] = math.max(unpack(precisions))
					else
						attrTab["precision"] = DEF_PRECISION
					end
				else
					attrTab["precision"] = DEF_PRECISION	
				end				
			else
				attrTab["precision"] = DEF_PRECISION
			end
		end

		-- font setup
		if(attrTab["font"] == nil) then
			attrTab["font"] = DEF_FONT
		end

		-- fontSize setup
		if(attrTab["fontSize"] == nil) then
			attrTab["fontSize"] = DEF_FONT_SIZE
		end

		-- symbol setup
		if(attrTab["symbol"] == nil) then
			attrTab["symbol"] = DEF_FONT_SYMBOL
		end

		--###############################################
		-- colorBar and stdColorBar setup complement
		if ( type(attrTab.colorBar) == "table" ) then
			attrTab.colorBar = colorBarToString(attrTab.colorBar);
		else
			-- Verificar
			print("colorBar: Expected a type table, found a ".. type(attrTab.colorBar) .. ". Using default color bar.");
			attrTab.colorBar = colorBarToString(DEF_COLOR)
		end

		if(attrTab["stdColorBar"]) then						
			if ( type(attrTab.stdColorBar) == "table") then
				if (#attrTab.stdColorBar > 2) then
					attrTab.stdColorBar = colorBarToString(attrTab.stdColorBar)
				else
					-- Verificar
					if (QUIET_MODE) then
						print("stdColorBar is incomplete!")
					end
				end
			elseif(type(attrTab["stdColorBar"]) ~= "string") then			
				error("stdColorBar: Expected a type table not a ".. type(attrTab.stdColorBar), 2)
			end
			attrTab.colorBar = attrTab["colorBar"] .. COLORBAR_SEP .. attrTab["stdColorBar"]
			-- it is not necessary to keep 'stdColorBar' as it is attached to 'colorBar'
			attrTab.stdColorBar = nil
		end			
		--###############################################		

		--###############################################
		-- LEGEND OPTIMIZATION
		-- TODO
		--###############################################
	end
	return attrTab;
end