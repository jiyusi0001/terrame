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
/*! \file luaCell.cpp
    \brief This file contains the implementation for the luaCell objects.
        \author Tiago Garcia de Senna Carneiro
*/

#include "luaCell.h"
#include "luaNeighborhood.h"

// Observadores
#include "../observer/types/observerTextScreen.h"
#include "../observer/types/observerGraphic.h"
#include "../observer/types/observerLogFile.h"
#include "../observer/types/observerTable.h"
#include "../observer/types/observerUDPSender.h"
#include "../observer/types/observerScheduler.h"

#define TME_STATISTIC_UNDEF

#ifdef TME_STATISTIC 
    // Estatisticas de desempenho
    #include "../observer/statistic/statistic.h"
#endif

//@RODRIGO
// #include "../observer/protocol/session/serverSession.h"

///< Gobal variabel: Lua stack used for comunication with C++ modules.
extern lua_State * L; 

///< true - TerrME runs in verbose mode and warning messages to the user; 
/// false - it runs in quite node and no messages are shown to the user.
extern bool QUIET_MODE; 

/// Constructor
luaCell::luaCell(lua_State *L)
{  
    NeighCmpstInterf& nhgs = Cell::getNeighborhoods( );
    it = nhgs.begin();

    // Antonio
    luaL = L;
    subjectType = TObsCell;
    observedAttribs.clear();

    //@RODRIGO
    // serverSession = new ServerSession();
}

/// Returns the current internal state of the LocalAgent (Automaton) within the cell and received as parameter 
int luaCell::getCurrentStateName( lua_State *L )		
{
    luaLocalAgent *agent = Luna<luaLocalAgent>::check(L, -1);
    ControlMode* controlMode = getControlMode((LocalAgent*)agent);

    if( controlMode) lua_pushstring( L, controlMode->getControlModeName( ).c_str() );
    else lua_pushnil(L);

    return 1;
}

/// Puts the iterator in the beginning of the luaNeighborhood composite.
int luaCell::first(lua_State *L){
    NeighCmpstInterf& nhgs = Cell::getNeighborhoods( );
    it = nhgs.begin();
    return 0;
}

/// Puts the iterator in the end of the luaNeighborhood composite.
int luaCell::last(lua_State *L) {
    NeighCmpstInterf& nhgs = Cell::getNeighborhoods( );
    it = nhgs.end();
    return 1;
}

/// Returns true if the Neighborhood iterator is in the beginning of the Neighbor composite data structure  
/// no parameters
int luaCell::isFirst(lua_State *L) {
    NeighCmpstInterf& nhgs = Cell::getNeighborhoods( );
    lua_pushboolean(L, it == nhgs.begin());
    return  1;
}

/// Returns true if the Neighborhood iterator is in the end of the Neighbor composite data structure  
/// no parameters
int luaCell::isLast(lua_State *L) {
    NeighCmpstInterf& nhgs = Cell::getNeighborhoods( );
    lua_pushboolean(L, it == nhgs.end());
    return  1;
}

/// Returns true if the Neighborhood is empty.
/// no parameters
int luaCell::isEmpty(lua_State *L) {  
    NeighCmpstInterf& nhgs = Cell::getNeighborhoods( );
    lua_pushboolean(L, nhgs.empty() );
    return 1;
}

/// Clears all the Neighborhood content
/// no parameters
int luaCell::clear(lua_State *L) {  
    NeighCmpstInterf& nhgs = Cell::getNeighborhoods( );
    nhgs.clear( );
    return 0;
}

/// Returns the number of Neighbors cells in the Neighborhood
int luaCell::size(lua_State *L) {  
    NeighCmpstInterf& nhgs = Cell::getNeighborhoods( );
    lua_pushnumber(L,nhgs.size( ));
    return 1;
}

