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
 * \brief Shows the schedule events
 * \author Antonio José da Cunha Rodrigues 
*/

#ifndef OBSERVER_SCHEDULER
#define OBSERVER_SCHEDULER

#include "../observerInterf.h"

#include <QDialog>
#include <QHash>
// #include <QThread>
#include <QStringList>

class QTreeWidget;
class QTreeWidgetItem;
class QLabel;
class QToolButton;
class QResizeEvent;

namespace TerraMEObserver {

class ObserverScheduler : public QDialog, public ObserverInterf // , public QThread
{
    Q_OBJECT

public:
    ObserverScheduler(QWidget *parent = 0);
    ObserverScheduler(Subject *, QWidget *parent = 0);
    virtual ~ObserverScheduler();

    bool draw(QDataStream &);
    void setAttributes(QStringList attribs);
    QStringList getAttributes();

    const TypesOfObservers getType();

    void pause();		// ref. à Thread

private slots:
    void on_butExpand_clicked();

protected:
    // void run();		// ref. à Thread
    //void closeEvent(QCloseEvent *e)
    //void resizeEvent(QResizeEvent *);

private:
    void setTimer(const QString & timer);
    const QString number2QString(double number);

    enum PositionItems {
        Key,
        Time,
        Periodicity,
        Priority
    };


    TypesOfObservers observerType;
    TypesOfSubjects subjectType;
    bool paused;		// ref. à Thread

    QTreeWidget* pipelineWidget;
    QLabel *lblClock;
    QWidget *clockPanel;
    QToolButton *butExpand;

    QStringList attributes;

    QHash<QString, QTreeWidgetItem *> hashTreeItem;

};

}

#endif
