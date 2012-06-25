/************************************************************************************
* TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
* Copyright © 2001-2012 INPE and TerraLAB/UFOP.
*  
* This code is part of the TerraME framework.
* This framework is free software; you can redistribute it and/or
* modify it under the terms of the GNU Lesser General Public
* License as published by the Free Software Foundation; either
* version 2.1 of the License, or (at your option) any later version.
* 
* You should have received a copy of the GNU Lesser General Public
* License along with this library.
* 
* The authors reassure the license terms regarding the warranties.
* They specifically disclaim any warranties, including, but not limited to,
* the implied warranties of merchantability and fitness for a particular purpose.
* The framework provided hereunder is on an "as is" basis, and the authors have no
* obligation to provide maintenance, support, updates, enhancements, or modifications.
* In no event shall INPE and TerraLAB / UFOP be held liable to any party for direct,
* indirect, special, incidental, or consequential damages arising out of the use
* of this library and its documentation.
*
*************************************************************************************/

/*!
 * \file observer.h
 * \brief Design Pattern Subject and Observer interfaces
 * \author Antonio José da Cunha Rodrigues 
 * \author Tiago Garcia de Senna Carneiro
*/

#ifndef OBSERVER_INTERFACE
#define OBSERVER_INTERFACE

#include <stdarg.h>
#include <string.h>
#include <list>
#include <iterator>
//#include <iostream>

#include <QtCore/QDataStream>
#include <QtCore/QDateTime>
#include <QtCore/QStringList>
#include <QSize>
#include <QPair>
#include <QString>


namespace TerraMEObserver{
    class Attributes;
    class Subject;
}


/// Auxiliary Function for sorting objects Attributes by the type.
bool sortAttribByType(TerraMEObserver::Attributes *a, TerraMEObserver::Attributes *b);

/// Auxiliary Function for sorting objects Subjects by the class name.
bool sortByClassName(const QPair<TerraMEObserver::Subject *, QString> & pair1, 
    const QPair<TerraMEObserver::Subject *, QString> & pair2);


// ---------------------- 

//const char *getSubjectName(TypesOfSubjects type);
//const char *getObserverName(TypesOfObservers type);
//const char *getDataName(TypesOfData type);
//const char *getGroupingName(GroupingMode type);
//const char *getStdDevNames(StdDev type);

/// Converte a tipo de Subject em char *
const char *getSubjectName(int type);

/// Converte a tipo de Observer em char *
const char *getObserverName(int type);

/// Converte a tipo de dado em char *
const char *getDataName(int type);

/// Converte a tipo de agrupamento em char *
const char *getGroupingName(int type);

/// Converte a tipo de desvio padrão em char *
const char *getStdDevNames(int type);


void delay(float seconds);


namespace TerraMEObserver{


//// Constants

static const int ZOOM_MAX = 11;
static const int ZOOM_MIN = -ZOOM_MAX;

static const int SIZE_CELL = 20;
static const int SIZE_AGENT = 10;
static const int SIZE_AUTOMATON = SIZE_CELL;

static const int DEFAULT_PORT = 456456;

static const QSize ICON_SIZE(16, 16);
static const QSize IMAGE_SIZE(1000, 1000);

static const QString BROADCAST_HOST = "255.255.255.255";
static const QString TIMER_KEY = "@time";
static const QString EVENT_KEY = "@event";
static const QString DEFAULT_NAME = "result_";

static const QString PROTOCOL_SEPARATOR = "‡";
static const QString VALUE_NOT_INFORMED = "not informed"; 

// Legend keys
static const QString TYPE = "type";
static const QString GROUP_MODE = "groupingMode";
static const QString SLICES = "slices";
static const QString PRECISION = "precision";
static const QString STD_DEV = "stdDeviation";
static const QString MAX = "maximum";
static const QString MIN = "minimum";
static const QString COLOR_BAR = "colorBar";
static const QString STD_COLOR_BAR = "stdColorBar";
static const QString FONT_FAMILY = "font";
static const QString FONT_SIZE = "fontSize";
static const QString SYMBOL = "symbol";
static const QStringList LEGEND_KEYS = QStringList() << TYPE << GROUP_MODE << SLICES 
    << PRECISION << STD_DEV << MAX << MIN << COLOR_BAR << FONT_FAMILY << FONT_SIZE 
    << SYMBOL; // << STD_COLOR_BAR; // is not a legend key
static const int LEGEND_ITENS = LEGEND_KEYS.size(); /// Número de itens que compoem a legenda de cada atributo


static const QString WINDOW = "Window";
static const QString TRAJECTORY_LABEL = "does not belong";
static const QString TRAJECTORY_COUNT = "others";
static const QString COMPLETE_STATE = "COMPLETE_STATE";
static const QString COMPLETE_SIMULATION = "COMPLETE_SIMUL";


static const qreal PI = 3.141592653589;



static const char *MEMORY_ALLOC_FAILED = "Failed: Not enough memory for execute this action.";




/**
* \enum TerraMEObserver::TypesOfSubjects
* \brief TerraME Subject Types.
* 
*/
enum TypesOfSubjects 
{
    TObsUnknown             = 0,    //!< Type unknown

    TObsCell,               //!< Cell type
    TObsCellularSpace,      //!< CellularSpace type
    TObsNeighborhood,       //!< Neighborhood type
    TObsTimer,              //!< Timer type
    TObsEvent,              //!< Event type
    TObsTrajectory,         //!< Trajectory type
    TObsAutomaton,          //!< Automaton type
    TObsAgent,              //!< Agent type
    TObsEnvironment         //!< Environment type

