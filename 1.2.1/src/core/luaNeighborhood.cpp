/************************************************************************************
TerraLib - a library for developing GIS applications.
Copyright � 2001-2007 INPE and Tecgraf/PUC-Rio.

This code is part of the TerraLib library.
This library is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public
License as published by the Free Software Foundation; either
version 2.1 of the License, or (at your option) any later version.

You should have received a copy of the GNU Lesser General Public
License along with this library.

The authors reassure the license terms regarding the warranties.
They specifically disclaim any warranties, including, but not limited to,
the implied warranties of merchantability and fitness for a particular purpose.
The library provided hereunder is on an "as is" basis, and the authors have no
obligation to provide maintenance, support, updates, enhancements, or modifications.
In no event shall INPE and Tecgraf / PUC-Rio be held liable to any party for direct,
indirect, special, incidental, or consequential damages arising out of the use
of this library and its documentation.
*************************************************************************************/
/*! \file luaNeighborhood.cpp
    \brief This file contaisn implementations  for the luaNeighborhood objects.
        \author Tiago Garcia de Senna Carneiro
*/

#include "luaCellularSpace.h"
#include "luaNeighborhood.h"

extern lua_State * L; ///< Gobal variabel: Lua stack used for comunication with C++ modules.

/// constructor
luaNeighborhood::luaNeighborhood(lua_State *) { 

    it = CellNeighborhood::begin();
    itNext = false;
}

/// destructor
luaNeighborhood::~luaNeighborhood( void ) { luaL_unref( L, LUA_REGISTRYINDEX, ref); } 

/// Adds a new cell to the luaNeigborhood
/// parameters: cell.y, cell.x,  cell, weight
/// return luaCell
int luaNeighborhood::addNeighbor(lua_State *L) {  
    double weight = luaL_checknumber(L, -1);
    luaCell *cell = Luna<luaCell>::check(L, -2);
    CellIndex cellIndex;
    cellIndex.second = luaL_checknumber(L, -3);
    cellIndex.first = luaL_checknumber(L, -4);
    if( cell != NULL ) {
        CellNeighborhood::add(cellIndex, (Cell*)cell, weight);
        ::getReference(L, cell);
    }
    else lua_pushnil( L );
    return 1;
}

/// Removes a cell from the luaNeighborhood
/// parameters: cell.x, cell.y
/// \author Raian Vargas Maretto
int luaNeighborhood::eraseNeighbor(lua_State *L) {
//	luaCell *cell = (luaCell*)Luna<luaCell>::check(L, -1);
	CellIndex cellIndex; 
	cellIndex.second = luaL_checknumber(L, -2);
	cellIndex.first = luaL_checknumber(L, -3);
	if( it != CellNeighborhood::end() && it->first == cellIndex){
		it++;
		itNext = true;
	}
	CellNeighborhood::erase( cellIndex );
	return 0;
}


/// Adds a new luaNeighbor cell into the luaNeighborhood
/// parameters: cell index,  cell, weight
/// return luaCell
int luaNeighborhood::addCell(lua_State *L) {  
    double weight = luaL_checknumber(L, -1);
    luaCellularSpace *cs = Luna<luaCellularSpace>::check(L,-2);
    luaCellIndex *cI = Luna<luaCellIndex>::check(L, -3);
    CellIndex cellIndex; cellIndex.first = cI->x; cellIndex.second = cI->y;
    luaCell *cell = ::findCell( cs, cellIndex );
    if( cell != NULL ) {
        CellNeighborhood::add(cellIndex, (Cell*)cell, weight);
        ::getReference(L, cell);
    }
    else lua_pushnil( L );
    return 1;
}

/// Removes the luaNeighbor cell from the luaNeighborhood
/// parameters: cell index
int luaNeighborhood::eraseCell(lua_State *L) {  
    luaCellIndex *cI = Luna<luaCellIndex>::check(L, -1);
    CellIndex cellIndex; cellIndex.first = cI->x; cellIndex.second = cI->y;
    // Raian: Coloquei esta compara��o porque quando um vizinho era retirado da vizinhan�a o iterador era invalidado
    // Aqui fa�o o tratamento para que isto n�o ocorra.
    if( it != CellNeighborhood::end() && it->first == cellIndex){
        it++;
        itNext = true;
    }
    CellNeighborhood::erase( cellIndex );
    return 0;
}

/// Gets the luaNeighborhood relationship weight value for the luaNeighbor idexed by the 2D coordenates received 
/// as parameter
/// parameters: cell index 
/// return weight
int luaNeighborhood::getCellWeight(lua_State *L) {  
    luaCellIndex *cI = Luna<luaCellIndex>::check(L, -1);
    CellIndex cellIndex; cellIndex.first = cI->x; cellIndex.second = cI->y;
    lua_pushnumber( L, CellNeighborhood::getWeight( cellIndex ) );
    return 1;
}

