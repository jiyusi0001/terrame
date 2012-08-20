dofile (TME_PATH.."/tests/run/run_util.lua")
local executeFileName = "TerraME ".. TME_PATH .."/tests/src/observers/test_observers_society.lua"

tests={
    [1] = 9,
    [2] = 9
}

executeObservers(executeFileName, tests)
