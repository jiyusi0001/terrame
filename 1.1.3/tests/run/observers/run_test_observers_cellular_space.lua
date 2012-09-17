dofile (TME_PATH.."/tests/run/run_util.lua")
local executeFileName = "TerraME ".. TME_PATH .."/tests/src/observers/test_observers_cellular_space.lua"

tests={
    [1] = 6,
    [2] = 6,
    [3] = 5,
    [4] = 6,
    [5] = 20,
    [6] = 11,
    [7] = 10,
    --[8] = 8
}

executeObservers(executeFileName, tests)
