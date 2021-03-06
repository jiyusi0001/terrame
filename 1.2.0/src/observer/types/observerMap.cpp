#include "observerMap.h"

#include <QApplication>
#include <QRect>
#include <QSplitter>
#include <QTreeWidgetItem>
#include <QMessageBox>
#include <QLineEdit>
#include <QScrollBar>
#include <QLabel>
#include <QToolButton>
#include <cmath>
#include <QDebug> 

#include "../protocol/decoder/decoder.h"

#define TME_STATISTIC_UNDEF

#ifdef TME_STATISTIC
    // Estatisticas de desempenho
    #include "../statistic/statistic.h"
#endif

using namespace TerraMEObserver;

ObserverMap::ObserverMap(QWidget *parent) : QDialog(parent)
{
    init();
}

ObserverMap::ObserverMap(Subject *sub)	: ObserverInterf(sub)
{
    init();
}

ObserverMap::~ObserverMap()
{
    foreach(Attributes *attrib, mapAttributes->values())
        delete attrib;
    delete mapAttributes;

    delete legendWindow;
    delete protocolDecoder;

    delete painterWidget;
    delete treeLayers;
    delete butLegend;
    delete butZoomIn;
    delete butZoomOut;
    delete butZoomWindow;
    delete butHand;
    delete butZoomRestore;
    delete zoomComboBox;

    delete scrollArea;
    //delete lblOperator;
    //delete operatorComboBox;
    delete frameTools; 	
}

void ObserverMap::init()
{
        observerType = TObsMap;
    subjectType = TObsUnknown;

    //resize(1000, 900);
    setWindowTitle("TerraME Observer : Map");
    setWindowFlags(Qt::Window);

    mapAttributes = new QHash<QString, Attributes*>();
    protocolDecoder = new Decoder(mapAttributes);
    legendWindow = 0;		// ponteiro para LegendWindow, instanciado no m�todo setHeaders

    builtLegend = 0;
    positionZoomVec = -1;
    zoomIdx = 11;
    actualZoom = 1.;
    needResizeImage = false;
    zoomCount = 0;  // indice do 100% no comboBox
    paused = false;
    numTiles = -1;

    cleanValues = false;

    width = 0;
    height = 0;
    newWidthCellSpace = 0.;
    newHeightCellSpace = 0.;

    setupGUI();
    showNormal();
}

const TypesOfObservers ObserverMap::getType()
{
    return observerType;
}

bool ObserverMap::draw(QDataStream &state)
{
    bool decoded = false;
    QString msg;
    state >> msg;

    QList<Attributes *> listAttribs = mapAttributes->values();
    Attributes * attrib = 0;

    connectTreeLayerSlot(false);
    for (int i = 0; i < listAttribs.size(); i++)
    {
        attrib = listAttribs.at(i);
        if (attrib->getType() == TObsCell)
        {
            attrib->clear();

#ifdef TME_STATISTIC 
        double t = Statistic::getInstance().startTime();

        decoded = protocolDecoder->decode(msg, *attrib->getXsValue(), *attrib->getYsValue());

        t = Statistic::getInstance().endTime() - t;
        Statistic::getInstance().addElapsedTime("Map Decoder", t);

        if (decoded)
        {
            t = Statistic::getInstance().startTime();

            painterWidget->plotMap(attrib);

            t = Statistic::getInstance().endTime() - t;
            Statistic::getInstance().addElapsedTime("Map Rendering", t);
        }
#else
            decoded = protocolDecoder->decode(msg, *attrib->getXsValue(), *attrib->getYsValue());
            if (decoded)
                painterWidget->plotMap(attrib);
#endif
        }
        qApp->processEvents();
    }

    connectTreeLayerSlot(true);

    // cria a legenda e exibe na tela
	//@RAIAN: Troquei esta comparacao porque nao estava criando a legenda da segunda camada (No meu caso, a vizinhanca)
    //if (/*decoded &&*/ legendWindow && (builtLegend < 1))
	if((legendWindow) && (builtLegend < mapAttributes->size()))
	//@RAIAN: FIM
    {
        connectTreeLayerSlot(false);
        legendWindow->makeLegend();
        showLayerLegend();

        painterWidget->replotMap();
        connectTreeLayerSlot(true);

        // exibe o zoom de janela
        zoomWindow();
        builtLegend++;
    }

    return decoded;
}

