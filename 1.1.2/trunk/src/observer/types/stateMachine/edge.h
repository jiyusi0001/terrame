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
 * \file edge.h
 * \brief State machine edge
 * \author Antonio Jos� da Cunha Rodrigues 
*/

#ifndef EDGE_H
#define EDGE_H

#include <QGraphicsLineItem>

QT_BEGIN_NAMESPACE
class QGraphicsPolygonItem;
class QGraphicsItem;
class QGraphicsLineItem;
class QGraphicsScene;
class QRectF;
class QGraphicsSceneMouseEvent;
class QPainterPath;
QT_END_NAMESPACE

namespace TerraMEObserver
{

class Node;

class Edge : public QGraphicsLineItem
{
public:
    Edge(Node *origin, Node *destiny, QGraphicsItem *parent = 0, QGraphicsScene *scene = 0);
    virtual ~Edge();

    QRectF boundingRect() const;
    QPainterPath shape() const;
    void paint(QPainter *painter, const QStyleOptionGraphicsItem *, QWidget *);

public slots:
    void updatePosition();

private:


    Node *origin, *destiny;
    QPolygonF arrowHead;
};

}

#endif // EDGE_H
