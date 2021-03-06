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

#ifndef BLACKBOARD_H
#define BLACKBOARD_H

#include <QHash>

class QBuffer;
class QDataStream;
class QByteArray;

class PrivateCache;

namespace TerraMEObserver
{ 
    class Subject;
}


namespace TerraMEObserver
{

/**
 * \brief BlackBoard class for otimization of visualization.
 *
 * The blackboard works like a cache memory and try to otimize the state
 * of a Subject.
 * References: Buschmann, F., Meunier, R., Rohnert, H., Sommerlad, P., and Stal, M. (1996).
 *    \a Pattern-oriented \a software \a architecture: \a a \a system \a of \a patterns. John Wiley & Sons, Inc.
 * \author Antonio Jos� da Cunha Rodrigues
 * \file blackBoard.h
*/
class BlackBoard
{
public:
    /**
     * Destructor
    */
    virtual ~BlackBoard();

    /**
     * Sets the \a dirty-bit for a subject state by their id
     * \param subjectID the unique identifier for a subject
     * \see Subject
     */
    void setDirtyBit(int subjectID);

    /**
     * Gets the \a dirty-bit state for a subject by their id
    */
    bool getDirtyBit(int subjectID) const;

    /**
     * Gets the subject state
     * \param subj a pointer to a subject object
     * \param observerID the unique identifier for a observer
     * \param attribs the list of attributes under observation
     * \return QDataStream a bytestream in serialized format
     * \see Subject, \see Observer
     * \see QDataStream
     */
    QDataStream & getState(TerraMEObserver::Subject *subj, int observerID,
                           QStringList &attribs);

    /**
     * Factory for the BlackBoard object
     * \return reference to the BlackBoard object
     */
    static BlackBoard & getInstance();

private:
    /**
     * Constructor
     */
    BlackBoard();

    QHash<int, PrivateCache *> cache;
};

}
#endif