void ObserverMap::setAttributes(QStringList &attribs, QStringList legKeys,
                                QStringList legAttribs)
{
    connectTreeLayerSlot(false);
    
    bool complexMap = false; 

    // lista com os atributos que ser�o observados
    //itemList = headers;
    if (itemList.isEmpty())
    {
        itemList << attribs;
    }
    else
    {
        complexMap = true;

        foreach(const QString & str, attribs)
        {
            if (! itemList.contains(str))
                itemList.append(str);
        }
    }

#ifdef DEBUG_OBSERVER
    qDebug() << "\nheaders:\n" << attribs;
    qDebug() << "\nitemList:\n" << itemList;
    qDebug() << "\nMapAttributes()->keys(): " << mapAttributes->keys() << "\n";

    qDebug() << "LEGEND_ITENS: " << LEGEND_ITENS;
    qDebug() << "num de legendas: " << (int) legKeys.size() / LEGEND_ITENS;

    for (int j = 0; j < legKeys.size(); j++)
        qDebug() << legKeys.at(j) << " = " << legAttribs.at(j);
#endif

    for (int j = 0; (legKeys.size() > 0 && j < LEGEND_KEYS.size()); j++)
    {
        if (legKeys.indexOf(LEGEND_KEYS.at(j)) < 0)
        {
            qFatal("Error: Parameter legend \"%s\" not found. Please check it in the model.",
                qPrintable( LEGEND_KEYS.at(j) ) );
        }
    }
    int type = 0, mode = 0, slices = 0, precision = 0, stdDeviation = 0, max = 0;
    int min = 0, colorBar = 0, font = 0, fontSize = 0, symbol = 0, width = 0;

    QTreeWidgetItem *item = 0;
    Attributes *attrib = 0;
    for( int i = 0; i < itemList.size(); i++)
    {
        if ((! mapAttributes->contains(itemList.at(i)) )
            && (itemList.at(i) != "x") && (itemList.at(i) != "y") )
        {
            obsAttrib.append(itemList.at(i));
            attrib = new Attributes(itemList.at(i), width * height, newWidthCellSpace, newHeightCellSpace );
            attrib->setVisible(true);

            //------- Recupera a legenda do arquivo e cria o objeto attrib
            if (! legKeys.isEmpty())
            {
                type = legKeys.indexOf(TYPE);
                mode = legKeys.indexOf(GROUP_MODE);
                slices = legKeys.indexOf(SLICES);
                precision = legKeys.indexOf(PRECISION);
                stdDeviation = legKeys.indexOf(STD_DEV);
                max = legKeys.indexOf(MAX);
                min = legKeys.indexOf(MIN);
                colorBar = legKeys.indexOf(COLOR_BAR);
                font = legKeys.indexOf(FONT_FAMILY);
                fontSize = legKeys.indexOf(FONT_SIZE);
                symbol = legKeys.indexOf(SYMBOL);
                width = legKeys.indexOf(WIDTH);

                attrib->setDataType( (TypesOfData) legAttribs.at(type).toInt());
                attrib->setGroupMode( (GroupingMode) legAttribs.at(mode).toInt());
                attrib->setSlices(legAttribs.at(slices).toInt() - 1);				// conta com o zero
                attrib->setPrecisionNumber(legAttribs.at(precision).toInt() - 1);	// conta com o zero
                attrib->setStdDeviation( (StdDev) legAttribs.at(stdDeviation).toInt());
                attrib->setMaxValue(legAttribs.at(max).toDouble());
                attrib->setMinValue(legAttribs.at(min).toDouble());

                //Fonte
                attrib->setFontFamily(legAttribs.at(font));
                attrib->setFontSize(legAttribs.at(fontSize).toInt());

                //Converte o c�digo ASCII do s�mbolo em caracter
                bool ok = false;
                int asciiCode = legAttribs.at(symbol).toInt(&ok, 10);
                if (ok)
                    attrib->setSymbol( QString( QChar(asciiCode ) ));
                else
                    attrib->setSymbol(legAttribs.at(symbol));
                
				attrib->setWidth(legAttribs.at(width).toDouble());

                std::vector<ColorBar> colorBarVec;
                std::vector<ColorBar> stdColorBarVec;
                QStringList labelList, valueList;

                createColorsBar(legAttribs.at(colorBar),
                    colorBarVec, stdColorBarVec, valueList, labelList);

                attrib->setColorBar(colorBarVec);
                attrib->setStdColorBar(stdColorBarVec);
                attrib->setValueList(valueList);
                attrib->setLabelList(labelList);

                // Removes the legend items retrieved
                for(int j = 0; j < LEGEND_ITENS; j++)
                {
                    legKeys.removeFirst();
                    legAttribs.removeFirst();
                }

#ifdef DEBUG_OBSERVER
                qDebug() << "valueList.size(): " << valueList.size();
                qDebug() << valueList;
                qDebug() << "\nlabelList.size(): " << labelList.size();
                qDebug() << labelList;
                qDebug() << "\nattrib->toString()\n" << attrib->toString();
#endif
            }
            mapAttributes->insert(itemList.at(i), attrib);
            attrib->makeBkp();

            item = new QTreeWidgetItem(treeLayers);
            item->setCheckState(0, Qt::Checked);
            item->setText(0, itemList.at(i));

            if ((complexMap) && (treeLayers->topLevelItemCount() > 1))
            {
                item = treeLayers->takeTopLevelItem(treeLayers->topLevelItemCount() - 1);
                treeLayers->insertTopLevelItem(0, item);
                item->setExpanded(true);
            }
        }
    }

    if (! legendWindow)
        legendWindow = new LegendWindow(this);
    
    legendWindow->setValues(mapAttributes);   

    // Atualiza o zoom de janela
    zoomWindow();

    connectTreeLayerSlot(true);
}

