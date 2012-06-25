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
 * \file modelConsole.h
 * \brief User interface for Model Console object
 * \author Antonio Jos� da Cunha Rodrigues 
*/

#ifndef MODELCONSOLE_H
#define MODELCONSOLE_H

#include <QWidget>

namespace Ui {
class ModelConsoleGUI;
}

class ModelConsole : public QWidget
{
    Q_OBJECT

public:

    virtual ~ModelConsole();

    // static ModelConsole& getInstance();
    void appendMessage(const QString &s);

protected:
    ModelConsole(QWidget *parent = 0);

private:
    Ui::ModelConsoleGUI *ui;
};

#endif // MODELCONSOLE_H
