/************************************************************************************
TerraLib - a library for developing GIS applications.
Copyright © 2001-2007 INPE and Tecgraf/PUC-Rio.

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
/*! \file luaCellularSpace.cpp
\brief This file contains implementations for the luaCellularSpace objects.
\author Tiago Garcia de Senna Carneiro
*/

#include "luaCellIndex.h"
#include "luaCellularSpace.h"
#include "luaNeighborhood.h"

// Observadores
#include "../observer/types/observerUDPSender.h"
#include "../observer/types/agentObserverMap.h"
#include "../observer/types/agentObserverImage.h"

#define TME_STATISTIC_UNDEF

#ifdef TME_STATISTIC
   // Estatisticas de desempenho
   #include "../observer/statistic/statistic.h"
#endif


// RODRIGO
#if defined( TME_MSVC ) && defined( TME_WIN32 )
#include <TeAdoDB.h>
#include <windows.h>
#endif

#include <TeLegendEntry.h>
#include <TeMySQL.h>
#include <TeVersion.h>
#include <TeDefines.h>

//#if ! defined( TME_TERRALIB_RC3 )
//#include <TeInitQuerierStrategy.h>
//#endif

#include <TeQuerier.h>
#include <TeQuerierParams.h>

#include <TeProgress.h>
#include <TeGeneralizedProxMatrix.h>
#include "loadNeighborhood.h"
#include "luaUtils.h"

#include <fstream>

#ifndef WIN32
#define stricmp strcasecmp
#define strnicmp strncasecmp
#endif

///< Gobal variabel: Lua stack used for comunication with C++ modules.
extern lua_State * L; 

///< true - TerrME runs in verbose mode and warning messages to the user; 
// false - it runs in quite node and no messages are shown to the user.
extern bool QUIET_MODE; 

using namespace TerraMEObserver;

/// constructor
luaCellularSpace::luaCellularSpace(lua_State *L) 
{  
    dbType = "mysql";
    host = "localhost";
    dbName = "";
    user = "";
    pass = "";
    inputLayerName = "";
    inputThemeName = "";

    // Antonio
    luaL = L;
    subjectType = TObsCellularSpace;
    observedAttribs.clear();
}

/// Sets the database type: MySQL, ADO, etc.
int luaCellularSpace::setDBType(lua_State *L )
{
    dbType =  string(lua_tostring(L, -1));
    return 0;
}

/// Sets the host name.
int luaCellularSpace::setHostName(lua_State *L )
{
    host =  string(lua_tostring(L, -1));
    return 0;
}

/// Sets the database name.
int luaCellularSpace::setDBName(lua_State *L )
{
    dbName =  string(lua_tostring(L, -1));
    return 0;
}

/// Sets the user name.
int luaCellularSpace::setUser(lua_State *L )
{
    user = string(lua_tostring(L, -1));
    return 0;
}

/// Sets the password name.
int luaCellularSpace::setPassword(lua_State *L )
{
    pass =  string(lua_tostring(L, -1));
    return 0;
}

/// Sets the geographical database layer name 
int luaCellularSpace::setLayer(lua_State *L )
{
    inputLayerName = string(lua_tostring(L, -1));
    return 0;
}

/// Sets the geographical database theme name
int luaCellularSpace::setTheme(lua_State *L)
{
    inputThemeName = string(lua_tostring(L, -1));
    return 0;
}

/// Clears the cellular space attributes names
int luaCellularSpace::clearAttrName(lua_State *L)
{
    attrNames.clear();
    return 0;
}

/// Adds a new attribute name to the CellularSpace attributes table used in the load function
int luaCellularSpace::addAttrName( lua_State *L)
{
    attrNames.push_back( lua_tostring(L, -1) );
    return 0;
}

/// Sets the SQL WHERE CLAUSE to the string received as parameter
int luaCellularSpace::setWhereClause(lua_State *L)
{
    whereClause =  string(lua_tostring(L,-1));
    return 0;
}

/// Clear all luaCellularSpace object content (cells)
int luaCellularSpace::clear(lua_State *L)
{
    CellularSpace::clear();
    return 0;
}

/// Adds a the luaCell received as parameter to the luaCellularSpace object
/// parameters: x, y, luaCell
int luaCellularSpace::addCell( lua_State *L)	 
{ 
    CellIndex indx;
    luaCell *cell = Luna<luaCell>::check(L,-1);
    indx.second = luaL_checknumber(L, -2);
    indx.first = luaL_checknumber(L, -3);
    CellularSpace::add( indx, cell);

    return 0;
}

/// Gets the luaCell object within the CellularSpace identified by the coordenates received as parameter
/// parameters: cell index
int luaCellularSpace::getCell(lua_State *L)
{  
    luaCellIndex *cI = Luna<luaCellIndex>::check(L, -1);
    CellIndex cellIndex; cellIndex.first = cI->x; cellIndex.second = cI->y;
    luaCell *cell = ::findCell( this, cellIndex );
    if( cell != NULL ) 
        ::getReference(L, cell);
    else 
        lua_pushnil( L );
    return 1;
}

/// Returns the number of cells of the CellularSpace object
/// no parameters
int luaCellularSpace::size(lua_State* L)
{
    lua_pushnumber(L, CellularSpace::size());
    return 1;
}

/// Registers the luaCellularSpace object in the Lua stack
int luaCellularSpace::setReference( lua_State* L)
{
    ref = luaL_ref(L, LUA_REGISTRYINDEX );
    return 0;
}

/// Gets the luaCellularSpace object reference
int luaCellularSpace::getReference( lua_State *L )
{
    lua_rawgeti(L, LUA_REGISTRYINDEX, ref);
    return 1;
}

