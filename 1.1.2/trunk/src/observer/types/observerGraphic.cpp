#include "observerGraphic.h"

#include <QColorDialog>
#include <QApplication>

#include <qwt_legend_item.h>
#include <qwt_plot_item.h>

extern bool QUIET_MODE;

#define TME_STATISTIC_UNDEF

#ifdef TME_STATISTIC
    // Estatisticas de desempenho
    #include "../statistic/statistic.h"
#endif

using namespace TerraMEObserver;

ObserverGraphic::ObserverGraphic(Subject *sub, QWidget *parent) 
    : ObserverInterf(sub), QThread()
{
    observerType = TObsGraphic;
    subjectType = TObsUnknown;

    modelTime = -1.;
    lastModelTime = -2.;

    paused = false;
    picker = 0;
    legend = 0;
    x = -1;
    y = 0;

    xValue = QVector<double>();
    yValue = QVector<double>();

    plotter = new QwtPlot();
    plotter->setAutoReplot(true);
    plotter->setMargin(5);
    plotter->resize(300, 180);
    plotter->setWindowTitle("TerraME Observer : Chart");

    // instancia a curva, desenho do gráfico
    curve = new QwtPlotCurve();
    curve->setPaintAttribute(QwtPlotCurve::PaintFiltered, true);
    curve->setRenderHint(QwtPlotItem::RenderAntialiased);
    curve->attach(plotter);

    plotter->showNormal();

    // prioridade da thread
    //setPriority(QThread::IdlePriority); //  HighPriority    LowestPriority
    start(QThread::IdlePriority);
}

ObserverGraphic::~ObserverGraphic()
{
    wait();

    delete curve; curve = 0;
    delete plotter; plotter = 0;

    //if (legend)
    //    delete legend;
    //legend = 0;

    //if (picker)
    //    delete picker;
    //picker = 0;
}


void ObserverGraphic::setObserverType(TypesOfObservers type)
{
    observerType = type;
}

const TypesOfObservers ObserverGraphic::getType()
{
    return observerType;
}

bool ObserverGraphic::draw(QDataStream &in)
{
#ifdef TME_STATISTIC
    // tempo gasto do 'getState' ate aqui
    // double t = Statistic::getInstance().endVolatileMicroTime();
    // Statistic::getInstance().addElapsedTime("comunicação graphic", t);

    double decodeSum = 0.0;
    int decodeCount = 0;

    // numero de bytes transmitidos
    Statistic::getInstance().addOccurrence("bytes graphic", in.device()->size());
#endif

    QString msg, key;
    in >> msg;
    QStringList tokens = msg.split(PROTOCOL_SEPARATOR);

    double num = 0, x = 0, y = 0;

#ifdef TME_STATISTIC 
        // t = Statistic::getInstance().startMicroTime();
        Statistic::getInstance().startVolatileMicroTime();
#endif

    //QString subjectId = tokens.at(0);
    subjectType = (TypesOfSubjects) tokens.at(1).toInt();
    int qtdParametros = tokens.at(2).toInt();
    //int nroElems = tokens.at(3).toInt();

#ifdef TME_STATISTIC 
        // decodeSum += Statistic::getInstance().endMicroTime() - t;
        decodeSum += Statistic::getInstance().endVolatileMicroTime();
        decodeCount++;
#endif

    int j = 4;

    for (int i=0; i < qtdParametros; i++)
    {

#ifdef TME_STATISTIC 
        // t = Statistic::getInstance().startMicroTime();
        Statistic::getInstance().startVolatileMicroTime();
#endif

        key = tokens.at(j);
        j++;
        int typeOfData = tokens.at(j).toInt();
        j++;

#ifdef TME_STATISTIC 
        // decodeSum += Statistic::getInstance().endMicroTime() - t;
        decodeSum += Statistic::getInstance().endVolatileMicroTime();
        decodeCount++;
#endif

        int idx = itemList.indexOf(key);
        // bool contains = itemList.contains(key);
        bool contains = (idx != -1); // caso a chave não exista, idx == -1

        switch (typeOfData)
        {
            case (TObsBool)		:
                if (contains)
                    if (! QUIET_MODE )
                        qWarning("Warning: Was expected a numeric parameter.");
                break;

            case (TObsDateTime)	:
                //break;

            case (TObsNumber)		:

                if (contains)
                {

#ifdef TME_STATISTIC
                    // t = Statistic::getInstance().startMicroTime();
                    Statistic::getInstance().startVolatileMicroTime();
#endif

                    num = tokens.at(j).toDouble();

#ifdef TME_STATISTIC 
                    // decodeSum += Statistic::getInstance().endMicroTime() - t;
                    decodeSum += Statistic::getInstance().endVolatileMicroTime();
                    decodeCount++;
#endif

                    // Gráfico Dinâmico: Tempo vs Y
                    if (observerType == TObsDynamicGraphic)
                    {
                        y = num;
                        x = modelTime;
                    }
                    else
                    {
                        // Gráfico: X vs Y
                        if (idx == 0 )
                            y = num ;
                        else if (idx == 1)
                            x = num;
                    }
                }
                break;

            default							:
                if (! contains)
                    break;

                if ( (subjectType == TObsAutomaton) || (subjectType == TObsAgent) )
                {

#ifdef TME_STATISTIC
                    // t = Statistic::getInstance().startMicroTime();
                    Statistic::getInstance().startVolatileMicroTime();
#endif

                    if (! states.contains(tokens.at(j)))
                        states.push_back(tokens.at(j));

                    num = states.indexOf(tokens.at(j));

#ifdef TME_STATISTIC
                    // decodeSum += Statistic::getInstance().endMicroTime() - t;
                    decodeSum += Statistic::getInstance().endVolatileMicroTime();
                    decodeCount++;
#endif

                    // Gráfico Dinâmico: Tempo vs Y
                    if (observerType == TObsDynamicGraphic)
                    {
                        y = num;
                        x = modelTime;
                    }
                    else
                    {
                        // Gráfico: X vs Y
                        if (idx == 0 )
                            y = num ;
                        else if (idx == 1)
                            x = num;
                    }
                }
                else
                {
                    if (! QUIET_MODE )
                        qWarning("Warnig: Was expected a numeric parameter not a string '%s'.\n",
                                 qPrintable(tokens.at(j)) );
                }
                break;
        }
        j++;
    }

    if (! picker)
        createPicker();

#ifdef TME_STATISTIC
    t = Statistic::getInstance().startMicroTime();
#endif

    setData(x, y);

#ifdef TME_STATISTIC
    t = Statistic::getInstance().endMicroTime() - t;
    Statistic::getInstance().addElapsedTime("Graphic Rendering ", t);

    if (decodeCount > 0)
        Statistic::getInstance().addElapsedTime("Graphic Decoder", decodeSum / decodeCount);
#endif

    qApp->processEvents();
    return true;
}

