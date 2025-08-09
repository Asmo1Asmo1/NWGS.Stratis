#include "..\..\globalDefines.h"
/*
	Fix NPCs position
	Yeah, that's dirty, but I found no better solution...
*/
[EVENT_ON_MISSION_HEARTBEAT,{
    private ["_posOrig","_dirOrig","_posCur"];
    {
        if (isNull _x || {!alive _x}) exitWith {
            (format ["NWG_MIS_SER_FixNpcPosition: NPC is null or dead: '%1'",_x]) call NWG_fnc_logError;
            NWG_MIS_SER_playerBaseNPCs deleteAt _forEachIndex;
            continue
        };

        _posOrig = _x getVariable "NWG_baseNpcOrigPos";
        _dirOrig = _x getVariable "NWG_baseNpcOrigDir";
        if (isNil "_posOrig" || {isNil "_dirOrig"}) then {
            _posOrig = getPosASL _x;
            _dirOrig = getDir _x;
            _x setVariable ["NWG_baseNpcOrigPos",_posOrig];
            _x setVariable ["NWG_baseNpcOrigDir",_dirOrig];
			continue
        };

        _posCur = getPosASL _x;
        if ((_posOrig distance _posCur) > 0.2) then {
            _x setDir _dirOrig;
            _x setPosASL _posOrig;
        };
    } forEachReversed NWG_MIS_SER_playerBaseNPCs;
}] call NWG_fnc_subscribeToServerEvent;
