-- AMAZONIA DEFORESTATION MODELS
-- (C) 2010 INPE AND UFOP

TME_PATH_1_1_2 = os.getenv("TME_PATH_1_1_2");

-- DBMS Type
-- 0 : mysql
-- 1 : msaccess
if(not dbms) then
	print("-- DBMS Type")
	print("-- 0 : mysql")
	print("-- 1 : msaccess")
	print("Please, enter database type: ")
  	dbms = tonumber(io.read())
end

if (not pwd) then 
  print("Please, enter database password: ")
  pwd=io.read()
end

-- access database properties
DB_VERSION = "4_2_0"
DB_HOME = TME_PATH_1_1_2 .. "\\database"
DB_ACCESS = DB_HOME .."\\amazonia_".. DB_VERSION .. ".mdb"

-------------------------------------------------------------------------------------------
-- yearly % of deforestation
demandByYear = { 3, 3, 6, 7, 8, 4, 3, 3, 3, 3}
FINAL_TIME = 10
DEFORESTED = 1
FOREST 	   = 0
INPUT_PATH = TME_PATH_1_1_2.."\\database\\"

-------------------------------------------------------------------------------------------

-- Create a legend for Observer Map
deforLeg = Legend(
	{
		type = "number",
		groupingMode = "uniquevalue",
		slices = 3,
		precision = 5,
		stdDeviation = "none",
		maximum = DEFORESTED,
		minimum = FOREST,
		colorBar = {
			{
				color = "green", 
				value = FOREST
			},
			{
				color = "red", 
				value = DEFORESTED
			}
		},
		stdColorBar = {}
	}
);	

-- define and load the cellular space
cs = nil
if(dbms == 0) then
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
cs:load();

forEachCell( cs, function(cell)
	if( cell.defor >= 0.5) then cell.defor = DEFORESTED else cell.defor = FOREST end
end)
cs:synchronize()


-- Create a Observer Map
obs = Observer{ subject = cs, type = "map", attributes={"defor"},legends= {deforLeg} }
cs:notify()

-------------------------------------------------------------------------------------------
-- model execution
total_defor = 0;
for time = 1, FINAL_TIME, 1 do
	demand = (demandByYear[ time ]/100) * #cs.cells;

	t = Trajectory{
		target = cs,
		select = function( cell ) return cell.defor < DEFORESTED	end,
		--function( cell1, cell2) return cell1.dist_urban_areas < cell2.dist_urban_areas end
		--function( cell1, cell2) return cell1.dist_roads < cell2.dist_roads end
		sort = function(c1, c2)
			return 
				(0.5* c1.dist_urban_areas + 0.5 * c1.dist_roads) 
				< 
				(0.5* c2.dist_urban_areas + 0.5 * c2.dist_roads);
		end
	}
	
	while (demand >= 1) do
			forEachCell(
				t, 
				--cs,
				function(cell)
					if( demand >= 1)then 
						cell.defor = DEFORESTED;
						demand = demand - 1;
						total_defor = total_defor + 1;
					else
						return false;
					end
					return true;
				end
			);
	end
	cs:synchronize();

	cs:notify()
end

cs:save(FINAL_TIME,"cobertura", {"defor"})
print(total_defor);

print("READY!")
io.flush()