void ObserverMap::butLegend_Clicked()
{
    // legendWindow->setValues(mapAttributes);

    //if (legendWindow->exec())
    //{
    //    painterWidget->replotMap();
    //    showLayerLegend();
    //    repaint();
    //}

    legendWindow->exec();

    painterWidget->replotMap();
    showLayerLegend();
    repaint();
}

void ObserverMap::butZoomIn_Clicked()
{
    // currentIndex() < 0 : o indice n�o existe no comboBox
    // currentIndex() > 22 : o indice � o zoom de janela
    if ((zoomComboBox->currentIndex() < 0) || (zoomComboBox->currentIndex() > 22))
        zoomComboBox->setCurrentIndex(positionZoomVec);
    calculeZoom(true);
    painterWidget->calculateResult();
}

void ObserverMap::butZoomOut_Clicked()
{
    if ((zoomComboBox->currentIndex() < 0) || (zoomComboBox->currentIndex() > 22))
    {
        positionZoomVec--;
        zoomComboBox->setCurrentIndex(positionZoomVec);
    }
    calculeZoom(false);
    painterWidget->calculateResult();
}

void ObserverMap::butZoomWindow_Clicked()
{
    painterWidget->setZoomWindow();
    butZoomWindow->setChecked(true);
    butHand->setChecked(false);
    painterWidget->calculateResult();
}

void ObserverMap::butZoomRestore_Clicked()
{
    if (zoomComboBox->currentText() == WINDOW)		// zoom em Window
        return;
    zoomComboBox->setCurrentIndex(zoomComboBox->findText(WINDOW));
    zoomActivated(WINDOW);
    painterWidget->calculateResult();
}

void ObserverMap::butHand_Clicked()
{
    painterWidget->setHandTool();
    butHand->setChecked(true);
    butZoomWindow->setChecked(false);
}

void ObserverMap::treeLayers_itemChanged(QTreeWidgetItem * item, int /*column*/)
{
    if (obsAttrib.size() == 0)
        return;

    Attributes * attrib = mapAttributes->value(item->text(0));
    if (attrib)
    {
        attrib->setVisible( (item->checkState(0) == Qt::Checked) ? true : false );
        painterWidget->calculateResult();
    }
}

void ObserverMap::createOperatorComboBox()
{
    //operatorComboBox = new QComboBox(frameTools);
    //operatorComboBox->setGeometry(10, 120, 150, 20);
    //connect(operatorComboBox, SIGNAL(activated(int)), this, SLOT(setOperatorMode(int)));
    //// *
    //operatorComboBox->addItem(tr("Clear"), QPainter::CompositionMode_Clear);

    //operatorComboBox->addItem(tr("SourceIn"), QPainter::CompositionMode_SourceIn);
    //operatorComboBox->addItem(tr("DestinationIn"), QPainter::CompositionMode_DestinationIn);

    //operatorComboBox->addItem(tr("SourceOut"), QPainter::CompositionMode_SourceOut);
    //operatorComboBox->addItem(tr("DestinationOut"), QPainter::CompositionMode_DestinationOut);

    //operatorComboBox->addItem(tr("SourceAtop"), QPainter::CompositionMode_SourceAtop);
    //operatorComboBox->addItem(tr("DestinationAtop"), QPainter::CompositionMode_DestinationAtop);
    //// * /
    //operatorComboBox->addItem(tr("Xor"), QPainter::CompositionMode_Xor);
    //operatorComboBox->addItem(tr("Plus"), QPainter::CompositionMode_Plus);
    //operatorComboBox->addItem(tr("Multiply"), QPainter::CompositionMode_Multiply);
    //operatorComboBox->addItem(tr("Difference"), QPainter::CompositionMode_Difference);
    //operatorComboBox->addItem(tr("Exclusion"), QPainter::CompositionMode_Exclusion);

    //operatorComboBox->addItem(tr("Screen"), QPainter::CompositionMode_Screen);
    //operatorComboBox->addItem(tr("Overlay"), QPainter::CompositionMode_Overlay);

    //operatorComboBox->addItem(tr("Darken"), QPainter::CompositionMode_Darken);
    //operatorComboBox->addItem(tr("Lighten"), QPainter::CompositionMode_Lighten);

    //operatorComboBox->addItem(tr("ColorDodge"), QPainter::CompositionMode_ColorDodge);
    //operatorComboBox->addItem(tr("ColorBurn"), QPainter::CompositionMode_ColorBurn);

    //operatorComboBox->addItem(tr("HardLight"), QPainter::CompositionMode_HardLight);
    //operatorComboBox->addItem(tr("SoftLight"), QPainter::CompositionMode_SoftLight);

    ////set OperatorMode(QPainter::CompositionMode_Multiply);
    //////operatorComboBox->setCurrentIndex(9);		// multiply
    //operatorComboBox->setCurrentIndex(2);		// multiply
    //painterWidget->setOperatorMode(QPainter::CompositionMode_Multiply);
}

