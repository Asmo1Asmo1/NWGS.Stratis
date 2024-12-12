#include "..\..\globalDefines.h"
/*
    Connector between shopMobile and missionMachine modules
*/

[EVENT_ON_MISSION_STATE_CHANGED,{
    // params ["_oldState","_newState"];
    params ["","_newState"];

    switch (_newState) do {
        case MSTATE_BASE_ECONOMY;
        case MSTATE_BUILD_ECONOMY: {
            //Refresh shop prices
			call NWG_MSHOP_SER_InitPriceMap;
        };
        default {};
    };
}] call NWG_fnc_subscribeToServerEvent;