/// Creates several types of observers to the luaCellularSpace object
/// parameters: observer type, observeb attributes table, observer type parameters
int luaCellularSpace::createObserver( lua_State * luaL)
{
    getSpaceDimensions = false;

#ifdef DEBUG_OBSERVER
    luaStackToQString(12);
#endif

    // flags para a definição do uso de compressão
    // na transmissão de datagramas e da visibilidade
    // dos observadores Udp Sender e Image
    bool compressDatagram = false, obsVisible = true;

    // recupero a tabela de atributos da celula
    int top = lua_gettop(luaL);

    // Não modifica em nada a pilha recupera o enum referente ao tipo
    // do observer
    int typeObserver = (int)luaL_checkinteger(luaL, top - 4);

    if (! lua_istable(luaL, top - 3) )
    {
        qFatal("\nError: The Attribute table not found. Incorrect sintax.\n");
        return -1;
    }

    if (! lua_istable(luaL, top - 2) )
    {
        qFatal("\nError: The Parameter table not found. Incorrect sintax.\n");
        return -1;
    }

    // FIX-ME: Não funciona
    if (! lua_istable(luaL, top - 1) )
    {
        qFatal("\nError: Cells not found.\n");
        return -1;
    }

    QStringList obsParams, obsParamsAtribs; // parametros/atributos da legenda
    QStringList obsAttribs;
    QStringList imagePath; //diretorio onde as imagens do ObsImage serão salvas

    const char *strAux;
    double numAux = -1;
    //int cellsNumber = 0;
    bool boolAux = false;

#ifdef DEBUG_OBSERVER
    qDebug("\npos table: %i\nRecuperando os parametros:\n", top);
#endif

    //----------------------------------------------------------------
    //------- RECUPERA A TABELA PARAMETROS

    // Recupera a tabela de parametros
    lua_pushnil(luaL);

#ifdef DEBUG_OBSERVER
    luaStackToQString(12);
    stackDump(luaL);
#endif

    while(lua_next(luaL, top - 1) != 0)
    {

        lua_pushstring(luaL, "Minimum");
        lua_gettable(luaL, -1);

#ifdef DEBUG_OBSERVER
        luaStackToQString(12);
        stackDump(luaL);
#endif

        //********************************************************************************
        int firstLegPos = lua_gettop(luaL);
        int iAux = 1;

        // percorre cada item da tabela parametros
        lua_pushnil(luaL);

        if (! lua_istable(luaL, firstLegPos - 1) )
        {
            // ---- Observer Image: Recupera o path/nome dos arquivos de imagem
            if (typeObserver == TObsImage)
            {
                if (lua_type(luaL, firstLegPos - 1) == LUA_TSTRING)
                {
                    // recupera o path para o arquivo
                    QString k( luaL_checkstring(luaL, firstLegPos - 1));
                    imagePath.push_back(k);
                }
                else
                {
                    if (lua_type(luaL, firstLegPos - 1) == LUA_TBOOLEAN)
                        obsVisible = lua_toboolean(luaL, firstLegPos - 1);
                }
                iAux = 4;
            }
            else
            {
                qFatal("\nError: incorrect sintaxe. Was expected a %s.\n",
                    (typeObserver == (int)TObsMap) ? "table" : "string");
                return -1;
            }
            lua_pop(luaL, 1); // lua_pushnil
        }
        else
        {

#ifdef DEBUG_OBSERVER
            luaStackToQString(12);
            stackDump(luaL);
#endif

            while (lua_next(luaL, firstLegPos - iAux) != 0)
            {
                QString key;

                if (lua_type(luaL, -2) == LUA_TSTRING)
                {
                    key = luaL_checkstring(luaL, -2);
                }
                else
                {
                    if (lua_type(luaL, -2) == LUA_TNUMBER)
                    {
                        char aux[100];
                        double number = luaL_checknumber(luaL, -2);
                        sprintf(aux, "%g", number);
                        key = aux;
                    }
                }
                obsParams.push_back(key);

                switch( lua_type(luaL, -1) )
                {
                case LUA_TBOOLEAN:
                    boolAux = lua_toboolean(luaL, -1);
                    //obsParamsAtribs.push_back(boolAux ? "true" : "false");
                    // Recupera o valor do paramentro
                    if (key == "compress")
                        compressDatagram = boolAux;

                    // Recupera o valor do paramentro
                    if (key == "visible")
                        obsVisible = boolAux;
                    break;

                case LUA_TNUMBER:
                    numAux = luaL_checknumber(luaL, -1);
                    obsParamsAtribs.push_back(QString::number(numAux));
                    break;

                case LUA_TSTRING:
                    strAux = luaL_checkstring(luaL, -1);
                    obsParamsAtribs.push_back(strAux);
                    break;

                case LUA_TNIL:
                case LUA_TTABLE:
                default:
                    // qWarning("%s - Just \"number\" or \" string\" are observable.\n", qPrintable(key));
                    break;
                }

                lua_pop(luaL, 1); // lua_pushnil
            }
        }
        //********************************************************************************

        lua_pop(luaL, 1); // lua_pushstring
        lua_pop(luaL, 1); // lua_pushnil
    }

    //----------------------------------------------------------------
    //------- RECUPERA A TABELA ATRIBUTOS

#ifdef DEBUG_OBSERVER
    qDebug("\npos table: %i\nRecuperando todos os atributos:\n", top);
#endif
    // Recupera a tabela de atributos
    lua_pushnil(luaL);
    while(lua_next(luaL, top - 2) != 0)
    {
        QString key( luaL_checkstring(luaL, -1) );
        obsAttribs.push_back(key);
        lua_pop(luaL, 1);
    }

    if ((typeObserver == TObsImage) || (typeObserver == TObsMap))
    {
        // LEGEND_ITENS esta definido dentro do observer.h
        if (obsAttribs.size() * LEGEND_ITENS < obsParams.size())
            if (! QUIET_MODE )
            {
                qWarning("Warning: The number of attributes is lower "
                    "than the number of legends.");
            }
    }

    //----------------------------------------------------------------
    //------- RECUPERA A TABELA DIMENSÃO

#ifdef DEBUG_OBSERVER
    printf("\npos table: %i\nRecuperando dimensões:\n", top);
#endif
    QList<int> obsDim;

    // Recupera a tabela de dimensões
    lua_pushnil(luaL);
    while(lua_next(luaL, top - 3) != 0)
    {
        int v = luaL_checknumber(luaL, -1);

#ifdef DEBUG_OBSERVER
        qDebug() << v;
#endif
        obsDim.push_back(v);
        lua_pop(luaL, 1);
    }

    int width, height;
    if (! obsDim.isEmpty())
    {
        width = obsDim.at(0);
        height = obsDim.at(1);
        if (( width > 0) && (height > 0))
            getSpaceDimensions = true;
    }

    ///////////////////////////--------------------------------------------
    lua_pushnumber(luaL, 1);
    lua_gettable(luaL, top );
    int firstCellPos = lua_gettop(luaL);

    QStringList allAttribCells;

    // percorre o espaço celular
    lua_pushnil(luaL);
    while(lua_next(luaL, firstCellPos ) != 0)
    {
        QString key( luaL_checkstring(luaL, -2) );
        allAttribCells << key;
        lua_pop(luaL, 1); 
    }

    if (obsAttribs.isEmpty())
    {
        obsAttribs = allAttribCells;
        observedAttribs = allAttribCells;
    }
    else
    {
        // posição da celula no espaço celular
        obsAttribs.push_back("x");
        obsAttribs.push_back("y");

        // Verifica se o atributo informado realmente existe na celula
        for (int i = 0; i < obsAttribs.size(); i++)
        {
            if (! observedAttribs.contains(obsAttribs.at(i)) )
                observedAttribs.push_back(obsAttribs.at(i));

            if (! allAttribCells.contains(obsAttribs.at(i)) )
            {
                qFatal("\nError: Attribute name '%s' not found.\n", 
                    qPrintable(obsAttribs.at(i)) );
                return 0;
            }
        }
    }

#ifdef DEBUG_OBSERVER
    luaStackToQString(12);
    qDebug("\n\nlua_gettop(luaL): %i -------------\n\n", lua_gettop(luaL));
#endif

    AgentObserverMap *obsMap = 0;
    ObserverUDPSender *obsUDPSender = 0;
    AgentObserverImage *obsImage = 0;

    int obsId = -1;

    switch (typeObserver)
    {
    case TObsMap:
        obsMap = (AgentObserverMap *) CellSpaceSubjectInterf::createObserver(TObsMap);
        if (obsMap)
        {
            obsId = obsMap->getId();
        }
        else
        {
            if (! QUIET_MODE)
                qWarning("%s", TerraMEObserver::MEMORY_ALLOC_FAILED);
        }
        break;

    case TObsUDPSender:
        obsUDPSender = (ObserverUDPSender *) CellSpaceSubjectInterf::createObserver(TObsUDPSender);
        if (obsUDPSender)
        {
            obsId = obsUDPSender->getId();
            obsUDPSender->setCompressDatagram(compressDatagram);

            if (obsVisible)
                obsUDPSender->show();
        }
        else
        {
            if (! QUIET_MODE)
                qWarning("%s", TerraMEObserver::MEMORY_ALLOC_FAILED);
        }
        break;

    case TObsImage:
        obsImage = (AgentObserverImage *) CellSpaceSubjectInterf::createObserver(TObsImage);
        if (obsImage)
        {
            obsId = obsImage->getId();
            
            if (obsVisible)
                obsImage->show();
        }
        else
        {
            if (! QUIET_MODE)
                qWarning("%s", TerraMEObserver::MEMORY_ALLOC_FAILED);
        }
        break;

    default:
        if (! QUIET_MODE )
        {
            qWarning("Warning: In this context, the code '%s' does not "
                "correspond to a valid type of Observer.",  getObserverName(typeObserver) );
        }
        return 0;
    }

    if (obsMap)
    {
        if (getSpaceDimensions)
            obsMap->setCellSpaceSize(width, height);

        ((ObserverMap *)obsMap)->setHeaders(obsAttribs, obsParams, obsParamsAtribs);
        observersHash.insert(obsMap->getId(), obsMap);
        lua_pushnumber(luaL,  obsMap->getId());

        // Antonio
        // push objeto na pilha
        return 1;
    }

    if (obsUDPSender)
    {
        obsUDPSender->setAttributes(obsAttribs);

        // if (obsParamsAtribs.at(0).isEmpty())
        if (obsParamsAtribs.isEmpty())
        {
            if (! QUIET_MODE )
                qWarning("Warning: Port not defined.");
        }
        else
        {
            obsUDPSender->setPort(obsParamsAtribs.at(0).toInt());
        }

        // broadcast
        if ((obsParamsAtribs.size() == 1)
            || ((obsParamsAtribs.size() == 2) && obsParamsAtribs.at(1).isEmpty()) )
        {
            if (! QUIET_MODE )
                qWarning("Warning: Observer will send to broadcast.");
            obsUDPSender->addHost(BROADCAST_HOST);
        }
        else
        {
            // multicast or unicast
            for(int i = 1; i < obsParamsAtribs.size(); i++){
                if (! obsParamsAtribs.at(i).isEmpty())
                    obsUDPSender->addHost(obsParamsAtribs.at(i));
            }
        }

        lua_pushnumber(luaL, obsId);
        return 1;
    }

    if(obsImage)
    {
        if (getSpaceDimensions)
            obsImage->setCellSpaceSize(width, height);

        obsImage->setHeaders(obsAttribs, obsParams, obsParamsAtribs);
        observersHash.insert(obsImage->getId(), obsImage);

        if (imagePath.isEmpty())
        {
            obsImage->setPath();
        }
        else
        {
            if (imagePath.size() == 1)
                obsImage->setPath( imagePath.at(0) );
            else
                obsImage->setPath(imagePath.at(0), imagePath.at(1));
        }

        lua_pushnumber(luaL, obsId);
        return 1;
    }
    return 0;
}

const TypesOfSubjects luaCellularSpace::getType()
{
    return subjectType;
}

/// Notifies the Observer objects about changes in the luaCellularSpace internal state
int luaCellularSpace::notify(lua_State * )
{
    double time = luaL_checknumber(L, -1);

#ifdef TME_STATISTIC
   double t = Statistic::getInstance().startTime();

   CellSpaceSubjectInterf::notify(time);

   t = Statistic::getInstance().endTime() - t;
   Statistic::getInstance().addElapsedTime("Total Response Time - cellspace", t);
   Statistic::getInstance().collectMemoryUsage();
#else
    CellSpaceSubjectInterf::notify(time);
#endif

    return 0;
}

/// Returns the Agent Map Observers linked to this cellular space
Observer * luaCellularSpace::getObserver(int id)
{
    if (observersHash.contains(id))
        return observersHash.value(id);
    else
        return NULL;
}
//@Rodrigo
QString luaCellularSpace::getAll(QDataStream& /*in*/, int /*observerId*/ , QStringList &attribs)
{
    lua_rawgeti(luaL, LUA_REGISTRYINDEX, ref);	// recupero a referencia na pilha lua
    return pop(luaL, attribs);
}

QString luaCellularSpace::getChanges(QDataStream& in, int observerId , QStringList &attribs)
{
    return getAll(in, observerId, attribs);
}

//------------
/// Serializes the luaCellularSpace object to the Observer objects
#ifdef TME_BLACK_BOARD
QDataStream& luaCellularSpace::getState(QDataStream& in, Subject *, int observerId, QStringList & /* attribs */)
#else
QDataStream& luaCellularSpace::getState(QDataStream& in, Subject *, int observerId, QStringList &  attribs )
#endif
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
#ifdef TME_BLACK_BOARD
        content = getAll(in, observerId, observedAttribs);
#else
        content = getAll(in, observerId, attribs);
