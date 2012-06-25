#include "blackBoard.h"
#include "../observer.h"

#include <QDataStream>
#include <QBuffer>
#include <QByteArray>
#include <QDebug>

//#define TME_STATISTIC
//
//#ifndef TME_STATISTIC
//    // Estatisticas de desempenho
//    #include "../observer/statistic/statistic.h"
//#endif

using namespace TerraMEObserver;

class Cache
{
public:
    bool dirtyBit;
    QByteArray *byteArray;
    QBuffer *buffer;
    QDataStream *out;

    // public:
    Cache()
    {
        dirtyBit = true;

        byteArray = new QByteArray();
        buffer = new QBuffer(byteArray);
        out = new QDataStream(buffer);
    }

    virtual ~Cache()
    {
        delete byteArray;
        delete buffer;
        delete out;
    }

};

BlackBoard::BlackBoard()
{

}

BlackBoard::~BlackBoard()
{
    foreach(Cache *c, cache)
        delete c;
}

BlackBoard & BlackBoard::getInstance()
{
    static BlackBoard blackBoard;
    return blackBoard;
}

void BlackBoard::setDirtyBit(int subjectId)
{
    if (cache.contains(subjectId))
        cache.value(subjectId)->dirtyBit = true;
    else
        cache.insert(subjectId, new Cache());
}

bool BlackBoard::getDirtyBit(int subjectId) const 
{
    return cache.value(subjectId)->dirtyBit;
}

QDataStream & BlackBoard::getState(Subject *subj, int observerId, QStringList &attribs)
{
    Cache *state = cache.value(subj->getId());

    if (! state->dirtyBit)
    {
        return *state->out;
    }

    state->buffer->open(QIODevice::WriteOnly);
    state->out = &subj->getState(*state->out, subj, observerId, attribs);
    state->buffer->close();
    
    state->dirtyBit = false;
    return *state->out;
}