void ObserverMap::setOperatorMode(int /*idx*/)
{
    //QPainter::CompositionMode mode =
    //    (QPainter::CompositionMode) operatorComboBox->itemData(idx).toInt();

    //painterWidget->setOperatorMode(mode);
    //painterWidget->calculateResult();
}

void ObserverMap::showLayerLegend()
{
    int layer = treeLayers->topLevelItemCount();

    QTreeWidgetItem *parent = 0, *child = 0;
    Attributes *attrib = 0;
    QVector<ObsLegend> *leg = 0;
    for(int i = 0; i < layer; i++)
    {
        parent = treeLayers->topLevelItem(i);
        treeLayers->setItemExpanded(parent, true);
        attrib = mapAttributes->value(parent->text(0));

        leg = attrib->getLegend();

        if (parent->childCount() > 0)
            parent->takeChildren();

        for(int j = 0; j < leg->size(); j++)
        {
            child = new QTreeWidgetItem( parent);
            child->setSizeHint(0, ICON_SIZE);
            child->setText(0, leg->at(j).getLabel());
            QColor color = leg->at(j).getColor();

			//@RAIAN: Para exibir a legenda da vizinhanca como linha 
            if(attrib->getType() == TObsNeighborhood)
			{
				child->setData(0, Qt::DecorationRole, legendWindow->color2PixmapLine(color, attrib->getWidth()));
			}
			//@RAIAN: FIM
			else
			{
				if (! leg->at(j).getLabel().contains("mean"))
					child->setData(0, Qt::DecorationRole,
					legendWindow->color2Pixmap(color, ICON_SIZE));
				else
					child->setData(0, Qt::DecorationRole, QString(""));
			}
        }

        // Apresenta o item "does not belong" na arvore de layers
        //if (attrib->getType() == TObsTrajectory)
        //{
        //    child = new QTreeWidgetItem(parent);
        //    child->setSizeHint(0, ICON_SIZE);
        //    child->setText(0, TRAJECTORY_LABEL);
        //    child->setData(0, Qt::DecorationRole,
        //        legendWindow->color2Pixmap(Qt::white, ICON_SIZE));
        //}
    }
    treeLayers->resizeColumnToContents(0);
}

void ObserverMap::zoomActivated(const QString &scale )
{
    if (scale == WINDOW)
    {
        zoomWindow();
        return;
    }

    double newScale = scale.left(scale.indexOf(tr("%"))).toDouble() * 0.01;
    double scW = newWidthCellSpace * newScale;
    double scH = newHeightCellSpace * newScale;

    QSize imgActual(scW, scH);

    if (painterWidget->rescale(imgActual))
    {
        //scrollArea->setUpdatesEnabled(false);
        painterWidget->resize(imgActual);
        //scrollArea->setUpdatesEnabled(true);
        actualZoom = newScale;

        if (scale.indexOf("%") < 0)
            zoomComboBox->lineEdit()->setText(scale + "%");
    }
    else
    {
        QString aux(QString::number(actualZoom * 100));
        int idx = zoomComboBox->findText(aux + "%");
        //printf("zoomActivated:>>>> findText(): %i\n", idx);
        zoomComboBox->setCurrentIndex(idx);
    }
}

