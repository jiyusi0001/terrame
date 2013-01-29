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
 \file bridge.h
 \brief The classes Interface and Implementation implements "bridge" design pattern (also known as
        "handle/body idiom").The class Implementation was implemented based on the class teCounted
        writed by Ricardo Cartaxo and Gilberto C�mara and founded in the geographic library TerraLib.
 \author Tiago Garcia de Senna Carneiro
*/

#if ! defined( HANDLE_BODY )
#define HANDLE_BODY

#ifdef DEBUGING
static int numInterfaceCreated = 0;
static int numInterfaceDeleted = 0;
static int numImplementationCreated = 0;
static int numImplementationDeleted = 0;
#endif


/** 
 * \brief
 *
 * The classes Interface and Implementatio implements "bridge" design pattern (also known as
 * "handle/body idiom").
 */
template <class T> 
class Interface
{

public:	

    /// constructor
    Interface<T>( ){
        pImpl_ = new T; pImpl_->attach();
#ifdef DEBUGING
        numInterfaceCreated++;
#endif	
    }

    /// Destructor
    virtual ~Interface<T>(){
        pImpl_->detach();
#ifdef DEBUGING
        numInterfaceDeleted++;
#endif
    }

    /// copy constructor
    Interface<T>( const Interface& interf ):pImpl_( interf.pImpl_ ) {
        pImpl_->attach();
#ifdef DEBUGING
        numInterfaceCreated++;
#endif	

    }

    /// assignment operator
    Interface<T>& operator=( const Interface& interf) {
        if (  this != &interf )
        {
            interf.pImpl_->attach();
            pImpl_->detach();
            pImpl_  = interf.pImpl_;
        }
        return *this;
    }

protected:

    /// refer�ncia para a implementa��o
    T *pImpl_;
};

/**
 * \brief
 *
 * The class Implementation was implemented based on the class teCounted writed by Ricardo Cartaxo
 * and Gilberto C�mara and founded in the geographic library TerraLib.
 */

class Implementation
{	
public:
    /// Constructor: zero references when the object is being built
    Implementation(): refCount_ ( 0 ){
#ifdef DEBUGING		
        numImplementationCreated++;
#endif
    }


    /// Increases the number of references to this object
    void attach ()	{ refCount_++; }

    /// Decreases the number of references to this object.
    /// Destroy it if there are no more references to it
    void detach (){
        if ( --refCount_ == 0 )	{
            delete this;
#ifdef DEBUGING
            numImplementationDeleted++;
#endif
        }
    }

    /// Returns the number of references to this object
    int refCount(){ return refCount_; }

    /// Destructor
    virtual ~Implementation(){}

private:

    /// No copy allowed
    Implementation(const Implementation&);

    /// Implementation
    Implementation& operator=(const Implementation&){return *this;}

    int refCount_; 	/// the number of references to this class

};

#endif
