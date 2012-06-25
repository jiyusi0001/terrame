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
 * \file agentObserverMap.h
 * \brief Combined visualization for Agent, Automaton and Trajectory in the user interface
 * \author Antonio José da Cunha Rodrigues 
*/

#ifndef AGENT_OBSERVER_MAP
#define AGENT_OBSERVER_MAP

#include <QStringList>
#include <QPair>

#include "observerMap.h"

class SubjectInterf;

namespace TerraMEObserver {

class AgentObserverMap : public ObserverMap
{

public:
    AgentObserverMap(QWidget *parent = 0);
    AgentObserverMap(Subject *sub);
    virtual ~AgentObserverMap();

    bool draw(QDataStream &in);

    void registry(Subject *, const QString & className = QString(""));
    bool unregistry(Subject *, const QString & className = QString(""));
    void unregistryAll();

    void setSubjectAttributes(const QStringList & headers, TypesOfSubjects type,
                            const QString &className = QString(""));
    QStringList & getSubjectAttributes();

private:
    bool decode(QDataStream &state, TypesOfSubjects subject);
    bool draw();

    QVector<QPair<Subject *, QString> > linkedSubjects;
    QStringList subjectAttributes;
    bool cleanImage;
    QString className;
};

}

#endif  //AGENT_OBSERVER_MAP
