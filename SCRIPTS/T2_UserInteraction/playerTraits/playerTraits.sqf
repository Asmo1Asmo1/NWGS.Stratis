//================================================================================================================
//================================================================================================================
//Settings
NWG_TRAITS_Settings = createHashMapFromArray [
    //TODO: Add later

    ["",0]
];

//================================================================================================================
//================================================================================================================
//Init
private _Init = {
    player addEventHandler ["Respawn",{call NWG_TRAITS_OnPlayerSpawn}];
    call NWG_TRAITS_OnPlayerSpawn;
};

//TODO: Replace hardcoded values with settings
NWG_TRAITS_OnPlayerSpawn = {
    player enableStamina false;
    player setCustomAimCoef 0.5;

    player setUnitTrait ["engineer",false];
    player setUnitTrait ["explosiveSpecialist",true];
    player setUnitTrait ["medic",true];
    player setUnitTrait ["UAVHacker",true];
    player setUnitTrait ["audibleCoef", 0.5];
    player setUnitTrait ["camouflageCoef", 0.5];
};

//================================================================================================================
//================================================================================================================
call _Init