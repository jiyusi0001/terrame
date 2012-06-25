#include "privatePlayerGUI.h"
#include "ui_privatePlayerGUI.h"

#include <QApplication>
// #include "../../components/console/modelConsole.h"


extern bool paused;
extern bool step;

PrivatePlayerGUI::PrivatePlayerGUI(QWidget *parent) 
    : QDialog(parent), ui(new Ui::PrivatePlayerGUI)
{
    ui->setupUi(this);
    // ui->mainVLayout->addWidget( &ModelConsole::getInstance() );
    resize(400, 300);

    ui->textMessage->append("TerraME started!");

    // The simulation will be launched in pause mode, so
    // the GUI must be similar
    playPauseClicked();
    
    connect(ui->btPlayPause, SIGNAL(clicked()), this, SLOT(playPauseClicked()));
    connect(ui->btStep, SIGNAL(clicked()), this, SLOT(stepClicked()));
    connect(ui->btStop, SIGNAL(clicked()), this, SLOT(stopClicked()));
}

PrivatePlayerGUI::~PrivatePlayerGUI()
{
    // Desattach the ModelConsole instance from the scrollArea
    // ui->scrollArea->setWidget(0);
    delete ui;
}

void PrivatePlayerGUI::appendMessage(const QString & msg)
{
    // ModelConsole::getInstance().appendMessage(msg);
    ui->textMessage->append(msg);
}

void PrivatePlayerGUI::playPauseClicked()
{
    QIcon icon;

    if (! paused)
    {
        // ModelConsole::getInstance().appendMessage("Simulation paused!\n");
        ui->textMessage->append("Simulation paused!\n");

        ui->btPlayPause->setText("Play");
        icon.addFile(QString::fromUtf8(":/icons/play.png"), QSize(), QIcon::Normal, QIcon::Off);
        ui->btPlayPause->setIcon(icon);
        paused = true;
    }
    else
    {
        // ModelConsole::getInstance().appendMessage("Simulation running...\n");
        ui->textMessage->append("Simulation running...\n");

        ui->btPlayPause->setText("Pause");
        icon.addFile(QString::fromUtf8(":/icons/pause.png"), QSize(), QIcon::Normal, QIcon::Off);
        ui->btPlayPause->setIcon(icon);
        paused = false;
        step = false;
    }
}

void PrivatePlayerGUI::stepClicked()
{
    if (! step)
    {
        // ModelConsole::getInstance().appendMessage("Step by step running...\n");
        ui->textMessage->append("Step by step running...\n");
        
        QIcon icon;
        ui->btPlayPause->setText("Play");
        icon.addFile(QString::fromUtf8(":/icons/play.png"), QSize(), QIcon::Normal, QIcon::Off);
        ui->btPlayPause->setIcon(icon);
    }
    
    step = true;
    paused = false;
}

void PrivatePlayerGUI::stopClicked()
{
    exit(0);
}

void PrivatePlayerGUI::setActiveButtons(bool active)
{
    ui->btPlayPause->setEnabled(active);
    ui->btStep->setEnabled(active);
    // ui->btStop->setEnabled(active);
}