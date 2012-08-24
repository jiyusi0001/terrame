#include "observerImage.h"
#include <QtGui/QApplication>

extern bool QUIET_MODE;


#include "image/imageGUI.h"
#include "../protocol/decoder/decoder.h"
#include "observerMap.h"

using namespace TerraMEObserver;

ObserverImage::ObserverImage (Subject *sub) : ObserverInterf(sub)
{
    obsImgGUI = new ImageGUI();

    observerType = TObsImage;
    subjectType = TObsUnknown;

    mapAttributes = new QHash<QString, Attributes*>();
    protocolDecoder = new Decoder(mapAttributes);

    painterWidget = new PainterWidget(mapAttributes);
    painterWidget->setOperatorMode(QPainter::CompositionMode_Multiply);
    // painterWidget->setGeometry(0, 0, 1500, 1500);
    // painterWidget->show();

    width = 0;
    height = 0;
    newWidthCellSpace = 0.;
    newHeightCellSpace = 0.;

    savingImages = true;
    builtLegend = 0;
    legendWindow = 0;		// ponteiro para LegendWindow
    path = DEFAULT_NAME;

    disableSaveImage = false;
}

ObserverImage::~ObserverImage()
{
    foreach(Attributes *attrib, mapAttributes->values())
        delete attrib;
    delete mapAttributes;

    delete painterWidget;
    delete legendWindow;

    delete obsImgGUI;
    delete protocolDecoder;
}

bool ObserverImage::draw(QDataStream &state)
{
    bool decoded = false;
    QString msg;
    state >> msg;

    QList<Attributes *> listAttribs = mapAttributes->values();
    Attributes * attrib = 0;

    for (int i = 0; i < listAttribs.size(); i++)
    {
        attrib = listAttribs.at(i);
        if (attrib->getType() == TObsCell)
        {
            attrib->clear();
            decoded = protocolDecoder->decode(msg, *attrib->getXsValue(), *attrib->getYsValue());
            if (decoded)
                painterWidget->plotMap(attrib);
        }
        qApp->processEvents();
    }

    if (/*decoded &&*/ legendWindow && (builtLegend < 1))
    {
        legendWindow->makeLegend();

        // Verificar porque a primeira invocação do método plotMap
        // gera a imagem foreground totalmente preta. Assim, é preciso
        // repetir essa chamada aqui!
        painterWidget->replotMap();

        builtLegend++;
    }

    //if (! disableSaveImage)
    //    return save();

    return decoded;
}

QStringList ObserverImage::getAttributes()
{
    return attribList;
}

const TypesOfObservers ObserverImage::getType()
{
    return observerType;
}

void ObserverImage::setPath(const QString & pth, const QString & prefix)
{
    if (pth.endsWith("/"))
        path = pth + prefix;
    else
        path = pth + "/" + prefix;

    obsImgGUI->setPath(pth, prefix);
}

