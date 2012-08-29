/************************************************************************************
TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
Copyright � 2001-2008 INPE and TerraLAB/UFOP.

This code is part of the TerraME framework.
This framework is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public
License as published by the Free Software Foundation; either
version 2.1 of the License, or (at your option) any later version.

You should have received a copy of the GNU Lesser General Public
License along with this library.

The authors reassure the license terms regarding the warranties.
They specifically disclaim any warranties, including, but not limited to,
the implied warranties of merchantability and fitness for a particular purpose.
The framework provided hereunder is on an "as is" basis, and the authors have no
obligation to provide maintenance, support, updates, enhancements, or modifications.
In no event shall INPE and TerraLAB / UFOP be held liable to any party for direct,
indirect, special, incidental, or consequential damages arising out of the use
of this library and its documentation.

Author: Tiago Garcia de Senna Carneiro (tiago@dpi.inpe.br)
*************************************************************************************/

/*! 
  \file neighborhood.h
  \brief This file contains definitions about the TerraME model for complex neteworks: CellularSpace class.
                 A Neighborhood object is a weighted directed graph of cells. It has been implemented as composite of cells.
                 It may be use to model spatial proximity, spatial topological relationships, system conectivity,
                 social contact networks, roads, rivers, etc.
                 Handles: CellularSpace
                 Implementations: CellularSpaceImpl
  \author Tiago Garcia de Senna Carneiro (tiago@dpi.inpe.br)
*/


#if ! defined( NEIGHBOURHOOD_H )
#define NEIGHBOURHOOD_H

#include "region.h"

class Cell;

/**
 * \brief
 *  CellIndex Tyoe
 *
 */
typedef pair<int,int> CellIndex;

/**
 * \brief
 *  Implementation for a Neighborhood object.
 *
 */
class CellNeighborhoodImpl : public Implementation
{

    string ID;  ///< Neighboorhood idetifier
    Region_<CellIndex> neighs; ///< a neighborhood it is a region (map) os cell indexes.
    CompositeInterface< mapComposite<CellIndex, double> > weights; ///< the arrows weights are stored in a separeted composite
public:

    typedef Region_<CellIndex>::iterator iterator;

    /// Adds a new neighbor cell to the cells neighborhood map
    /// \param cellIndex is a referento to "CellIndex" with the possible n-dimensional coordenate of the cell
    /// \param cell is a pointer to cell object being added as neighbor
    /// \param weight is double value
    void add(CellIndex& cellIndex, Cell* cell, double weight = 0 )
    {
        pair<CellIndex, double> indexWeightPair;

        indexWeightPair.first  = cellIndex;
        indexWeightPair.second = weight;

        neighs.add( cellIndex, cell);
        weights.add( indexWeightPair );
    }

    /// Removes a cell from the cell neigborhood.
    /// \param cellIndex is a reference to a "CellIndex" with the n-dimensional coordenate of the cell to be excluded.
    bool erase(CellIndex& cellIndex )
    {

        if ( neighs.erase( cellIndex ) && weights.erase(cellIndex) )
            return true;
        else
            return false;
    }

    /// Puts the neighborhood iterator in the beggining of the neighborhood composite.
    /// \return the neighborhood iterator
    iterator begin( void ) { return neighs.begin(); }

    /// Puts the neighborhood iterator in the end of the neighborhood composite.
    /// \return the neighborhood iterator
    iterator end( void ) { return neighs.end(); }

    /// Returns true if the neighbhood composite is empty
    /// \return bool is boolean value: true (empty), false (not empty)
    bool empty( void ) { return neighs.empty(); }

    /// Clears the neighborhood data structure.
    void clear( void ) { neighs.clear(); weights.clear(); }

    /// Returns the number of cells in the neighborhood
    /// \return a integer number
    int  size( void )  { return neighs.size(); }

    /// Searchs for a cell in the neighborhood composite. Similar to the "find" method semantics.
    /// \param i is a CellIndex representing a n-dimensional coordenate
    /// \return a pointer to Cell if it has been found, otherwise a NULL pointer.
    Cell* operator [] ( CellIndex i ) { return neighs[i]; }

    /// Searches for a cell in the neighborhood composite.
    /// \param k is a CellIndex representing a n-dimensional coordenate
    /// \return a pointer to Cell if it has been found, otherwise a NULL pointer.
    iterator find( CellIndex k ) { return neighs.find(k); }

    /// Gets the weigth of a neighboring relationship.
    /// \param cI is the CellIndex reference representing a n-dimensional coordenate
    /// \return a double value
    double getWeight( CellIndex& cI ) { return weights[cI].second; }

