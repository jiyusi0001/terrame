REM rmdir /S /Q ..\..\bin\
REM mkdir ..\..\bin\

copy /Y release\TerraME.exe ..\..\bin\

copy /Y ..\..\dependencies\qt\lib\QtCore4.dll ..\..\bin\
copy /Y ..\..\dependencies\qt\lib\QtGui4.dll ..\..\bin\
copy /Y ..\..\dependencies\qt\lib\QtNetwork4.dll ..\..\bin\
copy /Y ..\..\dependencies\qwt\lib\qwt5.dll ..\..\bin\

REM copy /Y ..\..\dependencies\terralib\Release\shapelib.dll ..\..\bin\
REM copy /Y ..\..\dependencies\terralib\Release\te_ado.dll ..\..\bin\
REM copy /Y ..\..\dependencies\terralib\Release\te_mysql.dll ..\..\bin\
REM copy /Y ..\..\dependencies\terralib\Release\te_utils.dll ..\..\bin\
REM copy /Y ..\..\dependencies\terralib\Release\te_functions.dll ..\..\bin\
REM copy /Y ..\..\dependencies\terralib\Release\tiff.dll ..\..\bin\
copy /Y ..\..\dependencies\terralib\Release\terralib.dll ..\..\bin\
copy /Y ..\..\dependencies\terralib\Release\terralib_ado.dll ..\..\bin\
copy /Y ..\..\dependencies\terralib\Release\terralib_shp.dll ..\..\bin\

copy /Y ..\..\dependencies\mysql\libmysql.dll ..\..\bin\
copy /Y ..\..\dependencies\lua\lib\lua5.2.dll ..\..\bin\
copy /Y ..\..\dependencies\msvc2010\msvcp100.dll ..\..\bin\
copy /Y ..\..\dependencies\msvc2010\msvcr100.dll ..\..\bin\

REM copy /Y ..\..\dependencies\luagd\*.* ..\..\bin\
REM copy /Y ..\..\dependencies\zlib\zlib1.dll ..\..\bin\
mkdir ..\..\bin\Lua
copy /Y ..\..\src\lua\*.lua ..\..\bin\Lua

mkdir ..\..\bin\database
copy /Y ..\..\database ..\..\bin\database\

mkdir ..\..\bin\demos
copy /Y ..\..\demos ..\..\bin\demos\