/// Gets the luaNeighbor cell idexed by the 2D coordenates received as parameter
/// parameters: cell index, 
/// return luaCell
int luaNeighborhood::getCellNeighbor(lua_State *L) {  
    luaCellIndex *cI = Luna<luaCellIndex>::check(L, -1);
    CellIndex cellIndex; cellIndex.first = cI->x; cellIndex.second = cI->y;
    luaCell *cell = (luaCell*)(*CellNeighborhood::pImpl_)[ cellIndex ];
    if( cell ) ::getReference(L, cell);
    else lua_pushnil( L );
    return 1;
}

/// Gets the luaNeighborhood relationship weight value for the luaNeighbor idexed by the 2D coordenates received 
/// as parameter.
/// no parameters
int luaNeighborhood::getWeight( lua_State *L )
{
    double weight = 0;
    CellIndex cellIndex;
    if( it != CellNeighborhood::end() ){
        cellIndex = it->first;
        weight = CellNeighborhood::getWeight( cellIndex );
    }
    lua_pushnumber( L, weight);
    return 1;
}

/// Gets the luaNeighbor cell pointed by the Nieghborhood interator.
/// no parameters
int luaNeighborhood::getNeighbor( lua_State *L )
{
    CellIndex cellIndex;
    if( it != CellNeighborhood::end() ){
        cellIndex = it->first;
        luaCell *cell = (luaCell*) it->second; //dynamic_cast<luaCell*>(it->second);
        ::getReference(L, cell);
        return 1;
    }
    lua_pushnil( L);
    return 1;
}


/// Gets luaNeighbor identifier
/// no parameters
int luaNeighborhood::getID( lua_State *L )
{
    const char *str = this->CellNeighborhood::getID().c_str();
    if( str ) lua_pushstring(L, str );
    else lua_pushnil( L);
    return 1;
}

/// Sets the weight of a neighborhood relationship
/// parameters: cell.x, cell.y, weight
/// \author Raian Vargas Maretto
int luaNeighborhood::setNeighWeight(lua_State *L) {  
	double weight = luaL_checknumber(L, -1);
//	luaCell *cell = (luaCell*)Luna<luaCell>::check(L, -2);
	CellIndex cellIndex; 
	cellIndex.second = luaL_checknumber(L, -3); 
	cellIndex.first = luaL_checknumber(L, -4);
	CellNeighborhood::setWeight( cellIndex, weight );
	return 0;
}

//Raian:
/// Gets the weight of a neighborhood relationship
/// parameters: cell.x, cell.y
/// \author Raian Vargas Maretto
int luaNeighborhood::getNeighWeight(lua_State *L) {
	//luaCell *cell = (luaCell*)Luna<luaCell>::check(L, -1);
	CellIndex cellIndex;
	cellIndex.second = luaL_checknumber(L, -2);
	cellIndex.first = luaL_checknumber(L, -3);
	double weight = CellNeighborhood::getWeight(cellIndex);
	lua_pushnumber(L, weight);
	return 1;
}

/// Sets the weight for the neighborhood relationship with the cell indexed by the coordenates 
/// received as parameter.
/// parameters: cell index, weight
int luaNeighborhood::setCellWeight(lua_State *L) {  
    double weight = luaL_checknumber(L, -1);
    luaCellIndex *cI = Luna<luaCellIndex>::check(L, -2);
    CellIndex cellIndex; cellIndex.first = cI->x; cellIndex.second = cI->y;
    CellNeighborhood::setWeight( cellIndex, weight );
    return 0;
}

/// Sets the weight for the neighborhood relationship with the Neighbor pointed by the Neighborhood iterator.
/// parameters: weight
int luaNeighborhood::setWeight( lua_State *L) {
    double weight = luaL_checknumber(L, -1);
    CellIndex cellIndex;
    if( it != CellNeighborhood::end() ){
        cellIndex = it->first;
        CellNeighborhood::setWeight( cellIndex, weight );
    }
    return 0;
}

/// Puts the Neighborhood iterator in the beginning of the Neighbor composite data structure  
/// no parameters
int luaNeighborhood::first( lua_State *)
{
    it = CellNeighborhood::begin();
    return 0;
}

/// Puts the Neighborhood iterator in the end of the Neighbor composite data structure  
/// no parameters
int luaNeighborhood::last( lua_State *)
{
    it = CellNeighborhood::end();
    return 0;
}

