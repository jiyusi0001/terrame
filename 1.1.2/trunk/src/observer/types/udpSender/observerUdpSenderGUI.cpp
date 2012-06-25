#include "observerUdpSenderGUI.h"
#include "ui_observerUdpSenderGUI.h"

#include <QDateTime>

ObserverUdpSenderGUI::ObserverUdpSenderGUI(QWidget *parent) :
    QDialog(parent),
    ui(new Ui::ObserverUdpSenderGUI)
{
    ui->setupUi(this);

    // ui->lblCompressIcon->setScaledContents(true);
    // ui->lblCompressIcon->setPixmap(QPixmap(":/icons/compress.png"));
    ui->lblCompress->setText("Compress: Off");
    ui->lblCompress->setToolTip("The send compressed is disabled.");
}

ObserverUdpSenderGUI::~ObserverUdpSenderGUI()
{
    delete ui;
}

void ObserverUdpSenderGUI::setPort(int port)
{
    ui->lblPortStatus->setText("Sending at Port: " + QString::number(port));
}

void ObserverUdpSenderGUI::setMessagesSent(int msg)
{
    ui->lblMessagesSent->setText("Messages sent: " + QString::number(msg));
}

void ObserverUdpSenderGUI::setStateSent(int state)
{
    ui->lblStatesSent->setText("States sent: " + QString::number(state));
}

void ObserverUdpSenderGUI::setSpeed(const QString &speed)
{
    ui->lblSpeedStatus->setText(speed);

//    float secs = stopWatch.elapsed() / 1000.0;
//    qDebug("\t%.2fMB/%.2fs: %.2fMB/s", float(nbytes / (1024.0*1024.0)),
//    secs, float(nbytes / (1024.0*1024.0)) / secs);
}

void ObserverUdpSenderGUI::appendMessage(const QString &message)
{
    ui->logEdit->appendPlainText(
        QDateTime::currentDateTime().toString("MM/dd/yyyy, hh:mm:ss: ") + message);
}

void ObserverUdpSenderGUI::setCompressDatagram(bool compress)
{
    if (compress)
    {
        ui->lblCompress->setText("Compress: On");
        ui->lblCompress->setToolTip("The send compressed is enabled.");
    }
    else
    {
        ui->lblCompress->setText("Compress: Off");
        ui->lblCompress->setToolTip("The send compressed is disabled.");
    }
}

