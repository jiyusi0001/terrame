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
  \file process.h
  \brief This file contains definitions about the TerraME model for represening spatial dynamic processes: Process class.
             It is a empty class!
                 Handles: Process
                 Implementations: ProcessImpl
  \author Tiago Garcia de Senna Carneiro (tiago@dpi.inpe.br)
*/


#if ! defined( PROCESS_H )
#define PROCESS_H

#include "bridge.h"
#include "composite.h"
#include "rule.h"
#include "cell.h"

/**
 * \brief
 *  Implementation for a Process object. It is a empty Implementation!

 *
 */
class ProcessImpl : public Implementation
{
public:


};

/**
 * \brief
 *  Process Handle Type.
 *
 */
typedef Interface<ProcessImpl> ProcessInterf;

/**
 * \brief
 *  JumpCondition Vector Composite Handle Type
 *
 */
typedef CompositeInterface< vectorComposite< JumpCondition*> > JumpCompositeInterf;

/**
 * \brief
 *  FlowCondition Vector Composite Handle Tyoe
 *
 */
typedef CompositeInterface< vectorComposite<FlowCondition*> > FlowCompositeInterf;


/**
 * \brief
 *  Handle for a Process object.
 *
 */
class Process : public ProcessInterf, public JumpCompositeInterf, public FlowCompositeInterf
{
public:

    /// Executes the Rules objets in the order they have been inserted into ControlMode composite. JumpCondition
    /// objects are executed before FlowCondition objects. If a JumpCondition object execution returns true (e.g.
    /// it transits to the targes ControlMode) the FlowCondition objects will be not executued. Runtime Exceptions
    /// are silenced.
    /// \param event is a reference to the Event which linked message has triggered the agent Process execution.
    /// \param agent is a ponter to the Agent being executed
    /// \param cellIndexPair is a pair of CellIndex objects and Cell pointers. The formers are user defined
    ///  n-dimensional coordenates for the latters.
    bool execute( Event &event, class Agent *agent, pair<CellIndex,Cell*> &cellIndexPair )
    {
        try
        {
            bool jumped = false;

            JumpCompositeInterf::iterator jIt;
            jIt = JumpCompositeInterf::pImpl_->begin();
            while( jIt != JumpCompositeInterf::pImpl_->end() )
            {
                if((*jIt)->execute(event, agent, cellIndexPair))
                {
                    jumped = true;
                    break;
                }
                jIt++;
            }

            if( ! jumped )
            {
                FlowCompositeInterf::iterator fIt;
                fIt = FlowCompositeInterf::pImpl_->begin();
                while( fIt != FlowCompositeInterf::pImpl_->end() )
                {
                    (*fIt)->execute(event, agent, cellIndexPair);
                    fIt++;
                }
            }
            else return false;

            return true;
        }
        catch(...){ return true; }
    }



};


#endif
