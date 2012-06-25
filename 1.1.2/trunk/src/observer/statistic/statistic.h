// #ifdef TME_STATISTIC

#ifndef STATISTIC_H
#define STATISTIC_H

#include <QObject>
#include <QString>
#include <QVector>
#include <QMap>
#include <QElapsedTimer>

#ifdef _MSC_VER
#include <windows.h>
static const double MICRO_DIV = 1/1000000.0f;
#else
#include <sys/time.h>
static const double MICRO_DIV = 1000000.0f;
#endif

class Statistic : public QObject
{
public:
    static Statistic& getInstance();
    virtual ~Statistic();

    inline double startTime()
    {
        return elapsedTimer->elapsed() * 1.0;
    }

    inline double endTime()
    {
        return elapsedTimer->elapsed() * 1.0;
    }

    inline double startMicroTime()
    {
#ifdef _MSC_VER
        __int64 time;
        QueryPerformanceCounter( (LARGE_INTEGER*)(&time ) );
        return ((double)time * MICRO_DIV);
#else
        // Not tested
        struct timeval time;
        gettimeofday(&time, NULL);
        return (double) time.tv_sec * MICRO_DIV + (time.tv_usec);
        // return (double) (time->tv_sec * 1000000000) + time->tv_nsec)
#endif
    }

    inline double endMicroTime()
    {
#ifdef _MSC_VER
        __int64 time;
        QueryPerformanceCounter( (LARGE_INTEGER*) (&time ) );
        return ((double)time * MICRO_DIV);
#else
        // Not tested
        struct timeval time;
        gettimeofday(&time, NULL);
        return (double) time.tv_sec * MICRO_DIV + (time.tv_usec);
        // return (float) (time->tv_sec * 1000000000) + time->tv_nsec)
#endif
    }

    /// Start the volatile time (miliseconds)
    inline void startVolatileTime()
    {
        volatileTimer->start();
    }

    /// Gets volatile time in miliseconds
    inline float endVolatileTime()
    {
        return volatileTimer->elapsed() * 1.0;
    }

    /// Start the volatile time (microseconds)
    inline void startVolatileMicroTime()
    {
#ifdef _MSC_VER
        QueryPerformanceCounter( (LARGE_INTEGER*)(&startMicroTime_ ) );
#else
        gettimeofday(&startMicroTime_, NULL);
#endif
    }

    /// Gets volatile time in microseconds
    inline double endVolatileMicroTime()
    {
#ifdef _MSC_VER
        QueryPerformanceCounter( (LARGE_INTEGER*)(&endMicroTime_ ) );
        return (double) ((double)endMicroTime_ * MICRO_DIV - (double)startMicroTime_ * MICRO_DIV);
#else
        return (double) (endMicroTime_.tv_sec * MICRO_DIV + endMicroTime_.tv_usec) -
           (startMicroTime_.tv_sec * MICRO_DIV + startMicroTime_.tv_usec);
        // return (double) (endMicroTime_->tv_sec * 1000000000) + endMicroTime_->tv_nsec) -
           // ((startMicroTime_->tv_sec * 1000000000) + startMicroTime_->tv_nsec);
#endif
    }

    void collectMemoryUsage();

    void addElapsedTime(const QString &name, double value = -1);
    void addOccurrence(const QString &name, int occur);
    // void addUsedSpace(const QString &name, float occur);

    bool saveData();

private:
    Statistic();
    bool saveTimeStatistic();
    bool saveOccurrenceStatistic();

    QMap<QString, QVector<double> *> timeStatistics;
    QMap<QString, QVector<int> *> occurStatistics;

    QElapsedTimer *elapsedTimer, *volatileTimer;

    // Variable for measure time in microseconds
#ifdef _MSC_VER
    __int64 endMicroTime_, startMicroTime_;
#else
    struct timeval endMicroTime_, startMicroTime_;
#endif
};

#endif // STATISTIC_H

// #endif // TME_STATISTIC