/// Fowards the Neighborhood iterator to the next Neighbor cell
// no parameters
int luaCell::next( lua_State *L )
{
    NeighCmpstInterf& nhgs = Cell::getNeighborhoods( );
    if( it != nhgs.end() ) it++;
    return 0;
}

/// destructor
luaCell::~luaCell( void ) { luaL_unref( L, LUA_REGISTRYINDEX, ref); }

/// Sets the Cell latency
int luaCell::setLatency(lua_State *L) { Cell::setLatency(luaL_checknumber(L, 1)); return 0; }

/// Gets the Cell latency
int luaCell::getLatency(lua_State *L) { lua_pushnumber(L, Cell::getLatency()); return 1; }

/// Sets the neighborhood
int luaCell::setNeighborhood(lua_State *L) { 
    //	luaNeighborhood* neigh = Luna<luaNeighborhood>::check(L, -1);
    return 0;
}

/// Gets the current active luaNeighboorhood
int luaCell::getCurrentNeighborhood(lua_State *L) { 

    NeighCmpstInterf& nhgs = Cell::getNeighborhoods( );
    if( it !=  nhgs.end() )
    {
        luaNeighborhood* neigh = (luaNeighborhood*) it->second;

        if( neigh != NULL )
            neigh->getReference(L);
        else
            lua_pushnil( L );

    }
    else
        lua_pushnil( L );

    return 1;
}

/// Returns the Neihborhood graph which name has been received as a parameter
int luaCell::getNeighborhood(lua_State *L) { 

    NeighCmpstInterf& neighs = Cell::getNeighborhoods();

    // Get and test parameters
    const char* charIndex = luaL_checkstring(L, -1);
    string index = string( charIndex );
    if( neighs.empty() ) lua_pushnil(L); // return nil
    else
    {
        // Get the cell	neighborhood
        NeighCmpstInterf::iterator location = neighs.find( index );
        if ( location == neighs.end())
        {
            string err_out = string("Erro: neighborhood \"" ) + string (index) + string("\" not found.\n");
            qFatal( "%s", err_out.c_str() );

            lua_pushnil( L );
            return 1;

        }
        luaNeighborhood* neigh = (luaNeighborhood*) location->second;

        if( neigh != NULL )
            neigh->getReference(L);
        else
            lua_pushnil( L );
    }

    return 1;
}

/// Adds a new luaNeighborhood graph to the Cell
/// parameters: identifier, luaNeighborhood 
int luaCell::addNeighborhood( lua_State *L )
{
    string id = string( luaL_checkstring(L, -2) );
    luaNeighborhood* neigh = Luna<luaNeighborhood>::check(L, -1);
    NeighCmpstInterf& neighs = Cell::getNeighborhoods();
    pair< string, CellNeighborhood*> pStrNeigh;
    neigh->CellNeighborhood::setID(id);
    pStrNeigh.first = id;
    pStrNeigh.second = neigh;
    neighs.erase(id );
    neighs.add( pStrNeigh );
    it = neighs.begin();
    return 0;
}

/// Synchronizes the luaCell
int luaCell::synchronize(lua_State *L) { 
    Cell::synchronize( sizeof(luaCell) ); // parametro n?o testado
    return 0;
}

/// Registers the luaCell object in the Lua stack
int luaCell::setReference( lua_State* L)
{
    ref = luaL_ref(L, LUA_REGISTRYINDEX );
    return 0;
}

/// Gets the luaCell object reference
int luaCell::getReference( lua_State *L )
{
    lua_rawgeti(L, LUA_REGISTRYINDEX, ref);
    return 1;
}

/// Gets the luaCell identifier 
int luaCell::getID( lua_State *L )
{
    lua_pushstring(L, objectId_.c_str() );
    return 1;
}

/// Sets the luaCell identifier
int luaCell::setID( lua_State *L )
{
    const char* id = luaL_checkstring( L , -1);
    objectId_ = string( id );
    return 0;
}

