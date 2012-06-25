/************************************************************************************
TerraLib - a library for developing GIS applications.
Copyright © 2001-2007 INPE and Tecgraf/PUC-Rio.

This code is part of the TerraLib library.
This library is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public
License as published by the Free Software Foundation; either
version 2.1 of the License, or (at your option) any later version.

You should have received a copy of the GNU Lesser General Public
License along with this library.

The authors reassure the license terms regarding the warranties.
They specifically disclaim any warranties, including, but not limited to,
the implied warranties of merchantability and fitness for a particular purpose.
The library provided hereunder is on an "as is" basis, and the authors have no
obligation to provide maintenance, support, updates, enhancements, or modifications.
In no event shall INPE and Tecgraf / PUC-Rio be held liable to any party for direct,
indirect, special, incidental, or consequential damages arising out of the use
of this library and its documentation.
*************************************************************************************/

#ifndef  __TERRALIB_INTERNAL_QTCOLORBAR_H
#define  __TERRALIB_INTERNAL_QTCOLORBAR_H

#include <QFrame>
//#include <TeVisual.h>
//#include <TeColorUtils.h>
#include "legendColorUtils.h"
#include <QMenu>
#include <QCursor>
#include <vector>
#include <map>
using namespace std;

//class Help;
namespace TerraMEObserver {

class TeQtColorBar : public QFrame
{
    Q_OBJECT

public:

    TeQtColorBar( QWidget* parent);
    virtual ~TeQtColorBar();
    void	setColorBar(const vector<TeColor>& colorVec);
    void	setColorBar(const vector<ColorBar>& colorBarVec);
    void	setColorBarFromNames(string colors);
    void	drawColorBar();
    void	setVerticalBar(bool b);
    void	setUpDownBar(bool b) {upDown_ = b;}
    void	invertColorBar();
    void	clearColorBar();
    void	setEqualSpace();
    std::vector<ColorBar>	getInputColorVec() {return inputColorVec_;}

    QVector<QColor> getQVectColor(){ return qvecColor;};

public slots:
    void	addColorSlot();
    void	changeColorSlot();
    void	removeColorSlot();
    void	helpSlot();

protected:

    void	paintEvent(QPaintEvent *);

    void	mousePressEvent(QMouseEvent*);
    void	mouseMoveEvent(QMouseEvent*);
    void	mouseReleaseEvent(QMouseEvent*);
    void	mouseDoubleClickEvent(QMouseEvent*);

    void	leaveEvent(QEvent*);
    void	resizeEvent(QResizeEvent*);

    void	generateColorMap();
    int		getColorIndiceToChange();
    void	fitMousePosition(QPoint);
    void	changeDistance();
    void	changeBrightness();
    void	changeAllSaturation();
    void	changeSaturation();
    void	changeAllBrightness();
    void	changeHue();
    void	sortByDistance();
    ColorBar* colorEdit_;
    //	std::vector<TeColor>	getColors(TeColor, TeColor, int);

    QMenu popupMenu_;
    QAction *addColor;
    QAction *removeColor;
    QAction *changeColor;


    QPoint	p_;
    QPoint	pa_;
    int		a_;
    int		b_;
    int		ftam_;
    int		ind_;
    std::vector<ColorBar> inputColorVec_;
    std::vector<int> changeVec_;
    std::map<int, std::vector<TeColor> > colorMap_;
    bool	vertical_;
    bool	upDown_;
    bool	brightness_;
    bool	change_;
    bool	distance_;
    int		limit_, inf_, sup_;
    double	totalDistance_;
    //Help*	help_;

    QVector<QColor> qvecColor;

signals:
    void mouseReleaseSignal(QMouseEvent*);
    void mouseMoveSignal(QMouseEvent*);
    void colorChangedSignal();
};

}

#endif // __TERRALIB_INTERNAL_QTCOLORBAR_H

