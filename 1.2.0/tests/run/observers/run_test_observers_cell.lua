dofile (TME_PATH.."/tests/run/run_util.lua")
local executeFileName = "TerraME ".. TME_PATH .."/tests/src/observers/test_observers_cell.lua"

tests={
    [1] = 5,
    [2] = 6,
    [3] = 6,
    [4] = 11,
    --[5] = 8
}

executeObservers(executeFileName, tests)