#endif

        // serverSession->setState(observerId, 1);
        //if (! QUIET_MODE )
        // 	qWarning(QString("Observer %1 passou ao estado %2").arg(observerId).arg(1).toAscii().constData());
        break;

    case 1:
#ifdef TME_BLACK_BOARD
        content = getChanges(in, observerId, observedAttribs);
#else
        content = getChanges(in, observerId, attribs);
#endif

        // serverSession->setState(observerId, 0);
        //if (! QUIET_MODE )
        // 	qWarning(QString("Observer %1 passou ao estado %2").arg(observerId).arg(0).toAscii().constData());
        break;
    }
    // cleans the stack
    // lua_settop(L, 0);

    in << content;
    return in;
}

QString luaCellularSpace::pop(lua_State *luaL, QStringList& attribs)
{
#ifdef DEBUG_OBSERVER	
    printf("\ngetState - CellularSpace\n\n");
    luaStackToQString(12);

    qDebug() << attribs;
#endif

    QString msg;

    // id
    msg.append("cellularSpace");
    msg.append(QString::number(this->ref));
    msg.append(PROTOCOL_SEPARATOR);

    // subjectType
    msg.append(QString::number(subjectType));
    msg.append(PROTOCOL_SEPARATOR);

    // recupero a referencia na pilha lua
    lua_rawgeti(luaL, LUA_REGISTRYINDEX, ref);

    int cellSpacePos = lua_gettop(luaL);

    //@RODRIGO
    //------------
    int attrCounter = 0;
    int elementCounter = 0;
    // bool contains = false;
    double num = 0;
    QString text, key, attrs, elements;

    lua_pushnil(luaL);
    while(lua_next(luaL, cellSpacePos ) != 0)
    {
        key = QString(luaL_checkstring(luaL, -2));

        if ((attribs.contains(key)) || (key == "cells"))
        {
            attrCounter++;
            attrs.append(key);
            attrs.append(PROTOCOL_SEPARATOR);

            switch( lua_type(luaL, -1) )
            {
            case LUA_TBOOLEAN:
                attrs.append(QString::number(TObsBool));
                attrs.append(PROTOCOL_SEPARATOR);
                attrs.append(QString::number( lua_toboolean(luaL, -1)));
                attrs.append(PROTOCOL_SEPARATOR);
                break;

            case LUA_TNUMBER:
                num = luaL_checknumber(luaL, -1);
                attrs.append(QString::number(TObsNumber));
                attrs.append(PROTOCOL_SEPARATOR);
                attrs.append(QString::number(num));
                attrs.append(PROTOCOL_SEPARATOR);
                break;

            case LUA_TSTRING:
                text = QString(luaL_checkstring(luaL, -1));
                attrs.append(QString::number(TObsText) );
                attrs.append(PROTOCOL_SEPARATOR);
                attrs.append( (text.isEmpty() || text.isNull() ? VALUE_NOT_INFORMED : text) );
                attrs.append(PROTOCOL_SEPARATOR);
                break;

            case LUA_TTABLE:
                {
                    char result[100];
                    sprintf(result, "%p", lua_topointer(luaL, -1) );
                    attrs.append(QString::number(TObsText) );
                    attrs.append(PROTOCOL_SEPARATOR);
                    attrs.append(QString("Lua-Address(TB): ") + QString(result));
                    attrs.append(PROTOCOL_SEPARATOR);

                    // Recupera a tabela de cells e delega a cada
                    // celula sua serialização
                    // if(key == "cells")
                    //{
                    int top = lua_gettop(luaL);

                    lua_pushnil(luaL);
                    while(lua_next(luaL, top) != 0)
                    {
                        int cellTop = lua_gettop(luaL);
                        lua_pushstring(luaL, "cObj_");
                        lua_gettable(luaL, cellTop);

                        luaCell*  cell;
                        cell = (luaCell*)Luna<luaCell>::check(L, -1);
                        lua_pop(luaL, 1);

                        // luaCell->pop(...) requer uma celula no topo da pilha
                        QString cellMsg = cell->pop(L, attribs);
                        elements.append(cellMsg);
                        elementCounter++;

                        lua_pop(luaL, 1);
                    }
                    break;
                    //}
                    //break;
                }

            case LUA_TUSERDATA	:
                {
                    char result[100];
                    sprintf(result, "%p", lua_topointer(luaL, -1) );
                    attrs.append(QString::number(TObsText) );
                    attrs.append(PROTOCOL_SEPARATOR);
                    attrs.append(QString("Lua-Address(UD): ") + QString(result));
                    attrs.append(PROTOCOL_SEPARATOR);
                    break;
                }

            case LUA_TFUNCTION:
                {
                    char result[100];
                    sprintf(result, "%p", lua_topointer(luaL, -1) );
                    attrs.append(QString::number(TObsText) );
                    attrs.append(PROTOCOL_SEPARATOR);
                    attrs.append(QString("Lua-Address(FT): ") + QString(result));
                    attrs.append(PROTOCOL_SEPARATOR);
                    break;
                }

            default:
                {
                    char result[100];
                    sprintf(result, "%p", lua_topointer(luaL, -1) );
                    attrs.append(QString::number(TObsText) );
                    attrs.append(PROTOCOL_SEPARATOR);
                    attrs.append(QString("Lua-Address(O): ") + QString(result));
                    attrs.append(PROTOCOL_SEPARATOR);
                    break;
                }
            }
        }
        lua_pop(luaL, 1);
    }

    // #attrs
    msg.append(QString::number(attrCounter));
    msg.append(PROTOCOL_SEPARATOR );

    // #elements
    msg.append(QString::number(elementCounter));
    msg.append(PROTOCOL_SEPARATOR );
    msg.append(attrs);

    msg.append(PROTOCOL_SEPARATOR);
    msg.append(elements);
    msg.append(PROTOCOL_SEPARATOR);

    return msg;
}

int luaCellularSpace::kill(lua_State *luaL)
{
    int id = luaL_checknumber(luaL, 1);

    bool result = CellSpaceSubjectInterf::kill(id);
    lua_pushboolean(luaL, result);
    return 1;
}