void ObserverGraphic::setGraphicTitle(QString title)
{
    graphicTitle = title;
    plotter->setTitle(graphicTitle.toAscii().data());
}

void ObserverGraphic::setCurveTitle(QString title)
{
    curveTitle = title;
    curve->setTitle(curveTitle.toAscii().data());
}

void ObserverGraphic::setAxisTitle( QString x, QString y)
{
    xTitle = x;
    yTitle = y;

    plotter->setAxisTitle(QwtPlot::xBottom, xTitle);
    plotter->setAxisTitle(QwtPlot::yLeft, yTitle);
}

void ObserverGraphic::setData(double &x, double &y)
{
    xValue.push_back(x);
    yValue.push_back(y);
    draw();
}

void ObserverGraphic::setLegendPosition(QwtPlot::LegendPosition pos)
{
    if (! legend)
        legend = new QwtLegend;
    legend->setItemMode(QwtLegend::ClickableItem);
    plotter->insertLegend(legend, pos);

    connect(plotter, SIGNAL(legendClicked(QwtPlotItem *)), SLOT(colorChanged(QwtPlotItem *)));
}

//void ObserverGraphic::setGrid()
//{
//    // grid
//    QwtPlotGrid *plotGrid = new QwtPlotGrid;
//    plotGrid->enableXMin(true);
//    plotGrid->enableYMin(true);
//    plotGrid->attach(this);
//}

void ObserverGraphic::draw()
{
    curve->setData(xValue, yValue);
    plotter->repaint();
}

void ObserverGraphic::setHeaders(QStringList headers)
{
    itemList = headers;
}

//#include <QMessageBox>
void ObserverGraphic::colorChanged(QwtPlotItem *item)
{
    QColor color = QColorDialog::getColor();

    QWidget *w = plotter->legend()->find(item);
    if ( w && w->inherits("QwtLegendItem") )
    {
        if (color != ((QwtLegendItem *)w)->curvePen().color())
        {
            ((QwtLegendItem *)w)->setCurvePen(QPen(color));
            curve->setPen(QPen(color));
        }
    }

    plotter->replot();
}

void ObserverGraphic::createPicker()
{
    // cria o objeto responsável por exibir as coordenadas do ponteiro do mouse na tela
    // if (! picker)
    {
        picker = new QwtPlotPicker(QwtPlot::xBottom, QwtPlot::yLeft,
                                   QwtPicker::PointSelection | QwtPicker::DragSelection,
                                   QwtPlotPicker::CrossRubberBand, QwtPicker::AlwaysOn,
                                   plotter->canvas());
    }

    picker->setRubberBandPen( QColor(Qt::green) );
    picker->setRubberBand(QwtPicker::CrossRubberBand);
    picker->setTrackerPen( QColor(Qt::black) );
}

void ObserverGraphic::run()
{
    //while (!paused)
    //{
    //    QThread::exec();

    //    //std::cout << "teste thread\n";
    //    //std::cout.flush();
    //}
    QThread::exec();
}

void ObserverGraphic::pause()
{
    paused = !paused;
}

QStringList ObserverGraphic::getAttributes()
{
    return itemList;
}

void ObserverGraphic::setModelTime(double time)
{
    modelTime = time;
}

void ObserverGraphic::setCurveStyle()
{
    curve->setStyle(QwtPlotCurve::Steps);
}

int ObserverGraphic::close()
{
    plotter->close();
    QThread::exit(0);
    return 0;
}