/// Creates several types of observers
/// parameters: observer type, observeb attributes table, observer type parameters
// verif. ref (endereco na pilha lua)
// olhar a classe event
int luaCell::createObserver( lua_State *L )
{	
    // recupero a referencia da celula
    lua_rawgeti(luaL, LUA_REGISTRYINDEX, ref);
            
    // flags para a definição do uso de compressão
    // na transmissão de datagramas e da visibilidade
    // dos observadores Udp Sender 
    bool compressDatagram = false, obsVisible = true;

    // recupero a tabela de
    // atributos da celula
    int top = lua_gettop(luaL);

    // Nao modifica em nada a pilha
    // recupera o enum referente ao tipo
    // do observer
    int typeObserver = (int)luaL_checkinteger(luaL, -4);
    bool isGraphicType = (typeObserver == TObsDynamicGraphic) || (typeObserver == TObsGraphic);

    //------------------------
    QStringList allAttribs, obsAttribs;

    // Pecorre a pilha lua recuperando todos os atributos celula
    lua_pushnil(luaL);
    while(lua_next(luaL, top) != 0)
    {
        QString key( luaL_checkstring(luaL, -2) );

        allAttribs.push_back(key);
        lua_pop(luaL, 1);
    }

    //------------------------
    // pecorre a pilha lua recuperando
    // os atributos celula que se quer observar
    lua_settop(luaL, top - 1);
    top = lua_gettop(luaL);

    // Verificacao da sintaxe da tabela Atributos
    if(! lua_istable(luaL, top) )
    {
        qFatal("Error: Attributes table not found. Incorrect sintax.\n");
        return -1;
    }

    bool attribTable = false;

    lua_pushnil(luaL);
    while(lua_next(luaL, top - 1 ) != 0)
    {
        QString key( luaL_checkstring(luaL, -1) );
        attribTable = true;

        // Verifica se o atributo informado não existe deve ter sido digitado errado
        if (allAttribs.contains(key))
        {
            obsAttribs.push_back(key);
            if (! observedAttribs.contains(key))
                observedAttribs.push_back(key);
        }
        else
        {
            if ( ! key.isNull() || ! key.isEmpty())
            {
                qFatal("Error: Attribute name '%s' not found.\n", qPrintable(key));
                return -1;
            }
        }
        lua_pop(luaL, 1);
    }
    //------------------------

    //QStringList lines;

    if ((obsAttribs.empty() ) && (! isGraphicType))
    {
        obsAttribs = allAttribs;
        observedAttribs = allAttribs;
    }

    if(! lua_istable(luaL, top) )
    {
        qWarning("Warning: Parameter table not found. Incorrect sintax.");
        return 0;
    }

    QStringList cols;

    // Recupera a tabela de parametros os observadores do tipo Table e Graphic
    // caso não seja um tabela a sintaxe do metodo esta incorreta
    lua_pushnil(luaL);
    while(lua_next(luaL, top) != 0)
    {   
        QString key;
        if (lua_type(luaL, -2) == LUA_TSTRING)
            key = QString( luaL_checkstring(luaL, -2));

        switch (lua_type(luaL, -1))
        {
        case LUA_TSTRING:
            {
                QString value( luaL_checkstring(luaL, -1));
                cols.push_back(value);
                break;
            }

        case LUA_TBOOLEAN:
            {
                bool val = lua_toboolean(luaL, -1);
                if (key == "visible")
                    obsVisible = val;
                else // if (key == "compress")
                    compressDatagram = val;
            }
        default:
            break;
        }
        lua_pop(luaL, 1);
    }

    // Caso não seja definido nenhum parametro,
    // e o observador não é TextScreen então
    // lança um warning
    if ((cols.isEmpty()) && (typeObserver != TObsTextScreen))
    {
        if (! QUIET_MODE )
            qWarning("Warning: The Parameters Table is empty.");
    }
    //------------------------

    ObserverTextScreen *obsText = 0;
    ObserverTable *obsTable = 0;
    ObserverGraphic *obsGraphic = 0;
    ObserverLogFile *obsLog = 0;
    ObserverUDPSender *obsUDPSender = 0;

    int obsId = -1;

    switch (typeObserver)
    {
        case TObsTextScreen			:
            obsText = (ObserverTextScreen*) 
                CellSubjectInterf::createObserver(TObsTextScreen);
            if (obsText)
            {
                obsId = obsText->getId();
            }
            else
            {
                if (! QUIET_MODE)
                    qWarning("%s", TerraMEObserver::MEMORY_ALLOC_FAILED);
            }
            break;

        case TObsLogFile:
            obsLog = (ObserverLogFile*) 
                CellSubjectInterf::createObserver(TObsLogFile);
            if (obsLog)
            {
                obsId = obsLog->getId();
            }
            else
            {
                if (! QUIET_MODE)
                    qWarning("%s", TerraMEObserver::MEMORY_ALLOC_FAILED);
            }
            break;

        case TObsTable:
            obsTable = (ObserverTable *) 
                CellSubjectInterf::createObserver(TObsTable);
            obsId = obsTable->getId();
            break;

        case TObsDynamicGraphic:
            obsGraphic = (ObserverGraphic *) 
                CellSubjectInterf::createObserver(TObsDynamicGraphic);
           
            if (obsGraphic)
            {
                obsGraphic->setObserverType(TObsDynamicGraphic);
                obsId = obsGraphic->getId();
            }
            else
            {
                if (! QUIET_MODE)
                    qWarning("%s", TerraMEObserver::MEMORY_ALLOC_FAILED);
            }
            break;

        case TObsGraphic:
            obsGraphic = (ObserverGraphic *) 
                CellSubjectInterf::createObserver(TObsGraphic);
            if (obsGraphic)
            {
                obsId = obsGraphic->getId();
            }
            else
            {
                if (! QUIET_MODE)
                    qWarning("%s", TerraMEObserver::MEMORY_ALLOC_FAILED);
            }
            break;

        case TObsUDPSender:
            obsUDPSender = (ObserverUDPSender *) 
                CellSubjectInterf::createObserver(TObsUDPSender);
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

        case TObsMap:
        default:
            if (! QUIET_MODE )
            {
                qWarning("Warning: In this context, the code '%s' does not correspond to a "
                         "valid type of Observer.",  getObserverName(typeObserver) );
            }
            return 0;
    }

    //@RODRIGO
    //serverSession->add(obsKey);

    /// Define alguns parametros do observador instanciado ---------------------------------------------------

    if (obsLog)
    {
        obsLog->setHeaders(obsAttribs);

        if (cols.at(0).isNull() || cols.at(0).isEmpty())
        {
            if (! QUIET_MODE )
                qWarning("Warning: Filename was not specified, using a "
                         "default \"%s\".", qPrintable(DEFAULT_NAME));
            obsLog->setFileName(DEFAULT_NAME + ".csv");
        }
        else
        {
            obsLog->setFileName(cols.at(0));
        }

        // caso não seja definido, utiliza o default ";"
        if ((cols.size() < 2) || cols.at(1).isNull() || cols.at(1).isEmpty())
        {
            if (! QUIET_MODE )
                qWarning("Warning: Separator not defined, using \";\".");
            obsLog->setSeparator();
        }
        else
        {
            obsLog->setSeparator(cols.at(1));
        }

        lua_pushnumber(luaL, obsId);
        return 1;
    }

    if (obsText)
    {
        obsText->setHeaders(obsAttribs);
        lua_pushnumber(luaL, obsId);
        return 1;
    }

    if (obsTable)
    {
        if ((cols.size() < 2) || cols.at(0).isNull() || cols.at(0).isEmpty()
                || cols.at(1).isNull() || cols.at(1).isEmpty())
        {
            if (! QUIET_MODE )
                qWarning("Warning: Column title not defined.");
        }

        obsTable->setColumnHeaders(cols);
        obsTable->setLinesHeader(obsAttribs);

        lua_pushnumber(luaL, obsId);
        return 1;
    }

    if (obsGraphic)
    {
        obsGraphic->setLegendPosition();
        if (obsAttribs.size() <= 2)
        {
            obsGraphic->setHeaders(obsAttribs);
        }
        else
        {
            //printf("\nError: This observer works only with one or two elements.\n");
            qFatal("Error: This observer works only with one or two elements.\n");
            return -1;
        }

        // titulo do gráfico
        if (cols.at(0).isNull() || cols.at(0).isEmpty())
        {
            if (! QUIET_MODE )
                qWarning("Warning: Graphic title not defined.");
            obsGraphic->setGraphicTitle();
        }
        else
        {
            obsGraphic->setGraphicTitle(cols.at(0));
        }

        // nome da curva
        if ((cols.size() < 2) || cols.at(1).isNull() || cols.at(1).isEmpty())
        {
            if (! QUIET_MODE )
                qWarning("Warning: Curve name not defined.");
            obsGraphic->setCurveTitle();
        }
        else
        {
            obsGraphic->setCurveTitle(cols.at(1));
        }

        // nome dos eixos
        // FIX-ME: Separar as chamadas do nome dos eixos
        if ( (cols.size() < 3) || (cols.size() < 4) || cols.at(2).isNull() || cols.at(2).isEmpty()
             || cols.at(3).isNull() || cols.at(3).isEmpty() )
        {
            if (! QUIET_MODE )
                qWarning("Warning: Axis name not defined.");
            obsGraphic->setAxisTitle();
        }
        else
        {
            obsGraphic->setAxisTitle(cols.at(2), cols.at(3));
        }

        lua_pushnumber(luaL, obsId);
        return 1;
    }

    if(obsUDPSender)
    {
        obsUDPSender->setAttributes(obsAttribs);

        // if (cols.at(0).isEmpty())
        if (cols.isEmpty())
        {
            if (! QUIET_MODE )
                qWarning("Warning: Port not defined.");
        }
        else
        {
            obsUDPSender->setPort(cols.at(0).toInt());
        }

        // broadcast
        if ((cols.size() == 1) || ((cols.size() == 2) && cols.at(1).isEmpty()) )
        {
            if (! QUIET_MODE )
                qWarning("Warning: Observer will send to broadcast.");
            obsUDPSender->addHost(BROADCAST_HOST);
        }
        else
        {
            // multicast or unicast
            for(int i = 1; i < cols.size(); i++){
                if (! cols.at(i).isEmpty())
                    obsUDPSender->addHost(cols.at(i));
            }
        }
        lua_pushnumber(luaL, obsId);
        return 1;
    }
    return 0;
}