/// Loads the CellularSpace from a TerraLib database.
int luaCellularSpace::load(lua_State *L)
{

    TeDatabase * db;

    try
    {
        // Opens a connection to a database accessible
        if( dbType == "mysql")
            db = new TeMySQL();
#if defined( TME_MSVC ) && defined( TME_TERRALIB_RC3 )
        else {
            ::configureADO();
            db = new TeAdo();
        }
#endif
        if (!db->connect(host,user,pass,dbName,0))
        {
            string err_out = string("Error: ") + db->errorMessage() + string("\n");
            qFatal( "%s", err_out.c_str() );
            return 0;
        }

        string dbVersion;
        db->loadVersionStamp(dbVersion);
        if( dbVersion != TeDBVERSION ) {

            qWarning( "\nFATAL ERROR: Wrong TerraLib database version, expected \"%s\", got \"%s\".", TeDBVERSION.c_str(), dbVersion.c_str() );
            qFatal( "Please, use TerraView to update the \"%s\" database.", dbName.c_str());
            return 0;
        }

        TeTheme *inputTheme;
        TeLayer *inputLayer;
        if ( inputLayerName == "")
        {
            // Load input theme
            inputTheme = new TeTheme(inputThemeName );
            if (!db->loadTheme (inputTheme))
            {
                string err_out = string("\tCan't open input theme: ") + string(inputThemeName) + string("\n");
                qFatal( "%s", err_out.c_str() );
                db->close();
                return 0;
            }
            // Load input layers
            inputLayer = inputTheme->layer();
            if (!db->loadLayer (inputLayer))
            {
                string err_out = string("\tCan't laod input layer: ") + string(inputLayerName) + string("\n");
                qFatal( "%s", err_out.c_str() );
                db->close();
                return false;
            }

        }
        else
        {
            // Load input layers
            inputLayer = new TeLayer (inputLayerName);
            if (!db->loadLayer (inputLayer))
            {
                string err_out = string("\tCan't open input layer: ") + string(inputLayerName) + string("\n");
                qFatal( "%s", err_out.c_str() );
                db->close();
                return 0;
            }
            // Load input theme
            inputTheme = new TeTheme(inputThemeName, inputLayer );
            if (!db->loadTheme (inputTheme)) // erro, tiago: parece que a terralib carrega um thema com mesmo nome, mas de outro layer, pois
                // esta função nao falha, caso o tema "inputTheme" não pertenca ao layer (inputLayer), quando deveria
                // assim, o proximo acesso ao aobjeto inputTheme procara uma excecao
                // Alem disso, quando dois temas possuem o mesmo nomemem layers diferentes, esta funcao falha
                // ao carregar o tema do layer selecionado, só funciona quando se tenta carregar o tema
                // do layer que o primeiro a ser inserido no banco, para os demais layers a tentativa abaixo
                // de criar um tema temporário irá falhar.
                // Se varios bancos que possuirem a mesta estrutura, portanto, temas de com o mesmo nome, estiverem
                // abertos simultaneamente no TerraView, então as vistas e os temas de resultados serão criados nos
                // dois bancos simultaneamente. Para isso, é preciso que os banco tenham o mesmo usuário e senha.
                //	Entretanto, as tabelas de resultados não são criadas em ambos os bancos.
            {
                string err_out = string("\tCan't open input theme: ") + string(inputThemeName) + string("\n");
                qFatal( "%s", err_out.c_str() );
                db->close();
                return 0;
            }
        }

        // Inicia o mecanismo de consula da TerraLib
        //	#if ! defined( TME_TERRALIB_RC3 )
        //		TeInitQuerierStrategies();
        //	#endif

        TeQuerierParams* querierParams;
        bool loadGeometries = true;

        TeTheme temporaryTheme("temporaryTheme", inputLayer);

        if(! QUIET_MODE )
        {
            qWarning("Using TerraLib version '%s' and database version '%s'. ", 
                    TERRALIB_VERSION,       // macro in the file "TeVersion.h"
                    TeDBVERSION.c_str());   // macro in the file "TeDefines.h" linha 221
            qWarning("Loading cellular space: \"%s\"...", inputThemeName.c_str());

        }
        
        if( ! whereClause.empty() )
        {
            // Create a temporary theme that aplies attribute restrictions over the
            // input theme
            temporaryTheme.attributeRest(whereClause);
            temporaryTheme.setAttTables( inputTheme->attrTables() );

            // Configura o mecanismo para buscar geometrias (loadGeometries = true), e também
            // buscar todos os atributos da c"lula (true )
            if( attrNames.empty() )
            {
                querierParams = new TeQuerierParams( loadGeometries, true );
                querierParams->setParams( &temporaryTheme );
            }
            else
            {
                querierParams = new TeQuerierParams( loadGeometries, attrNames );
                querierParams->setParams( &temporaryTheme );
            }
        }
        else
        {
            // Configura o mecanismo para buscar geometrias (loadGeometries = true), e também
            // buscar todos os atributos da c"lula (true )
            if( attrNames.empty() )
            {
                querierParams = new TeQuerierParams( loadGeometries, true );
                querierParams->setParams( inputTheme );
            }
            else
            {


                //	cout << attrNames[i] << endl;
                //	l++;
                //}
                //cout << l <<endl;

                querierParams = new TeQuerierParams( loadGeometries, attrNames );
                querierParams->setParams( inputTheme );
            }
        }
        // Cria uma consulta e a executa
        TeQuerier query( *querierParams );
        query.loadInstances();

        // puts a table for represent the whole cellular space on the top of the stack
        lua_newtable(L);
        int tabPos = lua_gettop(L);

        TeSTInstance element;
        bool primeiraCell = true;
        int minCol = 0, minLin = 0;
        int maxCol = 0, maxLin = 0;
        string luaCmd;
        //int  colAnt = -1;
        long int cont = 0;
        // Calcula quais s"o os indices minimos para a coluna e para a linha
        while( query.fetchInstance( element ) )
        {
            //TePropertyVector& properties = element.getPropertyVector();
            const TePropertyVector& properties = element.getPropertyVector();


            // Obtem o identificador do objeto espa"o-temporal associado " c"lula
            // e obtem coordenadas da c"lula
            int lin, col;
            char cellId[20];

            // Raian: Verifica se o layer é de células, linhas, pontos ou polígonos para pegar
            // as coordenadas x e y do objeto.
            if( element.hasCells() ){
                strcpy( (char *) cellId, element.objectId().c_str());
                objectId2coords( cellId, col, lin);
                //cout << col << ":" << lin << " - ";
            }
            else{
                if( element.hasPolygons() || element.hasPoints() || element.hasLines() ){
                    strcpy( (char *) cellId, element.getObjectId().c_str() );
                    lin = element.getCentroid().x();
                    col = element.getCentroid().y();
                }
            }
            if( primeiraCell )
            {
                minLin = lin;
                minCol = col;
                primeiraCell = false;
            }
            else
            {
                minLin = min(minLin, lin);
                minCol = min(minCol, col);
            }
            maxCol = max(maxCol, col);
            maxLin = max(maxLin, lin);


            // puts the index for the new cell on the stack
            lua_pushnumber(L, cont + 1);

            // puts the Cell constructor on the top of the lua stack
            lua_getglobal(L, "Cell" );
            if( !lua_isfunction(L, -1))
            {
                string err_out = string("Error: Event constructor not found!\n");
                qFatal( "%s", err_out.c_str() );

                return 0;
            };

            // creates a attribute table for the new cell of the cellular space
            string aux;
            lua_newtable(L);

            // puts the cell's coords on the table
            lua_pushstring(L, "x");
            lua_pushnumber(L, col );
            lua_settable(L, -3);
            lua_pushstring(L, "y");
            lua_pushnumber(L, lin );
            lua_settable(L, -3);

            // puts the cell's id on the table
            lua_pushstring(L, "objectId_");
            lua_pushstring(L, cellId );
            lua_settable(L, -3);

            // puts the others cell's attributes on the table
            for( unsigned int i = 0; i < properties.size(); i++)
            {
                //TeProperty &prop = properties[i];
                const TeProperty &prop = properties[i];

                lua_pushstring(L, prop.attr_.rep_.name_.c_str() );

                element.getPropertyValue(aux,i);
                switch( prop.attr_.rep_.type_  )
                {
                case TeSTRING:
                case TeDATETIME:
                case TeCHARACTER:
                    lua_pushstring(L, aux.c_str() );
                    break;

                case TeREAL:
                    lua_pushnumber( L, atof( aux.c_str() ) );
                    break;

                case TeINT:
                    lua_pushnumber( L, atoi( aux.c_str() ) );
                    break;

                case TeBLOB:
                case TeOBJECT:
                case TeUNKNOWN:
                default:
                    lua_pushstring(L, aux.c_str() );
                }

                lua_settable(L, -3);
            }

            // calls the Cell constructor
            if( lua_pcall( L, 1, 1, 0) != 0 )
            {
                cont++;
                return 0;
            }

            // insert the new cell into the cellular space table
            lua_settable(L, tabPos);

            //colAnt = col;
            cont++;
            element.clear();
            //cout << "<";
            //if((cont % 79) == 0) cout << endl;
        }

        if(! QUIET_MODE ) qWarning("\n\tNumber of read cells: %ld.\n", cont );

        // returns values to the attributes minCol, minRow, maxCol and maxRow
        // of the lua cellularSpace
        lua_pushnumber( L, minCol );
        lua_pushnumber( L, minLin );
        lua_pushnumber( L, maxCol );
        lua_pushnumber( L, maxLin );

        delete querierParams;

        // carrega legendas do banco
        QString dbLegend;
        loadLegendsFromDatabase(db, inputTheme, dbLegend);

        // debugging
        // cout << dbLegend.toAscii().constData() << endl; cout.flush();
        int response = -1;
        if (! dbLegend.isEmpty())
            response = luaL_dostring(L, dbLegend.toAscii().constData());

        // debugging
        // cout << response << endl; cout.flush();

        // fecha o banco
        db->close();

        return 5;
    }
    catch( ... ){
        qFatal( "FATAL ERROR: It is not possible to load the TerraLib database: %s\n", db->errorMessage().c_str() );
        return 0;
    }
}


// Loads existing legends from database
void luaCellularSpace::loadLegendsFromDatabase(TeDatabase *db, TeTheme *inputTheme, QString& luaLegend)
{
    luaLegend.clear();
    TeDatabasePortal *portal = db->getPortal();

    QString colorBar, colors;
    QStringList colorBarList;
    QString themeName;

    //QString themeNameQuery = QString("SELECT name FROM te_theme WHERE theme_id=%1").arg(inputTheme->id());
    //if(portal->query(themeNameQuery.toAscii().constData()))
    //{
    //    while(portal->fetchRow()) 
    //        themeName = QString("%1").arg(portal->getData(0));
    //}


    QString colorBarsQuery = QString("SELECT grouping_color FROM te_theme_application WHERE theme_id=%1")
        .arg(inputTheme->id());  

    if( portal->query(colorBarsQuery.toAscii().constData()) )
    {
        // na verdade existe uma unica linha na tabela (uma grande string) e 
        // o "while" eh, portanto, dispensavel
        while(portal->fetchRow()) 
            colorBar = QString("%1").arg(portal->getData(0));

        // Caso nao exista legenda no banco ou ela esta incorreta,
        // aborta a recuperacao
        if (! colorBar.contains("-"))
        {
            if (! QUIET_MODE)
                qWarning("Warning: The legend found is invalid!");

	    	luaLegend.clear();
        	return;
    	}
    }
    else
    {
        if (! QUIET_MODE)
        {
            qWarning("Warning: Failed to load database legend. The error message received from "
                "database driver was: \"%s\".", portal->errorMessage().c_str());
        }
        luaLegend.clear();
        return;
    }

    // substitiu separadores toscos do TerraView, que usa o caracter '-' 
    // mesmo quando há numero negativos na string
    string colorBarStr(colorBar.toAscii().constData());
    char previousChar = '#';
    for(int i = 0; i < colorBar.size(); i++ ){
        if(( colorBarStr[i] == '-') && (previousChar != '#')) 
            colorBarStr[i] = '#';
        previousChar = colorBarStr[i];
    }
    colorBar = QString(colorBarStr.c_str());

    // Cada cor do objeto ColorBar é separado por "#"
    colorBarList = colorBar.split("#", QString::SkipEmptyParts);
    colors.append(QString("{ "));

    for (int i = 0; i < colorBarList.size(); i++)
    {
        QStringList colorBarItem = colorBarList.at(i).split(";");

        // Must contains [hue, saturation, value, distance]
        QColor color = QColor::fromHsv(colorBarItem.at(0).toInt(),
            colorBarItem.at(1).toInt(),
            colorBarItem.at(2).toInt()).toRgb();

        colors.append("{");
        QString colorStr = QString("{%1, %2, %3}, %4, %5")
            .arg(color.red())
            .arg(color.green())
            .arg(color.blue())
            .arg(i)         // value
            .arg(colorBarItem.at(3).toFloat()); // color bar distance

        colors.append( colorStr );
        colors.append("},");
    }

    colors = colors.mid(0, colors.length() - 1);
    colors.append(" }");


    luaLegend.append("legendPOG___ = Legend{");

    TeGrouping grouping = inputTheme->grouping();
    TeAttributeRep attrRep = grouping.groupAttribute_;
    QString attr = QString(attrRep.name_.c_str());

    QString attrName = attr.mid(attr.lastIndexOf(".")+1,attr.length()-1);

    // type
    int attrType = attrRep.type_;
    luaLegend.append(QString("%1=").arg(TYPE));
    switch(attrType)
    {
    case TObsBool: 
        luaLegend.append("TYPES.BOOL,");
        break;

    case TObsDateTime:
        luaLegend.append("TYPES.DATETIME,");
        break;

    case TObsText:
        luaLegend.append("TYPES.TEXT,");
        break;

    default:
        luaLegend.append("TYPES.NUMBER,");
    }

    // std deviation
    StdDev stdMode = TObsNone;
    if(grouping.groupStdDev_ > 0)
    {
        if(grouping.groupStdDev_ == 1)
        {
            stdMode = TObsFull;
        }
        else
        {
            if(grouping.groupStdDev_ == 0.5) 
                stdMode = TObsHalf;
            else 
                stdMode = TObsQuarter;
        }
    }
    luaLegend.append(QString("%1=%2,").arg(STD_DEV).arg(stdMode));

    // slices
    TeSliceVector slices = inputTheme->getSlices();
    luaLegend.append(QString("%1=%2,").arg(SLICES).arg(slices.size()));

    // max value
    luaLegend.append(QString("%1=%2,").arg(MAX).arg(grouping.groupMaxVal_));

    // min value
    luaLegend.append(QString("%1=%2,").arg(MIN).arg(grouping.groupMinVal_));

    // symbol
    luaLegend.append(QString("%1=\"%2\",").arg(SYMBOL).arg("®"));

    // font size
    luaLegend.append(QString("%1=%2,").arg(FONT_SIZE).arg(12));

    // font family
    luaLegend.append(QString("%1=%2,").arg(FONT_FAMILY).arg("\"Symbol\""));

    // color bar
    luaLegend.append(QString("%1=%2,").arg(COLOR_BAR).arg(colors));

    // precision
    luaLegend.append(QString("%1=%2,").arg(PRECISION).arg(grouping.groupPrecision_));

    // grouping mode
    luaLegend.append(QString("%1=%2").arg(GROUP_MODE).arg((GroupingMode) grouping.groupMode_));

    luaLegend.append("}");
}