    // TObsMessage,         // it isn't a Subject
    // TObsState,           // it isn't a Subject
    // TObsJumpCondition,   // it isn't a Subject
    // TObsFlowCondition,  // it isn't a Subject
};

/**
* \enum TerraMEObserver::TypesOfObservers
* \brief TerraME Observer Types.
*
*/
enum TypesOfObservers
{
    TObsUndefined           =  0,   //!< Undefined type

    TObsTextScreen          =  1,   //!< TextScreen type
    TObsLogFile             =  2,   //!< LogFile type
    TObsTable               =  3,   //!< Table type
    TObsGraphic             =  4,   //!< Graphic type
    TObsDynamicGraphic      =  5,   //!< Observes one attribute over the time
    TObsMap                 =  6,   //!< Observes one or two attributes over the space
    TObsUDPSender           =  7,   //!< Sends the attributes via UDP protocol
    TObsScheduler           =  8,   //!< Observes the scheduler's event
    TObsImage               =  9,   //!< Saves in an image the attributes observed over the space
    TObsStateMachine        = 10    //!< Observes the states and transitions of a State Machine type
};

/**
* \enum TerraMEObserver::TypesOfData
* \brief TerraME Data Types.
*
*/
enum TypesOfData
{
    TObsBool,                   //!< Boolean type
    TObsNumber,                 //!< Numeric type 
    TObsDateTime,               //!< Time stamp type 
    TObsText,                   //!< Textual type

    TObsUnknownData     = 100   //!< Unknown type
};

/**
* \enum TerraMEObserver::GroupingMode
* \brief TerraME Grouping Mode.
*
*/
enum GroupingMode
{
    TObsEqualSteps      = 0,    //!< Equal steps type
    TObsQuantil         = 1,    //!< Quantil type
    TObsStdDeviation    = 2,    //!< Standard deviation type
    TObsUniqueValue     = 3     //!< Unique value type
};


/**
* \enum TerraMEObserver::StdDev
* \brief TerraME Standard Deviation Groupping Type.
*
*/
enum StdDev
{
    TObsNone    = -1,   //!< None deviation

    TObsFull    =  0,   //!< Full deviation
    TObsHalf    =  1,   //!< Half deviation
    TObsQuarter =  2    //!< Quarter deviation
};



class Subject;

/**
* \brief
*  Interface for a Observer object.
*
*/
class Observer
{
public:

    /**
    * Metodo responsável por atualizar o estado interno do Observer
    * \param tempo de simulação
    * \return boolean indicando que ocorreu ou não a atualização
    */
    virtual bool update(double ) = 0;

    /**
    * Define o tempo de simulação
    * \param tempo de simulação
    */ 
    virtual void setModelTime(double ) = 0;

    /**
    * Define a visibilidade do Observer
    * \param boolean visibilidade do observador
    */
    virtual void setVisible(bool ) = 0;

    /**
    * Recupera a visibilibdade do Obserser
    * \return visibilidade do observador
    */
    virtual bool getVisible() = 0;

    /**
    * Apresenta o estado do Subject observado
    * \param QDataStream objeto serializado contendo o estado do Subject
    * \see Subject, \see QDataStream
    */
    virtual bool draw(QDataStream &) = 0; //vê se vem pra ca tbm

    /**
    * Recupera o identificador do Observer
    * \return identificador do observador
    */
    virtual int getId() = 0;

    /**
    * Recupera o tipo do Observador
    * \return enumerador que identifica o tipo de Observer
    * \see TypesOfObservers
    */
    virtual const TypesOfObservers getType() = 0;

    // / Define a lista de atributos em observação
    //virtual void setAttributes(const QStringList &) = 0;
    
    /**
    * Recupera a lista de atributos em observação
    * \return QStringList lista de atributtos
    */
    virtual QStringList getAttributes() = 0;

    /**
    * Define o estado do Observer como desatualizado
    */ 
    virtual void setDirtyBit() = 0;
};

/**
* \brief
*  TerraME Subject Interface.
*
*/
class Subject
{
public:
    /**
    * Método responsável em 'anexar' o observer ao Subject
    * \param ponteiro para um objeto Observer
    * \see Observer
    */
    virtual void attach(Observer *) = 0;

    /**
    * Método responsável em 'liberar' o observer do Subject
    * \param ponteiro para um objeto Observer
    * \see Observer
    */
    virtual void detach(Observer *) = 0;

    /**
    * Recupera um ponteiro para um observador por meio de seu ID
    * ou um ponteiro nulo
    * \param identificador único de um observador
    * \return ponteiro para um observador
    */
    virtual Observer * getObserverById(int ) = 0;

    /**
    * Método responsável em 'notificar' todos os observer envolvidos
    * \param tempo da simulação
    */
    virtual void notify(double ) = 0;

    /**
    * Metodo puramente virtual, responsável por serializar/ deserializar o objeto
    * \param QDataStream, objeto serializável
    * \param ponteiro para o objeto Subject observado
    * \param identificador para o observador
    * \param lista de atributos observavéis
    * \see Subject, \see QDataStream, \see QStringList
    */
    virtual QDataStream& getState(QDataStream &, Subject *,
                                  int, QStringList &) = 0;
    
    /**
    * Recupera o tipo do Subject
    * \return enumerador que identifica o Subject
    * \see TypesOfSubjects
    */
    virtual const TypesOfSubjects getType() = 0;

    /**
    * Recupera o identificador do Subject
    * \return identificador único do Subject
    */
    virtual int getId() const = 0;
};

}


#endif
