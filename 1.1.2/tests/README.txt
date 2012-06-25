\author Tiago Garcia de Senna Carneiro

I have changed the "lunatest.lua" file just to allow the tests run from the 
Crinson execution environment.

TEST PROCEDURE


(1) Copy the content of the "lunatest" directory into the "TerraME.exe" install directory.
ATTENTION: DO NOT COPY THE "lunatest" DIRECTORY, INSTEAD COPY ITS CONTENT.


(2) Copy the "test_*.lua" files from the "terrame_basic_tests" into the "TerraME.exe" 
install direcyory. Again, copy the directory content, no the diretocy itself.



(3) Copy the "Database" directory into the directory above "TerraME.exe" install directory. 
For example:

 	"c:\TerraME\TerraME_RC5\>terrame test_space.lua"

In this case copy "Database" directory into the "C:\TerraME\" directory.


(4) Run the tests, typing one of these following comand in the operation system shell:

	"c:\TerraME\TerraME_RC5\>terrame test_agent_automaton.lua"

	"c:\TerraME\TerraME_RC5\>terrame test_timer.lua"

	"c:\TerraME\TerraME_RC5\>terrame test_cellularspace.lua"
