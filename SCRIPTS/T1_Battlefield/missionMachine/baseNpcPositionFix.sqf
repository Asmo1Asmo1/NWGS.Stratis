#include "..\..\globalDefines.h"
/*
	Fix NPCs position
	Yeah, that's dirty, but I found no better solution...
*/
[EVENT_ON_MISSION_HEARTBEAT,{
    private ["_posOrig","_posCur"];
    {
        if (isNull _x || {!alive _x}) exitWith {
            (format ["NWG_MIS_SER_FixNpcPosition: NPC is null or dead: '%1'",_x]) call NWG_fnc_logError;
            NWG_MIS_SER_playerBaseNPCs deleteAt _forEachIndex;
            continue
        };

        _posOrig = _x getVariable "NWG_baseNpcOrigPos";
        if (isNil "_posOrig") then {
            _posOrig = getPosASL _x;
            _x setVariable ["NWG_baseNpcOrigPos",_posOrig];
			continue
        };

        _posCur = getPosASL _x;
        if ((_posOrig distance _posCur) > 0.2) then {
            _x setPosASL _posOrig
        };
    } forEachReversed NWG_MIS_SER_playerBaseNPCs;
}] call NWG_fnc_subscribeToServerEvent;
