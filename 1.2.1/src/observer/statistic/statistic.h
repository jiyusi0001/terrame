/************************************************************************************
* TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
* Copyright � 2001-2012 INPE and TerraLAB/UFOP.
*
* This code is part of the TerraME framework.
* This framework is free software; you can redistribute it and/or
* modify it under the terms of the GNU Lesser General Public
* License as published by the Free Software Foundation; either
* version 2.1 of the License, or (at your option) any later version.
*
* You should have received a copy of the GNU Lesser General Public
* License along with this library.
*
* The authors reassure the license terms regarding the warranties.
* They specifically disclaim any warranties, including, but not limited to,
* the implied warranties of merchantability and fitness for a particular purpose.
* The framework provided hereunder is on an "as is" basis, and the authors have no
* obligation to provide maintenance, support, updates, enhancements, or modifications.
* In no event shall INPE and TerraLAB / UFOP be held liable to any party for direct,
* indirect, special, incidental, or consequential damages arising out of the use
* of this library and its documentation.
*
*************************************************************************************/

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
    /**
     * Factory for Statistic
     * \return a reference this object
     */
    static Statistic& getInstance();

    /**
     * Destructor
     */
    virtual ~Statistic();

    /**
     * Gets the start time in miliseconds
     * \return double the start time
     */
    inline double startTime()
    {
        return elapsedTimer->elapsed() * 1.0;
    }

    /**
     * Gets the end time in miliseconds
     * \return double the end time
     */
    inline double endTime()
    {
        return elapsedTimer->elapsed() * 1.0;
    }

    /**
     * Gets the start time in microseconds
     * \return double the start time
     */
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

    /**
     * Gets the end time in microseconds
     * \return double the end time
     */
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

    /**
     * Start the volatile time in miliseconds
     */
    inline void startVolatileTime()
    {
        volatileTimer->start();
    }

    /**
     * Gets elapsed volatile time in miliseconds
     * \return float the elapsed time
     */
    inline float endVolatileTime()
    {
        return volatileTimer->elapsed() * 1.0;
    }

    /**
     * Start the volatile time in microseconds
     */
    inline void startVolatileMicroTime()
    {
#ifdef _MSC_VER
        QueryPerformanceCounter( (LARGE_INTEGER*)(&startMicroTime_ ) );
#else
        gettimeofday(&startMicroTime_, NULL);
#endif
    }

    /**
     * Gets the elapsed volatile time in microseconds
     * \return double the elapsed time
     */
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

    /**
     * Collects the memory usage using the \a "pslist.exe" application and saves it in the
     * file \a "output_MemoryUsage.txt" inside the application directory.
     * \sa http://technet.microsoft.com/en-us/sysinternals/bb795533
     */
    void collectMemoryUsage();

    /**
     * Adds the elapsed time for the method \a name
     * \param name a reference to a method name
     * \param value a value to the elapsed time
     */
    void addElapsedTime(const QString &name, double value = -1);

    /**
     * Adds the occurrence to a specific item called \a name
     * \param name a reference to an item name
     * \param occur an occurrence of an item
     */
    void addOccurrence(const QString &name, int occur);

    /**
     * Saves the statistic information in the file
     * \return boolean, if \a true the file was saved. Otherwise, the file was not saved.
     */
    bool saveData();

private:
    /**
     * Constructor
     */
    Statistic();

    /**
     * Saves the statistic of time
     */
    bool saveTimeStatistic();

    /**
     * Saves the statistic of occurrence
     */
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
