//Switch primary<->additional weapon
//note: if there is no additional weapon at the moment, this function will remove the primary weapon and put it into 'additional' slot
//note: effectively, this function will swap the primary and additional weapons
//returns: boolean - true if successful, false if not
NWG_fnc_awSwitchWeapon = {
    call NWG_AW_SwitchWeapon
};

/*Server<->Client*/
//Get holder data
//params: _unit - player object
//returns: array - holder data, empty array if none
NWG_fnc_awGetHolderData = {
    // private _unit = _this;
    if !(_this isEqualType objNull) exitWith {
        "NWG_fnc_awGetHolderData: Invalid unit object" call NWG_fnc_logError;
        []
    };
    if (isNull _this) exitWith {
        "NWG_fnc_awGetHolderData: Unit is null" call NWG_fnc_logError;
        []
    };

    _this call NWG_AW_GetHolderData
};

//Set holder data
//params: _unit - player object, _config - array - holder data
NWG_fnc_awSetHolderData = {
    params ["_unit","_config"];
    if !(_unit isEqualType objNull) exitWith {
        "NWG_fnc_awSetHolderData: Invalid unit object" call NWG_fnc_logError;
    };
    if (isNull _unit) exitWith {
        "NWG_fnc_awSetHolderData: Unit is null" call NWG_fnc_logError;
    };
    if !(_config isEqualType []) exitWith {
        "NWG_fnc_awSetHolderData: Invalid data array" call NWG_fnc_logError;
    };

    _this call NWG_AW_SetHolderData
};

//Create holder object
//params:
//  _unit - player object
//  _config - array - holder config
//returns: holder object on success, 'false' on failure
NWG_fnc_awCreateHolderObject = {
    params ["_unit","_config"];
    _this call NWG_AW_CreateHolderObject
};

//Delete holder object
//params: _unit - player object
NWG_fnc_awDeleteHolderObject = {
    //private _unit = _this;
    _this call NWG_AW_DeleteHolderObject
};

//Add holder data AND create object
//params: _unit - player object, _config - array - holder data
NWG_fnc_awAddHolderDataAndCreateObject = {
    // params ["_unit","_config"];
    _this call NWG_fnc_awSetHolderData;
    _this call NWG_fnc_awCreateHolderObject;
};
