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
 * \file observerInterf.h
 * \brief Design Pattern Subject and Observer handles.
 * \author Antonio José da Cunha Rodrigues 
 * \author Tiago Garcia de Senna Carneiro
*/

#ifndef OBSERVER_INTERF
#define OBSERVER_INTERF

#include "../core/bridge.h"
#include "observer.h"
#include "observerImpl.h"

#include <stdarg.h>
#include <string.h>
#include <list>
#include <iterator>
//#include <iostream>
#include <QtCore/QDataStream>
#include <QtCore/QDateTime>

class SubjectInterf;

// mantem o numero de observer já criados
//static long int numObserverCreated = 0;

/**
* \brief  
*  Handle for a Observer object.
*
*/
class ObserverInterf :public Observer, public Interface<ObserverImpl>
{
public:
    ObserverInterf();
    ObserverInterf(Subject *);
    virtual ~ObserverInterf();

    // Metodo puramente virtual, responsável por atualizar os estado do Subject
    virtual bool update(double );

    bool getVisible();

    void setVisible(bool );

    // Metodo puramente virtual, responsável por deserializar/serializar o objeto
    virtual bool draw(QDataStream& ) = 0;

    virtual const TypesOfObservers getType() = 0;

    virtual void setModelTime(double );

    int getId();

    virtual QStringList getAttributes() = 0;

    void setDirtyBit();
};



////////////////////////////////////////////////////////////  Subject


/*
** \classe Subject
** \author Antônio José da Cunha Rodrigues
** Baseado no padrão Observer do livro "Padrões de Projeto"
*/

/**
* \brief  
*  Handle for a Subject object.
*
*/
class SubjectInterf : public Subject, public Interface<SubjectImpl>
{
public:
    /**
    * Método responsável em 'anexar' o observer ao Subject
    * \param ponteiro para um objeto Observer
    * \see Observer
    */
    void attach(Observer *);

    /**
    * Método responsável em 'liberar' o observer do Subject
    * \param ponteiro para um objeto Observer
    * \see Observer
    */
    void detach(Observer *);

    /**
    * Recupera um ponteiro para um observador por meio de seu ID
    * ou um ponteiro nulo
    * \param identificador único de um observador
    * \return ponteiro para um observador
    */
    Observer * getObserverById(int );

    /**
    * Método responsável em 'notificar' todos os observer envolvidos
    * \param tempo da simulação
    */
    void notify(double );

    /**
    * Metodo puramente virtual, responsável por serializar/ deserializar o objeto
    * \param QDataStream, objeto serializável
    * \param ponteiro para o objeto Subject observado
    * \param identificador para o observador
    * \param lista de atributos observavéis
    * \see Subject, \see QDataStream, \see QStringList
    */
    virtual QDataStream& getState(QDataStream &, Subject *,
                                  int, QStringList &) = 0;
    
    /**
    * Recupera o tipo do Subject
    * \return enumerador que identifica o Subject
    * \see TypesOfSubjects
    */
    virtual const TypesOfSubjects getType() = 0;

    /**
    * Recupera o identificador do Subject
    * \return identificador único do Subject
    */
    int getId() const;
};


#endif
