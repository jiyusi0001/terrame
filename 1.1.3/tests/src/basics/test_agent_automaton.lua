-------------------------------------------------------------------------------------------
--TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
--Copyright © 2001-2007 INPE and TerraLAB/UFOP.
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
-- Author: Tiago Garcia de Senna Carneiro (tiago@dpi.inpe.br)
-------------------------------------------------------------------------------------------
-- Expected result: 9 teste, 76 assertations, (9 passed, 0 failed, 0 erros)
-- 
--  In the DEBUG mode the tests result change. Maybe due to the different compiler optimization 
--  settings, the (/02) flag is incompatible with the DEBUG mode (/Zi). In the DEBUG mode, 
--  the optimization is disabled (/Od).  
--  Expected result: 10 teste, 76 assertations, (9 passed, 0 failed, 0 erros, 1 skipped)
-- 
arg = "nada"
pcall(require, "luacov")    --measure code coverage, if luacov is present
dofile (TME_PATH.."/bin/lunatest.lua")
dofile (TME_PATH.."/tests/run/run_util.lua")

function test_AgentBasics()

	print("--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=") io.flush()
	if (SKIPS[1]) then
		skip("No testing...") io.flush()
	end
	print("Testing Agent, Jump, Flow, and State...") io.flush() 


	a = Agent{
		x = 3,
		State{
			id="stop",
			Jump{ function(ev, self)
					if self.x > 5 then 
						print(">>>JUMP"); io.flush()
						assert_equal(6, self.x)
						assert_equal(3, ev:getTime())
						assert_equal(0, self:getLatency())
						return true 
					end
				end,
				target = "go"},
			Flow{ function(ev, self)
					self.x = self.x + 1
					print("stop: "..self.x.." -> "..self:getLatency().."  "..ev:getTime()) io.flush() 
				end}
		},
		State{
			id="go",
			Jump{ function(ev, self)
					if self.x < 3 then 
						print(">>>JUMP"); io.flush() 
						assert_equal(7, ev:getTime())
						assert_equal(2, self.x)					
						assert_equal(3, self:getLatency() )
						return true 
					end
				end,
				target = "stop"},
			Jump{ function(ev, self)
					print("ANOTHER JUMP") io.flush()
					return false
				end,
				target = "stop"},
			Flow{ function(ev, self)
					self.x = self.x - 1
					print("go: "..self.x.." -> "..self:getLatency()) io.flush() 
				end},
			Flow{ function(ev, self)
					print("ANOTHER FLOW") io.flush() 
				end}
		}
	}

	print "add" io.flush() 
	a:add(State{
		id="new",
		Jump{ function()
				return false
			end,
			target = "stop"},
		Flow{ function()
				print("new")
			end}
	})
	print "add" io.flush() 
	a:add(2)
	print("LATENCY: "..a:getLatency()) io.flush() 
	assert_equal(0, a:getLatency()) 

	print("BUILD:") io.flush() 
	a:build()
	print("\nEND BUILD:") io.flush() 
	assert_true(true)

	print("STATE: "..a:getStateName()) io.flush() 
	assert_equal("stop", a:getStateName())

	print("::EXECUTE") io.flush() 
	a:execute(Event{time = 1})
	print("::EXECUTE") io.flush() 
	assert_equal(0,a:getLatency() )
	assert_equal(4,a.x)


	t = Timer{
		Event{time = 1, period = 1, action = function(ev)
				print("TIME: ".. ev:getTime()) io.flush() 
				a:execute(ev)
			end}
	}

	t:execute(10)

	assert_equal( 11, t:getTime())
	assert_equal( 6, a.x )
	assert_equal( 7, a:getLatency())


	--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=
	print("...End of Agent, Jump, Flow, and State")  io.flush() 
	--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=


	print("Please, press <ENTER> to quit...") io.flush() 
	assert_true(true)
end


