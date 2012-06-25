/author Rodrigo Reis Pereira

Steps for building TerraME under Windows (Using VisualStudio)

1 - Download and compile dependencies. (Read instructions from dependencies folder)
2 - cd to build/msvc++32
3 - Open TerraME VC++ Project
4 - Buil project using VisualStudio IDE
PS.: This builder was made with VS2010 version.
5 - Use InstallJammer and select the 'win32' installer project from 'install' folder



* Solving LNK 1104 error

  During the compilation of TerraME under Windows x86 or x64 should happen an error called LNK 1104. 
Its happen because a conflit between TerraME's and Visual Studio's include of the "process.h" file.
The way to fix it is edit the atlbase.h in Visual Studio folder. 

  Follow the steps for solve it.

1 - Open the atlbase.h (default path: C:\Arquivos de programas\Microsoft Visual Studio 10.0\VC\atlmfc\include)
2 - Find the 83 line. The line is an include for process.h.
3 - Change the include line: "#include <process.h" for "#include <../include/process.h"
4 - Save the file
5 - Rebuild the TerraME project
