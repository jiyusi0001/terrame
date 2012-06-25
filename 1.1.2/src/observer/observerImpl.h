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
 * \file observerImpl.h
 * \brief Design Pattern Subject and Observer implementations
 * \author Antonio José da Cunha Rodrigues
 * \author Tiago Garcia de Senna Carneiro
*/
#ifndef OBSERVER_IMPL
#define OBSERVER_IMPL

#include "../core/bridge.h"
#include "observer.h"

#include <stdarg.h>
#include <string.h>
#include <list>
#include <iterator>
//#include <iostream>
#include <QtCore/QDataStream>
#include <QtCore/QDateTime>


class SubjectImpl;

using namespace TerraMEObserver;


/**
 * \brief
 *  Implementation for a Observer object.
 *
 */
class ObserverImpl : public Implementation
{
public:	
    /// Constructor
    ObserverImpl();

    /// Destructor
    virtual ~ObserverImpl();

    // Metodo responsável por atualizar os estado do Subject
    bool update(double time);

    bool getVisible();

    void setVisible(bool b);

    void setSubject(TerraMEObserver::Subject *s);

    void setObsHandle(Observer* o);

    virtual const TypesOfObservers getObserverType();

    virtual void setModelTime(double time);

    int getId();

    virtual QStringList getAttributes();

    void setDirtyBit();

private:
    ObserverImpl(const ObserverImpl &);
    ObserverImpl & operator=(ObserverImpl &);

    bool visible;
    int observerID;
    TerraMEObserver::Subject* subject_;
    Observer* obsHandle_;
};



////////////////////////////////////////////////////////////  Subject


/**
 * \brief
 *  Observer List Type.
 *
 */
typedef std::list<Observer*> ObsList;

/**
 * \brief
 *  Observer List Iterator Type.
 *
 */
typedef ObsList::iterator ObsListIterator;

/**
 * \brief
 *  Implementation for a Subject object.
 *
 */
class SubjectImpl : public Implementation
{
public:

    /// constructor
    SubjectImpl();

    virtual ~SubjectImpl();

    // Método responsável em 'anexar' o observer ao Subject
    void attachObserver(Observer *);

    // Método responsável em 'liberar' o observer do Subject
    void detachObserver(Observer *);

    // Recuperar um observador por meio de seu ID
    Observer * getObserverById(int observerId);

    // Método responsável em 'notificar' todos os observer envolvidos
    void notifyObservers(double time);

    virtual const TypesOfSubjects getSubjectType();

    int getId() const;

private:
    SubjectImpl(const SubjectImpl &);
    SubjectImpl & operator=(SubjectImpl &);

    ObsList observers;
    int subjectID;
};


#endif