-- Create an Agent and an Automaton: what is the current state?
function test_CreatesAgentAndAutomatonAndAskWhereTheyAre()

	if (SKIPS[2]) then
		skip("No testing...") io.flush() -- 3 assertion
	end

	print("----------------------------------------------");
	print("-- CreatesAgentAndAutomatonAndAskWhereTheyAre ");
	print("----------------------------------------------");


	ag1 = Agent{

		id = "MyAgent",

		State{
			id = "first"
		},

		State{
			id = "second"
		}
	}

	at1 = Automaton{

		id = "MyAutomaton",

		State{
			id = "first"
		},

		State{
			id = "second"
		}
	}

	print( "Automaton: "); io.flush()
	print( at1.id..", ".. at1:getLatency() ); io.flush()
	print( at1:getStateName()); io.flush()
	print(); io.flush()
	print( "Agent: "); io.flush()
	print( ag1.id..", ".. ag1:getLatency() ); io.flush()
	print( ag1:getStateName()); io.flush()
	print(); io.flush()

	-- "In what cell?" - asks the Automaton!
	-- Automata should be inside an Environment since is may be in differentes states in different cells. 
	assert_equal("Where?", at1:getStateName() )
	-- The agent has a global state inside the Environment. Its internal states doesn't depend on the 
	-- where the rules run. It should be in first state inserted in its state machine, the "first" state.
	assert_equal("first", ag1:getStateName() );

	print("READY!!!")
	assert_true( true )
end


-- Jump among Automaton and Agent's states: Automanton should be inserted in a Environment to work properly
function test_AgentAndAutomatonJumpConditions()

	if (SKIPS[3]) then
		skip("No testing...") io.flush()
	end

	print("-------------------------------------");
	print("-- AgentAndAutomatonJumpConditions ");
	print("-------------------------------------");


	ag1 = Agent{

		id = "MyAgent",

		cont  = 0,

		State{
			id = "first",
			Jump{
				function( event, agent, cell )
					if (agent.cont < 10) then 
						agent.cont = agent.cont + 1;
						print("Fst: "..agent.id..": "..agent.cont);
						return true
					end
					return false
				end,
				target = "second"
			}
		},

		State{
			id = "second",
			Jump{
				function( event, agent, cell )
					if (agent.cont < 10) then 
						agent.cont = agent.cont + 1;
						print("Scd: "..agent.id..": "..agent.cont);
						return true
					end
					return false
				end, 
				target = "first"
			}
		}
	}

	at1 = Automaton{

		id = "MyAutomaton",

		cont  = 0,

		State{
			id = "first",
			Jump{
				function( event, agent, cell )
					agent.cont = agent.cont + 1;
					if (agent.cont < 10) then 
						agent.cont = agent.cont + 1;
						print("Fst: "..agent.id..": "..agent.cont);
						return true
					end
					return false
				end,
				target = "second"
			}
		},

		State{
			id = "second",
			Jump{
				function( event, agent, cell )
					agent.cont = agent.cont + 1;
					if (agent.cont < 10) then 
						agent.cont = agent.cont + 1;
						print("Scd: "..agent.id..": "..agent.cont);
						return true
					end
					return false
				end, 
				target = "first"
			}
		}
	}

	print( "Automaton... ");
	ev = Event{ time = 0 }
	at1:execute(ev);
	print("Automaton working but not inserted in an Environment object!") io.flush()
	print();
	assert_equal(0, at1.cont)


	print( "Agent... ");
	ev = Event{ time = 0 }
	ag1:execute(ev);
	print();
	assert_equal(10, ag1.cont)
end

