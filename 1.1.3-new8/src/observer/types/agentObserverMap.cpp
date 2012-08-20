#include "agentObserverMap.h"

#include "../globalAgentSubjectInterf.h"
#include "../protocol/decoder/decoder.h"

#include <QBuffer>
#include <QStringList>
#include <QTreeWidget>
#include <QDebug>

#ifdef TME_BLACK_BOARD
    #include "blackBoard.h"
#endif

#define TME_STATISTIC_UNDEF

#ifdef TME_STATISTIC
    // Estatisticas de desempenho
    #include "../observer/statistic/statistic.h"
#endif

extern bool QUIET_MODE;

using namespace TerraMEObserver;

AgentObserverMap::AgentObserverMap(QWidget *parent) : ObserverMap(parent)
{
    subjectAttributes.clear();
    cleanImage = false;
}

AgentObserverMap::AgentObserverMap(Subject * subj) : ObserverMap(subj)
{
    subjectAttributes.clear();
    cleanImage = false;
}

AgentObserverMap::~AgentObserverMap()
{
    unregistryAll();
}

bool AgentObserverMap::draw(QDataStream & state)
{
#ifdef TME_STATISTIC
    //// tempo gasto do 'getState' ate aqui
    //double decodeSum = 0.0, t = Statistic::getInstance().endVolatileTime();
    //Statistic::getInstance().addElapsedTime("comunica��o map", t);

    int decodeCount = 0;

    // numero de bytes transmitidos
    Statistic::getInstance().addOccurrence("bytes map", in.device()->size());
#endif

    // bool drw = ObserverMap::draw(in);
    bool drw = true, decoded = false;
    cleanImage = true;
    className = "";

    for(int i = 0; i < linkedSubjects.size(); i++)
    {
        Subject *subj = linkedSubjects.at(i).first;
        // className = linkedSubjects.at(i).second;

        QByteArray byteArray;
        QBuffer buffer(&byteArray);
        QDataStream out(&buffer);

        buffer.open(QIODevice::WriteOnly);

        //QStringList attribListAux;
        //// attribListAux.push_back("@getLuaAgentState");
        //attribListAux << subjectAttributes;        

		//@RAIAN: Solucao provisoria
#ifndef TME_BLACK_BOARD
		if(subj->getType() == TObsCell)
			subjectAttributes.push_back("@getNeighborhoodState");
#endif
		//@RAIAN: FIM
		
//#ifdef TME_BLACK_BOARD
//        QDataStream& state = BlackBoard::getInstance().getState(subj, getId(), subjectAttributes);
//        BlackBoard::getInstance().setDirtyBit(subj->getId() );
//#else
        QDataStream& state = subj->getState(out, subj, getId(), subjectAttributes);
//#endif

        buffer.close();
        buffer.open(QIODevice::ReadOnly);

        //-----
		// @RAIAN: Acrescentei a celula na comparacao, para o observer do tipo Neighborhood
        if ((subj->getType() == TObsAgent) || (subj->getType() == TObsAutomaton) || (subj->getType() == TObsCell))
        {
            if (className != linkedSubjects.at(i).second)
                cleanImage = true;
            
            // if (className != attribListAux.first())
            //    cleanImage = true;

            // className = attribListAux.first();
            className = linkedSubjects.at(i).second;
        }
        //-----

#ifdef TME_STATISTIC 
        t = Statistic::getInstance().startTime();
#endif
        ///////////////////////////////////////////// DRAW AGENT
        decoded = decode(state, subj->getType());

#ifdef TME_STATISTIC 
        decodeSum += Statistic::getInstance().endTime() - t;
        decodeCount++;
#endif

        cleanImage = false;
        /////////////////////////////////////////////

        buffer.close();
    }
    //bool drw = true;


#ifdef TME_STATISTIC

    if (decoded)
    {
        t = Statistic::getInstance().startMicroTime();

        drw = draw();

        t = Statistic::getInstance().endMicroTime() - t;
        Statistic::getInstance().addElapsedTime("Map-Complex Rendering", t);
    }
    drw = drw && ObserverMap::draw(in);

    if (decodeCount > 0)
        Statistic::getInstance().addElapsedTime("Map-Complex Decoder", decodeSum / decodeCount);
    
    return drw;

#else

    if (decoded)
        drw = draw();

    return drw && ObserverMap::draw(state);

#endif
}

void AgentObserverMap::setSubjectAttributes(const QStringList & attribs, TypesOfSubjects type,
                                          const QString & className)
{
    QHash<QString, Attributes*> * mapAttributes = getMapAttributes();

    for (int i = 0; i < attribs.size(); i++)
    {
        if (! subjectAttributes.contains(attribs.at(i)) )
            subjectAttributes.push_back(attribs.at(i));
        // }
 
        //// Define os tipos de subject que est�o sendo observados
        //// por esse objeto
        //for (int i = 0; i < attribs.size(); i++)
        //{
        if (! mapAttributes->contains(attribs.at(i)))
        {
            if (! QUIET_MODE )
                qWarning("Warning: The attribute called \"%s\" "
                         "not found.", qPrintable(attribs.at(i)));
        }
        else
        {
            Attributes *attrib = mapAttributes->value(attribs.at(i));
            attrib->setType(type);
            attrib->setClassName(className);
        }
    }

    if (type == TObsAgent)
        getPainterWidget()->setExistAgent(true);
}