void ObserverMap::calculeZoom(bool in)
{
    int idx = zoomComboBox->currentIndex();

    if ((idx < 1) || (idx > 21))
        return;

    if (in)
        idx = zoomComboBox->currentIndex() - 1;
    else
        idx = zoomComboBox->currentIndex() + 1;

    QString scale = zoomComboBox->itemText(idx);
    double newScale = scale.left(scale.indexOf(tr("%"))).toDouble() * 0.01;
    double scW = newWidthCellSpace * newScale;
    double scH = newHeightCellSpace * newScale;

    QSize imgActual(scW, scH);

    if (painterWidget->rescale(imgActual))
    {
        //scrollArea->setUpdatesEnabled(false);
        painterWidget->resize(imgActual);
        //scrollArea->setUpdatesEnabled(true);
        zoomComboBox->setCurrentIndex(idx);
        actualZoom = newScale;
    }
}

void ObserverMap::zoomChanged(QRect zoomRect, double width, double height)
{
    double zoom = 0.0;

    if (width < height)
        zoom = width - 0.01;
    else
        zoom = height - 0.01;

#ifdef DEBUG_OBSERVER
    qDebug() << "zoomChanged: " << zoom;
    qDebug() << "factWidth: " << width << " height: " << height;
    qDebug() << "imgSize: " << imgSize;
    qDebug() << "scrollArea->viewport: " << scrollArea->viewport()->size();
    qDebug() << "painterWidget->size: " << painterWidget->size();
#endif

    QSize imgSize(painterWidget->size() * zoom);

    if (! painterWidget->rescale(imgSize))
    {
        //printf("\nzoomChanged:> painterWidget->rescale() FALSO\n\n");
        return;
    }

    double x = zoomRect.x();
    double y = zoomRect.y();

    x *= zoom;
    y *= zoom;

    int xScroll = (int) x;
    int yScroll = (int) y;

    scrollArea->setUpdatesEnabled(false);
    painterWidget->resize(imgSize);

    // reposiciona as barras de rolagem no ponto onde
    // foi selecionado
    scrollArea->horizontalScrollBar()->setValue(xScroll);
    scrollArea->verticalScrollBar()->setValue(yScroll);

    scrollArea->setUpdatesEnabled(true);

    double ratio = newWidthCellSpace / newHeightCellSpace;
    ratio *= newWidthCellSpace;
    double percent = (imgSize.width() / ratio);// - 1.0;

#ifdef DEBUG_OBSERVER
    qDebug() << "zoomChanged::percent: " << percent;
    qDebug() << "scrollArea->viewport: " << scrollArea->viewport()->size();
    qDebug() << "painterWidget->size: " << painterWidget->size();
#endif

    QString newZoom(QString::number(ceil(percent * 100)));
    int curr = zoomComboBox->findText(newZoom + "%");

    if (curr >= 0)
    {
        zoomComboBox->setCurrentIndex(curr);
        //positionZoomVec = -2;
    }
    else
    {
        zoomComboBox->setCurrentIndex(-1);
        //if (zoomComboBox->isEditable())
        zoomComboBox->lineEdit()->setText(newZoom + "%");

        QVector<int> zoomVecAux(zoomVec);
        zoomVecAux.push_back(newZoom.toInt());
        qStableSort(zoomVecAux.begin(), zoomVecAux.end(), qGreater<int>());
        positionZoomVec = zoomVecAux.indexOf(newZoom.toInt()); // armazena a posi��o do novo valor de zoom
    }
}

void ObserverMap::zoomOut()
{
    zoomComboBox->setCurrentIndex(zoomComboBox->currentIndex() + 1);
    QString scale(zoomComboBox->currentText());
    zoomActivated(scale);
}

QStringList ObserverMap::getAttributes()
{
    return itemList;
}

void ObserverMap::resizeEvent(QResizeEvent *)
{
    if (zoomComboBox->currentText() == WINDOW)
        zoomWindow();

    painterWidget->calculateResult();
}

void ObserverMap::zoomWindow()
{
    QRect zoomRect = painterWidget->rect();

    double factWidth = scrollArea->width() - 1;
    double factHeight = scrollArea->height() - 1;

    factWidth /= zoomRect.width() - 1;
    factHeight /= zoomRect.height() - 1;

    // Define o maior zoom como sendo 3200%
    factWidth = factWidth > 32.0 ? 32.0 : factWidth;
    factHeight = factHeight > 32.0 ? 32.0 : factHeight;

    zoomChanged(zoomRect, factWidth, factHeight);
    // zoomComboBox->setCurrentIndex(23);
    zoomComboBox->setCurrentIndex(zoomComboBox->findText(WINDOW));
}

void ObserverMap::setCellSpaceSize(int w, int h)
{
    width = w;
    height = h;
    newWidthCellSpace = width * SIZE_CELL;
    newHeightCellSpace = height * SIZE_CELL;

    painterWidget->resizeImage(QSize(newWidthCellSpace, newHeightCellSpace));
    needResizeImage = true;
}

