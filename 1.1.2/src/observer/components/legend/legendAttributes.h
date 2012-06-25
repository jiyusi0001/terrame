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
 * \file legendAttributes.h
 * \brief Attributes for observation in the spacial observers
 * \author Antonio José da Cunha Rodrigues 
*/

#ifndef ATTRIBUTES
#define ATTRIBUTES

#include <QtCore/QString>
#include <QtCore/QVector>
#include <QImage>
#include <QFont>
#include <QPair>

#include "../../observer.h"
#include "legendColorBar.h"

namespace TerraMEObserver {

class ObsLegend
{
public:
    ObsLegend();
    ObsLegend(const ObsLegend &);
    virtual ~ObsLegend();
    ObsLegend & operator=(const ObsLegend &);

    void setColor(const QColor & c);
    void setColor(int r, int g, int b, int a = 255);
    QColor getColor() const;

    void setFrom(const QString & f);
    const QString & getFrom() const;
    double getFromNumber() const;

    void setTo(const QString &  t);
    const QString & getTo() const;
    double getToNumber() const;

    void setLabel(const QString &  l);
    const QString & getLabel() const;

    void setOcurrence(int o);
    int getOcurrence() const;

    void setIdxColor(unsigned int i);
    unsigned int getIdxColor() const;

private:

    QColor color;
    QString from;
    QString to;
    QString label;
    int ocurrence;
    unsigned int idxColor; // indice da cor no vetor de cores

    double fromNumber;
    double toNumber;
};


class Attributes
{
public:

    Attributes(QString name, int containersSize, double width, double height);

    virtual ~Attributes();

    // Define o nome do atributo
    void setName(QString name);

    // Recupera o nome do atributo
    QString getName() ;

    // Define valores númericos do atributo
    void setValues( QVector<double>* v);

    // Recupera valores númericos do atributo
    QVector<double>* getNumericValues();

    // Define valores textuais do atributo
    void setValues( QVector<QString>* s);

    // Recupera valores númericos do atributo
    QVector<QString>* getTextValues();

    // Define valores booleanos do atributo
    void setValues( QVector<bool>* b);

    // Recupera valores númericos do atributo
    QVector<bool>* getBoolValues();

    // Adiciona um valor númerico do atributo
    void addValue(double num);

    // Adiciona um valor booleano do atributo
    void addValue(bool b);

    // Adiciona um valor textual do atributo
    void addValue(QString txt);

    // Define a legenda do atributo
    void setLegend( QVector<ObsLegend>* l);

    // Recupera a legenda do atributo
    QVector<ObsLegend>* getLegend();

    // Adiciona um valor de legenda
    void addLegend(ObsLegend leg);

    // Define o valor máximo do atributo
    void setMaxValue(double m);

    // Recupera o valor máximo
    double getMaxValue();

    // Define o valor mínimo do atributo
    void setMinValue(double m);

    // Recupera o valor mínimo
    double getMinValue();

    // Converte o valor em sua cor correspondente
    double getVal2Color();

    void setColorBar(vector<ColorBar> colorVec);
    vector<ColorBar> getColorBar();

    void setStdColorBar(vector<ColorBar> colorVec);
    vector<ColorBar> getStdColorBar();

    void setSlices(int i);
    int getSlices();

    void setPrecisionNumber(int i);
    int getPrecisionNumber();

    void setType(TypesOfSubjects t);
    TypesOfSubjects getType();

    void setDataType(TypesOfData t);
    TypesOfData getDataType();

    void setGroupMode(GroupingMode i);
    GroupingMode getGroupMode();

    void setStdDeviation(StdDev i);
    StdDev getStdDeviation();

    void setValueList(const QStringList & values);
    int addValueListItem(QString value);
    QStringList & getValueList();

    void setLabelList(const QStringList & labels);
    int addLabelListItem(QString value);
    QStringList & getLabelList();

    QString toString();

    void restore();
    void makeBkp();

    void setImageSize(int, int);
    QImage * getImage();

    void setVisible(bool);
    bool getVisible();

    void setXsValue(QVector<double>* );
    void setYsValue(QVector<double>* );

    QVector<double>* getXsValue();
    QVector<double>* getYsValue();

    // Define o tamanho dos vetores
    // que esse atributo pode receber
    // baseado na número de coornadas
    void setContainersSize(int );

    // limpa todas as estruturas de dados
    void clear();

    // define todos os atributos da fonte que será utilizada
    // para desenhar esse atributo (válido apenas
    //  para o Agent) Familia, tamanho
    void setFontSize(int size);
    void setFontFamily(const QString &family);
    void setFont(const QFont &);
    const QFont & getFont();

    void setSymbol(const QString &);
    const QString & getSymbol();

    void setClassName(const QString &exhibitionName);
    const QString & getClassName();

    void appendLastPos(double x, double y);
    qreal getDirection(int pos, double x1, double y1);
    // void resetLastPos();

private:
    Attributes(const Attributes &);
    Attributes & operator=(const Attributes &);

    QVector<double> *xs, *ys;
    QVector<double> *numericValues; //modificar para template
    QVector<QString> *textValues; //modificar para template
    QVector<bool> *boolValues; //modificar para template
    QVector<ObsLegend> *legend;
    vector<ColorBar> colorBarVec;
    vector<ColorBar> stdColorBarVec;
    QStringList labelList, valueList;

    QString attribName;
    double maxValue;
    double minValue;
    double val2Color;	//conversão do valor observado em cor
    int containersSize;  // tamanho dos vetores

    // indice nos comboBoxes
    int slicesNumber;
    int precNumber;

    // Enumerators
    TypesOfSubjects attribType;
    TypesOfData attribDataType;
    GroupingMode groupMode;
    StdDev stdDev;

    QImage image;
    bool visible;

    QFont font;
    QString symbol, className;

    //---- Bkps ---------------------------------
    int slicesNumberBkp;
    int precNumberBkp;

    TypesOfData attribDataTypeBkp;
    GroupingMode groupModeBkp;
    StdDev stdDevBkp;
    vector<ColorBar> colorBarVecBkp;
    vector<ColorBar> stdColorBarVecBkp;


    QList<QPair<QPointF, qreal> > lastPos;
};


}

#endif
