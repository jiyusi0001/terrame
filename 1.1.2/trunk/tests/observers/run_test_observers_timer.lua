executeFileName = "TerraME test_observers_timer.lua"

function updateInput(test,number)
	file=io.open("input.txt","w")
	file:write(test.."\n"..number)
	file:close()
end
for i=1, 13, 1 do
test="TextScreen"
updateInput(test,i)
os.execute(executeFileName)
end

for i=1, 13, 1 do
test="LogFile"
updateInput(test,i)
os.execute(executeFileName)
end

for i=1, 13, 1 do
test="Table"
updateInput(test,i)
os.execute(executeFileName)
end

for i=1, 7, 1 do
test="Scheduler"
updateInput(test,i)
os.execute(executeFileName)
end

for i=1, 11, 1 do
	test="UDP"
	updateInput(test,i)
	os.execute(executeFileName)
end
