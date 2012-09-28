# This script builds the TerraME
# (c) Gilberto Camara, Gilberto Ribeiro, Raian Maretto, Pedro Andrade june 2011
# (c) Rodrigo Reis january 2012
#
cmake_minimum_required(VERSION 2.8)
project( TerraME )

set(ROOT ../..) # change this if TerraME is somewhere else
#set(ROOT /home/terralab/TerraME_Beta)
set(DEPS ${ROOT}/dependencies)
set(SRCDIR ${ROOT}/src) # this is the directory where terralib sources will be located

set(BLDIR  ${ROOT}/build/cmake) # this is the directory where cmake scripts are
set(CMAKE_MODULE_PATH ${BLDIR}/Find) # this is the directory where additional scritps are located

set(CMAKE_BUILD_TYPE debug) # Set the type of build
add_definitions(-Wall -DTME_LUA_5_1 -DTME_TERRALIB_RC3 -DQWT_DLL) #Set -D define flags to the compilation of source files

set(BINARY_DIR ${ROOT}/bin)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${BINARY_DIR})

file(MAKE_DIRECTORY ${ROOT}/bin/Lua)
file(COPY 
	${ROOT}/tests/dependencies/XDebug.lua 
	${ROOT}/tests/dependencies/lunatest.lua 
	DESTINATION ${BINARY_DIR}
	)

file(COPY
	${SRCDIR}/lua/Action.lua
	${SRCDIR}/lua/Agent.lua
	${SRCDIR}/lua/Automaton.lua
	${SRCDIR}/lua/Cell.lua
	${SRCDIR}/lua/CellularSpace.lua
	${SRCDIR}/lua/Coord.lua
	${SRCDIR}/lua/Environment.lua 
	${SRCDIR}/lua/Event.lua
	${SRCDIR}/lua/Flow.lua
	${SRCDIR}/lua/Group.lua
	${SRCDIR}/lua/Jump.lua
	${SRCDIR}/lua/Legend.lua 
	${SRCDIR}/lua/Neighborhood.lua
	${SRCDIR}/lua/Observer.lua
	${SRCDIR}/lua/Pair.lua	
	${SRCDIR}/lua/SocialNetwork.lua	
	${SRCDIR}/lua/Society.lua	
	${SRCDIR}/lua/State.lua
	${SRCDIR}/lua/TerraME.lua
	${SRCDIR}/lua/Timer.lua
	${SRCDIR}/lua/Trajectory.lua

	DESTINATION ${BINARY_DIR}/Lua
	)

message("Using additional find package files located in ${CMAKE_MODULE_PATH}")


