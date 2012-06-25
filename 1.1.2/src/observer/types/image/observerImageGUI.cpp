#include "observerImageGUI.h"
#include "ui_observerImageGUI.h"

// using namespace TerraMEObserver;

ObserverImageGUI::ObserverImageGUI(QWidget *parent) :
    QDialog(parent),
    ui(new Ui::ObserverImageGUI)
{
    ui->setupUi(this);
}

ObserverImageGUI::~ObserverImageGUI()
{
    delete ui;
}

void ObserverImageGUI::setPath(const QString &path, const QString &prefix)
{
    ui->editPrefix->setText( prefix );
    ui->editPath->setText( path );
}

void ObserverImageGUI::setStatusMessage(const QString &msg)
{
    ui->lblStatus->setText(msg);
}
