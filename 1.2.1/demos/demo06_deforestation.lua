-- AMAZONIA DEFORESTATION MODELS
-- (C) 2010 INPE AND UFOP


-- DBMS Type
-- 0 : mysql
-- 1 : msaccess
print(">> Database type: ")io.flush()
print("\t0 : MySQL")io.flush()
print("\t1 : MSAccess")io.flush()
dbms = tonumber(io.read())

if (dbms == 0) then 
	print(">> MySQL password: ")io.flush()
	pwd=io.read()
end

-- access database properties
                                                           
DB_HOME = TME_PATH .. "\\database"
DB_ACCESS = DB_HOME .."\\amazonia_".. TME_DB_VERSION .. ".mdb"

-------------------------------------------------------------------------------------------
-- yearly % of deforestation
demandByYear = {3, 3, 6, 7, 8, 4, 3, 3, 3, 3}
FINAL_TIME = 10
DEFORESTED = 1
FOREST 	   = 0
INPUT_PATH = TME_PATH.."\\database\\"

-------------------------------------------------------------------------------------------
deforLeg = Legend{
	colorBar = {
		{color = "green", value = FOREST},
		{color = "red", value = DEFORESTED}
	}
}

if (dbms == 0) then
	cs = CellularSpace{
		dbType = "mysql",
		host = "127.0.0.1",
		database = "amazonia",
		user = "root",
		password = pwd,
		theme = "dinamica",
		select = {"defor", "dist_urban_areas", "dist_roads"}
	}
else
	cs = CellularSpace{
		dbType = "ADO",
		database = DB_ACCESS,
		theme = "dinamica",
		select = {"defor", "dist_urban_areas", "dist_roads"}
			
	}		
end

forEachCell( cs, function(cell)
	if (cell.defor >= 0.5) then cell.defor = DEFORESTED else cell.defor = FOREST end
end)
cs:synchronize()

obs = Observer{
	subject = cs,
	attributes = {"defor"},
	legends = {deforLeg}
}
cs:notify()

-------------------------------------------------------------------------------------------
-- model execution
total_defor = 0
for time = 1, FINAL_TIME, 1 do
	demand = (demandByYear[ time ]/100) * #cs.cells

	t = Trajectory{
		target = cs,
		select = function(cell) return cell.defor < DEFORESTED end,
		--function( cell1, cell2) return cell1.dist_urban_areas < cell2.dist_urban_areas end
		--function( cell1, cell2) return cell1.dist_roads < cell2.dist_roads end
		greater = function(c1, c2)
			return c1.dist_urban_areas + c1.dist_roads < c2.dist_urban_areas + c2.dist_roads
		end
	}
	
	while (demand >= 1) do
		forEachCell(t, function(cell)
			if (demand >= 1) then
				cell.defor = DEFORESTED
				demand = demand - 1
				total_defor = total_defor + 1
			else
				return false
			end
		end)
	end
	cs:synchronize()
	cs:notify()
end

--PEDROO: erro nesta funcao. corrigir.
--cs:save(FINAL_TIME,"cobertura", {"defor"})
print(total_defor)

print("READY!")
print("Press <ENTER> to quit...")io.flush()	
io.read()
os.exit(0)
