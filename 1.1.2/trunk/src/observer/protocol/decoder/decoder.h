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
 * \file decoder.h
 * \brief Decoder class for comunication protocol
 * \author Antonio José da Cunha Rodrigues 
*/

#ifndef DECODER_H
#define DECODER_H

#include <QVector>
#include <QHash>
#include <QDebug>

#include "../../components/legend/legendAttributes.h"
#include "../../observer.h"

namespace TerraMEObserver {

class Decoder
{

public:
    Decoder( QHash<QString, Attributes *> *);
    virtual ~Decoder();

    bool decode(const QString &protocol, QVector<double> &xs, QVector<double> &ys);

private:
    Decoder(const Decoder &);
    Decoder& operator=(Decoder &);

    // Método recursivo
    bool interpret(QStringList &tokens, int &idx, QVector<double> &xs, QVector<double> &ys);

    // transição 1-2: idenficação do objeto
    inline bool consumeID(QString &id, QStringList &tokens, int &idx );

    // transição 2-3: definicao do tipo de subject
    inline bool consumeSubjectType(TypesOfSubjects &type, QStringList &tokens, int &idx);

    // transição 3-4: número de atributos
    inline bool consumeAttribNumber(int &attrNum, QStringList &tokens, int &idx);

    // transição 4-5: número de elementos
    inline bool consumeElementNumber(int &elemNum, QStringList &tokens, int &idx);

    // transição 5-[6-7-8]*: chave, tipo, valor
    inline bool consumeTriple(QStringList &tokens, int &idx, QVector<double> &xs, QVector<double> &ys);


    QHash<QString, Attributes *> *mapAttributes;
    TypesOfSubjects parentSubjectType;
};

}

#endif // DECODER_H
