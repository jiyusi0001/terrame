executeFileName = "TerraME test_observers_cell.lua"

function updateInput(test,number)
	file=io.open("input.txt","w")
	file:write(test.."\n"..number)
	file:close()
end

for i=1, 5, 1 do
	test="TextScreen"
	updateInput(test,i)
	os.execute(executeFileName)
end

for i=1, 6, 1 do
	test="LogFile"
	updateInput(test,i)
	os.execute(executeFileName)
end

for i=1, 6, 1 do
	test="Table"
	updateInput(test,i)
	os.execute(executeFileName)
end

for i=1, 10, 1 do
	test="Chart"
	updateInput(test,i)
	os.execute(executeFileName)
end

for i=1, 8, 1 do
	test="UDP"
	updateInput(test,i)
	os.execute(executeFileName)
end
