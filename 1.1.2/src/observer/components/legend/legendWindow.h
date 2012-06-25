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
 * \file legendWindow.h
 * \brief User interface for legend
 * \author Antonio José da Cunha Rodrigues 
*/

#ifndef LEGEND_WINDOW_OBSERVERMAP
#define LEGEND_WINDOW_OBSERVERMAP

#include <QtCore/QVariant>
#include <QtGui/QAction>
#include <QtGui/QApplication>
#include <QtGui/QButtonGroup>
#include <QtGui/QComboBox>
#include <QtGui/QDialog>
#include <QtGui/QGridLayout>
#include <QtGui/QGroupBox>
#include <QtGui/QHBoxLayout>
#include <QtGui/QLabel>
#include <QtGui/QPushButton>
#include <QtGui/QSpacerItem>
#include <QtGui/QVBoxLayout>
//#include <QtCore/QDir>
#include <set>
#include <QtCore/QAbstractItemModel>
#include <QtGui/QAbstractItemView>
#include <QtGui/QItemSelectionModel>
#include <QtGui/QStandardItemModel>
#include <QtGui/QTableWidget>

//#include "TeQtBigTable.h"
#include "legendColorBar.h"
#include <QtGui/QColor>
#include <QtCore/QString>

#include "../../terrameIncludes.h"
#include "legendAttributes.h"

namespace TerraMEObserver {

class LegendWindow : public QDialog
{
    Q_OBJECT

public:
    LegendWindow(QWidget *parent = 0);
    virtual ~LegendWindow();

    void setValues(QHash<QString, Attributes*> *mapAttributes);
    void putLegend(Attributes *attrib);
    void makeLegend();

    // Converte uma cor em uma imagem
    QPixmap color2Pixmap(const QColor &color, const QSize size = ICON_SIZE);

public slots:
    int exec();
    void rejectWindow();

    void slicesComboBox_activated( const QString & );
    void attributesComboBox_activated(const QString &);
    void stdDevComboBox_activated(const QString &);
    void precisionComboBox_activated(const QString &);

    //    void importFromThemeComboBox_activated(const QString &);
    //    void importFromViewComboBox_activated(const QString &);

    void functionComboBox_activated(int);
    //    void chrononComboBox_activated(int);
    //    void loadNamesComboBox_activated(int);
    void groupingModeComboBox_activated(int);

    void okPushButton_clicked();
    //    void helpPushButton_clicked();
    void invertColorsPushButton_clicked();
    void equalSpacePushButton_clicked();
    void clearColorsPushButton_clicked();
    void applyPushButton_clicked();
    //    void importPushButton_clicked();
    //    void saveColorPushButton_clicked();


    //    void importCheckBox_toggled(bool);
    void colorChangedSlot();
    void legendTable_doubleClicked(int, int);

private slots:
    void valueChanged();

private:
    void setupUi();
    void setupComboBoxes();
    void createView(int rowsNum);
    void retranslateUi();
    void connectSlots(bool);
    void setAndAdjustTableColumns();
    void countElementsBySlices();
    void createColorVector();
    void insertAttributesCombo();

    void GroupByEqualStep(double fix, Attributes *attrib);
    void GroupByQuantil(double fix, Attributes *attrib);
    void GroupByStdDeviation(double fix, Attributes *attrib);
    void GroupByUniqueValue(double fix, Attributes *attrib);

    void commitFile();
    void makeAttribsBkp();
    void rollbackChanges(const QString &);

    QString enumToQString(QString type, int e);
    QString typesOfDataToQString(int e);
    QString groupingToQString(int e);
    QString stdDevToQString(int e);



    QGridLayout *gridLayout, *gridLayout1;
    QGridLayout *gridLayout2, *gridLayout3;

    QHBoxLayout *hboxlayout_1, *hboxlayout_2;
    QHBoxLayout *hboxlayout_3;

    QVBoxLayout *vboxlayout_1;

    QGroupBox *groupingParamsGroupBox;
    QGroupBox *loadGroupBox, *colorGroupBox;

    QSpacerItem *spacer13, *spacer14_2;
    QSpacerItem *spacer16, *spacer14;
    QSpacerItem *spacer22, *spacer23;

    QLabel *attributeTextLabel;
    QLabel *groupingModeTextLabel;
    QLabel *precisionTextLabel;
    QLabel *slicesTextLabel;
    QLabel *stdDevTextLabel;
    QLabel *functionTextLabel;
    QLabel *chrononTextLabel;
    
    QComboBox *groupingModeComboBox;
    QComboBox *slicesComboBox;
    QComboBox *precisionComboBox;
    QComboBox *chrononComboBox;
    QComboBox *functionComboBox;
    QComboBox *stdDevComboBox;
    QComboBox *attributesComboBox;
    QComboBox *loadNamesComboBox;

    QPushButton *clearColorsPushButton;
    QPushButton *invertColorsPushButton;
    QPushButton *equalSpacePushButton;
    QPushButton *saveColorPushButton;
    QPushButton *helpPushButton;
    QPushButton *cancelPushButton;
    QPushButton *okPushButton;
    QPushButton *applyPushButton;

    TeQtColorBar *frameTeQtStdColorBar;
    TeQtColorBar *frameTeQtColorBar;
    //TeQtBigTable *legendTable;

    bool invertColor, attrValuesChanged;
    int rows;

    // QAbstractItemModel *model;
    QTableWidget *legendTable;
    QHash<QString, Attributes*> *mapAttributes;
    std::vector<TeColor> *teColorVec;

    //double minValue;
    //double maxValue;

    QString attributesActive;
};

}

#endif // LEGEND_WINDOW_OBSERVERMAP
