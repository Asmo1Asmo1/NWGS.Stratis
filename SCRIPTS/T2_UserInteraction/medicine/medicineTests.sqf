#include "medicineDefines.h"

//================================================================================================================
//================================================================================================================
//Units actions
// test1 call NWG_MED_CLI_SetupDebugDummy
NWG_MED_CLI_SetupDebugDummy = {
    // private _unit = _this;
    _this setDamage 0.9;
    _this setUnconscious true;
    _this setCaptive true;
    [_this,true] call NWG_MED_COM_MarkWounded;
    [_this,SUBSTATE_DOWN] call NWG_MED_COM_SetSubstate;
};