#include "..\..\globalDefines.h"
#include "medicineDefines.h"

//================================================================================================================
//================================================================================================================
//Settings
NWG_MED_SER_Settings = createHashMapFromArray [
    ["BLAME_REPORT_SELFDAMAGE",true],//If true, self-inflicted damage will be reported as well (e.g.: True: 'Joe hit Joe', False: 'Joe is hit')

    ["",0]
];

//================================================================================================================
//================================================================================================================
//Blame handler
NWG_MED_SER_OnBlame = {
    params ["_activeUnit","_passiveUnit","_blame"];
    //Checks
    if (isNull _passiveUnit) exitWith {
        "NWG_MED_SER_OnBlame: Passive unit is null" call NWG_fnc_logError;
    };
    if (_activeUnit isEqualTo _passiveUnit && {!(NWG_MED_SER_Settings get "BLAME_REPORT_SELFDAMAGE")}) then {
        _activeUnit = objNull;
    };

    //Report
    switch (_blame) do {
        case BLAME_VEH_KO: {
            if (isNull _activeUnit)
                then {["#MED_BLAME_VEH_KO_NOBODYS#",(name _passiveUnit)] call NWG_fnc_systemChatAll}
                else {["#MED_BLAME_VEH_KO_DAMAGER#",(name _activeUnit),(name _passiveUnit)] call NWG_fnc_systemChatAll};
        };
        case BLAME_WOUND: {
            if (isNull _activeUnit)
                then {["#MED_BLAME_WOUND_NOBODYS#",(name _passiveUnit)] call NWG_fnc_systemChatAll}
                else {["#MED_BLAME_WOUND_DAMAGER#",(name _activeUnit),(name _passiveUnit)] call NWG_fnc_systemChatAll};
        };
        case BLAME_KILL: {
            if (isNull _activeUnit)
                then {["#MED_BLAME_KILL_NOBODYS#",(name _passiveUnit)] call NWG_fnc_systemChatAll}
                else {["#MED_BLAME_KILL_DAMAGER#",(name _activeUnit),(name _passiveUnit)] call NWG_fnc_systemChatAll};
        };
        default {
            (format ["NWG_MED_SER_OnBlame: Unknown blame type '%1'",_blame]) call NWG_fnc_logError;
        };
    };
};

//================================================================================================================
//================================================================================================================
//Action handler
NWG_MED_SER_OnMedAction = {
    params ["_activeUnit","_passiveUnit","_action"];
    //TODO
};