/// Saves celular space.
int luaCellularSpace::save(lua_State *L)
{
    // get the 3 parameters:
    // the simulation time(year, day, etc) that will be concatened to the attribute names,
    // the output table name,
    // table of names of attributes to be saved
    //char xx[20], yy[20], val[255];
    char val[255];
    const char *key, *value, *objId;
    double v;
    char attName[255];
    //int index;
    TeAttributeList attList;
    vector<string> attNameList;
    TeTableRow tableRow;
    TeAttribute column;
    const char* outputTableName = luaL_checkstring(L, -3);
    char outputTable[100];
    long int contCells = 0;

    // Convert time value to string ********
    const float time = luaL_checknumber(L, -4);
    char aux[100], *ch;
    if( (time - floor(time)) > 0 ) sprintf(aux, "%f", time); else sprintf(aux, "%.0f", time);
    ch = aux;
    for( unsigned int i= 0; i < strlen(aux); i++) { if( ch[i] == '.' || ch[i] ==',' ) ch[i] = '_'; }

    strcpy(outputTable,outputTableName);
    strcat(outputTable, aux);

    if( ! lua_istable(L, -2) )
    {
        qFatal("Error: attribute names table not found!");
        return false;
    }

    if( ! lua_istable(L, -1) )
    {
        qFatal("Error: cells not found!");
        return false;
    }

    //  get the cellular space position *********
    int cellsPos = lua_gettop(L);

    // Opens a connection to a database accessible *******
    TeDatabase * db;
    if( dbType == "mysql")
        db = new TeMySQL();
    // RODRIGO
    //#if defined ( TME_WIN32 )
#if defined( TME_MSVC ) && defined( TME_TERRALIB_RC3 )
    else {
        ::configureADO();
        db = new TeAdo();
    }
#endif
    if (!db->connect(host,user,pass,dbName,0))
    {
        string err_out = string("Error: ") + db->errorMessage() + string("\n");
        qFatal( "%s", err_out.c_str() );

        return false;
    }

    // Load the layer ******
    TeLayer *layer;
    if ( inputLayerName == "")
    {
        // Load input theme
        TeTheme *inputTheme = new TeTheme(inputThemeName );
        if (!db->loadTheme (inputTheme))
        {

            string err_out = string("\tCan't open input theme: ") + string(inputThemeName) + string("\n");
            qFatal( "%s", err_out.c_str() );

            db->close();
            return false;
        }
        // Load input layers
        layer = inputTheme->layer();
        if (!db->loadLayer (layer))
        {

            string err_out = string("Error: fail to load the layer ") + string(db->errorMessage()) + string("\n");
            qFatal( "%s", err_out.c_str() );

            db->close();
            return false;
        }

    }
    else
    {
        layer = new TeLayer(inputLayerName);
        if (!db->loadLayer(layer))
        {

            string err_out = string("Error: fail to load the layer ") + string(inputLayerName) + string(db->errorMessage()) + string("\n");
            qFatal( "%s", err_out.c_str() );

            db->close();
            return false;
        }

    }

    if(! QUIET_MODE )
    {
        qWarning("Saving cellular space \"%s\" into \"%s\" table...", 
            inputThemeName.c_str(), outputTable);
    }

    // Delete the new attribute table whether it already exist *********
    if( db->tableExist( string( outputTable ) ) )
    {
        // RODRIGO
        //if( !deleteLayerTableName( db, string ( outputTable ) ) )
        if( !deleteLayerTableName( db, (string&)(string const&)string( outputTable ) ) )
        {
            /*cout << "Error: fail to delete table \"" << outputTable
            << db->errorMessage() << endl;
            db->close();*/
            return false;
        }


    }

    // Get the first cell of the cellular space (cells)
    // "index" is at index -2 and "value(cell)" at index -1
    lua_pushnumber(L, 1);
    lua_gettable(L, cellsPos );
    int firstCellPos = lua_gettop(L);

    // Create the new attribute table **********
    // Set the primary key field of the attribute table
    column.rep_.name_  = "object_id_";
    column.rep_.type_ = TeSTRING;
    column.rep_.isPrimaryKey_ = true;
    column.rep_.numChar_ = 255;
    attList.push_back(column);

    // tranverse the table( attribute names )
    int count = 0;
    lua_pushnil(L);
    while(lua_next(L, cellsPos - 1 ) != 0)
    {
        // "index" is at index -2 and "value(attribute name)" at index -1
        key = luaL_checkstring(L, -1); // gets the cell attribute name

        strcpy( attName, key );
        attNameList.push_back( key);

        //strcat( attName, aux ); // Raian: Comentei para colocar o nome da coluna sem o tempo.
        column.rep_.name_  = attName;
        column.rep_.isPrimaryKey_ = false;

        lua_pushstring(L, key);
        lua_gettable(L,firstCellPos);
        switch( lua_type(L, -1) )
        {
        case LUA_TNUMBER:
        case LUA_TBOOLEAN:
            // always save numbers as double (TeReal)
            column.rep_.type_ = TeREAL;
            column.rep_.numChar_ = 0;
            break;

        case LUA_TSTRING:
            column.rep_.type_ = TeSTRING;
            column.rep_.numChar_ = 255;
            break;

        default:
            column.rep_.type_ = TeSTRING;
            column.rep_.numChar_ = 255;
            break;

        }
        attList.push_back(column);
        lua_pop(L,1); // remove the attribute value

        lua_pop(L, 1); // removes the cell attribute name
        count++;
    }
    // there are no attributes name in the table (count ==0),
    // then save all cells attributes
    if( !count )
    {
        // tranverse the table (cell)
        lua_pushnil(L);
        while(lua_next(L, -2 ) != 0)
        {
            // "index" is at index -2 and "value(attribute name)" at index -1
            key = luaL_checkstring(L, -2);
            if( strcmp(key, "x") && strcmp(key, "y") )
            {
                strcpy( attName, key );
                attNameList.push_back( key );

                strcat( attName, aux );
                column.rep_.name_  = attName;
                column.rep_.isPrimaryKey_ = false;

                switch( lua_type(L, -1) )
                {
                case LUA_TNUMBER:
                case LUA_TBOOLEAN:
                    // always save numbers as double (TeReal)
                    column.rep_.type_ = TeREAL;
                    column.rep_.numChar_ = 0;
                    break;

                case LUA_TSTRING:
                    column.rep_.type_ = TeSTRING;
                    column.rep_.numChar_ = 255;
                    break;

                default:
                    column.rep_.type_ = TeSTRING;
                    column.rep_.numChar_ = 255;
                    break;

                }
                attList.push_back(column);
            }

            lua_pop(L, 1); // removes the cell attribute name
        }

    }
    TeTable attTable( string( outputTable ),attList, "object_id_", "object_id_", TeAttrStatic);
    if ( !layer->createAttributeTable(attTable) )
    {

        string err_out = string("Error creating table \"") + string(outputTable) + string("\" in the TerraLib database!\n\n") + string("\n");
        qFatal( "%s", err_out.c_str() );

        db->close();
        return false;
    }


    // Save data on the attribute table *****************
    // tranverse the table(cells)
    lua_pushnil(L); // first key
    while (lua_next(L, cellsPos) != 0)
    {	// "key" is at index -2 and "value(luaCell)" at index -1

        // build a table row for the cell at the top of the lua stack
        tableRow.clear();


        // Raian: Gets the cell's Id
        lua_pushstring(L, "objectId_");
        lua_gettable( L, -2);
        objId = luaL_checkstring(L, -1);
        lua_pop(L, 1);
        tableRow.push_back( objId );

        // tranverse the attribute names list
        TeAttributeList::iterator it = attList.begin();
        vector<string>::iterator itName = attNameList.begin();
        it++; // skip the field "object_id_"
        while ( it != attList.end() )
        {
            column = *it;

            //printf("%s, %s\n",itName->c_str(), column.rep_.name_.c_str() );

            lua_pushstring(L, itName->c_str() );
            lua_gettable( L, -2 );
            switch(  column.rep_.type_ )
            {
            case TeREAL:
                // always save numbers as double
                v = lua_tonumber(L, -1);
                sprintf( val, "%f", v);
                value = val;
                break;

            case TeSTRING:
                value = lua_tostring(L, -1);
                break;

            default:
                value = lua_tostring(L, -1);
                break;

            }
            tableRow.push_back( value );

            lua_pop(L, 1); // removes the cell attribute value
            it++;
            itName++;
        }

        attTable.add( tableRow );
        lua_pop(L, 1); // removes "value (cell)"; keeps "key" for next iteration
        //cout << ">";
        contCells++;
    }
    // save the new attribute table to the database
    if (attTable.size() > 0)
    {
        if (!layer->saveAttributeTable(attTable))
        {
            string err_out = string("Error creating table \"") + string(outputTable) + string("\" in the TerraLib database!\n\n") + string("\n");
            qFatal( "%s", err_out.c_str() );

            db->close();
            return false;
        }
    }


    // Create a view to show the saved results *****************
    TeProjection* proj = layer->projection();
    string viewName = "Result";
    TeView* view = new TeView(viewName, user);
    // Check whether there is a view with this name in the datatabase
    if (db->viewExist(viewName))
    {
        // loads the existing view
        if( !db->loadView( view ) )
        {
            string err_out = string("Error: fail to load view \"") + string(viewName) + string("\" - ")+ db->errorMessage()  + string("\n");
            qFatal( "%s", err_out.c_str() );

            db->close();
            return false;
        }
    }
    else
    {
        // Create a view with the same projection of the layer
        view->projection(proj);
        if (!db->insertView(view))			// save the view in the database
        {
            string err_out = string("Error: fail to insert the view \"") + string(viewName) + string("\" into the database - ")+ db->errorMessage()  + string("\n");
            qFatal( "%s", err_out.c_str() );

            db->close();
            return false;
        }
    }

    // Create a theme that will contain the objects of the layer which satisfies the
    // attribute restrictions applied
    TeTheme* theme;
    theme = new TeTheme(string(outputTable), layer);
    // Check whether there is a theme with this name in the datatabse
    if( db->themeExist( string(outputTable)) )
    {
        /// load the inputTheme properties
        // loads the existing view
        if( !db->loadTheme( theme ) )
        {
            string err_out = string("Error: fail to load theme \"") + string(outputTable) + string("\" - ")+ db->errorMessage()  + string("\n");
            qFatal( "%s", err_out.c_str() );

            db->close();
            return false;
        }
        // delete the existing theme
        int themeId = theme->id();
        if ( !db->deleteTheme( themeId ) )
        {
            string err_out = string("Error: fail to delete theme \"") + string(outputTable) + string("\" - ")+ db->errorMessage()  + string("\n");
            qFatal( "%s", err_out.c_str() );

            db->close();
            return false;
        }
        // BEGIN: Raian
        theme = new TeTheme(string(outputTable), layer);

        if( !createNewTheme( attTable, outputTable, whereClause, inputThemeName, view, layer, db, theme ) )
        {

            string err_out = string("Error: fail to create theme \"") + string(inputThemeName) + string("\" - ")+ db->errorMessage()  + string("\n");
            qFatal( "%s", err_out.c_str() );

            return false;
        }

    }
    else
    {
        if( !createNewTheme( attTable, outputTable, whereClause, inputThemeName, view, layer, db, theme ) )
        {
            string err_out = string("Error: fail to create theme \"") + string(inputThemeName) + string("\" - ")+ db->errorMessage()  + string("\n");
            qFatal( "%s", err_out.c_str() );

            return false;
        }

    }
    // END: Raian
    if(! QUIET_MODE ) qWarning("\tnumber of saved cells: %ld\n.", contCells);

    db->close();
    return 0;
}


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// A funcao abaixo recebe um o nome da GPM (campo "gmp_id" nda tabela "te_gmp")
// Parameters: 
//		gpmName - it is the GPM unique identifier, a ASCII text.
// Problemas:
// 1) TerraLib nao oferece em sua API uma método para carregar uma GPM a partir do banco.
// 2) Por enquanto, os testes so funcionaram para GPMs com estratégia "contiguity". Para as demais estrategias, nao consegui
// gerar uma GPM cuja tabela de conexoes tivessem elementos. 
// 3) Arquivos ponto GAL nao possuem informacoes suficientes para a construcao da estrutura de vizinhanca de TerraME. Veja
//    documentacao do metodo loadGALNeighborhood();
// 4) O TerraView também parece nao gravar arquivos com extensao GWT. Assim, o metodo pre-existente para carregar
// este tipo de arquivo nao foi adaptado para a nova classe vizinhanca.
// 5) Ainda é necessária a implementacao de um iterador sobres as vizinhancaS de uma celula: begin, first, last, next, etc.
// 6) A API TerraLib para GPM no que tange ao ponto de vista do usuario final merece uma revisao.
int luaCellularSpace::loadTerraLibGPM(lua_State *L){

    const char* neighName = luaL_checkstring(L, -1);

    // Opens a connection to a database accessible
    TeDatabase * db;
    if( dbType == "mysql")
        db = new TeMySQL();
#if defined( TME_MSVC ) && defined( TME_TERRALIB_RC3 )
    else
        db = new TeAdo();
#endif
    if (!db->connect(host,user,pass,dbName,0))
    {

        string err_out = string("Error: ") + db->errorMessage().c_str() + string( "\n");
        qFatal( "%s", err_out.c_str() );
        return false;
    }

    TeTheme *inputTheme;
    TeLayer *inputLayer;
    if ( inputLayerName == "")
    {
        // Load input theme
        inputTheme = new TeTheme(inputThemeName );
        if (!db->loadTheme (inputTheme))
        {
            string err_out = string("\tCan't open input theme: ") + string(inputThemeName) + string( "\n");
            qFatal( "%s", err_out.c_str() );
            db->close();
            return false;
        }
        // Load input layers
        inputLayer = inputTheme->layer();
        if (!db->loadLayer (inputLayer))
        {

            string err_out = string("\tCan't open input layer: ") + string(inputLayerName) + string( "\n");
            qFatal( "%s", err_out.c_str() );

            db->close();
            return false;
        }

    }
    else
    {
        // Load input layers
        inputLayer = new TeLayer (inputLayerName);
        if (!db->loadLayer (inputLayer))
        {
            string err_out = string("\tCan't open input layer: ") + string(inputLayerName) + string( "\n");
            qFatal( "%s", err_out.c_str() );

            db->close();
            return false;
        }
        // Load input theme
        inputTheme = new TeTheme(inputThemeName, inputLayer );
        if (!db->loadTheme (inputTheme)) // erro, tiago: parece que a terralib carrega um thema com mesmo nome, mas de outro layer, pois
            // esta função nao falha, caso o tema "inputTheme" não pertenca ao layer (inputLayer), quando deveria
            // assim, o proximo acesso ao aobjeto inputTheme procara uma excecao
            // Alem disso, quando dois temas possuem o mesmo nomemem layers diferentes, esta funcao falha
            // ao carregar o tema do layer selecionado, só funciona quando se tenta carregar o tema
            // do layer que o primeiro a ser inserido no banco, para os demais layers a tentativa abaixo
            // de criar um tema temporário irá falhar.
            // Se varios bancos que possuirem a mesta estrutura, portanto, temas de com o mesmo nome, estiverem
            // abertos simultaneamente no TerraView, então as vistas e os temas de resultados serão criados nos
            // dois bancos simultaneamente. Para isso, é preciso que os banco tenham o mesmo usuário e senha.
            //	Entretanto, as tabelas de resultados não são criadas em ambos os bancos.
        {

            string err_out = string("\tCan't open input theme: ") + string(inputThemeName) + string( "\n");
            qFatal( "%s", err_out.c_str() );

            db->close();
            return false;
        }
    }

    if(! QUIET_MODE ) qWarning( "Loading default TerraLib GPM (Generalized Proximity Matrix). Please, wait...");
    //  Load an existing proximity matrix or create a new one
    double tol = TeGetPrecision(inputLayer->projection());
    TePrecision::instance().setPrecision(tol);
    //TeProxMatrixConstructionStrategy<TeSTElementSet>*   constStrategy=0;
    TeGeneralizedProxMatrix<TeSTElementSet>* proxMat=0;
    TeGPMConstructionStrategy strategy;
    double max_distance;
    double num_neighbours;
    // RODRIGO
    //if (!loadGPM(db, inputTheme->id(), proxMat, string( neighName ), strategy, max_distance, num_neighbours)){
    if (!loadGPM(db, inputTheme->id(), proxMat, (string&)(string const&)string(neighName), strategy, max_distance, num_neighbours)){
        string err_out = string("\tCan't load the \"") + string(neighName) + string( "\" TerraLib GPM.\n");
        qFatal( "%s", err_out.c_str() );

        db->close();
        return false;
    }

    // NOW that the teGeneralizedProxMatrix is loaded, the neighbours will be added to the TerraME CellularSpace
    // neighborhood structure
    CellIndex cellIndex;
    luaCell *cell,*viz;
    CellularSpace::iterator itCell;
    unsigned long int cont = 0;

#if defined( DEBUG_NEIGH )	
    cout << endl;
#endif

    itCell = CellularSpace::begin();
    while (itCell != CellularSpace::end())
    {

        cellIndex.first = itCell->first.first; // cell.x
        cellIndex.second = itCell->first.second; // cell.y
        cell = (luaCell*) itCell->second;

#if defined( DEBUG_NEIGH )
        cout << "C++, Cell: " << cell << endl;
#endif
        // adds a new TerraME Neighborhood structure to the each cell in the CellularSpace
        NeighCmpstInterf* neighborhoods = &cell->getNeighborhoods( );
        luaNeighborhood* neighborhood = new luaNeighborhood( L );
        pair< string, CellNeighborhood*> pStrNeigh;
        //string matrix;
        //if( strategy == TeAdjacencyStrategy )  //adjacencia
        //{
        //	matrix = string("Contiguity");
        //}
        //else if( strategy == TeDistanceStrategy)  //distancia
        //{
        //	matrix = string("Distance: ") + Te2String( max_distance, 6);
        //}
        //else if( strategy == TeNearestNeighboursStrategy)  //nn
        //{
        //	matrix = string("Nearest neighbours: ")+ Te2String(num_neighbours);
        //}
        //pStrNeigh.first = matrix;
        pStrNeigh.first = neighName;
        pStrNeigh.second = neighborhood;
        // RODRIGO
        //neighborhood->setID( string(neighName) );
        neighborhood->setID( (string&)(string const&)string(neighName) );
        neighborhoods->erase( neighName );
        neighborhoods->add( pStrNeigh );
        cont ++;

#if defined( DEBUG_NEIGH )
        cout << "C++, Neighs: " << neighborhoods << ", ";
        cout.flush();
        cout << neighborhoods->size() << endl;
        cout << "C++, Neigh: " << neighborhood << ", "<< neighborhood->CellNeighborhood::size() << endl;
#endif
        lua_getglobal(L, "Neighborhood" );
        if( !lua_isfunction(L, -1))
        {
            qFatal("Error: Neighborhood constructor not found!");

            db->close();
            return 0;
        };

        // puts the neighborhood on the stack top
        lua_newtable(L);
        lua_pushstring(L, "cObj_");
        typedef struct { luaNeighborhood *pT; } userdataType;
        userdataType *ud = static_cast<userdataType*>(lua_newuserdata(L, sizeof(userdataType)));
        ud->pT = neighborhood;  // store pointer to object in userdata//lua_pushlightuserdata(L,(void*) neigh);
        luaL_getmetatable(L, luaNeighborhood::className);  // lookup metatable in Lua registry
        lua_setmetatable(L, -2);
        lua_settable(L,-3);

        // calls the Neighborhood constructor
        if( lua_pcall( L, 1, 1, 0) != 0 )
        {
            qFatal(" Error: Neighborhood constructor not found in the stack");
            db->close();
            return 0;
        }

#if defined( DEBUG_NEIGH )
        //break;
#endif
        //  fullfil the cell Neighborhood structure, e. g. adds neighbours to the cell
        char xx[20], yy[20];
        sprintf(xx, "%02d", cellIndex.first );
        sprintf(yy, "%02d", cellIndex.second );
        string object_id = "C" + string( xx ) + "L" + string( yy );

#if defined( DEBUG_NEIGH )
        cout << object_id << "........................................................" << endl;
        cout.flush();
#endif
        // RODRIGO
        //TeNeighbours& neigh = proxMat->getNeighbours(object_id );
        TeNeighbours neigh = proxMat->getNeighbours(object_id );
        TeNeighbours::iterator itNeigh = neigh.begin();

        while (itNeigh != neigh.end())
        {
            string& neighId = itNeigh->first;
            TeProxMatrixAttributes& proxMatrixAttr = itNeigh->second;

            char str[30];
            strcpy((char*)str, neighId.c_str());
            int neighX, neighY;
            objectId2coords(str,neighX, neighY);

#if defined( DEBUG_NEIGH )
            cout << neighId << "\t" << proxMatrixAttr.Weight() << "\t" << neighX << "\t" << neighY << endl;
#endif

            // insert the new neighbor in the cell neighborhood
            cellIndex.first = neighX;
            cellIndex.second = neighY;
            viz = (luaCell * ) CellularSpace::operator [](cellIndex);
            float peso = (float) proxMatrixAttr.Weight();
            neighborhood->add(cellIndex, viz, peso);

            itNeigh++;
        }
        //cout << neigh.size() << ", "<< neighborhood->size() << endl;
        itCell++;
    }


    if(! QUIET_MODE ) qWarning("\tGPM sucessfuly loaded.\n");
    return 0;
}