-- Jump into not declared states: Automaton and Agent crashes
function test_NotDeclaredStates( )

	if (SKIPS[4]) then
		skip("No testing...") io.flush() --  1 assert
	end

	print("-------------------------------------");
	print("-- NotDeclaredStates");
	print("-------------------------------------");
	print(">>>>>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<<<<<<");
	print(">> ATENTION: this test must be ran alone.      <<");
	print(">> Please, skip it to run the other tests.     <<");
	print(">> This test should cause a crash in TerraME.  <<");
	print(">>>>>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<<<<<<");

	print("\nAgent...")  io.flush()
	ag1 = Agent{

		id = "MyAgent",

		cont  = 0,

		State{
			id = "first",
			Jump{
				function( event, agent, cell )
					if (agent.cont < 10) then 
						agent.cont = agent.cont + 1;
						print(agent.id..": "..agent.cont);
						return true
					end
					return false
				end,
				target = "nao existe"
			}
		},

		State{
			id = "second",
			Jump{
				function( event, agent, cell )
					if (agent.cont < 10) then 
						agent.cont = agent.cont + 1;
						print(agent.id..": "..agent.cont);
						return true
					end
					return false
				end, 
				target = "first"
			}
		}
	}

	print("\n\nAutomaton...")  io.flush()
	at1 = Automaton{

		id = "MyAutomaton",

		cont  = 0,

		State{
			id = "first",
			Jump{
				function( event, agent, cell )
					if (agent.cont < 10) then 
						agent.cont = agent.cont + 1;
						print(agent.id..": "..agent.cont);
						return true
					end
					return false
				end,
				target = "nao existe"
			}
		},

		State{
			id = "second",
			Jump{
				function( event, agent, cell )
					if (agent.cont < 10) then 
						agent.cont = agent.cont + 1;
						print(agent.id..": "..agent.cont);
						return true
					end
					return false
				end, 
				target = "first"
			}
		}
	}

	ev = Event{ time = 0 }
	io.flush();
	--at1:execute(ev);
	print();


	ev = Event{ time = 0 }
	io.flush();
	--ag1:execute(ev);
	print();

	print("READY!!!")
	assert_false(true)
end


-- An Automaton does not run anywhere, it should be inserted in a Environment and  at least a  Trajectory should be define for it
-- As well, a Agent with no Trajectories does not execute in any cell. Therefore, the "cell" parameter in "jump" and "flow" rules are "nil".
function test_AgentAndAutomatonTrajectories() -- Action Regions!!! 

	if (SKIPS[5]) then
		skip("No testing...") io.flush() --  17 assert
	end

	print("-------------------------------------");
	print("-- AgentAndAutomatonTrajectories");
	print("-------------------------------------");

	cs = CellularSpace{ xdim = 2 }

	forEachCell( cs, 
	function( cell) cell.soilType = 0 
	end )

	contCell = 0
	forEachCell( cs, function(cell, idx) 
		contCell = contCell + 1
		--print( "Cell["..idx.."]: "..cell.soilType ); 
		assert_equal(cell.soilType,0)
	end );
	assert_equal( contCell, 4 )

	print( "Agent... ");

	ag1 = Agent{

		id = "MyAgent",

		cont  = 0,

		State{
			id = "first",
			Jump{
				function( event, agent, cell )
					if (agent.cont < 10) then 
						agent.cont = agent.cont + 1;
						-- print(agent.id..": "..agent.cont);
						-- print( cell );
						assert_nil(cell)
						return true
					end
					return false
				end,
				target = "second"
			}
		},

		State{
			id = "second",
			Jump{
				function( event, agent, cell )
					if (agent.cont < 10) then 
						agent.cont = agent.cont + 1;
						-- print(agent.id..": "..agent.cont);
						-- print( cell );
						assert_nil(cell)
						return true
					end
					return false
				end, 
				target = "first"
			}
		}
	}

	print( "Automaton... ") io.flush()

	at1 = Automaton{

		id = "MyAutomaton",

		cont  = 0,

		State{
			id = "first",
			Jump{
				function( event, agent, cell )
					if (agent.cont < 10) then 
						agent.cont = agent.cont + 1;
						print(agent.id..": "..agent.cont);
						return true
					end
					return false
				end,
				target = "second"
			}
		},

		State{
			id = "second",
			Jump{
				function( event, agent, cell )
					if (agent.cont < 10) then 
						agent.cont = agent.cont + 1;
						print(agent.id..": "..agent.cont);
						return true
					end
					return false
				end, 
				target = "first"
			}
		}
	}


	env = Environment{ 
		id = "MyEnvironment"
	}
	-- insert CellularSpaces before Automata and Agents
	env:add( cs );
	env:add( at1 );
	ev = Event{ time = 0 }
	at1:execute(ev);
	print();
	assert_equal( at1.cont, 0 )

	ev = Event{ time = 0 }
	ag1:execute(ev);
	print();
	assert_equal( ag1.cont, 10 )

