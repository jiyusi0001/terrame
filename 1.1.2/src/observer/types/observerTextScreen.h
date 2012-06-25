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
 * \file observerPlayerGUI.h
 * \brief Shows in tabled form attributes observed 
 * \author Antonio José da Cunha Rodrigues 
*/

#ifndef OBSERVER_TEXTSCREEN
#define OBSERVER_TEXTSCREEN

#include "../observerInterf.h"

#include <QtGui/QDialog>
#include <QtGui/QTextEdit>
#include <QtCore/QString>
#include <QtCore/QStringList>
#include <QtCore/QThread>
#include <QtGui/QCloseEvent>

namespace TerraMEObserver {

class ObserverTextScreen : public QTextEdit, public ObserverInterf, public QThread
{
public:
    ObserverTextScreen (QWidget *parent = 0);
    ObserverTextScreen (Subject *, QWidget *parent = 0);
    virtual ~ObserverTextScreen();

    bool draw(QDataStream &);
    void setHeaders(QStringList h);
    //QStringList getHeaders();
    QStringList getAttributes();

    //void setShowScreen(bool screen = true);
    //bool getShowScreen();

    const TypesOfObservers getType();

    void pause();		// ref. à Thread

    int close();

protected:
    void run();		// ref. à Thread
    //void closeEvent(QCloseEvent *e);

private:
    bool write();
    bool headerDefined();

    TypesOfObservers observerType;
    TypesOfSubjects subjectType;

    QStringList itemList,valuesList;

    bool header;
    //bool showScreen;

    bool paused;		// ref. à Thread

};

}

#endif
