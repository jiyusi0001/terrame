#include "observerTable.h"

#include <QtGui/QApplication>
#include <QtGui/QVBoxLayout>
#include <QtGui/QTreeWidgetItem>
#include <QDebug>

#include <math.h>

#define TME_STATISTIC_UNDEF

#ifdef TME_STATISTIC
    // Estatisticas de desempenho
    #include "../observer/statistic/statistic.h"
#endif


ObserverTable::ObserverTable(Subject *s, QWidget *parent) 
    : QDialog(parent), ObserverInterf( s ), QThread()
{
    observerType = TObsTable;
    subjectType = TObsUnknown;
    paused = false;

    resize(200, 480);
    setWindowTitle("TerraME Observer : Table");
    //setMaximumSize(QSize(200, 480));

    tableWidget = new QTreeWidget(this);
    tableWidget->setGeometry(8, 8, 184, 464);
    tableWidget->setAlternatingRowColors(true);
    tableWidget->setRootIsDecorated(false);

    QVBoxLayout *vertLayout = new QVBoxLayout();
    vertLayout->addWidget(tableWidget);

    setLayout(vertLayout);

    showNormal(); // tranferido para o metodo run()

    // prioridade da thread
    //setPriority(QThread::IdlePriority); //  HighPriority    LowestPriority
    start(QThread::IdlePriority);
}

ObserverTable::~ObserverTable()
{
    wait();
    delete tableWidget;
    tableWidget = 0;
}

const TypesOfObservers ObserverTable::getType()
{
    return observerType;
}

//void ObserverTable::closeEvent(QCloseEvent *e)
//{
//	pause();
//	wait();
//	e->accept();
//}

void ObserverTable::setColumnHeaders(QStringList cols)
{
    for (int i = 0; i < cols.size(); i++)
    {
        QString c = cols.at(i);
        if (c.isNull() || c.isEmpty())
            cols[i] = "empty col " + QString::number(i);
    }
    tableWidget->setHeaderLabels(cols);
}

void ObserverTable::setLinesHeader(QStringList lines)
{
    itemList = lines;

    QTreeWidgetItem *item;
    for(int i = 0; i < lines.size(); i++)
    {
        item = new QTreeWidgetItem(tableWidget);
        item->setText(0, lines.at(i));
    }
    // redimensiona o tamanho da coluna
    tableWidget->resizeColumnToContents(0);
}

bool ObserverTable::draw(QDataStream &in)
{
#ifdef TME_STATISTIC
    // tempo gasto do 'pop()' ate aqui
    float t = Statistic::getInstance().endVolatileTime();
    Statistic::getInstance().addElapsedTime("comunicacao table", t);

    // numero de bytes transmitidos
    Statistic::getInstance().addOccurrence("bytes table", in.device()->size());
#endif

    QString msg;
    in >> msg;

#ifdef TME_STATISTIC 
        t = Statistic::getInstance().startMicroTime();
#endif

    QStringList tokens = msg.split(PROTOCOL_SEPARATOR); //, QString::SkipEmptyParts);
    QTreeWidgetItem *item = 0;

    //QString subjectId = tokens.at(0);
    //int subType = tokens.at(1).toInt();
    int qtdParametros = tokens.at(2).toInt();
    // int nroElems = tokens.at(3).toInt();
    int j = 4;

    for (int i=0; i < qtdParametros; i++)
    {
        QString key = tokens.at(j);
        j++;
        int typeOfData = tokens.at(j).toInt();
        j++;

        bool contains = itemList.contains(key);

        if(contains)
            item = tableWidget->topLevelItem(itemList.indexOf(key));

        switch (typeOfData)
        {
            case (TObsBool):
                if (contains)
                    item->setText(1, (tokens.at(j).toInt() ? "true" : "false"));
                break;

            case (TObsDateTime):
                //break;

            case (TObsNumber):
                if (contains)
                    item->setText(1, tokens.at(j));
                break;

            default:
                if (contains)
                    item->setText(1, tokens.at(j));
                break;
        }
        j++;
    }

#ifdef TME_STATISTIC
        t = Statistic::getInstance().endMicroTime() - t;
        Statistic::getInstance().addElapsedTime("rendering table", t);
#endif

    // redimensiona o tamanho da coluna
    tableWidget->resizeColumnToContents(1);
    qApp->processEvents();
    return true;
}

void ObserverTable::run()
{
    QThread::exec();
}

void ObserverTable::pause()
{
    paused = !paused;
}

QStringList ObserverTable::getAttributes()
{
    return itemList;
}

int ObserverTable::close()
{
    QDialog::close();
    QThread::exit(0);
    return 0;
}
