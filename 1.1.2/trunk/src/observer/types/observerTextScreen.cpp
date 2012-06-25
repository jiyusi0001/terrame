#include "observerTextScreen.h"

#include <QtGui/QApplication>
#include <QtCore/QByteArray>

ObserverTextScreen::ObserverTextScreen(Subject *sub, QWidget *parent) 
    : QTextEdit(parent), ObserverInterf(sub), QThread()
{
    observerType = TObsTextScreen;
    subjectType = TObsUnknown;

    paused = false;
    header = false;

    setReadOnly(true);
    //setAutoFormatting(QTextEdit::AutoAll);
    setWindowTitle("TerraME Observer : Text Screen");

    show();
    resize(600, 480);

    // prioridade da thread
    //setPriority(QThread::IdlePriority); //  HighPriority    LowestPriority
    start(QThread::IdlePriority);
}

ObserverTextScreen::~ObserverTextScreen()
{
    wait();
}

const TypesOfObservers ObserverTextScreen::getType()
{
    return observerType;
}

bool ObserverTextScreen::draw(QDataStream &in)
{
    QString msg;
    in >> msg;
    QStringList tokens = msg.split(PROTOCOL_SEPARATOR);

    //double num;
    //QString text;
    //bool b;

    //QString subjectId = tokens.at(0);
    //int subType = tokens.at(1).toInt();
    int qtdParametros = tokens.at(2).toInt();
    //int nroElems = tokens.at(3).toInt();
    int j = 4;

    for (int i=0; i < qtdParametros; i++)
    {
        QString key = tokens.at(j);
        j++;
        int typeOfData = tokens.at(j).toInt();
        j++;

        bool contains = itemList.contains(key);

        switch (typeOfData)
        {
            case (TObsBool)		:
                if (contains)
                    valuesList.replace(itemList.indexOf(key),
                                       (tokens.at(j).toInt() ? "true" : "false"));
                break;

            case (TObsDateTime)	:
                //break;

            case (TObsNumber)		:
                if (contains)
                    valuesList.replace(itemList.indexOf(key), tokens.at(j));
                break;

            default							:
                if (contains)
                    valuesList.replace(itemList.indexOf(key), tokens.at(j));
                break;
        }
        j++;
    }

    qApp->processEvents();
    return write();
}

void ObserverTextScreen::setHeaders(QStringList h)
{
    itemList = h;
    for (int i = 0; i < itemList.size(); i++)
        valuesList.insert(i, QString("")); // lista dos itens na ordem em que aparecem
    header = false;
}

bool ObserverTextScreen::headerDefined()
{
    return header;
}

bool ObserverTextScreen::write()
{
    // insere o cabeçalho do arquivo
    if (! header)
    {
        QString headers;
        for (int i = 0; i < itemList.size(); ++i)
        {
            headers += itemList.at(i);

            if (i < itemList.size() - 1)
                headers += "\t";
        }

        this->setText(headers);
        header = true;
    }

    QString text;
    for (int i = 0; i < valuesList.size(); i++)
    {
        text += valuesList.at(i) + "\t";

        if (i < valuesList.size() - 1)
            text += "\t";
    }

    this->append(text);
    return true;
}

void ObserverTextScreen::run()
{
    //while (!paused)
    //{
    //    QThread::exec();
    //    //show();
    //    //printf("run() ");
    //}
    QThread::exec();
}

void ObserverTextScreen::pause()
{
    paused = !paused;
}

QStringList ObserverTextScreen::getAttributes()
{
    return itemList;
}

int ObserverTextScreen::close()
{
    QThread::exit(0);
    return 0;
}