    /// Sets the weigth of a neighboring relationship.
    /// \param cI is the CellIndex reference representing a n-dimensional coordenate
    /// \param weight is a double number
    void setWeight( CellIndex& cI, double weight = 0 ) { weights[cI].second = weight; }

    /// Searches for a cell in the neighborhood composite.
    /// \param cI is a CellIndex representing a n-dimensional coordenate
    /// \return a pointer to Cell if it has been found, otherwise a NULL pointer.
    Cell* getNeighbor( CellIndex& cI ) { return neighs[cI]; }


    /// Gets the Neighborhood identifier
    /// \return a string reference to the identifier
    string& getID ( void ) { return ID; }

    /// Sets the Neighborhood identifier
    /// \param id is a reference to a string containing the cell identifier.
    void setID( string &id ) { ID = id; }
};

/**
 * \brief
 *  Neighborhood Handle Tyoe
 *
 */
typedef Interface<CellNeighborhoodImpl> CellNeighInterf;

/**
 * \brief
 *  Handler for a Neighborhood object.
 *
 */
class CellNeighborhood : public CellNeighInterf
{
public:

    typedef CellNeighborhoodImpl::iterator iterator;


    /// HANDLE - Adds a new neighbor cell to the cells neighborhood map
    /// \param cellIndex is a referento to "CellIndex" with the possible n-dimensional coordenate of the cell
    /// \param cell is a pointer to cell object being added as neighbor
    /// \param weight is double value
    void add(CellIndex& cellIndex, Cell* cell, double weight = 0 )
    { CellNeighInterf::pImpl_->add( cellIndex, cell, weight ); }

    /// HANDLE - Removes a cell from the cell neigborhood.
    /// \param cellIndex is a reference to a "CellIndex" with the n-dimensional coordenate of the cell to be excluded.
    bool erase(CellIndex& cellIndex ) { return CellNeighInterf::pImpl_->erase( cellIndex ); }

    /// HANDLE - Gets the weigth of a neighboring relationship.
    /// \param cI is the CellIndex reference representing a n-dimensional coordenate
    /// \return a double value
    double getWeight( CellIndex& cI ) { return CellNeighInterf::pImpl_->getWeight( cI ); }

    /// HANDLE - Sets the weigth of a neighboring relationship.
    /// \param cI is the CellIndex reference representing a n-dimensional coordenate
    /// \param weight is a double number
    void setWeight( CellIndex& cI, double weight = 0 ) { CellNeighInterf::pImpl_->setWeight( cI, weight ); }
    
    /// HANDLE - Searches for a cell in the neighborhood composite.
    /// \param cI is a CellIndex representing a n-dimensional coordenate
    /// \return a pointer to Cell if it has been found, otherwise a NULL pointer.
    Cell* getNeighbor( CellIndex& cI ) { return CellNeighInterf::pImpl_->getNeighbor( cI ); }

    /// HANDLE - Returns true if the neighbhood composite is empty
    /// \return bool is boolean value: true (empty), false (not empty)
    bool empty( void ) { return CellNeighInterf::pImpl_->empty(); }

    /// HANDLE - Clears the neighborhood data structure.
    void clear( void ) { CellNeighInterf::pImpl_->clear(); }

    /// HANDLE - Returns the number of cells in the neighborhood
    /// \return a integer number
    int  size( void )  { return CellNeighInterf::pImpl_->size(); }

    /// HANDLE - Searchs for a cell in the neighborhood composite. Similar to the "find" method semantics.
    /// \param i is a CellIndex representing a n-dimensional coordenate
    /// \return a pointer to Cell if it has been found, otherwise a NULL pointer.
    Cell* operator [] ( CellIndex i ) { return (*CellNeighInterf::pImpl_)[i]; }

    /// HANDLE - Puts the neighborhood iterator in the beggining of the neighborhood composite.
    /// \return the neighborhood iterator
    iterator begin( void ) { return CellNeighInterf::pImpl_->begin(); }

    /// HANDLE - Puts the neighborhood iterator in the end of the neighborhood composite.
    /// \return the neighborhood iterator
    iterator end( void ) { return CellNeighInterf::pImpl_->end(); }

    /// HANDLE - Searches for a cell in the neighborhood composite.
    /// \param k is a CellIndex representing a n-dimensional coordenate
    /// \return a pointer to Cell if it has been found, otherwise a NULL pointer.
    iterator find( CellIndex k ) { return CellNeighInterf::pImpl_->find(k); }

    /// HANDLE - Gets the Neighborhood identifier
    /// \return a string reference to the identifier
    string& getID ( void ) { return CellNeighInterf::pImpl_->getID(); }

    /// HANDLE - Sets the Neighborhood identifier
    /// \param id is a reference to a string containing the cell identifier.
    void setID( string &id ) { CellNeighInterf::pImpl_->setID(id); }

};
#endif