end 

-- Automata and Agents working
function test_AutomataAndAgentsworking()

	if (SKIPS[6]) then
		skip("No testing...") io.flush() --  8 assert
	end

	print("-------------------------------------");
	print("-- AutomataAndAgentsworking");
	print("-------------------------------------");

	cellCont = 0
	assert_equal(cellCont,0)
	cs = CellularSpace{ xdim = 2}
	forEachCell( cs, function( cell) 
		cell.soilType = 0 
		cellCont = cellCont + 1
	end )
	assert_equal(cellCont, 4)

	forEachCell( cs, function( cell, idx) 
		--print( "Cell["..idx.."]: "..cell.soilType ); 
		assert_equal(cell.soilType, 0)
	end );

	cont = 0 

	print( "Agent... "); io.flush()
	ag1 = Agent{

		id = "MyAgent",

		it = Trajectory{
			target = cs
		},

		cont  = 0,

		State{
			id = "first",
			Jump{
				function( event, agent, cell )
					cont = cont + 1
					if (agent.cont < 10) then 
						agent.cont = agent.cont + 1;
						--print(agent.id..": "..agent.cont.." - cell["..cell.x..", "..cell.y.."]");
						return true
					end
					if( agent.cont == 10 ) then agent.cont = 0 end
					return false
				end,
				target = "second"
			}
		},

		State{
			id = "second",
			Jump{
				function( event, agent, cell )
					cont = cont + 1
					if (agent.cont < 10) then 
						agent.cont = agent.cont + 1;
						--print(agent.id..": "..agent.cont.." - cell["..cell.x..", "..cell.y.."]");
						return true
					end
					if( agent.cont == 10 ) then agent.cont = 0 end
					return false
				end, 
				target = "first"
			}
		}
	}

	print( "Automaton... ") io.flush()

	at1 = Automaton{

		id = "MyAutomaton",

		it = Trajectory{
			target = cs
		},

		cont  = 0,

		State{
			id = "first",
			Jump{
				function( event, agent, cell )
					cont = cont + 1
					if (agent.cont < 10) then 
						agent.cont = agent.cont + 1;
						--print(agent.id..": "..agent.cont.." - cell["..cell.x..", "..cell.y.."]");
						return true
					end
					if( agent.cont == 10 ) then agent.cont = 0 end
					return false
				end,
				target = "second"
			}
		},

		State{
			id = "second",
			Jump{
				function( event, agent, cell )
					cont = cont + 1
					if (agent.cont < 10) then 
						agent.cont = agent.cont + 1;
						--print(agent.id..": "..agent.cont.." - cell["..cell.x..", "..cell.y.."]");
						return true
					end
					if( agent.cont == 10 ) then agent.cont = 0 end
					return false
				end, 
				target = "first"
			}
		}
	}

	env = Environment{ 
		id = "MyEnvironment"
	}
	env:add( cs );
	env:add( at1 );
	ev = Event{ time = 0 }
	-- Automaton:setTrajectoryStatus( false ) turns an Automaton off
	at1:setTrajectoryStatus( true );
	at1:execute(ev);
	print("Automaton count: ", cont);
	assert_equal(44, cont)

	ev = Event{ time = 0 }
	-- Agent:setTrajectoryStatus( false ) makes Agent run only once
	ag1:setTrajectoryStatus( true );
	ag1:execute(ev);
	print("Agent count:", cont);
	assert_equal(88, cont )

end