//void ObserverMap::setVectorPos(QVector<double> *xs, QVector<double> *ys)
//{
//    // painterWidget->setVectorPos(xs, ys);
//}

PainterWidget * ObserverMap::getPainterWidget() const
{
    return painterWidget;
}

QHash<QString, Attributes*> * ObserverMap::getMapAttributes() const
{
    return mapAttributes;
}

Decoder & ObserverMap::getProtocolDecoder() const
{
    return *protocolDecoder;
}

QTreeWidget * ObserverMap::getTreeLayers()
{
    return treeLayers;
}

const QSize ObserverMap::getCellSpaceSize()
{
    return QSize(newWidthCellSpace, newHeightCellSpace);
}

void ObserverMap::connectTreeLayerSlot(bool on)
{
    // conecta/disconecta o sinal do treeWidget com o slot
    if (! on)
    {
        disconnect(treeLayers, SIGNAL(itemChanged( QTreeWidgetItem *, int )),
            this, SLOT(treeLayers_itemChanged( QTreeWidgetItem *, int ) ));
    }
    else
    {
        QWidget::connect(treeLayers, SIGNAL(itemChanged( QTreeWidgetItem *, int )),
            this, SLOT(treeLayers_itemChanged( QTreeWidgetItem *, int ) ));
    }
}

int ObserverMap::close()
{
    QDialog::close();
    painterWidget->close();
    return 0;
}




ColorBar ObserverMap::makeColorBarStruct(int distance, QString strColorBar,
                QString &value, QString &label)
{
    int COLOR_ = 0, VALUE_ = 1, LABEL_ = 2, DISTANCE_ = 3;

    QStringList colorItemList = strColorBar.split(ITEM_SEP, QString::SkipEmptyParts);
    QStringList teColorList = colorItemList.at(COLOR_).split(COMP_COLOR_SEP); //, QString::SkipEmptyParts); // lista com os componentes r, g, b

#ifdef DEBUG_OBSERVER
    qDebug() << "colorList.size(): " <<  colorItemList.size();
    qDebug() << colorItemList;

    qDebug() << "teColorList.size(): " <<   teColorList.size();
    qDebug() << teColorList;
#endif

    if (colorItemList.at(LABEL_) != ITEM_NULL)
        label = colorItemList.at(LABEL_);

    if (colorItemList.at(VALUE_) != ITEM_NULL)
        value = colorItemList.at(VALUE_);

    ColorBar b;

    if ((teColorList.size() == 3) || (teColorList.size() == 4))
    {
        TeColor c(teColorList.at(0).toInt(),
                  teColorList.at(1).toInt(),
                  teColorList.at(2).toInt());
        b.color(c);
    }
    else
    {
        qFatal("\nError: The color bar is invalid! "
               "Please, check the 'colorBar' item in the legend.");
    }

    // Caso a distancia seja informada
    if (colorItemList.at(DISTANCE_) != ITEM_NULL)
        b.distance_ = colorItemList.at(DISTANCE_).toDouble();
    else
        b.distance_ = distance * 1.;

    return b;
}

void ObserverMap::createColorsBar(QString colors, std::vector<ColorBar> &colorBarVec,
    std::vector<ColorBar> &stdColorBarVec, QStringList &valueList, QStringList &labelList)
{
    colorBarVec.clear();
    stdColorBarVec.clear();
    valueList.clear();
    labelList.clear();

    int pos = colors.indexOf(COLOR_BAR_SEP); // separa a colorBar e o stdColorBar
    QString colorBarStr = colors.mid(0, pos);
    QStringList colorBarList = colorBarStr.split(COLORS_SEP, QString::SkipEmptyParts);

    QString value, label;

#ifdef DEBUG_OBSERVER
        qDebug() << "\ncolorBarStr: " << colorBarStr;
        qDebug() << "colorList: " << colorBarList;
#endif

    // cria a colorBar1 do atributo
    for (int i = 0; i < colorBarList.size(); i++)
    {
        ColorBar b = makeColorBarStruct(i, colorBarList.at(i), value, label);
        colorBarVec.push_back(b);
        valueList.append( (value.isEmpty() || value.isNull()) ? QString::number(i) : value );
        labelList.append( (label.isEmpty() || label.isNull()) ? QString::number(i) : label );
    }

    // Desvio padr�o -----------------------
    // cria a stdColorBar do atributo
    if (pos > -1)
    {
        value.clear();
        label.clear();

        QString stdColorBarStr = colors.mid(pos + 1);
        QStringList stdColorBarList = stdColorBarStr.split(COLORS_SEP, QString::SkipEmptyParts);

#ifdef DEBUG_OBSERVER
        qDebug() << "\nstdColorBarStr: " << stdColorBarStr;
        qDebug() << "stdColorBarList: " << stdColorBarList;
#endif

        for (int i = 0; i < stdColorBarList.size(); i++)
        {
            ColorBar b = makeColorBarStruct(i, stdColorBarList.at(i), value, label);
            stdColorBarVec.push_back(b);
            valueList.append( (value.isEmpty() || value.isNull()) ? QString::number(i) : value );
            labelList.append( (label.isEmpty() || label.isNull()) ? QString::number(i) : label );
        }
    }
}

