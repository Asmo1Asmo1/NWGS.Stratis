#include "..\..\globalDefines.h"
#include "garageDefines.h"
//================================================================================================================
//================================================================================================================
//Garage values logic (must work both on server and client)
NWG_GRG_GetGarageArray = {
    // private _player = _this;
    _this getVariable ["NWG_GRG_GarageArray",[]]
};

NWG_GRG_SetGarageArray = {
    params ["_player","_array"];

    //Set new garage array
    private _publicFlag = if (isServer) then {[(owner _player),2]} else {[clientOwner,2]};
    _player setVariable ["NWG_GRG_GarageArray",_array,_publicFlag];

    //Raise event
    if (local _player && {_player isEqualTo player}) then {
        [EVENT_ON_GARAGE_CHANGED,_array] call NWG_fnc_raiseClientEvent;
    };
};

//================================================================================================================
//================================================================================================================
//Convertion actual vehicle <-> garage array
NWG_GRG_VehicleToGarageArray = {
    // private _vehicle = _this;
    private _result = [];

    /*GR_CLASSNAME:*/
    _result pushBack (typeOf _this);

    /*GR_DAMAGE:*/
    private _hitIndexArray = [];
    {
        if (_x > 0.1) then {
            _hitIndexArray pushBack _forEachIndex;
            _hitIndexArray pushBack _x;
        };
    } forEach ((getAllHitPointsDamage _this) param [2,[]]);
    _result pushBack _hitIndexArray;

    /*GR_FUEL:*/
    _result pushBack (fuel _this);

    /*GR_AMMO:*/
    private _totalMaxAmmo = 0;
    private _totalCurAmmo = 0;
    private ["_reverse","_i1","_i2","_i3"];
    {
        _reverse = reverse _x;
        _i1 = _reverse find ")";
        _i2 = _reverse find ["/",_i1];
        _i3 = _reverse find ["(",_i2];
        _totalMaxAmmo = _totalMaxAmmo + (parseNumber (reverse (_reverse select [(_i1+1),(_i2 - _i1 - 1)])));
        _totalCurAmmo = _totalCurAmmo + (parseNumber (reverse (_reverse select [(_i2+1),(_i3 - _i2 - 1)])));
    } forEach (magazinesDetail [_this,true,true]);
    _result pushBack (if (_totalMaxAmmo > 0) then {_totalCurAmmo / _totalMaxAmmo} else {1});

    /*GR_APPEARANCE:*/
    (_this call BIS_fnc_getVehicleCustomization) params ["_colors","_animations"];
    _animations = _animations select {_x isEqualType 1};//Omit strings - they are not changing ("Save 12kb of data"©Sezam)
    _result pushBack [_colors,_animations];

    /*GR_ALLWHEEL:*/
    _result pushBack (_this call NWG_fnc_avAllWheelIsSigned);

    //return
    _result
};

NWG_GRG_ApplyGarageArray = {
    params ["_vehicle","_garageArray"];

    /*GR_DAMAGE:*/
    private _hitIndexArray = _garageArray param [GR_DAMAGE,[]];
    if ((count _hitIndexArray) > 0) then {
        [_vehicle,_hitIndexArray] call NWG_fnc_setHitIndex;
    };

    /*GR_FUEL:*/
    _vehicle setFuel (_garageArray param [GR_FUEL,1]);

    /*GR_AMMO:*/
    _vehicle setVehicleAmmoDef (_garageArray param [GR_AMMO,1]);

    /*GR_APPEARANCE:*/
    (_garageArray param [GR_APPEARANCE,[]]) params [["_colors",[]],["_animationsNumbers",[]]];
    _animationsNumbers = _animationsNumbers + [];//Shallow copy
    (_vehicle call BIS_fnc_getVehicleCustomization) params ["","_animations"];
    private _number = 0;
    {
        if (_x isEqualType "") then {continue};//Skip strings
        _number = _animationsNumbers deleteAt 0;
        if (isNil "_number") then {continue};//Prevent errors
        _animations set [_forEachIndex,_number];
    } forEach _animations;
    [_vehicle,_colors,_animations] call BIS_fnc_initVehicle;

    /*GR_ALLWHEEL:*/
    private _signed = _garageArray param [GR_ALLWHEEL,false];
    if (_signed) then {_vehicle call NWG_fnc_avAllWheelSign};
};
