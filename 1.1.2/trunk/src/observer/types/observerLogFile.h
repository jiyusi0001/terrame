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
 * \file observerGraphic.h
 * \brief Saves the observed attributes in a log file
 * \author Antonio José da Cunha Rodrigues 
*/

#ifndef OBSERVER_LOG_FILE
#define OBSERVER_LOG_FILE

#include "../observerInterf.h"

#include <QtGui/QDialog>
#include <QtCore/QString>
#include <QtCore/QStringList>
#include <QtCore/QFile>
#include <QtCore/QThread>
#include <QtGui/QCloseEvent>

#include <iostream>

namespace TerraMEObserver {

class ObserverLogFile : public QObject, public ObserverInterf//, public QThread
{
public:
    //enum WriteMode {
    //    WriteOnly	= 0,
    //    Append		= 1,
    //};

    // WriteMode == w  -> writeOnly
    // WriteMode == w+ -> append

    ObserverLogFile();
    ObserverLogFile (Subject *);
    virtual ~ObserverLogFile();

    bool draw(QDataStream &in);
    void setFileName(QString name);
    void setSeparator(QString sep = ";");
    void setHeaders(QStringList h);
    bool headerDefined();
    //void setWriteMode(WriteMode mode = WriteMode::WriteOnly);
    //WriteMode getWriteMode();
    void setWriteMode(QString mode = "w");
    QString getWriteMode();
    QStringList getAttributes();

    const TypesOfObservers getType();

    void pause();		// ref. à Thread
    int close();

protected:
    void run();		// ref. à Thread
    //void closeEvent(QCloseEvent *e);

private:
    void init();
    void formatFile();
    bool write();

    TypesOfObservers observerType;
    TypesOfSubjects subjectType;

    QStringList itemList, valuesList;
    QString fileName;
    QString separator;
    //QFile *file;

    bool header;
    //WriteMode mode;
    QString mode;

    bool paused;		// ref. à Thread
};

}

#endif
