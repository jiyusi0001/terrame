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
 * \file painterWidget.h
 * \brief Draws an state machine
 * \author Antonio José da Cunha Rodrigues 
*/

#ifndef CANVAS_H
#define CANVAS_H

#include <QGraphicsView>
#include <QMouseEvent>
#include <QPaintEvent>
#include <QCursor>
#include <QPoint>

class QGraphicsRectItem;

namespace TerraMEObserver
{

class Canvas : public QGraphicsView
{
    Q_OBJECT

public:
    Canvas(QGraphicsScene * scene, QWidget *parent = 0);
    virtual ~Canvas();

    void setWindowCursor();
    void setPanCursor();



signals:
    void zoomChanged(QRectF, float, float);
    void zoomOut();

protected:
    virtual void paintEvent(QPaintEvent *event);
    virtual void mousePressEvent(QMouseEvent *event);
    virtual void mouseMoveEvent(QMouseEvent *event);
    virtual void mouseReleaseEvent(QMouseEvent *event);
    
private:

    QPointF lastDragPos, imageOffset;
    bool showRectZoom, zoomWindow, handTool;
    bool gridEnabled;
    bool existAgent;
    QGraphicsRectItem *zoomRectItem;

    QCursor zoomWindowCursor;
    QCursor zoomInCursor, zoomOutCursor;
};

}

#endif // CANVAS_H