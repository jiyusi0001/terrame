#ifndef ImageCompare_H
#define ImageCompare_H

#include<QImage>

class ImageCompare{
public:
    ImageCompare(const QString &type);
    bool comparePerPixel(const QString &img1, const QString &img2);
    bool compare(const QString &img1, const QString &img2);
private:
    QString type_;
};

#endif // ImageCompare_H
