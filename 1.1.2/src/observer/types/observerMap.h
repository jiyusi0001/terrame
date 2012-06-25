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
 * \file observerMap.h
 * \brief Spatial visualization for cells and saved in the user interface
 * \author Antonio José da Cunha Rodrigues 
*/

#ifndef OBSERVER_MAP_H
#define OBSERVER_MAP_H


#include <QDialog>
#include <QTextEdit>
#include <QString>
#include <QStringList>
//#include <QPaintEvent>

#include <QThread>
#include <QTreeWidget>
#include <QTreeWidgetItem>
#include <QPainter>

class QLabel;
class QToolButton;
class QSplitter;
class QHBoxLayout;
class QSpacerItem;
class QVBoxLayout;

#include "../observerInterf.h"
#include "../components/legend/legendWindow.h"
#include "../components/painter/painterWidget.h"

namespace TerraMEObserver {

class Decoder;

class ObserverMap :  public QDialog, public ObserverInterf
{
    Q_OBJECT

public:
    ObserverMap (QWidget *parent = 0);
    ObserverMap (Subject *sub);
    virtual ~ObserverMap();

    bool draw(QDataStream &in);
    QStringList getAttributes();
    const TypesOfObservers getType();

    void setHeaders(QStringList headers, QStringList legKeys, QStringList legAttrib);
    void setCellSpaceSize(int width, int height);
    const QSize getCellSpaceSize();

    static void createColorsBar(QString colors, std::vector<ColorBar> &colorBarVec,
                        std::vector<ColorBar> &colorBarVecB, QStringList &valueList,
                        QStringList &labelList);

    static bool constainsItem(const QVector<QPair<Subject *, QString> > &linkedSubjects, 
        const Subject *subj);
    
    int close();

signals:
    void gridOn(bool);

public slots:
    void butLegend_Clicked();
    void butZoomIn_Clicked();
    void butZoomOut_Clicked();
    void butZoomWindow_Clicked();
    void butZoomRestore_Clicked();
    void butHand_Clicked();

    void treeLayers_itemChanged(QTreeWidgetItem * item, int column);
    void setOperatorMode(int );
    void zoomActivated(const QString & );
    void zoomChanged(QRect, double, double);
    void zoomOut();

protected:
    void resizeEvent(QResizeEvent *event);
    //// void paintEvent(QPaintEvent *event);
    //// void wheelEvent(QWheelEvent *event);
    //// void keyPressEvent(QKeyEvent *event);

    PainterWidget * getPainterWidget() const;
    QHash<QString, Attributes*> * getMapAttributes() const ;
    Decoder & getProtocolDecoder() const;
    void legend();
    QTreeWidget * getTreeLayers();

private:
    void init();
    void setupGUI();
    void connectTreeLayer(bool connect);
    void createOperatorComboBox();
    QPainter::CompositionMode currentMode() const;

    void calculeZoom(bool in);
    void calculateResultSize();
    void showLayerLegend();
    static ColorBar makeColorBarStruct(int distance,
                 QString strColorBar, QString &value, QString &label);
    void zoomWindow();

    TypesOfObservers observerType;
    TypesOfSubjects subjectType;

    bool paused, cleanValues;
    int numTiles;
    int rows, cols;  /// numero de linha e colunas


    QStringList itemList; /// lista de todas as chaves
    QStringList obsAttrib;  /// lista de chaves em observação
    QHash<QString, Attributes*> *mapAttributes;	/// map de todas as chaves
    QTreeWidget *treeLayers;

    QScrollArea *scrollArea;
    QFrame *frameTools;

    // QLabel *lblOperator;
    // QComboBox *operatorComboBox;
    QComboBox *zoomComboBox;

    QToolButton *butLegend, *butGrid;
    QToolButton *butZoomIn, *butZoomOut;
    QToolButton *butZoomWindow, *butHand;
    QToolButton *butZoomRestore;
    
    PainterWidget *painterWidget;
    LegendWindow *legendWindow;
    Decoder *protocolDecoder;
    int builtLegend;

    bool needResizeImage;
    double 	newWidthCellSpace, newHeightCellSpace;
    int width, height;

    QVector<int> zoomVec;
    int positionZoomVec;
    int zoomCount, zoomIdx;
    double actualZoom;
};

}

#endif