-- Trajectories may be filtered, ordered and recalculated
function test_TrajectoriesFiltersAndReordered()

	if (SKIPS[7]) then
		skip("No testing...") io.flush() --  7 assertions
	end

	print("-------------------------------------");
	print("-- TrajectoriesFiltersAndReordered");
	print("-------------------------------------");


	contCell = 0
	cs = CellularSpace{ xdim = 2}
	forEachCell( cs, function( cell) 
		cell.soilType = 0 
		contCell = contCell + 1
	end )
	assert_equal( 4, contCell)

	forEachCell( cs, function( cell, idx) 
		print( "Cell["..idx.."]: "..cell.soilType ); 
	end );


	ag1 = Agent{

		id = "MyAgent",


		it = Trajectory{
			target = cs
		},

		cont  = 0,

		State{
			id = "first",
			Jump{
				function( event, agent, cell )
					cont = cont + 1
					if (agent.cont < 10) then 
						agent.cont = agent.cont + 1;
						--print(agent.id..": "..agent.cont.." - cell["..cell.x..", "..cell.y.."]");
						return true
					end
					if( agent.cont == 10 ) then agent.cont = 0 end
					return false
				end,
				target = "second"
			}
		},

		State{
			id = "second",
			Jump{
				function( event, agent, cell )
					cont = cont + 1
					if (agent.cont < 10) then 
						agent.cont = agent.cont + 1;
						--print(agent.id..": "..agent.cont.." - cell["..cell.x..", "..cell.y.."]");
						return true
					end
					if( agent.cont == 10 ) then agent.cont = 0 end
					return false
				end, 
				target = "first"
			}
		}
	}


	at1 = Automaton{

		id = "MyAutomaton",

		it = Trajectory{
			target = cs
		},

		cont  = 0,

		State{
			id = "first",
			Jump{
				function( event, agent, cell )
					cont = cont + 1
					if (agent.cont < 10) then 
						agent.cont = agent.cont + 1;
						--print(agent.id..": "..agent.cont.." - cell["..cell.x..", "..cell.y.."]");
						return true
					end
					if( agent.cont == 10 ) then agent.cont = 0 end
					return false
				end,
				target = "second"
			}
		},

		State{
			id = "second",
			Jump{
				function( event, agent, cell )
					cont = cont + 1
					if (agent.cont < 10) then 
						agent.cont = agent.cont + 1;
						--print(agent.id..": "..agent.cont.." - cell["..cell.x..", "..cell.y.."]");
						return true
					end
					if( agent.cont == 10 ) then agent.cont = 0 end
					return false
				end, 
				target = "first"
			}
		}
	}


	print( "Automaton... ");
	env = Environment{ 
		id = "MyEnvironment"
	}
	env:add( cs );
	env:add( at1 );
	ev = Event{ time = 0 }

	at1:setTrajectoryStatus( true );
	at1.it:sort(function(a,b) return a.x > b.x; end );
	cont = 0
	at1:execute(ev);

	print("-----------------------");
	at1.it:sort(greaterByCoord(">"));
	cont = 0
	at1:execute(ev);
	print();

	print( "Agent... ");
	ev = Event{ time = 0 }
	ag1:setTrajectoryStatus( true );
	ag1.it:sort(function(a,b) return a.x > b.x; end );
	cont = 0
	ag1:execute(ev);
	print("Cont: ", cont) io.flush()
	assert_equal(44, cont)

	print("-----------------------");
	ag1.it:sort(greaterByCoord(">"));
	cont = 0
	ag1:execute(ev);
	print("Cont: ", cont) io.flush()
	assert_equal(44, cont)

	print("-----------------------");
	ag1.it:filter( function(cell) return cell.x ~= 1; end );
	cont = 0
	ag1:execute(ev);
	print("Cont: ", cont) io.flush()
	assert_equal(22, cont)

	print("-----------------------");
	ag1.it:filter( function(cell) return true; end );
	cont = 0
	ag1:execute(ev);
	print("Cont: ", cont) io.flush()
	assert_equal(44, cont)

	print("-----------------------");
	ag1.it:rebuild( );
	cont = 0
	ag1:execute(ev);
	print("Cont: ", cont) io.flush()
	assert_equal(44, cont)

	print("READY!!!")
	assert_true(true)
