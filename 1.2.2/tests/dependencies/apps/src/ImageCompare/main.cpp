#include <QtGui/QApplication>
#include "ImageCompare.h"
#include <iostream>

using namespace std;

int main(int argc, char **argv)
{
    if(argc != 4) return 1;
    ImageCompare comp(argv[1]);
    cout << comp.compare(argv[2],argv[3]) << endl;
    return 0;
}

