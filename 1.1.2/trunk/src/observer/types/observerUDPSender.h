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
 * \file observerPlayerGUI.h
 * \brief Sends the attributes observed via UDP Protocol
 * \author Antonio José da Cunha Rodrigues 
*/

#ifndef OBSERVER_UDP_SENDER
#define OBSERVER_UDP_SENDER

#include "../observerInterf.h"
#include "udpSender/observerUdpSenderGUI.h"

#include <QtGui/QDialog>
#include <QtCore/QThread>
#include <QtNetwork/QHostAddress>

class QUdpSocket;

namespace TerraMEObserver {

class ObserverUDPSender : public QThread, public ObserverInterf 
{
public:
    ObserverUDPSender();
    ObserverUDPSender (Subject *);
    virtual ~ObserverUDPSender();

    bool draw(QDataStream &);

    QStringList getAttributes();
    void setAttributes(QStringList& attrs);

    QStringList & getParameters();
    void setParameters(QStringList& params);

    void setCompressDatagram(bool compress);
    bool getCompressDatagram();

    const TypesOfObservers getType();
    
    void setPort(int port);
    int getPort();

    void addHost(const QString & host);

    void pause();		// ref. à Thread
    int close();

    void show();

protected:
    void run();		// ref. à Thread
    //void closeEvent(QCloseEvent *e);
    void setModelTime(double time);

private:
    void init();
    bool sendDatagram(QString & msg);
    bool completeState(const QByteArray &flag);

    TypesOfObservers observerType;
    TypesOfSubjects subjectType;
    //int sizeCellSpace;

    QList<QHostAddress> *hosts;
    int port, stateCount, msgCount;
    int datagramSize;
    float datagramRatio;

    QUdpSocket *udpSocket;

    QStringList attributes;
    QStringList parameters;

    ObserverUdpSenderGUI *udpGUI;

    bool failure2Send, compressDatagram;		
    bool paused;    // ref. à Thread
};

}

#endif
