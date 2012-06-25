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
 * \brief Plots the state machine nodes and edges
 * \author Antonio José da Cunha Rodrigues 
*/

#ifndef OBSERVERSTATEMACHINE_H
#define OBSERVERSTATEMACHINE_H

#include <QDialog>
#include <QHash>
#include <QRectF>

#include "../observerInterf.h"
#include "components/legend/legendWindow.h"

class QGraphicsView;
class QGraphicsScene;
class QWheelEvent;
class QLabel;
class QToolButton;
class QComboBox;
class QFrame;
class QTreeWidget;
class QResizeEvent;

namespace TerraMEObserver
{

class Decoder;
class Node;
class Canvas;

class ObserverStateMachine : public QDialog, public ObserverInterf
{
    Q_OBJECT

public:
    ObserverStateMachine(Subject *sub, QWidget *parent = 0);
    ~ObserverStateMachine();

    bool draw(QDataStream &);
    void setAttributes(QStringList attribs, QStringList legKeys, QStringList legAttrib);
    QStringList getAttributes();

    void addState(QList<QPair<QString, QString> > &allStates);

    const TypesOfObservers getType();

public slots:
    void butLegend_Clicked();
    void butZoomIn_Clicked();
    void butZoomOut_Clicked();
    void butZoomWindow_Clicked();
    void butZoomRestore_Clicked();
    void butHand_Clicked();

    void zoomActivated(const QString & );
    void zoomChanged(const QRectF &zoomRect, float factWidth, float factHeight);
    void zoomOut();

protected:
    void wheelEvent(QWheelEvent *event);
    void scaleView(qreal scaleFactor);
    void resizeEvent(QResizeEvent *);

private:
    void setupGUI();
    void showLayerLegend();
    // void connectTreeLayer(bool );
    int calculeZoom(bool in);
    void zoomWindow();

    TypesOfObservers observerType;
    TypesOfSubjects subjectType;
    int buildLegend;

    Canvas *view;
    QGraphicsScene *scene;
    QTreeWidget *treeLayers;

    LegendWindow *legendWindow;
    Decoder *protocolDecoder;

    QHash<QString, Node *> *states;
    QStringList attributes;
    QStringList obsAttrib;							// lista de chaves em observação
    QHash<QString, Attributes *> *mapAttributes;		// map de todas as chaves
    
    QVector<int> zoomVec;
    int positionZoomVec;
    float offsetState;
    QPointF center;

    QComboBox *zoomComboBox;
 
    QToolButton *butLegend, *butGrid;
    QToolButton *butZoomIn, *butZoomOut;
    QToolButton *butZoomWindow, *butHand;
    QToolButton *butZoomRestore;

    // QLabel *lblOperator;
    QFrame *frameTools;
};

}

#endif // OBSERVERSTATEMACHINE_H