end 

-- Trajectories may be constructed from trajectories. However, once defined for an Agent or Automaton they can not be overwritten. You 
-- may just change them.
function test_TrajectoriesCanBeChangeNotOverwritten()

	if (SKIPS[8]) then
		skip("No testing...") io.flush() --  21 assertions
	end

	print("-----------------------------------------");
	print("-- TrajectoriesCanBeChangeNotOverwritten");
	print("-----------------------------------------");


	cs = CellularSpace{ xdim = 4}
	cont = 0
	forEachCell( cs, function( cell) 
		cell.soilType = 0 
		cont = cont + 1
	end )
	assert_equal(16,cont)

	forEachCell( cs, function( cell, idx) 
		--print( "Cell["..idx.."]: "..cell.soilType ); 
		assert_equal(cell.soilType, 0)
	end );


	at1 = Automaton{

		id = "MyAutomaton",

		it = Trajectory{
			target = cs
		},

		cont  = 0,

		State{
			id = "first",
			Jump{
				function( event, agent, cell )
					cont = cont + 1
					if (agent.cont < 10) then 
						agent.cont = agent.cont + 1;
						print(agent.id..": "..agent.cont.." - cell["..cell.x..", "..cell.y.."]");
						return true
					end
					if( agent.cont == 10 ) then 
						agent.cont = 0 
					end
					return false
				end,
				target = "second"
			}
		},

		State{
			id = "second",
			Jump{
				function( event, agent, cell )
					cont = cont + 1
					if (agent.cont < 10) then 
						agent.cont = agent.cont + 1;
						print(agent.id..": "..agent.cont.." - cell["..cell.x..", "..cell.y.."]");
						return true
					end
					if( agent.cont == 10 ) then 
						agent.cont = 0 
					end
					return false
				end, 
				target = "first"
			}
		}
	}

	print( "Automaton... ");
	env = Environment{ 
		id = "MyEnvironment"
	}
	env:add( cs );
	env:add( at1 );
	ev = Event{ time = 0 }
	at1:setTrajectoryStatus( true );

	cont = 0
	print("This works");
	at1.it:filter( function(cell) return cell.x == 1; end );
	at1:execute(ev);
	print("Count: ", cont ) io.flush()
	assert_equal(44, cont)

	cont = 0;
	at1.it:filter( function(cell) return true; end );
	at1:execute(ev);
	print("Count: ", cont ) io.flush()
	assert_equal(176, cont)

	--TODO
	--[[
	cont = 0
	print("This doesn't work");
	at1.it = Trajectory{ target = at1.it, select = function(cell) return cell.x ==3; end };
	forEachCell( at1.it, function(cell, idx) 
	print( "Cell["..idx.."]: ".." - ["..cell.x..", "..cell.y.."]" ); 
	end );
	print("probably because the way regions are implemented inside TerraME C++ kernel.");
	print("The implementation does not use the hande-body (bridge) pattern.");
	at1:execute(ev);
	print("Cont: ", cont ) io.flush()
	print();
	assert_equal(176, cont)
	--]]

	print("READY!!!")
	assert_true(true)

end