QStringList & AgentObserverMap::getSubjectAttributes()
{
    return subjectAttributes;
}

void AgentObserverMap::registry(Subject *subj, const QString & className)
{
    if (! constainsItem(linkedSubjects, subj) )
    {

//#ifdef TME_BLACK_BOARD
//        BlackBoard::getInstance().setDirtyBit(subj->getId() );
//#endif

        linkedSubjects.push_back(qMakePair(subj, className));

        // sorts the subject linked vector by the class name
        qStableSort(linkedSubjects.begin(), linkedSubjects.end(), sortByClassName);
    }
}

bool AgentObserverMap::unregistry(Subject *subj, const QString & className)
{
    if (! constainsItem(linkedSubjects, subj))
        return false;

#ifdef DEGUB_OBSERVER
    // qDebug() << "subjectAttributes " << subjectAttributes;
    // qDebug() << "linkedSubjects " << linkedSubjects;

    foreach(SubjectInterf *s, subjects)
        qDebug() << s->getSubjectType() << ", " << getSubjectName(s->getSubjectType());
#endif

    int idxItem = -1;
    for (int i = 0; i < linkedSubjects.size(); i++)
    {
        if (linkedSubjects.at(i).first == subj)
        {
            idxItem = i;
            break;
        }
    }
    linkedSubjects.remove(idxItem);

    // QTreeWidget * treeLayers = getTreeLayers();

    for (int i = 0; i < subjectAttributes.size(); i++)
    {
        if (getMapAttributes()->contains(subjectAttributes.at(i)))
        {
            Attributes *attrib = getMapAttributes()->value(subjectAttributes.at(i));
            
            if (className == attrib->getClassName())
            {
                attrib->clear();
                break;
            }
            /*
            // Remove apenas o atributo que n�o possui valores
            if (subj->getSubjectType() == attrib->getType())
            {
                qDebug() << "\nclassName " << className;
                qDebug() << "attrib->getExhibitionName() " << attrib->getExhibitionName();

                if ( (attrib->getType() != TObsAgent) 
                    || ((className == attrib->getExhibitionName()) && 
                         (! ObserverMap::existAgents(linkedSubjects)) ) )
                {
                    //for (int j = 0; j < treeLayers->topLevelItemCount(); j++)
                    //{
                    //    // Remove o atributo da �rvore de layers
                    //    if ( treeLayers->topLevelItem(j)->text(0) == attrib->getName())
                    //    {
                    //        QTreeWidgetItem *treeItem = treeLayers->takeTopLevelItem(j);
                    //        delete treeItem;
                    //        break;
                    //    }
                    //}

                    // Remove o atributo do mapa de atributos
                    getMapAttributes()->take(attrib->getName());
                    getPainterWidget()->setExistAgent(false);
                    subjectAttributes.removeAt( subjectAttributes.indexOf(attrib->getName()) );
                    delete attrib;
                    return true;
                }
            }*/
        }
    }

    if (linkedSubjects.isEmpty())
        getPainterWidget()->setExistAgent(false);

    return true;
}

void AgentObserverMap::unregistryAll()
{
    linkedSubjects.clear();
}

bool AgentObserverMap::decode(QDataStream &in, TypesOfSubjects subject)
{
    bool ret = false;
    QString msg;
    in >> msg;

    // qDebug() << msg.split(PROTOCOL_SEPARATOR, QString::SkipEmptyParts);

    Attributes * attrib = 0;
    
    if (subject == TObsTrajectory)
    {
        attrib = getMapAttributes()->value("trajectory");
    }
    else
    {
		//@RAIAN: Neighborhood
		if(subject == TObsCell)
		{
			attrib = getMapAttributes()->value(className);
		}
		//@RAIAN: FIM
		else
		{
			// ((subjectType == TObsAgent) || (subjectType == TObsAutomaton))
			attrib = getMapAttributes()->value("currentState" + className);
		}
    }

    if (attrib)
    {
        if (cleanImage)
            attrib->clear();

        ret = getProtocolDecoder().decode(msg, *attrib->getXsValue(), *attrib->getYsValue());
        // getPainterWidget()->plotMap(attrib);
    }
    qApp->processEvents();

    return ret;
}

bool AgentObserverMap::draw()
{
    QList<Attributes *> attribList = getMapAttributes()->values();
    Attributes *attrib = 0;

    qStableSort(attribList.begin(), attribList.end(), sortAttribByType);

    for(int i = 0; i < attribList.size(); i++)
    {
        attrib = attribList.at(i);
        if ( (attrib->getType() != TObsCell)
              && (attrib->getType() != TObsAgent) )
            getPainterWidget()->plotMap(attrib);
    }

    //static int ss = 1;
    //for(int i = 0; i < attribList.size(); i++)
    //{
    //    //attrib = attribList.at(i);
    //    //if ( (attrib->getType() != TObsCell)
    //    //       && (attrib->getType() != TObsAgent) )
    //    //       attrib->getImage()->save("imgs/" + attrib->getName() + QString::number(ss) + ".png");

    //    qDebug() << attrib->getName() << ": " << getSubjectName(attrib->getType());
    //}

    //ss++;
    return true;
}