const TypesOfSubjects luaCell::getType()
{
    return subjectType;
}

/// Notifies observers about changes in the luaCell internal state
int luaCell::notify(lua_State *L )
{
#ifdef DEBUG_OBSERVER
    printf("\ncell::notifyObservers\n");
    luaStackToQString(12);
# endif

    double time = luaL_checknumber(L, -1);

#ifdef TME_STATISTIC
    double t = Statistic::getInstance().startTime();

    CellSubjectInterf::notifyObservers(time);

    t = Statistic::getInstance().endTime() - t;
    Statistic::getInstance().addElapsedTime("Total Response Time - cell", t);
    Statistic::getInstance().collectMemoryUsage();
#else
    CellSubjectInterf::notify(time);
#endif
    return 0;
}

//@RODRIGO
QString luaCell::getAll(QDataStream& in, int /*observerId*/, QStringList& attribs)
{
    lua_rawgeti(luaL, LUA_REGISTRYINDEX, ref);	// recupero a referencia na pilha lua
    return pop(luaL, attribs);
}

QString luaCell::pop(lua_State *luaL, QStringList& attribs)
{
    double num = 0;
    bool boolAux = false;

    QString msg, attrs, key, text;

    // id
    msg.append("cell");
    msg.append(QString::number(this->ref)); // QString("%1").arg(this->ref));
    msg.append(PROTOCOL_SEPARATOR);

    // subjectType
    msg.append(QString::number(subjectType));
    msg.append(PROTOCOL_SEPARATOR);


    int attrCounter = 0;
    int cellsPos = lua_gettop(luaL);
    // int type = lua_type (luaL, cellsPos);

    lua_pushnil(luaL);
    while(lua_next(luaL, cellsPos ) != 0)
    {
        key = QString(luaL_checkstring(luaL, -2));

        if( attribs.contains(key) )
        {
            attrCounter++;
            attrs.append(key);
            attrs.append(PROTOCOL_SEPARATOR);

            switch( lua_type(luaL, -1) )
            {
                case LUA_TBOOLEAN:
                    boolAux = lua_toboolean(luaL, -1);
                    attrs.append(QString::number(TObsBool));
                    attrs.append(PROTOCOL_SEPARATOR);
                    attrs.append(QString::number(boolAux));
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
                    attrs.append(QString::number(TObsText));
                    attrs.append(PROTOCOL_SEPARATOR);
                    attrs.append( (text.isEmpty() || text.isNull() ? VALUE_NOT_INFORMED : text) );
                    attrs.append(PROTOCOL_SEPARATOR);
                    break;

                case LUA_TTABLE:
                {
                    char result[100];
                    sprintf( result, "%p", lua_topointer(luaL, -1) );
                    attrs.append(QString::number(TObsText));
                    attrs.append(PROTOCOL_SEPARATOR);
                    attrs.append(QString("Lua-Address(TB): ") + QString(result));
                    attrs.append(PROTOCOL_SEPARATOR);
                    break;
                }
                case LUA_TUSERDATA:
                {
                    char result[100];
                    sprintf( result, "%p", lua_topointer(luaL, -1) );
                    attrs.append(QString::number(TObsText));
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
    msg.append(QString::number(0));
    msg.append(PROTOCOL_SEPARATOR );

    msg.append(attrs);
    msg.append(PROTOCOL_SEPARATOR);

    return msg;
}

QString luaCell::getChanges(QDataStream& in, int observerId, QStringList& attribs)
{
    return getAll(in, observerId, attribs);
}

#ifdef TME_BLACK_BOARD
QDataStream& luaCell::getState(QDataStream& in, Subject *, int observerId, QStringList & /* attribs */)
#else
QDataStream& luaCell::getState(QDataStream& in, Subject *, int observerId, QStringList &  attribs )
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
            // if (! QUIET_MODE )
            // qWarning(QString("Observer %1 passou ao estado %2").arg(observerId).arg(1).toAscii().constData());
            break;

        case 1:
#ifdef TME_BLACK_BOARD
        content = getChanges(in, observerId, observedAttribs);
#else
        content = getChanges(in, observerId, attribs);
#endif
            // serverSession->setState(observerId, 0);
            // if (! QUIET_MODE )
            // qWarning(QString("Observer %1 passou ao estado %2").arg(observerId).arg(0).toAscii().constData());
            break;
    }
    // cleans the stack
    // lua_settop(L, 0);

    in << content;
    return in;
}


int luaCell::kill(lua_State *luaL)
{
    int id = luaL_checknumber(luaL, 1);

    bool result = CellSubjectInterf::kill(id);
    lua_pushboolean(luaL, result);
    return 1;
}




/// Gets the luaCell position of the luaCell in the Lua stack
/// \param L is a pointer to the Lua stack
/// \param cell is a pointer to the cell within the Lua stack
void getReference( lua_State *L, luaCell *cell )
{
    cell->getReference(L);
}