/// This method loads a neighborhood from a. file Extensions supported: .GAL, .GWT, .txt
/// \author  Raian Vargas Maretto
int luaCellularSpace::loadNeighborhoodFile(lua_State *L){
    const char* neighName = luaL_checkstring(L, -1);
    const char* fileName = luaL_checkstring(L, -2);
    char aux[255], extension[10];
    char *auxExt;

    if(! QUIET_MODE ) qWarning("Loading neighborhood \"%s\"", neighName );

    strcpy(aux, const_cast<char*>(fileName));
    auxExt = strtok( aux, "." );

    while( auxExt != NULL )
    {
        strcpy(extension, auxExt);
        auxExt = strtok( NULL, "." );
    }

    if( stricmp( extension, "GAL" ) == 0 )
    {
        if(! QUIET_MODE ) qWarning(" from a GAL file...\n");
        loadGALNeighborhood(L, fileName, neighName);
    }
    else
    {
        if( stricmp( extension, "GWT" ) == 0 )
        {
            if(! QUIET_MODE ) qWarning(" from a GWT file...\n");
            loadGWTNeighborhood(L, fileName, neighName);
        }
        else
        {
            if( stricmp( extension, "txt" ) == 0 )
            {
                if(! QUIET_MODE ) qWarning(" from a txt file...\n");
                loadTXTNeighborhood(L, fileName, neighName);
            }
            else
            {
                qWarning("...\n");
                qFatal("Error: The file extension \"%s\" is not supported!\n", extension);
            }

        }
    }

    return 0;
}