bool ObserverMap::constainsItem(const QVector<QPair<Subject *, QString> > &linkedSubjects, 
        const Subject *subj)
{
    for (int i = 0; i < linkedSubjects.size(); i++)
    {
        if (linkedSubjects.at(i).first == subj)
            return true;
    }
    return false;
}

void ObserverMap::setupGUI()
{
    scrollArea = new QScrollArea(this);
    scrollArea->setObjectName("scrollArea");
    scrollArea->setBackgroundRole(QPalette::Dark);  // (QPalette::Dark);// Light
    scrollArea->setAlignment(Qt::AlignCenter);

    painterWidget = new PainterWidget(mapAttributes, this);
    connect(painterWidget, SIGNAL(zoomOut()), this, SLOT(zoomOut() ));
    connect(painterWidget, SIGNAL(zoomChanged(QRect, double, double) ),
        this, SLOT(zoomChanged(QRect, double, double) ));

    scrollArea->setWidget(painterWidget);
    painterWidget->setParentScroll(scrollArea);

    frameTools = new QFrame(this);
    frameTools->setGeometry(0, 0, 200, 500);

    QVBoxLayout *layoutTools = new QVBoxLayout();
    layoutTools->setMargin(5);

    frameTools->setLayout(layoutTools);

    butLegend = new QToolButton(frameTools);
    butLegend->setText(tr("legend"));
    butLegend->setIcon(QIcon(QPixmap(":/icons/legend.png")));
    butLegend->setGeometry(5, 5, 50, 20);
    butLegend->setToolButtonStyle(Qt::ToolButtonTextBesideIcon);
    connect(butLegend, SIGNAL(clicked()), this, SLOT(butLegend_Clicked()));

    butGrid = new QToolButton(frameTools);
    butGrid->setText(tr("grid"));
    butGrid->setCheckable(true);
    butGrid->setIcon(QIcon(QPixmap(":/icons/grid.png")));
    butGrid->setGeometry(75, 5, 50, 20);
    butGrid->setToolButtonStyle(Qt::ToolButtonTextBesideIcon);
    connect(butGrid, SIGNAL(toggled(bool)), painterWidget, SLOT(gridOn(bool)));

    butZoomIn = new QToolButton(frameTools);
    butZoomIn->setText("In");
    butZoomIn->setIcon(QIcon(QPixmap(":/icons/zoomIn.png")));
    butZoomIn->setGeometry(5, 35, 20, 20);
    butZoomIn->setToolTip("Zoom in");
    butZoomIn->setToolButtonStyle(Qt::ToolButtonTextBesideIcon);
    connect(butZoomIn, SIGNAL(clicked()), this, SLOT(butZoomIn_Clicked()));

    butZoomOut = new QToolButton(frameTools);
    butZoomOut->setText("Out");
    butZoomOut->setIcon(QIcon(QPixmap(":/icons/zoomOut.png")));
    butZoomOut->setGeometry(5, 65, 20, 20);
    butZoomOut->setToolTip("Zoom out");
    butZoomOut->setToolButtonStyle(Qt::ToolButtonTextBesideIcon);
    connect(butZoomOut, SIGNAL(clicked()), this, SLOT(butZoomOut_Clicked()));

    butHand = new QToolButton(frameTools);
    butHand->setText("Pan");
    butHand->setIcon(QIcon(QPixmap(":/icons/hand.png")));
    butHand->setGeometry(5, 95, 20, 20);
    butHand->setToolTip("Pan");
    butHand->setToolButtonStyle(Qt::ToolButtonTextBesideIcon);
    butHand->setCheckable(true);
    connect(butHand, SIGNAL(clicked()), this, SLOT(butHand_Clicked()));

    butZoomWindow = new QToolButton(frameTools);
    butZoomWindow->setText("Window");
    butZoomWindow->setIcon(QIcon(QPixmap(":/icons/zoomWindow.png")));
    butZoomWindow->setGeometry(5, 125, 20, 20);
    butZoomWindow->setToolTip("Zoom window");
    butZoomWindow->setToolButtonStyle(Qt::ToolButtonTextBesideIcon);
    butZoomWindow->setCheckable(true);
    connect(butZoomWindow, SIGNAL(clicked()), this, SLOT(butZoomWindow_Clicked()));

    butZoomRestore = new QToolButton(frameTools);
    butZoomRestore->setText("Restore");
    butZoomRestore->setIcon(QIcon(QPixmap(":/icons/zoomRestore.png")));
    butZoomRestore->setGeometry(5, 155, 20, 20);
    butZoomRestore->setToolTip("Restore Zoom");
    butZoomRestore->setToolButtonStyle(Qt::ToolButtonTextBesideIcon);
    //butZoomRestore->setCheckable(true);
    connect(butZoomRestore, SIGNAL(clicked()), this, SLOT(butZoomRestore_Clicked()));

    zoomVec << 3200 << 2400 << 1600 << 1200 << 800 << 700 << 600 << 500 << 400 << 300 
        << 200 << 100 << 66 << 50 << 33 << 25 << 16  << 12 << 8 << 5 << 3 << 2 << 1;
    
    QStringList zoomList;

    for (int i = 0; i < zoomVec.size(); i++)
        zoomList.append( QString::number(zoomVec.at(i)) + "%");

    zoomList.append(WINDOW);

    zoomComboBox = new QComboBox(frameTools);
    zoomComboBox->addItems(zoomList);
    zoomComboBox->setGeometry(10, 95, 30, 20);
    zoomComboBox->setSizeAdjustPolicy(QComboBox::AdjustToContents);
    zoomComboBox->setCurrentIndex(23); // window  //zoomIdx); //11);
    //zoomComboBox->setCurrentIndex(zoomIdx); //11);
    zoomComboBox->setEditable(true);
    connect(zoomComboBox, SIGNAL(activated(const QString & )),
        this, SLOT(zoomActivated(const QString &)));

    QHBoxLayout *hLayoutZoom1 = new QHBoxLayout();
    hLayoutZoom1->setMargin(5);

    QHBoxLayout *hLayoutZoom2 = new QHBoxLayout();
    hLayoutZoom2->setMargin(5);

    hLayoutZoom1->addWidget(butZoomIn);
    hLayoutZoom1->addWidget(butZoomOut);
    hLayoutZoom1->addWidget(butHand);
    hLayoutZoom2->addWidget(butZoomWindow);
    hLayoutZoom2->addWidget(butZoomRestore);

    // Exibe os layers de informa��o
    treeLayers = new QTreeWidget(frameTools);
    treeLayers->setGeometry(5, 150, 190, 310);
    treeLayers->setHeaderLabel(tr("Layers"));
    //treeLayers->setRootIsDecorated(false);
    //treeLayers->setAlternatingRowColors(true);
    connect(treeLayers, SIGNAL(itemClicked( QTreeWidgetItem *, int )),
        this, SLOT(treeLayers_itemChanged( QTreeWidgetItem *, int ) ));
    connect(treeLayers, SIGNAL(itemActivated( QTreeWidgetItem *, int )),
        this, SLOT(treeLayers_itemChanged( QTreeWidgetItem *, int ) ));

    // lblOperator = new QLabel(tr("Operations: "), frameTools);
    // lblOperator->setGeometry(10, 95, 150, 20);
    createOperatorComboBox();

    QSpacerItem *verticalSpacer = new QSpacerItem(20, 50,  QSizePolicy::Minimum,
        QSizePolicy::Preferred);

    //--------------------------
    QHBoxLayout *hLayoutZoom3 = new QHBoxLayout();
    hLayoutZoom3->addWidget(butLegend);
    hLayoutZoom3->addWidget(butGrid);
    layoutTools->addItem(hLayoutZoom3);

    layoutTools->addItem(verticalSpacer);

    layoutTools->addWidget(zoomComboBox);
    layoutTools->addItem(hLayoutZoom1);
    layoutTools->addItem(hLayoutZoom2);

    //layoutTools->addWidget(lblOperator);
    // layoutTools->addWidget(operatorComboBox);
    layoutTools->addWidget(treeLayers);
    //-------------------------

    QSplitter *splitter = new QSplitter(this);
    splitter->setStyleSheet("QSplitter::handle{image: url(:/icons/splitter.png); QSplitter { width: 3px; }}");
    splitter->addWidget(frameTools);
    splitter->addWidget(scrollArea);
    splitter->setStretchFactor(0, 0);
    splitter->setStretchFactor(1, 1);

    QHBoxLayout *layoutDefault = new QHBoxLayout(this);
    layoutDefault->setMargin(5);

    layoutDefault->addWidget(splitter);
    setLayout(layoutDefault);
}

