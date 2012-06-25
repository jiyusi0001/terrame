#ifndef DIALOG_H
#define DIALOG_H

#include <QDialog>
#include <QUdpSocket>


namespace TerraMEObserver {
class AgentObserverMap;
}

namespace Ui {
class receiverGUI;
}

class Receiver : public QDialog
{
    Q_OBJECT
    
public:
    explicit Receiver(QWidget *parent = 0);
    ~Receiver();
    
public slots:
    void closeButtonClicked();
    void blindButtonClicked();
    void processPendingDatagrams();

private:

    void processDatagram(const QString msg);
    void processDatagram(QByteArray msg);


    int msgReceiver,statesReceiver;
    QByteArray completeData;
    QString message;

    Ui::receiverGUI *ui;
    QUdpSocket *udpSocket;
    TerraMEObserver::AgentObserverMap *obsMap;

};

#endif // DIALOG_H