void ObserverImage::setAttributes(QStringList &attribs, QStringList legKeys,
                                  QStringList legAttribs)
{
    // lista com os atributos que serão observados
    //itemList = headers;
    if (attribList.isEmpty())
    {
        attribList << attribs;
    }
    else
    {
        foreach(const QString & str, attribs)
        {
            if (! attribList.contains(str))
                attribList.append(str);
        }
    }

#ifdef DEBUG_OBSERVER
    qDebug() << "\nheaders:\n" << headers;
    qDebug() << "\nitemList:\n" << itemList;
    qDebug() << "\nMapAttributes()->keys(): " << mapAttributes->keys() << "\n";

    qDebug() << "LEGEND_ITENS: " << LEGEND_ITENS;
    qDebug() << "num de legendas: " << (int) legKeys.size() / LEGEND_ITENS;

    for (int j = 0; j < legKeys.size(); j++)
        qDebug() << legKeys.at(j) << " = " << legAttrib.at(j);
#endif

    for (int j = 0; (legKeys.size() > 0 && j < LEGEND_KEYS.size()); j++)
    {
        if (legKeys.indexOf(LEGEND_KEYS.at(j)) < 0)
        {
            qFatal("Error: Parameter legend \"%s\" not found. Please check it in the model.", 
                qPrintable( LEGEND_KEYS.at(j) ) );
        }
    }

    int type = legKeys.indexOf(TYPE);
    int mode = legKeys.indexOf(GROUP_MODE);
    int slices = legKeys.indexOf(SLICES);
    int precision = legKeys.indexOf(PRECISION);
    int stdDeviation = legKeys.indexOf(STD_DEV);
    int max = legKeys.indexOf(MAX);
    int min = legKeys.indexOf(MIN);
    int colorBar = legKeys.indexOf(COLOR_BAR);
    int font = legKeys.indexOf(FONT_FAMILY);
    int fontSize = legKeys.indexOf(FONT_SIZE);
    int symbol = legKeys.indexOf(SYMBOL);

    // são 8 itens para cada atributo sendo observado
    int numLegs = (int) legKeys.size() / LEGEND_ITENS;
    int cont = 0, contAttrib = 0;

    Attributes *attrib = 0;
    for( int i = 0; i < attribList.size(); i++)
    {
        if ((! mapAttributes->contains(attribList.at(i)) )
                && (attribList.at(i) != QString("x"))
                && (attribList.at(i) != QString("y")) )
        {
            obsAttrib.append(attribList.at(i));
            attrib = new Attributes(attribList.at(i), width * height,
                                    newWidthCellSpace, newHeightCellSpace );

            //------- Recupera a legenda do arquivo e cria o objeto attrib
            if ((legKeys.size() > 0) && ( contAttrib + 1 <= numLegs))
            {
                attrib->setDataType( (TypesOfData) legAttribs.at(type + cont).toInt());
                attrib->setGroupMode( (GroupingMode) legAttribs.at(mode + cont).toInt());
                attrib->setSlices(legAttribs.at(slices + cont).toInt() - 1);				// conta com o zero
                attrib->setPrecisionNumber(legAttribs.at(precision + cont).toInt() - 1);	// conta com o zero
                attrib->setStdDeviation( (StdDev) legAttribs.at(stdDeviation + cont).toInt());
                attrib->setMaxValue(legAttribs.at(max + cont).toDouble());
                attrib->setMinValue(legAttribs.at(min + cont).toDouble());

                //Fonte
                attrib->setFontFamily(legAttribs.at(font + cont));
                attrib->setFontSize(legAttribs.at(fontSize + cont).toInt());
                
                //Converte o código ASCII do símbolo em caracter
                bool ok = false;
                int asciiCode = legAttribs.at(symbol + cont).toInt(&ok, 10);
                if (ok)
                    attrib->setSymbol( QString( QChar(asciiCode ) ));
                else
                    attrib->setSymbol(legAttribs.at(symbol + cont));

                std::vector<ColorBar> colorBarVec;
                std::vector<ColorBar> stdColorBarVec;
                QStringList labelList, valueList;

                ObserverMap::createColorsBar(legAttribs.at(colorBar + cont),
                    colorBarVec, stdColorBarVec, valueList, labelList);

                attrib->setColorBar(colorBarVec);
                attrib->setStdColorBar(stdColorBarVec);
                attrib->setValueList(valueList);
                attrib->setLabelList(labelList);

#ifdef DEBUG_OBSERVER
                qDebug() << "valueList.size(): " << valueList.size();
                qDebug() << valueList;
                qDebug() << "\nlabelList.size(): " << labelList.size();
                qDebug() << labelList;

                qDebug() << "\nattrib->toString()\n" << attrib->toString();
#endif
            }

            //------- end

            mapAttributes->insert(attribList.at(i), attrib);

            cont = LEGEND_ITENS;
            contAttrib++;
        }
    }

    if (! legendWindow)
        legendWindow = new LegendWindow();
    legendWindow->setValues(mapAttributes);
}

void ObserverImage::setCellSpaceSize(int w, int h)
{
    width = w;
    height = h;
    newWidthCellSpace = width * SIZE_CELL;
    newHeightCellSpace = height * SIZE_CELL;

    painterWidget->resizeImage(QSize(newWidthCellSpace, newHeightCellSpace));
    needResizeImage = true;
}

bool ObserverImage::save()
{
    if (savingImages)
        savingImages = painterWidget->save(path);

    if (! savingImages)
    {
        obsImgGUI->setStatusMessage("Unable to save the image.");
        if (! QUIET_MODE )
        {
            qWarning("Warning: Unable to save the image."
                     "The path is incorrect or you do not have permission to perform this task.");
        }
    }
    return savingImages;
}

PainterWidget * ObserverImage::getPainterWidget() const
{
    return painterWidget;
}

QHash<QString, Attributes*> * ObserverImage::getMapAttributes() const
{
    return mapAttributes;
}

Decoder & ObserverImage::getProtocolDecoder() const
{
    return *protocolDecoder;
}

const QSize ObserverImage::getCellSpaceSize()
{
    return QSize(newWidthCellSpace, newHeightCellSpace);
}

void ObserverImage::setDisableSaveImage()
{
    disableSaveImage = true;
}

bool ObserverImage::getDisableSaveImage() const
{
    return disableSaveImage;
}

int ObserverImage::close()
{
    obsImgGUI->close();
    painterWidget->close();
    return 0;
}

void ObserverImage::show()
{
    obsImgGUI->showNormal();
}
