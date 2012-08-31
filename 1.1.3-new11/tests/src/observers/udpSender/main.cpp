//@RODRIGO
// TME_BUILD is defined in TerraME.pro
// this skips the main code above in TerraME compilation
// does nothing in udpreceiver compilation

#ifndef TME_BUILD

#include <QApplication>

#include "receiver.h"

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    Receiver receiver;
    receiver.show();
    return receiver.exec();
}

#endif
