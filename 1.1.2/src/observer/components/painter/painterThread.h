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
 * \file painterThread.h
 * \brief Auxiliary class for draws the cellular space state
 * \author Antonio José da Cunha Rodrigues 
*/

#ifndef OBESERVERMAP_RENDERTHREAD_H
#define OBESERVERMAP_RENDERTHREAD_H


#include <QtCore/QMutex>
#include <QtCore/QSize>
#include <QtCore/QWaitCondition>
#include <QtGui/QImage>
#include <QtCore/QThread>
#include <QtGui/QPainter>

#include "../../observer.h"

namespace TerraMEObserver {

class Attributes;

class PainterThread : public QThread
{
    Q_OBJECT

public:
    PainterThread(QObject *parent = 0);
    virtual ~PainterThread();

    void drawAttrib(QPainter *p, Attributes *attrib);
    // void setVectorPos(QVector<double> *xs, QVector<double> *ys);

    void drawGrid(QImage &imgResult, double &width, double &height);

signals:
    //void teste();
    //void renderedImage(const QImage &image, double scaleFactor);

public slots:
    // void gridOn(bool);

protected:
    void run();

private:
    void draw(QPainter *, TypesOfSubjects , double &, double &);

    QMutex mutex;
    QWaitCondition condition;
    bool restart, abort, reconfigMaxMin;

    QPainter *p;
    // QPen defaultPen;
};

}

#endif
