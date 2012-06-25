#include "cellSpaceSubjectInterf.h"

#include "types/agentObserverMap.h"
#include "types/observerUDPSender.h"
#include "types/agentObserverImage.h"

using namespace TerraMEObserver;

Observer * CellSpaceSubjectInterf::createObserver(TypesOfObservers typeObserver)
{
    Observer* obs = 0;

    switch (typeObserver)
    {
        case TObsMap	:
            obs = new AgentObserverMap(this);
            break;

        case TObsUDPSender	:
            obs = new ObserverUDPSender(this);
            break;

        case TObsImage	:
            obs = new AgentObserverImage(this);
            break;

        default		:
            qFatal("Error: Invalid type '%s'.\n", getObserverName(typeObserver) );
            return 0;
            break;
    }
    return obs;
}

bool CellSpaceSubjectInterf::kill(int id)
{
    Observer * obs = getObserverById(id);
    detach(obs);

    if (! obs)
        return false;

    switch (obs->getType())
    {
        //case TObsLogFile:
        //    ((ObserverLogFile *)obs)->close();
        //    delete (ObserverLogFile *)obs;
        //    break;

        //case TObsTable:
        //    ((ObserverTable *)obs)->close();
        //    delete (ObserverTable *)obs;
        //    break;

        //case TObsGraphic:
        //case TObsDynamicGraphic:
        //    ((ObserverGraphic *)obs)->close();
        //    delete (ObserverGraphic *)obs;
        //    break;

        case TObsUDPSender:
            ((ObserverUDPSender *)obs)->close();
            delete (ObserverUDPSender *)obs;
            break;

            //case TObsTextScreen:
            //    ((ObserverTextScreen *)obs)->close();
            //    delete (ObserverTextScreen *)obs;
            //    break;

        case TObsMap:
            ((AgentObserverMap *)obs)->close();
            delete (AgentObserverMap *)obs;
            break;

        case TObsImage:
            ((AgentObserverImage *)obs)->close();
            delete (AgentObserverImage *)obs;
            break;

        default:
            delete obs;
            break;
    }
    obs = 0;
    return true;
}
