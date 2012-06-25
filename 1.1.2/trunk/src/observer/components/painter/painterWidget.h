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
 * \brief Draws the cellular space state
 * \author Antonio José da Cunha Rodrigues 
*/

#ifndef PAINTER_WIDGET_H
#define PAINTER_WIDGET_H

#include <QtGui/QScrollArea>
#include <QtGui/QLabel>
#include <QtGui/QImage>
#include <QtGui/QPainter>
#include <QtCore/QHash>
#include <QtCore/QString>
#include <QtGui/QPaintEvent>
#include <iostream>

#include "painterThread.h"

namespace TerraMEObserver {


class PainterWidget : public QWidget
{
    Q_OBJECT
public:
    PainterWidget(QHash<QString, Attributes*> *mapAttributes, QWidget *parent = 0);
    virtual ~PainterWidget();

    void setOperatorMode(QPainter::CompositionMode mode);
    // void plotMap(QHash<QString, Attributes*> *mapAttributes = 0);
    void plotMap(Attributes *attrib);
    void replotMap();
    // void setVectorPos(QVector<double> *xs, QVector<double> *ys);

    bool rescale(QSize size); // modifica o zoom de acordo com o tamanho do painterWidget

    void resizeImage(const QSize &newSize);   //, QImage *img = 0);
    QSize getOriginalSize();

    void setParentScroll(QScrollArea *mParentScroll);
    // Ativa o ícone como zoom de janela
    void setZoomWindow();
    // Ativa o ícone como pan
    void setHandTool();
    void defineCursor(QCursor &cursor);

    bool save(const QString &);
    void setExistAgent(bool exist);
    int close();

signals:
    void zoomChanged(QRect, double, double);
    void zoomOut();

public slots:
    void calculateResult();
    //void updatePixmap(const QImage &, double){};
    void gridOn(bool);

protected:
    void paintEvent(QPaintEvent *event);
    void mousePressEvent(QMouseEvent *event);
    void mouseMoveEvent(QMouseEvent *event);
    void mouseReleaseEvent(QMouseEvent *event);
    //void wheelEvent(QWheelEvent *event);
    void resizeEvent(QResizeEvent *event);

private:
    void drawGrid();
    void drawAgent();

    int countSave;
    double pixmapScale, curScale, scaleFactor;
    double heightProportion, widthProportion;
    QPainter::CompositionMode operatorMode;

    // atributos em observação
    QImage resultImage;
    QImage resultImageBkp;

    // objetos do ObserverMap
    QHash<QString, Attributes*> *mapAttributes;
    QScrollArea *mParentScroll;

    PainterThread painterThread;

    QPoint lastDragPos, imageOffset;
    bool showRectZoom, zoomWindow, handTool;
    bool gridEnabled;
    bool existAgent;

    QCursor zoomWindowCursor;
    QCursor zoomInCursor, zoomOutCursor;
};

}

#endif
