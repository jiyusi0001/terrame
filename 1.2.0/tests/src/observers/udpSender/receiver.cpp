//@RODRIGO
// TME_BUILD is defined in TerraME.pro
// this skips the main code above in TerraME compilation
// does nothing in udpreceiver compilation

#ifndef TME_BUILD

#include <QtGui>
#include <QtNetwork>
#include <QFile>
#include <QCoreApplication>
#include <QTextStream>
#include <QStringList>
#include "receiver.h"

const QString PROTOCOL_SEPARATOR = "‡";

Receiver::Receiver(QWidget *parent)
    : QDialog(parent)
{
    int host;
    host =  QInputDialog::getInt(0,"Port","Insert port");
    statusLabel = new QLabel(tr("Listening for broadcasted messages"));
    quitButton = new QPushButton(tr("&Quit"));

    udpSocket = new QUdpSocket(this);
    udpSocket->bind(host, QUdpSocket::ShareAddress);

    connect(udpSocket, SIGNAL(readyRead()),
            this, SLOT(processPendingDatagrams()));
    connect(quitButton, SIGNAL(clicked()), this, SLOT(close()));

    QHBoxLayout *buttonLayout = new QHBoxLayout;
    buttonLayout->addStretch(1);
    buttonLayout->addWidget(quitButton);
    buttonLayout->addStretch(1);

    QVBoxLayout *mainLayout = new QVBoxLayout;
    mainLayout->addWidget(statusLabel);
    mainLayout->addLayout(buttonLayout);
    setLayout(mainLayout);

    setWindowTitle(tr("Broadcast Receiver"));
}

void Receiver::processPendingDatagrams()
{
    QString msg;
    //QFile file ("/home/terralab/Desktop/out.txt");

    while (udpSocket->hasPendingDatagrams()) {
        QByteArray datagram;
        datagram.resize(udpSocket->pendingDatagramSize());
        udpSocket->readDatagram(datagram.data(), datagram.size());
        msg.append(datagram); // .data());
        //statusLabel->setText(tr("Received datagram: \"%1\"")
        //                     .arg());
    }

    //QStringList list = s.split("");
    //if ( file.open(QIODevice::WriteOnly | QIODevice::Text))
    //{
    //file.write(s.toAscii().constData());
    //file.close();
    //}

    static int asas = 0; asas++;
    QFile file("out_" + QString::number(asas) + ".txt");
    if (file.open(QIODevice::WriteOnly | QIODevice::Text))
    {
        QTextStream out(&file);
        foreach(QString x, msg.split(PROTOCOL_SEPARATOR, QString::SkipEmptyParts))
            out << x << "\n";
    }

}

#endif