-- Never change Trajectories while they are in use: the Automaton will crash
function test_AutomatonCrash()

	-- The crash happens just in the TerraME DEBUG version.
	if (SKIPS[9]) then
		skip("No testing...") io.flush() --  2 assertions
	end

	print("-------------------------------------");
	print("-- AutomatonCrash");
	print("-------------------------------------");
	print(">>>>>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<<<<<<");
	print(">> ATENTION: this test must be ran alone when  <<");
	print(">> the TerraME is on debug mode. Please, skip  <<");
	print(">> it to run the other tests.                  <<");
	print(">> This test should cause a crash in TerraME   <<");
	print(">> on debug mode.                              <<");
	print(">>>>>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<<<<<<");


	cs = CellularSpace{ xdim = 2}
	forEachCell( cs, function( cell) 
		cell.soilType = 0 
	end )

	forEachCell( cs, function( cell, idx) 
	--print( "Cell["..idx.."]: "..cell.soilType ); 
	end );


	at1 = Automaton{

		id = "MyAutomaton",

		it = Trajectory{
			target = cs
		},

		cont  = 0,

		State{
			id = "first",
			Jump{
				function( event, agent, cell )
					cont = cont + 1
					if (agent.cont < 10) then 
						agent.cont = agent.cont + 1;
						--print(agent.id..": "..agent.cont.." - cell["..cell.x..", "..cell.y.."]");
						return true
					end
					if( agent.cont == 10 ) then 
						agent.cont = 0 
						agent.it:sort(function(a,b) return a.x > b.x; end );
					end
					return false
				end,
				target = "second"
			}
		},

		State{
			id = "second",
			Jump{
				function( event, agent, cell )
					cont = cont + 1
					if (agent.cont < 10) then 
						agent.cont = agent.cont + 1;
						--print(agent.id..": "..agent.cont.." - cell["..cell.x..", "..cell.y.."]");
						return true
					end
					if( agent.cont == 10 ) then 
						agent.cont = 0 
						agent.it:sort(function(a,b) return a.x < b.x; end );
					end
					return false
				end, 
				target = "first"
			}
		}
	}

	cont = 0
	print( "Automaton... ");
	env = Environment{ 
		id = "MyEnvironment"
	}
	env:add( cs );
	env:add( at1 );
	ev = Event{ time = 0 }
	at1:setTrajectoryStatus( true );
	at1:execute(ev);
	print();
	print("Count: ", cont) io.flush()
	assert_equal(44,cont)

	print("READY!!!")
	assert_true(true)
end

-- Never change Trajectories while they are in use: stop the Automaton first
-- falta terminar de implementar este teste - Tiago Carneiro
function test_NeverTestTrajectoriesInUse()

	if (SKIPS[10]) then
		skip("No testing...") io.flush() --  2 assertions
	end
	print("-------------------------------------");
	print("-- NeverTestTrajectoriesInUse");
	print("-------------------------------------");


	cs = CellularSpace{ xdim = 1, ydim = 2}
	forEachCell( cs, function( cell) 
		cell.soilType = 0 
	end )

	forEachCell( cs, function( cell, idx) 
	--print( "Cell["..idx.."]: "..cell.soilType ); 
	end );

	globalCont = 0	
	at1 = Automaton{

		id = "MyAutomaton",

		it = Trajectory{
			target = cs
		},

		lastState = "first",

		cont  = 0,

		jTrajectory = function( event, agent, cell)
			cont = cont + 1
			print("jump: "..globalCont..", "..agent.lastState);
			globalCont = globalCont + 1
			if( globalCont >=4 ) then return false end;

			if( agent.cont == 9 ) then 
				agent.cont = 0 ;
				agent:setTrajectoryStatus( false );
				return true;
			end
			return false;
		end,			

		State{
			id = "first",
			Jump{
				function( event, agent, cell )
					cont = cont + 1
					agent.lastState = "first";
					if (agent.cont < 9) then 
						agent.cont = agent.cont + 1;
						--print("Fst: "..agent.id..": "..agent.cont.." - cell["..cell.x..", "..cell.y.."]");
						return true;
					end

					return false
				end,
				target = "second"
			},

			Jump{
				function( event, agent, cell)
					cont = cont + 1 
					agent.lastState = "first";
					return agent.jTrajectory(event,agent, cell );
				end,
				target = "changeTrajectory"
			}

		},

		State{
			id = "second",
			Jump{
				function( event, agent, cell )
					cont = cont + 1
					agent.lastState = "second";
					if (agent.cont < 9) then 
						agent.cont = agent.cont + 1;
						print("Scd: "..agent.id..": "..agent.cont.." - cell["..cell.x..", "..cell.y.."]");
						return true
					end
					return false
				end, 
				target = "first"
			},

			Jump{
				function( event, agent, cell)
					cont = cont + 1 
					agent.lastState = "second";
					return agent.jTrajectory(event,agent, cell );
				end,
				target = "changeTrajectory"
			}

		},

		State{
			id = "changeTrajectory",
			Jump{
				function( event, agent, cell )
					cont = cont + 1
					if (agent.lastState == "first") then return true; end
					return false;
				end,
				target = "first"
			},
			Jump{
				function( event, agent, cell )
					cont = cont + 1
					if (agent.lastState == "second") then return true; end
					return false;
				end,
				target = "second"
			}
		}
	}

	cont = 0
	print( "Automaton... ");
	env = Environment{ 
		id = "MyEnvironment"
	}
	env:add( cs );
	env:add( at1 );
	ev = Event{ time = 0 }
	at1:setTrajectoryStatus( true );
	at1:execute(ev);
	print();
	print("Count: ", cont) io.flush()
	assert_equal(56,cont)

	print("READY!!!")
	assert_true(true)	
