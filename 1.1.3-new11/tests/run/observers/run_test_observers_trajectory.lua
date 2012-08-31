dofile (TME_PATH.."/tests/run/run_util.lua")
local executeFileName = "TerraME ".. TME_PATH .."/tests/src/observers/test_observers_trajectory.lua"

tests={
    [1] = 4,
    [2] = 5,
    [3] = 5,
    [4] = 20,
    [5] = 9,
    [6] = 9,
    [7] = 7
}

executeObservers(executeFileName, tests)

