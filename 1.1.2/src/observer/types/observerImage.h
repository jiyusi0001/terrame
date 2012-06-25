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
 * \file observerImage.h
 * \brief Spatial visualization for cells and saved in a png image
 * \author Antonio José da Cunha Rodrigues 
*/

#ifndef OBSERVER_IMAGE_H
#define OBSERVER_IMAGE_H

#include "../observerInterf.h"
#include "../components/legend/legendWindow.h"
#include "../components/painter/painterWidget.h"

#include <QDataStream>
#include <QVector>
#include <QHash>

class ObserverImageGUI;

namespace TerraMEObserver {

class Decoder;

class ObserverImage :  public ObserverInterf
{
    // Q_OBJECT

public:
    /**
    * Constructor
    * \param subj a pointer to a Subject
    */
    ObserverImage(Subject *subj);

    /// Destructor
    virtual ~ObserverImage();

    bool draw(QDataStream &in);
    QStringList getAttributes();
    const TypesOfObservers getType();

    void setHeaders(QStringList attrib, QStringList legKeys, QStringList legAttrib);
    void setCellSpaceSize(int width, int height);
	void setPath(const QString & path = QString("./"), 
        const QString & prefix = DEFAULT_NAME);

    const QSize getCellSpaceSize();
    int close();
    void show();

protected:
	PainterWidget * getPainterWidget() const;
	QHash<QString, Attributes*> * getMapAttributes() const ;
	Decoder & getProtocolDecoder() const;
    bool save();

    // Desativa a chamada do método save() no objeto ObserverImage para
    // evitar inconsistências
    void setDisableSaveImage();
    bool getDisableSaveImage() const;

private:
	
    TypesOfObservers observerType;
    TypesOfSubjects subjectType;
	
	int width, height;
    int builtLegend;
	double 	newWidthCellSpace, newHeightCellSpace;
	bool needResizeImage, savingImages;
    // desativa o salvamento da imagem, o método seja invocado por meio de outro objeto
    bool disableSaveImage; 

	QString path;
    QSize resultSize;
    QImage resultImage;
    QStringList itemList, obsAttrib;  // lista de todas as chaves, lista de chaves em observação

	ObserverImageGUI *obsImgGUI;  // interface gráfica
	LegendWindow *legendWindow;
    PainterWidget *painterWidget;
    QHash<QString, Attributes*> *mapAttributes;		// map de todas as chaves
	Decoder *protocolDecoder;
};
	

}

#endif