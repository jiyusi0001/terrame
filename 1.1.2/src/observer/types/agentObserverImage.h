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
 * \file agentObserverImage.h
 * \brief Combined visualization for Agent, Automaton and Trajectory and saved in a png image
 * \author Antonio José da Cunha Rodrigues 
*/

#ifndef AGENT_OBSERVER_IMAGE
#define AGENT_OBSERVER_IMAGE

#include <QStringList>

#include "observerImage.h"


namespace TerraMEObserver {

class AgentObserverImage : public ObserverImage
{

public:
    /** 
    * Constructor 
    * \param parent, pointer to a QWidget
    */
    AgentObserverImage(QWidget *parent = 0);

    /**
    * Constructor
    * \param sub, pointer to a Subject
    */
    AgentObserverImage(Subject *sub);

    /// Destructor
    virtual ~AgentObserverImage();

    /**
    * Apresenta o estado interno de Subject observador
    * \param in, referência para um objeto QDataStream
    * \return 'true' se o estado pôde ser apresentado. Caso contrário, retorna 'false'
    */
    bool draw(QDataStream &in);

    /**
    * Acopla outro Subject para a observação 
    * \param subj ponteiro para o Subject do tipo 'Agent', 'Automaton' e 'Trajectory'
    * \param className nome da classe que um subject pertence
    */
    void registry(Subject *subj, const QString & className = QString(""));

    /**
    * Desacopla um Subject observado
    * \param subj ponteiro para o Subject ('Agent', 'Automaton' e 'Trajectory') observado
    * \param className nome da classe que um subject pertence
    * \return 'true' se o Subject foi desacoplado. Caso contrário, retorna 'false'
    */
    bool unregistry(Subject *subj, const QString & className = QString(""));

    /** 
    * Desacopla todos os Subjects registrados
    */ 
    void unregistryAll();

    /**
    * Define a lista de atributos de um subject acoplado
    * \param headers lista de atributos que serão observados
    * \param type tipo de um Subject
    * \param className nome da classe que um agente pertence
    */
    void setSubjectAttributes(const QStringList & attribs, TypesOfSubjects type,
                            const QString &className = QString(""));
    
    /// Recupera a lista de atributos em observação
    QStringList & getSubjectAttributes();


private:
    bool decode(QDataStream &state, TypesOfSubjects subject);
    bool draw();

    QVector<QPair<Subject *, QString> > linkedSubjects;
    QStringList subjectAttributes;

    bool cleanImage;
    QString className;

};

}

#endif  //AGENT_OBSERVER_IMAGE