/// Returns true if the Neighborhood iterator is in the beginning of the Neighbor composite data structure  
/// no parameters
int luaNeighborhood::isFirst( lua_State *L )
{
    lua_pushboolean(L, it == CellNeighborhood::begin());
    return 1;
}

/// Returns true if the Neighborhood iterator is in the end of the Neighbor composite data structure  
/// no parameters
int  luaNeighborhood::isLast( lua_State *L )
{
    lua_pushboolean(L, it == CellNeighborhood::end());
    return  1;
}

/// Verifies if a cell is a neighbor 
/// parameters: cell.x, cell.y
/// return: true if cell is within the luaNeighborhood, otherwise retuens false
/// \author Raian Vargas Maretto
int luaNeighborhood::isNeighbor( lua_State *L )
{
//  luaCell *cell = (luaCell*)Luna<luaCell>::check(L, -1);
  CellIndex cellIndex; 
  cellIndex.second = luaL_checknumber(L, -2);
  cellIndex.first = luaL_checknumber(L, -3);
  CellNeighborhood::iterator itAux;
  itAux = CellNeighborhood::begin();
  bool pertence = false;
  while( itAux != CellNeighborhood::end() ){
	  if( itAux->first == cellIndex ){ 
		  pertence = true;
	  }
	  itAux++;
  }
  lua_pushboolean(L, pertence);
  return 1;
}

/// Fowards the Neighborhood iterator to the next Neighbor cell
/// no parameters
int luaNeighborhood::next( lua_State *)
{
    if( itNext ){
        itNext = false;
        return 0;
    }
    else{
        if( it != CellNeighborhood::end() ) it++;
    }
    return 0;
}

/// Gets the coordenates of the Neighbor cell pointed by the Neighborhood interator
/// no parameters
int luaNeighborhood::getCoord( lua_State *L )
{
    int x = 0, y = 0;
    if ( it != CellNeighborhood::end() )
    {
        x = it->first.first;
        y = it->first.second;
    }
    lua_pushnumber(L, y);
    lua_pushnumber(L, x);
    return 2;
}

/// Returns true if the Neighborhood is empty.
/// no parameters
int luaNeighborhood::isEmpty(lua_State *L) {  
    lua_pushboolean(L, CellNeighborhood::empty() );
    return 1;
}

/// Clears all the Neighborhood content
/// no parameters
int luaNeighborhood::clear(lua_State *) {  
    CellNeighborhood::clear( );
    return 0;
}

/// Returns the number of Neighbors cells in the Neighborhood
/// no parameters
int luaNeighborhood::size(lua_State *L) {  
    lua_pushnumber(L,CellNeighborhood::size( ));
    return 1;
}

/// Registers the Lua object in the Lua stack, storing its reference
int luaNeighborhood::setReference( lua_State* L)
{
    ref = luaL_ref(L, LUA_REGISTRYINDEX );
    return 0;
}

/// Gets the luaNeighborhood object reference.
/// no parameters
int luaNeighborhood::getReference( lua_State *L )
{
    lua_rawgeti(L, LUA_REGISTRYINDEX, ref);
    return 1;
}

// int luaTrajectory::createObserver( lua_State *L )
// {
// return 0;
// }

// int luaTrajectory::notifyObservers(lua_State *L )
// {
// return 0;
// }

QDataStream& luaNeighborhood::getState(QDataStream& in, Subject *, int observerId, QStringList &attribs)
{
#ifdef DEBUG_OBSERVER
    printf("\ngetState\n\nobsAttribs.size(): %i\n", obsAttribs.size());
    luaStackToQString(12);
#endif

    int obsCurrentState = 0; //serverSession->getState(observerId);
    QString content;

    switch(obsCurrentState)
    {
        case 0:
            content = getAll(in, observerId, attribs);
            // serverSession->setState(observerId, 1);
            // qWarning(QString("Observer %1 passou ao estado %2").arg(observerId).arg(1).toAscii().constData());
            break;

        case 1:
            content = getChanges(in, observerId, attribs);
            // serverSession->setState(observerId, 0);
            // qWarning(QString("Observer %1 passou ao estado %2").arg(observerId).arg(0).toAscii().constData());
            break;
    }
    // cleans the stack
    // lua_settop(L, 0);

    in << content;
    return in;
}

QString luaNeighborhood::pop(lua_State *, QStringList &)
{
    return QString();
}

QString luaNeighborhood::getAll(QDataStream& /*in*/, int /*observerId*/, QStringList& /*attribs*/)
{
    return QString();
}

QString luaNeighborhood::getChanges(QDataStream& in, int observerId, QStringList& attribs)
{
    return getAll(in,observerId,attribs);
}
