#include "ImageCompare.h"
#include<qdebug.h>

ImageCompare::ImageCompare(const QString &type) : type_(type){}

bool ImageCompare::compare(const QString &img1, const QString &img2)
{
    if(type_ == "pixel") return comparePerPixel(img1,img2);
    return false;
}

bool ImageCompare::comparePerPixel(const QString &img1, const QString &img2)
{
    QImage image1(img1);
    QImage image2(img2);

    if(image1.width()==0 || image1.height() == 0)
        return false;

    if(image2.width()==0 || image2.height() == 0)
        return false;

    if(image1.width() != image2.width() || image1.height() != image2.height())
        return false;

    for(int i = 0; i < image1.height(); i++)
        for(int j = 0; j < image1.width(); j++)
            if(image1.pixel(j,i) != image2.pixel(j,i))
                return false;
    return true;
}
