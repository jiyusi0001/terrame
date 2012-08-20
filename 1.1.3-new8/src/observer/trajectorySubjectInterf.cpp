#include "trajectorySubjectInterf.h"

#include "types/agentObserverMap.h"
#include "types/observerUDPSender.h"
#include "types/agentObserverImage.h"

using namespace TerraMEObserver;

Observer * TrajectorySubjectInterf::createObserver(TypesOfObservers typeObserver)
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

bool TrajectorySubjectInterf::kill(int id)
{
    Observer * obs = getObserverById(id);
    detach(obs);

    if (! obs)
        return false;

    // if ((obs->getObserverType() != TObsMap) && (obs->getObserverType() != TObsImage)) 
    //     detachObserver(obs);

    switch (obs->getType())
    {
        case TObsUDPSender:
            ((ObserverUDPSender *)obs)->close();
            delete (ObserverUDPSender *)obs;
            break;

        //case TObsMap:
        //    ((AgentObserverMap *)obs)->unregistry(this);
        //    break;

        //case TObsImage:
        //    ((AgentObserverImage *)obs)->unregistry(this);
        //    break;

        default:
            delete obs;
            break;
    }
    return true;
}


