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
-- Expected result: 5 teste, 9 assertations, (5 passed, 0 failed, 0 erros)
-- 

dofile (TME_PATH.."/tests/dependencies/UnitTest.lua")

local environmentTest = UnitTest {
	test_EnvironmentType = function(self)

		print("--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=") io.flush()
		print("Testing Environment...")


		cs = CellularSpace{
			xdim=10
		}

		a = Agent{
			x = 3,
			State{
				id="stop",
				Jump{ function(ev, self)
						return false
					end,
					target = "stop"},
				Flow{ function(ev, self)
						self.x = self.x + 1
						--print("stop: "..self.x.." -> "..self:getLatency())
					end}
			},
		}

		t = Timer{
			Pair{
				Event{time = 1, period = 1},
				Action {function(ev)
						--print("TIME: "..t:getTime())
						a:execute(ev)
					end}
			}
		}

		env = Environment{id = "env", cs, a, t}

		-- first add all CellularSpace objects
		print("ADDING CELLULAR SPACE") io.flush()
		env:add(cs)

		-- second add all behavioral objects
		--print("ADDING AGENT") io.flush()
		env:add(a)
		--print("ADDING TIMER") io.flush()
		--print("ADDING AUTOMATON") io.flush()
		env:add(Automaton{State{id="idle"}})

		-- then, add the timers
		env:add(t)
		--print("EVERYTHING ADDED") io.flush()

		env:execute(10)
		--assert_equal(11, env:getTime() ) -- I still need to implement "getTime" for the Environment class
		self:assert_equal( 13 , a.x)

		print("READY!!!")
		self:assert_true(true)

	end,

	-- MULTIPLE timers one Environment
	test_MultipleTimersOneEnvironment = function(self)

		print("--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=") io.flush()

		print("-------------------------------------");
		print("-- MultipleTimersOneEnvironment ");
		print("-------------------------------------");

		orderToken = 0 -- Priority test token (position reserved to the Event for this timeslice)
		local timeMemory = 0   -- memory of time test variable 
		self:assert_equal(orderToken, 0)

		env = Environment{
			id = "MyEnvironment",

			clock1 = Timer{
				Pair{
					Event{ time = 0, period = 1 },
					Action { function(event) 
							-- print("Message1: ",event:getTime(), event:getPeriod(), event:getPriority()) io.flush()
							if ( event:getTime() == timeMemory) then 
								self:assert_lte(orderToken,1)
							end
							timeMemory = event:getTime()
							orderToken = 1
						end }
				},
				Pair{
					Event{ time = 1, period = 1, priority = 1 },
					Action { function(event)
							-- print("Message2: ",event:getTime(), event:getPeriod(), event:getPriority())  io.flush()
							timeMemory = event:getTime()
							if ( event:getTime() == timeMemory) then 
								self:assert_lte(1, orderToken )
							else
								-- -- Message2 can never execute before Message1 during the same time interval 
								print("OUT OF ORDER: TerraME (CRASH!!!) was expected due to the next assertion fail.") io.flush()
								self:assert_equal(2, orderToken )
							end
							orderToken = 2
						end }
				}
			},
			clock2 = Timer{
				Pair{
					--## PRATICE:  Change the "priority" value. Try: 1 and 2;
					--## PRATICE:  Change the "period" value. Try: 1 and 2;
					Event{ time = 0, period = 2 , priority = 2 },
					Action { function(event) 
							-- print("Message3: ",event:getTime(), event:getPeriod(), event:getPriority()) io.flush()
							timeMemory = event:getTime()
							if ( event:getTime() == timeMemory) then 
								self:assert_lte(orderToken,2)
							else
								-- -- Message3 can never execute before Message1 or 2 during the same time interval 
								print("OUT OF ORDER: TerraME (CRASH!!!) was expected due to the next assertion fail.") io.flush()
								self:assert_equal(3, orderToken )
							end
							orderToken = 3
						end }
				},
				Pair{
					Event{ time = 1, period = 1, priority = 3 },
					Action { function(event) 
							-- print("Message4: ",event:getTime(), event:getPeriod(), event:getPriority()) io.flush()
							if ( event:getTime() == timeMemory) then
								self:assert_lte(orderToken,4)
							else
								-- -- Message4 can never execute before Message1,2 or 3 during the same time interval 
								print("OUT OF ORDER: TerraME (CRASH!!!) was expected due to the next assertion fail.") io.flush()
								self:assert_equal(4, orderToken )
							end
							timeMemory = event:getTime()
							orderToken = 0
						end }
				}
			}
		}

		env:execute(6);


		print("READY")
		self:assert_true(true)

	end,

	-- MULTIPLE environments SINGLE timer
	test_MultipleEnvironmentsSingleTimer = function(self)

		print("--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=") io.flush()
		print("-------------------------------------");
		print("-- MultipleEnvironmentsSingleTimer ");
		print("-------------------------------------");

		orderToken = 0 -- Priority test token (position reserved to the Event for this timeslice)
		local timeMemory = 0   -- memory of time test variable 
		self:assert_equal(orderToken, 0)

		env = Environment{
			id = "MyEnvironment",

			firstEnv = Environment{
				id = "MyEnvironment1",
				clock1 = Timer{
					Pair{
						Event{ time = 0, period = 1 },
						Action { function(event) 
								--print("Message1: ",event:getTime(), event:getPeriod(), event:getPriority())  io.flush()
								if ( event:getTime() == timeMemory) then 
									self:assert_lte(1,orderToken )
								end
								timeMemory = event:getTime()
								orderToken = 1
							end }
					},
					Pair{
						Event{ time = 1, period = 1, priority = 1 },
						Action { function(event) 
								--print("Message2: ",event:getTime(), event:getPeriod(), event:getPriority()) io.flush()
								timeMemory = event:getTime()

								if ( event:getTime() == timeMemory) then 
									self:assert_lte(1, orderToken )
								else
									-- -- Message2 can never execute before Message1 during the same time interval 
									print("OUT OF ORDER: TerraME (CRASH!!!) was expected due to the next assertion fail.") io.flush()
									self:assert_equal(2, orderToken )
								end
								orderToken = 2
							end }
					}
				}
			},
			secondEnv = Environment{
				id = "MyEnvironment2",	
				clock2 = Timer{
					Pair{
						--## PRATICE:  Change the "priority" value. Try: 1 and 2;
						--## PRATICE:  Change the "period" value. Try: 1 and 2;
						Event{ time = 0, period = 2 , priority = 2 },
						Action { function(event) 
								--print("Message3: ",event:getTime(), event:getPeriod(), event:getPriority()) io.flush()
								timeMemory = event:getTime()
								if ( event:getTime() == timeMemory) then 
									self:assert_lte(2, orderToken )
								else
									-- -- Message3 can never execute before Message1 or 2 during the same time interval 
									print("OUT OF ORDER: TerraME (CRASH!!!) was expected due to the next assertion fail.") io.flush()
									self:assert_equal(3, orderToken )
								end
								orderToken = 3
							end }
					},
					Pair{
						Event{ time = 1, period = 1, priority = 3 },
						Action { function(event) 
								--print("Message4: ",event:getTime(), event:getPeriod(), event:getPriority()) io.flush()
								if ( event:getTime() == timeMemory) then 
									self:assert_lte(4, orderToken )
								else
									-- -- Message4 can never execute before Message1,2 or 3 during the same time interval 
									print("OUT OF ORDER: TerraME (CRASH!!!) was expected due to the next assertion fail.") io.flush()
									self:assert_equal(4, orderToken )
								end
								timeMemory = event:getTime()
								orderToken = 0
							end }
					}
				}
			}
		}

		env:execute(6);

		print("READY!!!")
		self:assert_true(true)

	end,

	-- MULTIPLE environments MULTIPLE timers
	test_MultipleEnvironmentsMultipleTimers = function(self)

		print("--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=") io.flush()
		print("-------------------------------------");
		print("-- MultipleEnvironmentsMultipleTimers ");
		print("-------------------------------------");

		--## PRATICE:  Change the "priority" values. 
		--   Try: 1, 3, 5, 7, 2, 4, 6, 8 or
		--        1, 2, 3, 4, 5, 6, 7, 8
		PRIO1 = 1
		PRIO2 = 2
		PRIO3 = 3
		PRIO4 = 4
		PRIO5 = 5
		PRIO6 = 6
		PRIO7 = 7
		PRIO8 = 8

		orderToken = 0 -- Priority test token (position reserved to the Event for this timeslice)
		local timeMemory = 0   -- memory of time test variable 
		self:assert_equal(orderToken, 0)

		env = Environment{
			id = "MyEnvironment",

			firstEnv = Environment{
				id = "MyEnvironment1",
				clock1 = Timer{
					Pair{
						Event{ time = 0, period = 1, priority = PRIO1 },
						Action { function(event) 
								--print("Message1: ",event:getTime(), event:getPeriod(), event:getPriority()) io.flush()
								if ( event:getTime() == timeMemory) then 
									self:assert_lte(1,orderToken )
								end
								timeMemory = event:getTime()
								orderToken = 1
							end }
					},
					Pair{
						Event{ time = 1, period = 1, priority = PRIO2 },
						Action { function(event) 
								--print("Message2: ",event:getTime(), event:getPeriod(), event:getPriority()) io.flush()
								timeMemory = event:getTime()
								if ( event:getTime() == timeMemory) then 
									self:assert_lte(1, orderToken )
								else
									-- Message2 can never execute before Message1 during the same time interval 
									print("OUT OF ORDER: TerraME (CRASH!!!) was expected due to the next assertion fail.") io.flush()
									self:assert_equal(2, orderToken )
								end
								orderToken = 2
							end }
					}
				},
				clock2 = Timer{
					Pair{
						--## PRATICE:  Change the "priority" value. Try: 1 and 2;
						--## PRATICE:  Change the "period" value. Try: 1 and 2;
						Event{ time = 0, period = 2 , priority = PRIO3 },
						Action { function(event) 
								--print("Message3: ",event:getTime(), event:getPeriod(), event:getPriority()) io.flush()
								timeMemory = event:getTime()
								if ( event:getTime() == timeMemory) then 
									self:assert_lte(2, orderToken )
								else
									-- Message3 can never execute before Message1 or 2 during the same time interval 
									print("OUT OF ORDER: TerraME (CRASH!!!) was expected due to the next assertion fail.") io.flush()
									self:assert_equal(3, orderToken )
								end
								orderToken = 3
							end }
					},
					Pair{
						Event{ time = 1, period = 1, priority = PRIO4 },
						Action { function(event) 
								--print("Message4: ",event:getTime(), event:getPeriod(), event:getPriority()) io.flush()
								timeMemory = event:getTime()
								if ( event:getTime() == timeMemory) then 
									self:assert_lte(3, orderToken )
								else
									-- Message4 can never execute before Message1 to 3 during the same time interval 
									print("OUT OF ORDER: TerraME (CRASH!!!) was expected due to the next assertion fail.") io.flush()
									self:assert_equal(4, orderToken )
								end
								orderToken = 4
							end }
					}
				}
			},
			secondEnv = Environment{
				id = "MyEnvironment2",	
				clock1 = Timer{
					Pair{
						Event{ time = 0, period = 1, priority = PRIO5 },
						Action { function(event)
								--print("Message5: ",event:getTime(), event:getPeriod(), event:getPriority()) io.flush()
								timeMemory = event:getTime()
								if ( event:getTime() == timeMemory) then 
									self:assert_lte(4, orderToken )
								else
									-- Message5 can never execute before Message1 or 4 during the same time interval 
									print("OUT OF ORDER: TerraME (CRASH!!!) was expected due to the next assertion fail.") io.flush()
									self:assert_equal(5, orderToken )
								end
								orderToken = 5
							end }
					},
					Pair{
						Event{ time = 1, period = 1, priority = PRIO6 },
						Action { function(event) 
								--print("Message6: ",event:getTime(), event:getPeriod(), event:getPriority()) io.flush()
								timeMemory = event:getTime()
								if ( event:getTime() == timeMemory) then 
									self:assert_lte(5, orderToken )
								else
									-- Message3 can never execute before Message1 or 5 during the same time interval 
									print("OUT OF ORDER: TerraME (CRASH!!!) was expected due to the next assertion fail.") io.flush()
									self:assert_equal(6, orderToken )
								end
								orderToken = 6
							end }
					}
				},
				clock2 = Timer{
					Pair{
						--## PRATICE:  Change the "priority" value. Try: 1 and 2;
						--## PRATICE:  Change the "period" value. Try: 1 and 2;
						Event{ time = 0, period = 2 , priority = PRIO7 },
						Action { function(event) 
								--print("Message7: ",event:getTime(), event:getPeriod(), event:getPriority()) io.flush()
								timeMemory = event:getTime()
								if ( event:getTime() == timeMemory) then 
									self:assert_lte(6, orderToken )
								else
									-- Message3 can never execute before Message1 or 6 during the same time interval 
									print("OUT OF ORDER: TerraME (CRASH!!!) was expected due to the next assertion fail.") io.flush()
									self:assert_equal(7, orderToken )
								end
								orderToken = 7
							end }
					},
					Pair{
						Event{ time = 1, period = 1, priority = PRIO8 },
						Action { function(event) 
								--print("Message8: ",event:getTime(), event:getPeriod(), event:getPriority()) io.flush()
								if ( event:getTime() == timeMemory) then 
									self:assert_lte(8, orderToken )
								else
									-- Message8 can never execute before Message1,2,3,..,7 during the same time interval 
									print("OUT OF ORDER: TerraME (CRASH!!!) was expected due to the next assertion fail.") io.flush()
									self:assert_equal(8, orderToken )
								end
								timeMemory = event:getTime()
								orderToken = 0
							end }
					}
				}
			}
		}

		env:execute(6);

		print("READY!!!")
		self:assert_true(true)

	end,

	-- MULTIPLE environments MULTIPLE timers with internal timer
	test_MutipleEnvorinmentsMultipleTimersWithInternalTimer = function(self)

		print("--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=") io.flush()

		--## PRATICE:  Change the "priority" values. 
		--   Try: 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11 or
		--        0, 2, 4, 6, 8, 10, 1, 3, 5, 7, 9, 11
		PRIO0 = 0
		PRIO1 = 1
		PRIO2 = 2
		PRIO3 = 3
		PRIO4 = 4
		PRIO5 = 5
		PRIO6 = 6
		PRIO7 = 7
		PRIO8 = 8
		PRIO9 = 9
		PRIO10 = 10
		PRIO11 = 11

		print("------------------------------------------------------");
		print("-- MutipleEnvironmentsMultipleTimersWithInternalTimer");
		print("------------------------------------------------------");

		env = Environment{
			id = "MyEnvironment",

			clock1 = Timer{
				Pair{
					Event{ time = 0, period = 1, priority = PRIO0 },
					Action { function(event) 
							--print("-----") print("Message0: ",event:getTime(), event:getPeriod(), event:getPriority()) io.flush()
							if ( event:getTime() == timeMemory) then 
								self:assert_lte(-1,orderToken )
							end
							timeMemory = event:getTime()
							orderToken = 0
						end }
				},
				Pair{
					Event{ time = 1, period = 1, priority = PRIO1 },
					Action { function(event) 
							--print("Message1: ",event:getTime(), event:getPeriod(), event:getPriority()) io.flush()
							timeMemory = event:getTime()
							if ( event:getTime() == timeMemory) then 
								self:assert_lte(0, orderToken )
							else
								-- Message1 can never execute before Message0 during the same time interval 
								print("OUT OF ORDER: TerraME (CRASH!!!) was expected due to the next assertion fail.") io.flush()
								self:assert_equal(1, orderToken )
							end
							orderToken = 1
						end }
				}
			},

			clock2 = Timer{
				Pair{
					Event{ time = 0, period = 2 , priority = PRIO2 },
					Action { function(event)
							--print("Message2: ",event:getTime(), event:getPeriod(), event:getPriority()) io.flush()
							timeMemory = event:getTime()
							if ( event:getTime() == timeMemory) then 
								self:assert_lte(orderToken,1)
							else
								-- Message2 can never execute before Message1 during the same time interval 
								print("OUT OF ORDER: TerraME (CRASH!!!) was expected due to the next assertion fail.") io.flush()
								self:assert_equal(2, orderToken )
							end
							orderToken = 2
						end }
				},
				Pair{
					Event{ time = 1, period = 1, priority = PRIO3 },
					Action { function(event) 
							--print("Message3: ",event:getTime(), event:getPeriod(), event:getPriority()) io.flush()
							timeMemory = event:getTime()
							if ( event:getTime() == timeMemory) then 
								self:assert_lte(orderToken,2)
							else
								-- Message3 can never execute before Message2 during the same time interval 
								print("OUT OF ORDER: TerraME (CRASH!!!) was expected due to the next assertion fail.") io.flush()
								self:assert_equal(3, orderToken )
							end
							orderToken = 3
						end }
				}
			},

			firstEnv = Environment{
				id = "MyEnvironment1",
				clock1 = Timer{
					Pair{
						Event{ time = 0, period = 1, priority = PRIO4 },
						Action { function(event) 
								--print("Message4: ",event:getTime(), event:getPeriod(), event:getPriority()) io.flush()
								timeMemory = event:getTime()
								if ( event:getTime() == timeMemory) then 
									self:assert_lte(3, orderToken )
								else
									-- Message4 can never execute before Message3 during the same time interval 
									print("OUT OF ORDER: TerraME (CRASH!!!) was expected due to the next assertion fail.") io.flush()
									self:assert_equal(4, orderToken )
								end
								orderToken = 4
							end }
					},
					Pair{
						Event{ time = 1, period = 1, priority = PRIO5 },
						Action { function(event) 
								--print("Message5: ",event:getTime(), event:getPeriod(), event:getPriority()) io.flush()
								timeMemory = event:getTime()
								if ( event:getTime() == timeMemory) then 
									self:assert_lte(4, orderToken )
								else
									-- Message5 can never execute before Message4 during the same time interval 
									print("OUT OF ORDER: TerraME (CRASH!!!) was expected due to the next assertion fail.") io.flush()
									self:assert_equal(5, orderToken )
								end
								orderToken = 5
							end }
					}
				},
				clock2 = Timer{
					Pair{
						Event{ time = 0, period = 2 , priority = PRIO6 },
						Action { function(event) 
								--print("Message6: ",event:getTime(), event:getPeriod(), event:getPriority()) io.flush()
								timeMemory = event:getTime()
								if ( event:getTime() == timeMemory) then 
									self:assert_lte(5, orderToken )
								else
									-- Message6 can never execute before Message5 during the same time interval 
									print("OUT OF ORDER: TerraME (CRASH!!!) was expected due to the next assertion fail.") io.flush()
									self:assert_equal(6, orderToken )
								end
								orderToken = 6
							end }
					},
					Pair{
						Event{ time = 1, period = 1, priority = PRIO7 },
						Action { function(event) 
								--print("Message7: ",event:getTime(), event:getPeriod(), event:getPriority()) io.flush()
								timeMemory = event:getTime()
								if ( event:getTime() == timeMemory) then 
									self:assert_lte(6, orderToken )
								else
									-- Message7 can never execute before Message6 during the same time interval 
									print("OUT OF ORDER: TerraME (CRASH!!!) was expected due to the next assertion fail.") io.flush()
									self:assert_equal(7, orderToken )
								end
								orderToken = 7
							end }
					}
				}
			},
			secondEnv = Environment{
				id = "MyEnvironment2",	
				clock1 = Timer{
					Pair{
						Event{ time = 0, period = 1, priority = PRIO8 },
						Action { function(event) 
								--print("Message8: ",event:getTime(), event:getPeriod(), event:getPriority()) io.flush()
								timeMemory = event:getTime()
								if ( event:getTime() == timeMemory) then 
									self:assert_lte(7, orderToken )
								else
									-- Message8 can never execute before Message7 during the same time interval 
									print("OUT OF ORDER: TerraME (CRASH!!!) was expected due to the next assertion fail.") io.flush()
									self:assert_equal(8, orderToken )
								end
								orderToken = 8
							end }
					},
					Pair{
						Event{ time = 1, period = 1, priority = PRIO9 },
						Action { function(event) 
								--print("Message9: ",event:getTime(), event:getPeriod(), event:getPriority()) io.flush()
								timeMemory = event:getTime()
								if ( event:getTime() == timeMemory) then 
									self:assert_lte(8, orderToken )
								else
									-- Message9 can never execute before Message8 during the same time interval 
									print("OUT OF ORDER: TerraME (CRASH!!!) was expected due to the next assertion fail.") io.flush()
									self:assert_equal(9, orderToken )
								end
								orderToken = 9
							end }
					}
				},
				clock2 = Timer{
					Pair{
						--## PRATICE:  Change the "priority" value. Try: 1 and 2;
						--## PRATICE:  Change the "period" value. Try: 1 and 2;
						Event{ time = 0, period = 2 , priority = PRIO10 },
						Action { function(event) 
								--print("Message10: ",event:getTime(), event:getPeriod(), event:getPriority()) io.flush()
								timeMemory = event:getTime()
								if ( event:getTime() == timeMemory) then 
									self:assert_lte(9, orderToken )
								else
									-- Message10 can never execute before Message9 during the same time interval 
									print("OUT OF ORDER: TerraME (CRASH!!!) was expected due to the next assertion fail.") io.flush()
									self:assert_equal(10, orderToken )
								end
								orderToken = 10
							end }
					},
					Pair{
						Event{ time = 1, period = 1, priority = PRIO11 },
						Action { function(event)
								--print("Message11: ",event:getTime(), event:getPeriod(), event:getPriority()) io.flush()
								timeMemory = event:getTime()
								if ( event:getTime() == timeMemory) then 
									self:assert_lte(10, orderToken )
								else
									-- Message11 can never execute before Message10 during the same time interval 
									print("OUT OF ORDER: TerraME (CRASH!!!) was expected due to the next assertion fail.") io.flush()
									self:assert_equal(11, orderToken )
								end
								orderToken = 0
							end }
					}
				}
			}
		}

		env:execute(6);


		print("READY!!!")
		self:assert_true( true )

	end
}

environmentTest:run()
