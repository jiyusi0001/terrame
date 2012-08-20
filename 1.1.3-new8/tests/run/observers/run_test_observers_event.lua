dofile (TME_PATH.."/tests/run/run_util.lua")
local executeFileName = "TerraME ".. TME_PATH .."/tests/src/observers/test_observers_event.lua"

tests={
    [1] = 5,
    [2] = 5,
    [3] = 6,
    [4] = 7
}

executeObservers(executeFileName, tests)
