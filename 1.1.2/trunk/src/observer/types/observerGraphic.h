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
 * \brief Plots a simple scatter plot graphic or a scatter plot over the time
 * \author Antonio José da Cunha Rodrigues 
*/

#ifndef OBSERVER_GRAPHIC
#define OBSERVER_GRAPHIC

#include "../observerInterf.h"

#include <QDialog>
#include <QThread>
//#include <QCloseEvent>

#include <qwt_plot.h>
#include <qwt_plot_curve.h>
#include <qwt_legend.h>
#include <qwt_plot_grid.h>
#include <qwt_plot_picker.h>

//#include <qwt_plot_marker.h>
//
//#include <qwt_data.h>
//#include <qwt_text.h>
//#include <math.h>

namespace TerraMEObserver {

class ObserverGraphic : public QThread, public ObserverInterf 
{
    Q_OBJECT

public:
    //enum LegendPosition{
    //	Left,
    //	Top,
    //	Right,
    //	Bottom,

    //	External // legenda em uma janela externa
    //};

    // ObserverGraphic (QWidget *parent = 0);
    ObserverGraphic (Subject *, QWidget *parent = 0);
    virtual ~ObserverGraphic();

    bool draw(QDataStream &);

    void setGraphicTitle(QString title = "unnamed graphic");
    void setCurveTitle(QString title = "unnamed curve");
    void setAxisTitle(QString x = "axis x", QString y = "axis y");
    void setData(double &, double &);
    void setHeaders(QStringList );
    QStringList getAttributes();

    void setLegendPosition(QwtPlot::LegendPosition pos = QwtPlot::RightLegend);
    //void setGrid()

    void setObserverType(TypesOfObservers type);
    const TypesOfObservers getType();
    void setModelTime(double time);
    void setCurveStyle();

    void pause();		// ref. à Thread
    int close();

private slots:
    void colorChanged(QwtPlotItem *);

protected:
    void run();		// ref. à Thread
    //void closeEvent(QCloseEvent *e);

private:
    void draw();
    void createPicker();

    TypesOfObservers observerType;
    TypesOfSubjects subjectType;
    double modelTime, lastModelTime;

    QStringList itemList, states;
    QString curveTitle;
    QString xTitle;
    QString yTitle;
    QString graphicTitle;

    QwtPlot* plotter;
    QwtPlotCurve* curve;
    QwtLegend *legend;
    QwtPlotPicker *picker;

    QVector<double> xValue;
    QVector<double> yValue;

    bool paused;		// ref. à Thread
    double x, y;
};
}
#endif
