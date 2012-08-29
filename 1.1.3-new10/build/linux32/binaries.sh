rm ../../bin/*.*
mkdir ../../bin

#rm -R ../../bin/tests
rm -R ../../bin/database
rm -R ../../bin/Lua

cp TerraME ../../bin/

cp ../../dependencies/lua/lib/liblua5.1.a ../../bin/
cp ../../dependencies/qwt/lib/libqwt.so.5.2.1 ../../bin
cp ../../dependencies/terralib/Release/linux-g++/libshapelib.so.3.6.1 ../../bin
cp ../../dependencies/terralib/Release/linux-g++/libterralibtiff.so.3.6.1 ../../bin
cp ../../dependencies/terralib/Release/linux-g++/libte_mysql.so.3.6.1 ../../bin
cp ../../dependencies/terralib/Release/linux-g++/libterralib.so.3.6.1 ../../bin
cp ../../dependencies/qt/lib/libQtCore.so.4.7.3 ../../bin
cp ../../dependencies/qt/lib/libQtNetwork.so.4.7.3 ../../bin
cp ../../dependencies/qt/lib/libQtGui.so.4.7.3 ../../bin

cp ../../dependencies/lunatest/lunatest.lua ../../bin/
cp -R ../../tests/ ../../bin/
cp -R ../../database ../../bin/

cp -R ../../src/lua/ ../../bin/Lua

cd ../../bin
ln -s libqwt.so.5.2.1 libqwt.so.5
ln -s libshapelib.so.3.6.1 libshapelib.so.3
ln -s libterralibtiff.so.3.6.1 libterralibtiff.so.3
ln -s libterralib.so.3.6.1 libterralib.so.3
ln -s libte_mysql.so.3.6.1 libte_mysql.so.3