# Set source files location
file(GLOB SRCS  
          ${SRCDIR}/core/*.cpp 
          ${SRCDIR}/observer/components/*.cpp
          ${SRCDIR}/observer/components/console/*.cpp
          ${SRCDIR}/observer/components/legend/*.cpp
          ${SRCDIR}/observer/components/painter/*.cpp
          ${SRCDIR}/observer/components/player/*.cpp 
          ${SRCDIR}/observer/components/receiver/*.cpp 
          ${SRCDIR}/observer/protocol/blackBoard/*.cpp    
          ${SRCDIR}/observer/protocol/decoder/*.cpp
          ${SRCDIR}/observer/statistic/*.cpp
          ${SRCDIR}/observer/types/image/*.cpp
          ${SRCDIR}/observer/types/udpSender/*.cpp
          ${SRCDIR}/observer/types/stateMachine/*.cpp
          ${SRCDIR}/observer/types/*.cpp
          ${SRCDIR}/observer/*.cpp
	  ${SRCDIR}/observer/types/chartPlot/*.cpp
          )
set(LIBS) #Variable which will contain the libraries location

#Set include directories location
include_directories( ${SRCDIR}
          ${SRCDIR}/core/
          ${SRCDIR}/observer/components/
          ${SRCDIR}/observer/components/console/
	  ${SRCDIR}/observer/types/chartPlot/
          ${SRCDIR}/observer/components/legend/
          ${SRCDIR}/observer/components/painter/
          ${SRCDIR}/observer/components/player/
          ${SRCDIR}/observer/protocol/blackBoard/
          ${SRCDIR}/observer/protocol/decoder/
          ${SRCDIR}/observer/statistic/
          ${SRCDIR}/observer/types/image/
          ${SRCDIR}/observer/types/stateMachine/
          ${SRCDIR}/observer/types/udpSender/
          ${SRCDIR}/observer/types/
          ${SRCDIR}/observer/
  	)

## ---------------------------------------- Find dependencies -------------------------------------------------- ##
#TerraLib
if(MINGW)
	set(TERRALIB_KERNEL_INCLUDE_DIR ${DEPS}/terralib/src/terralib/kernel )
	set(TERRALIB_MYSQL_INCLUDE_DIR ${DEPS}/terralib/src/terralib/drivers/MySQL)
	set(TERRALIB_JPEG_INCLUDE_DIR  ${DEPS}/terralib/src/terralib/drivers/libjpeg )
	set(TERRALIB_LIBRARIES ${DEPS}/terralib/Release/win32-g++)
	Set(TERRALIB_LIBRARY ${TERRALIB_LIBRARIES}/libterralib.a)
	set(TERRALIB_FOUND TRUE)
else(MINGW)
	find_package(TerraLib)
endif(MINGW)
if( TERRALIB_FOUND )
    message(" -- found TerraLib library ${TERRALIB_LIBRARY} and include dir ${TERRLIB_INCLUDE_DIR}")
	include_directories(${TERRALIB_KERNEL_INCLUDE_DIR})
	include_directories(${TERRALIB_MYSQL_INCLUDE_DIR})
	include_directories(${TERRALIB_JPEG_INCLUDE_DIR})
	link_directories(${TERRALIB_LIBRARY})
    set(LIBS ${LIBS} ${TERRALIB_LIBRARY})
endif( TERRALIB_FOUND )

### --------------
#MySQL 
if(MINGW) 
	set(MYSQL_INCLUDE_DIR ${DEPS}/terralib/src/MySQL/)
	set(MYSQL_LIBRARIES ${DEPS}/terralib/dependencies/win32/MySQL/lib/mingw)
	set(MYSQL_LIBRARY ${MYSQL_LIBRARIES}/libmysql_mingw.a)
	set(MYSQL_FOUND true)
elseif(MINGW)
	find_package(MySQL)
endif(MINGW) 

if( MYSQL_FOUND )
		message(" -- found MySQL library ${MYSQL_LIBRARY} and include dir ${MYSQL_INCLUDE_DIR}")
		include_directories(${SRCDIR} ${MYSQL_INCLUDE_DIR})
		set(LIBS ${LIBS} ${MYSQL_LIBRARY})
		#list(APPEND SRCS ${TERRALIB_MYSQL_INCLUDE_DIR}/TeMySQL.cpp)
endif( MYSQL_FOUND )

if(MINGW) 
	#TE_MYSQL
	set(TE_MYSQL_LIBRARY ${TERRALIB_LIBRARIES}/libte_mysql.a)
	set(LIBS ${LIBS} ${TE_MYSQL_LIBRARY})
endif(MINGW)

### --------------
#JPEG
if(MINGW)
	set(JPEG_INCLUDE_DIR ${DEPS}/terralib/src/libjpeg)
	set(JPEG_LIBRARIES ${DEPS}/terralib/Release/win32-g++/)
	set(JPEG_LIBRARY ${JPEG_LIBRARIES}/libjpeg.a)
	set(LIBS ${LIBS} ${JPEG_LIBRARY})
else(MINGW)
	find_package(JPEG REQUIRED)
	set(LIBS ${LIBS} ${JPEG_LIBRARIES})
endif(MINGW)
link_directories(${JPEG_LIBRARIES})
include_directories(${JPEG_INCLUDE_DIR})

### --------------
#QWT
if(MINGW)
	set(QWT_INCLUDE_DIR ${DEPS}/qwt/src)
	set(QWT_LIBRARIES ${DEPS}/qwt/lib)
	set(QWT_LIBRARY ${QWT_LIBRARIES}/libqwt5.a)
	set(QWT_FOUND true)
	if( QWT_FOUND )
		message(" -- found qwt library ${QWT_LIBRARY} and include_dir ${QWT_INCLUDE_DIR}")
		include_directories(${QWT_INCLUDE_DIR})
		link_directories(${QWT_LIBRARIES})
		set(LIBS ${LIBS} ${QWT_LIBRARY})
	endif( QWT_FOUND )
else(MINGW)
	find_package(qwt-qt4)
	if( QWT_FOUND )
		message(" -- found qwt library ${QWT_LIBRARY} and include_dir ${QWT_INCLUDE_DIR}")
		include_directories(${QWT_INCLUDE_DIR})
		link_directories(${QWT_LIBRARY_DIR})
		if(QWTQT4_LIBRARY)
			set(LIBS ${LIBS} ${QWTQT4_LIBRARY})
		else(QWTQT4_LIBRARY)
			set(LIBS ${LIBS} ${QWT_LIBRARY})
		endif(QWTQT4_LIBRARY)
	endif( QWT_FOUND )
endif(MINGW)


### --------------
#LUA51
if(MINGW)
	set(LUA_INCLUDE_DIR ${DEPS}/lua/include)
	set(LUA_LIBRARIES ${DEPS}/lua/lib)
	Set(LUA_LIBRARY ${LUA_LIBRARIES}/liblua5.1.a)
	set(LIBS ${LIBS} ${LUA_LIBRARY})
else(MINGW)
	find_package(Lua51)
	set(LIBS ${LIBS} ${LUA_LIBRARIES})
endif(MINGW)
link_directories(${LUA_LIBRARIES})
include_directories(${LUA_INCLUDE_DIR})

### --------------
#QT4
find_package(Qt4)
set(QT_USE_QTNETWORK TRUE)
include(${QT_USE_FILE})
set(LIBS ${LIBS} ${QT_LIBRARIES})
link_directories(${QT_LIBRARIES})
include_directories(${QT_INCLUDES})

## ------------------------------------------------------------------------------------------------------------- ##
# Set Qt moc parameters

set(MOC_SRCS)

set(MOC_HDRS
    ${SRCDIR}/observer/types/observerMap.h
    ${SRCDIR}/observer/types/observerGraphic.h
    ${SRCDIR}/observer/types/observerScheduler.h
    ${SRCDIR}/observer/types/observerStateMachine.h
    ${SRCDIR}/observer/types/image/imageGUI.h
    ${SRCDIR}/observer/types/udpSender/udpSenderGUI.h
    ${SRCDIR}/observer/components/player/playerGUI.h
    ${SRCDIR}/observer/components/console/modelConsole.h
    ${SRCDIR}/observer/components/legend/legendWindow.h
    ${SRCDIR}/observer/components/legend/legendColorBar.h
    ${SRCDIR}/observer/components/painter/painterWidget.h
    ${SRCDIR}/observer/components/painter/painterThread.h
    ${SRCDIR}/observer/components/receiver/receiver.h
    ${SRCDIR}/observer/components/canvas.h
    ${SRCDIR}/observer/types/chartPlot/chartPlot.h
    ${SRCDIR}/observer/types/chartPlot/internalCurve.h
    ${SRCDIR}/observer/types/chartPlot/plotPropertiesGUI.h
)

set(MOC_RSRCS 
	${SRCDIR}/observer/observerResource.qrc
)

set(UIS
	${SRCDIR}/observer/components/console/modelConsoleGUI.ui
        ${SRCDIR}/observer/components/player/playerGUI.ui
	${SRCDIR}/observer/components/receiver/receiverGUI.ui
        ${SRCDIR}/observer/types/image/imageGUI.ui
        ${SRCDIR}/observer/types/udpSender/udpSenderGUI.ui
        ${SRCDIR}/observer/types/chartPlot/plotPropertiesGUI.ui
)

qt4_wrap_cpp(MOC_SRCS ${MOC_HDRS})
qt4_add_resources(MOC_SRCS ${MOC_RSRCS})
qt4_wrap_ui(UI_SRCS ${UIS})

include_directories(${CMAKE_CURRENT_BINARY_DIR})

## ------------------------------------------------------------------------------------------------------------- ##
# Add Target and link directories, and link with libraries
#add_executable( TerraME ${SRCS} ${MOC_SRCS})
add_executable( TerraME ${SRCS} ${MOC_SRCS} ${UI_SRCS})
link_directories(/usr/lib) # Set link directories
target_link_libraries(TerraME ${LIBS}) # Link with libraries

#message("${LIBS}")
#message("${SRCS}")

## ------------------------------------- Set Installation procedure -------------------------------------------- ##
#INSTALL(TARGETS TerraME
#    RUNTIME DESTINATION /usr/bin/TerraME
#)