end

skips = {
	4
}



function test_AgentCellInteraction()
	if (SKIPS[11]) then
		skip("No testing...") io.flush() --  2 assertions
	end
	state1 = State {
	id = "walking",
		Jump {
			function( event, agent, cell )

				print(agent:getStateName());
				print(agent.energy)
				agent.energy= agent.energy - 1
				hungry = agent.energy == 0
				ag1.counter = ag1.counter + 10;
				--ag1:notify(ag1.time);

				if (hungry) then
					--agent.energy = agent.energy + 30
					return true
				end
				return false
			end,
			target = "sleeping"
		}
	}

	state2 = State {
		id = "sleeping",
		Jump {
			function( event, agent, cell )
				agent.energy = agent.energy + 1
				print(agent:getStateName());
				hungry = ag1.energy>0
				ag1.counter = ag1.counter + 10;
				--ag1:notify(ag1.time);

				if (not hungry)or( ag1.energy >=5) then
					return true
				end
				return false
			end,
			target = "walking"
		}
	}

	ag1 = Agent{
		id = "Ag1",
		energy  = 5,
		hungry = false,
		counter = 0,
		st1=state1,
		st2=state2
	}
    ag2 = Agent{
		id = "Ag2",
		energy  = 5,
		hungry = false,
		counter = 0,
		st1=state1,
		st2=state2
	}
	cs = CellularSpace{ xdim = 3}
	forEachCell( cs, function( cell) 
		cell.soilType = 0 
	end )

	local myEnv = Environment {
		"MyEnvironment",
		cs,
		ag1
	}
	myEnv:createPlacement{strategy = "void"}

    local id = ag1:getID()
    assert_equal(id, "Ag1")

    local c1 = cs.cells[1]
    ag1:enter(c1)
    local c2 = ag1:getCell()
    assert_equal(c1.x,c2.x)

    local c1 = cs.cells[4]
    ag1:move(c1)
    local c2 = ag1:getCell()
    assert_equal(c1.x,c2.x)

    ag1:leave() 
    assert_nil(ag1:getCell())
    

end
functionList = {
	[1] = "test_AgentBasics",
	[2] = "test_CreatesAgentAndAutomatonAndAskWhereTheyAre",
	[3] = "test_AgentAndAutomatonJumpConditions",
	[4] = "test_NotDeclaredStates",
	[5] = "test_AgentAndAutomatonTrajectories",
	[6] = "test_AutomataAndAgentsworking",
	[7] = "test_TrajectoriesFiltersAndReordered",
	[8] = "test_TrajectoriesCanBeChangeNotOverwritten",
	[9] = "test_AutomatonCrash",
	[10] = "test_NeverTestTrajectoriesInUse",
	[11] = "test_AgentCellInteraction()"
}

SKIPS = executeBasics("agent / automaton", functionList, skips)

lunatest.run()

os.exit(0)

