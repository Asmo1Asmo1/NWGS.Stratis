#include "..\..\globalDefines.h"
/*
    Connector between quests and medicine module
	Specifically for WOUNDED quest type
	note: We use medicine module methods directly, it is not a good practice and should be avoided
*/

//================================================================================================================
//Defines (copied from medicineDefines.h)
/*Wounded sub-state enum*/
#define SUBSTATE_NONE 0
#define SUBSTATE_RAGD 1
#define SUBSTATE_INVH 2
#define SUBSTATE_DOWN 3
#define SUBSTATE_CRWL 4
#define SUBSTATE_HEAL 5
#define SUBSTATE_DRAG 6
#define SUBSTATE_CARR 7

//================================================================================================================
//Set wounded npc
NWG_QST_MC_SetWounded = {
    private _unit = _this;
	if (isNull _unit || {!alive _unit}) exitWith {
		format ["NWG_QST_MC_SetWoundedNPC: Wounded NPC is null or dead. Args: '%1'",_this] call NWG_fnc_logError;
	};
	if !(_unit isKindOf "Man") exitWith {
		format ["NWG_QST_MC_SetWoundedNPC: Wounded NPC is not a man. Args: '%1'",_this] call NWG_fnc_logError;
	};
	if (_unit call NWG_MED_COM_IsWounded) exitWith {
		format ["NWG_QST_MC_SetWoundedNPC: Wounded NPC is already wounded. Args: '%1'",_this] call NWG_fnc_logError;
	};

	//Set wounded state
    _unit setUnconscious true;
    _unit setCaptive true;

	//Mark for medicine module
    [_unit,true] call NWG_MED_COM_MarkWounded;
	[_unit,SUBSTATE_NONE] call NWG_MED_COM_SetSubstate;

    //Run 'bleeding' cycle to update states
    waitUntil {
		//Check if unit is deleted or dead
        if (isNull _unit) exitWith {true};//Exit the loop if deleted
		if (!alive _unit) exitWith {
			[_unit,false] call NWG_MED_COM_MarkWounded;//Prevent any further actions
			true//Exit the loop
		};

        //Check and update substate
        private _substate = _unit call NWG_MED_COM_CalculateSubstate;
        if (_substate isEqualTo SUBSTATE_INVH && {!alive (vehicle _unit)}) then {
            //Fix (im)possible stucking inside burning vehicle
            _unit moveOut (vehicle _unit);
            _substate = SUBSTATE_NONE;
        };
        if ((_unit call NWG_MED_COM_GetSubstate) isNotEqualTo _substate) then {
            [_unit,_substate] call NWG_MED_COM_SetSubstate;
        };

		//Check if unit is brought to base
		if (_unit call NWG_fnc_mmIsPlayerOnBase) exitWith {
			//Define winner and report it
			private _winner = call {
				//Define player who drove him to base
				if ((vehicle _unit) isNotEqualTo _unit && {!isNull (driver (vehicle _unit)) && {isPlayer (driver (vehicle _unit))}}) exitWith {(driver (vehicle _unit))};
				//Define player who carried him to base
				private _allPlayers = call NWG_fnc_getPlayersAll;
				private _i = _allPlayers findIf {(_unit distance _x) < 5};
				if (_i != -1) exitWith {(_allPlayers select _i)};
				//Well, somebody did it, but we don't know who
				objNull
			};
			_winner call NWG_QST_SER_OnQuestDone;
			//Delete unit
			_unit call NWG_fnc_gcDeleteUnit;
			//Exit the loop
			true
		};

        //Repeat
        sleep 0.5;//Should be enough time even if all players returned to base and mission is completing
        false
    };

};

//================================================================================================================

