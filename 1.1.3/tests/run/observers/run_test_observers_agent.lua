dofile (TME_PATH.."/tests/run/run_util.lua")
local executeFileName = "TerraME ".. TME_PATH .."/tests/src/observers/test_observers_agent.lua"

tests={
    [1] = 5,
    [2] = 6,
    [3] = 6,
    [4] = 19,
    [5] = 6,
    [6] = 7,
    [7] = 6
    --[8] = 8
}

executeObservers(executeFileName, tests)