/// Loads GAL Neighborhood files
/// \author Raian Vargas Maretto
int luaCellularSpace::loadGALNeighborhood(lua_State *L, const char* fileName, const char* neighName){
    FILE *file;
    char aux[255], aux1[255];
    char cellId[20], neighId[20];
    int cellQtde, numCell, numNeigh;
    int cellX, cellY, neighX, neighY;
    float weight, defaultWeight=1;
    CellIndex cellIndex, neighIndex;
    luaCell *cell, *neighbor;
    CellularSpace::iterator itAux;

    if( (file  = fopen( fileName, "r" )) == NULL )
    {
        qFatal("Error: fail to open neighborhood file \"%s\"...\n", fileName);
        return false;
    }

    // get the total number of cells
    fseek( file, 0L, SEEK_SET );
    fscanf( file, "%s", aux );
    cellQtde = atoi( aux );

    for( numCell = 1; numCell <= cellQtde && !feof( file ); numCell++ )
    {
        // get the cell ID and the number of neighbors
        fscanf( file, "%s %s", cellId, aux1 );
        numNeigh = atoi( aux1 );

        objectId2coords( cellId, cellX, cellY );

        cellIndex.first = cellX;
        cellIndex.second = cellY;

        itAux = CellularSpace::find( cellIndex );

        // creates the neighborhood
        if( itAux != CellularSpace::end() )
        {
            cell = (luaCell*) itAux->second;

            // creates the neighborhood and add it to the cell's set of neighborhoods
            NeighCmpstInterf& neighborhoods = cell->getNeighborhoods();
            luaNeighborhood* neighborhood = new luaNeighborhood( L );
            pair< string, CellNeighborhood* > pairStrNeigh;
            pairStrNeigh.first = neighName;
            pairStrNeigh.second = neighborhood;
            // RODRIGO
            //neighborhood->setID( string(neighName) );
            neighborhood->setID( (string&)(string const&)string(neighName) );
            neighborhoods.erase( neighName );
            neighborhoods.add( pairStrNeigh );

            lua_getglobal( L, "Neighborhood" );
            if( !lua_isfunction(L, -1))
            {
                qFatal( "Error: Neighborhood constructor not found!\n");
                fclose(file);
                return 0;
            }

            //puts the neighborhood on the stack top
            lua_newtable(L);
            lua_pushstring(L, "cObj_");
            typedef struct {luaNeighborhood *pT; } userdataType;
            userdataType *ud = static_cast<userdataType*>(lua_newuserdata(L, sizeof(userdataType)));
            ud->pT = neighborhood; // store pointer to object in userdata
            luaL_getmetatable(L, luaNeighborhood::className);
            lua_setmetatable(L, -2);
            lua_settable(L, -3);

            // Calls the Neighborhood constructor
            if( lua_pcall(L, 1, 1, 0) != 0 )
            {
                qFatal("Error: Neighborhood constructor not found in the stack - \n");
                fclose(file);
                return 0;
            }

            // get the neighbors and add them to the neighborhood
            for( int countNeigh = 1; countNeigh <= numNeigh; countNeigh++ )
            {
                fscanf(file, "%s", neighId);
                objectId2coords( neighId, neighX, neighY );
                neighIndex.first = neighX;
                neighIndex.second = neighY;
                neighbor = (luaCell *) CellularSpace::operator [](neighIndex);
                weight = defaultWeight;
                // Add the new neighbor to the neighborhood
                neighborhood->add( neighIndex, neighbor, weight );

                //cout << "Ref:\t" << neighbor->getReference() << "\t" << neighbor->getID() << endl;
            }
        }
    }
    // The file ends before it was expected
    if( (numCell-1) != cellQtde ) return false;
    fclose(file);

    if(! QUIET_MODE ) qWarning("Thank you. GAL file sucessfuly loaded!!!\n");
    return 0;
}


