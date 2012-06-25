/************************************************************************************
* TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
* Copyright � 2001-2012 INPE and TerraLAB/UFOP.
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
 * \file observerPlayerGUI.h
 * \brief Shows in tabular form attributes observed 
 * \author Antonio Jos� da Cunha Rodrigues 
*/

#ifndef OBSERVER_TABLE
#define OBSERVER_TABLE

#include "../observerInterf.h"

#include <QtGui/QDialog>
#include <QtGui/QTreeWidget>
#include <QtCore/QThread>
#include <QtCore/QStringList>

namespace TerraMEObserver {

class ObserverTable : public QDialog, public ObserverInterf, public QThread
{
public:
    ObserverTable (QWidget *parent = 0);
    ObserverTable (Subject *, QWidget *parent = 0);
    virtual ~ObserverTable();

    void setColumnHeaders(QStringList colHeaders);
    void setLinesHeader(QStringList linHeaders);

    void setContents(QStringList, QStringList );
    bool draw(QDataStream &);
    QStringList getAttributes();

    const TypesOfObservers getType();

    void pause();		// ref. � Thread
    // void suspend();		// ref. � Thread

    int close();

protected:
    void run();		// ref. � Thread
    //void closeEvent(QCloseEvent *e);

private:
    TypesOfObservers observerType;
    TypesOfSubjects subjectType;

    QTreeWidget* tableWidget;
    bool paused;		// ref. � Thread
    QStringList itemList;
};

}

#endif
