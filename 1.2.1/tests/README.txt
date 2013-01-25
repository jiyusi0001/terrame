\author Tiago Garcia de Senna Carneiro
I have changed the "lunatest.lua" file just to allow the tests run from the 
Crinson execution environment.

\author Rodrigo Reis Pereira
To run all possible tests database "cabecaDeBoi" must be set up;

TEST PROCEDURE
Running a single test or a group of tests
(1) Access the "tests/src" directory;
(2) Use command "TerraME PATH/TEST.lua" to run a specific test file. 
Ex.:    "TerraME basics/test_cell.lua";
        "TerraME observers/run_test_observers_cell.lua"
(3) Test self contained information should guide you through each test file.

Running test blocks
(1) Access the "tests/run" directory;
(2) Use command "TerraME TEST.lua" to run a specific test file. 
Ex.:    "TerraME run_all_basics.lua";
(3) Test self contained information should guide you through each test file.

\author Henrique Cota Camello
To run the tests under the "tests/run" folder you need to download the "wtee" program
(http://code.google.com/p/wintee) and put it in "TerraME_Beta/bin" folder