/// Loads GWT Neighborhood files
/// \author Raian Vargas Maretto
int luaCellularSpace::loadGWTNeighborhood(lua_State *L, const char* fileName, const char* neighName)
{
    ifstream file;
    char aux[255], aux1[255];
    char cellId[20], neighId[20];
    int cellQtde, numCell;
    int cellX, cellY, neighX, neighY;
    CellIndex cellIndx, neighIndx;
    double weight; //, defaultweight=1;
    luaCell *cell, *neighbor;
    CellularSpace::iterator itAux;

    file.open(fileName, ios::in);

    if( !file )
    {
        qFatal("Error: fail to open neighborhood file \"%s\"...\n", fileName);
        return false;
    }

    file.seekg(ios::beg);
    file >> aux;
    cellQtde = atoi( aux );
    file >> cellId;
    strcpy(aux, cellId);

    for(numCell = 1; numCell <= cellQtde && !file.eof(); numCell++)
    {
        if(strcmp(cellId, aux) != 0)
        {
            strcpy(cellId, aux);
        }
        objectId2coords(cellId, cellX, cellY);

        cellIndx.first = cellX;
        cellIndx.second = cellY;

        itAux = CellularSpace::find(cellIndx);

        if( itAux != CellularSpace::end() )
        {
            cell = (luaCell*) itAux->second;

            // Creates a neighborhood and add it to the cell's set of neighborhoods
            NeighCmpstInterf& neighborhoods = cell->getNeighborhoods();
            luaNeighborhood* neighborhood = new luaNeighborhood(L);
            //CellNeighborhood* neighborhood = new CellNeighborhood();
            pair<string, CellNeighborhood*> pairStrNeigh;
            pairStrNeigh.first = neighName;
            pairStrNeigh.second = neighborhood;
            // RODRIGO
            //neighborhood->setID(string(neighName));
            neighborhood->setID( (string&)(string const&)string(neighName) );
            neighborhoods.erase(neighName);
            neighborhoods.add(pairStrNeigh);

            lua_getglobal(L, "Neighborhood");

            // Verify if the Neighborhood constructor is in the LUA Stack
            if(!lua_isfunction(L, -1))
            {
                qFatal("Error: Neighborhood constructor not found!\n");
                file.close();
                return 0;
            }

            // puts the neighborhood on the stack top
            lua_newtable(L);
            lua_pushstring(L, "cObj_");
            typedef struct{luaNeighborhood *pT;} userdataType;
            userdataType *ud = static_cast<userdataType*>(lua_newuserdata(L, sizeof(userdataType)));
            ud->pT = neighborhood; // store pointer to object in userdata
            luaL_getmetatable(L, luaNeighborhood::className);
            lua_setmetatable(L, -2);
            lua_settable(L, -3);

            // calls the neighborhood constructor
            if(lua_pcall(L, 1, 1, 0) != 0)
            {
                qFatal("Error: Neighborhood constructor not found in the stack!\n");
                file.close();
                return 0;
            }

            // get the neighbors and add them to the neighborhood
            while( strcmp(cellId, aux) == 0 )
            {
                file >> neighId >> aux1;
                weight = atof( aux1 );
                objectId2coords(neighId, neighX, neighY);
                neighIndx.first = neighX;
                neighIndx.second = neighY;
                neighbor = (luaCell*) CellularSpace::operator [](neighIndx);
                // Add the new neighbor to the neighborhood
                neighborhood->add(neighIndx, neighbor, weight);

                file >> aux;
            }

        }

    }
    // The file ends before it was expected
    if( (numCell-1) != cellQtde ) return false;
    file.close();

    if(! QUIET_MODE ) qWarning("Thank you. GWT file successfuly loaded!!!\n");

    return 0;
}

/// Loads TXT Neighborhood file.
/// \author Raian Vargas Maretto
int luaCellularSpace::loadTXTNeighborhood( lua_State *L, const char* fileName, const char* neighName )
{
    ifstream file;
    char aux[500], aux1[255];
    char* aux2;
    vector<char*> idNeighbors;
    char cellId[20], neighId[20];
    int cellQtde, neighQtde, numCell, numNeigh;
    int cellX, cellY, neighX, neighY;
    int weight, defaultWeight=1;
    CellIndex cellIndx, neighIndx;
    luaCell *cell, *neighbor;
    CellularSpace::iterator itAux;

    file.open(fileName, ios::in);

    if( !file )
    {
        qFatal("Error: fail to open neighborhood file \"%s\"...\n", fileName);
        return false;
    }

    // gets the total number of cells
    file.seekg(ios::beg);
    file.getline(aux1, 255);

    aux2 = strtok(aux1, " \t\n");
    int count = 0;
    while(aux2 != NULL)
    {
        if( count ==0 )
            strcpy(aux1, aux2);
        aux2 = strtok( NULL, " \t\n" );
        count++;
    }
    cellQtde = atoi(aux1);

    for( numCell = 1; numCell<=cellQtde && !file.eof(); numCell++ )
    {
        file.getline(aux, 500);
        aux2 = strtok(aux, " \t\n");
        neighQtde = 0;
        while(aux2 != NULL)
        {
            if(neighQtde == 0)
            {
                strcpy(cellId, aux2);
            }
            else
            {
                idNeighbors.push_back(aux2);
            }
            aux2 = strtok(NULL, " \t\n");
            neighQtde++;
        }

        objectId2coords(cellId, cellX, cellY);
        cellIndx.first = cellX;
        cellIndx.second = cellY;

        itAux = CellularSpace::find(cellIndx);

        // Creates the neighborhood
        if(itAux != CellularSpace::end())
        {
            cell = (luaCell*) itAux->second;

            // creates the neighborhood and add it to the cell's set of neighborhoods
            NeighCmpstInterf& neighborhoods = cell->getNeighborhoods();
            luaNeighborhood* neighborhood = new luaNeighborhood( L );
            pair<string, CellNeighborhood*> pairStrNeigh;
            pairStrNeigh.first = neighName;
            pairStrNeigh.second = neighborhood;
            // RODRIGO
            //neighborhood->setID(string(neighName));
            neighborhood->setID( (string&)(string const&)string(neighName) );
            neighborhoods.erase(neighName);
            neighborhoods.add(pairStrNeigh);

            lua_getglobal(L, "Neighborhood");
            if( !lua_isfunction(L,-1) )
            {
                qFatal("Error: Neighborhood constructor not found!\n");
                file.close();
                return 0;
            }

            //puts the neighborhood on the stack top
            lua_newtable(L);
            lua_pushstring(L, "cObj_");
            typedef struct{luaNeighborhood *pT;} userdataType;
            userdataType *ud = static_cast<userdataType*>(lua_newuserdata(L,sizeof(userdataType)));
            ud->pT = neighborhood; //store the pointer to object in userdata
            luaL_getmetatable(L, luaNeighborhood::className);
            lua_setmetatable(L, -2);
            lua_settable(L, -3);

            // Calls the Neighborhood constructor
            if( lua_pcall(L, 1, 1, 0) != 0 )
            {
                qFatal("Error: Neighborhood constructor not found in the stack\n");
                file.close();
                return 0;
            }

            // get the neighbors and add them to the neighborhood
            for(numNeigh = 0; numNeigh < neighQtde - 1; numNeigh++)
            {
                strcpy(neighId, idNeighbors.at(numNeigh));
                objectId2coords(neighId, neighX, neighY);
                neighIndx.first = neighX;
                neighIndx.second = neighY;
                neighbor = (luaCell*) CellularSpace::operator [](neighIndx);
                weight = defaultWeight;
                //Add the new neighbor to the neighborhood
                neighborhood->add(neighIndx, neighbor, weight);
            }
            idNeighbors.clear();
        }
    }

    // The file ends before it was expected
    if( (numCell-1) != cellQtde ) return false;
    file.close();

    if(! QUIET_MODE) qWarning("Thank you. txt file sucessfuly loaded!!!\n");

    return 0;
}



/// Find a cell given a luaCellularSpace object and a luaCellIndex object
luaCell * findCell( luaCellularSpace* cs, CellIndex& cellIndex)
{
    Region_<CellIndex>::iterator it = cs->find( cellIndex );
    if( it != cs->end() ) return (luaCell*)it->second;
    return (luaCell*)0;
}

#if defined( TME_MSVC ) && defined( TME_WIN32 )
void configureADO(){
    // begin - copy from tview
    //verify what is the decimal separator
    HKEY    hk;
    DWORD	DataSize = 2;
    DWORD   Type = REG_SZ;
    char    buf[2];

    string key = "Control Panel\\International";
    string sepDecimal = "sDecimal";
    string sepDecimalResult = "";

    if (RegOpenKeyExA(HKEY_CURRENT_USER, key.c_str(), 0, KEY_READ, &hk) == ERROR_SUCCESS)
    {
        memset (buf, 0, 2);
        DataSize = 2;
        //decimal separator
        if (RegQueryValueExA(hk, sepDecimal.c_str(), NULL, &Type, (LPBYTE)buf, &DataSize) == ERROR_SUCCESS)
            sepDecimalResult = buf;

        RegCloseKey (hk);
    }

    if((!sepDecimalResult.empty()) && (sepDecimalResult==","))
    {
        if (RegOpenKeyExA(HKEY_CURRENT_USER, key.c_str(), 0, KEY_SET_VALUE, &hk) == ERROR_SUCCESS)
        {
            memset (buf, 0, 2);
            buf[0] = '.';
            DataSize = 2;

            RegSetValueExA(hk, sepDecimal.c_str(), NULL, Type, (LPBYTE)buf, DataSize);
            RegCloseKey (hk);
        }
    }
    // end - copy from tview
}
#endif
