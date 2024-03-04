#include "..\..\globalDefines.h"

//================================================================================================================
//Settings
NWG_OBCL_Settings = createHashMapFromArray [
    ["BUILDINGS_CATALOGUE_ADDRESS","DATASETS\Server\ObjectClassificator\Buildings.sqf"],
    ["FURNITURE_CATALOGUE_ADDRESS","DATASETS\Server\ObjectClassificator\Furniture.sqf"],

    ["",0]
];

//================================================================================================================
//Fields
NWG_OBCL_BuildingsCatalogue = createHashMap;
NWG_OBCL_FurnitureCatalogue = createHashMap;

//================================================================================================================
//Init
private _Init = {

    private _initCatalogue = {
        params ["_catalogueAddress","_resultCatalogue"];

        //Compile initial catalogue
        private _rawCatalogue = call (_catalogueAddress call NWG_fnc_compile);
        if (isNil "_rawCatalogue" || {!(_rawCatalogue isEqualType [])}) exitWith {
            (format ["NWG_OBCL_Init: Catalogue '%1' is invalid",_catalogueAddress]) call NWG_fnc_logError;
        };

        //Rearrange into a more efficient structure
        private ["_category","_entries","_same"];
        for "_i" from 0 to ((count _rawCatalogue)-2) step 2 do {
            _category = _rawCatalogue param [_i,-1];
            _entries  = _rawCatalogue param [(_i+1),-1];
            if (!(_category isEqualType "") || {!(_entries isEqualType [])}) then {
                (format ["NWG_OBCL_Init: Defective record in %1:%2 cat:%3 ent:%4",_catalogueAddress,_i,_category,_entries]) call NWG_fnc_logError;
                continue;
            };
            {
                //It's either a string (one of a kind) or an array of strings (same objects with different textures and classnames)
                _same = if (_x isEqualType "") then {[_x]} else {_x};
                {_resultCatalogue set [_x,[_category,_same]]} forEach _same;
            } forEach _entries;
        };
    };

    [(NWG_OBCL_Settings get "BUILDINGS_CATALOGUE_ADDRESS"),NWG_OBCL_BuildingsCatalogue] call _initCatalogue;
    [(NWG_OBCL_Settings get "FURNITURE_CATALOGUE_ADDRESS"),NWG_OBCL_FurnitureCatalogue] call _initCatalogue;
};

//================================================================================================================
//Buldings and Furniture methods
#define CATEGORY 0
#define SAME 1

#define GET_CLASSNAME(ARG)\
    private _classname = switch (true) do {\
        case (ARG isEqualType objNull): {typeOf ARG};\
        case (ARG isEqualType ""): {ARG};\
        default {(format ["NWG_OBCL: Unexpected argument '%1'",ARG]) call NWG_fnc_logError; ""};\
    };\

NWG_OBCL_IsBuilding = {
    //private _objectOrClassname = _this;
    GET_CLASSNAME(_this);
    //return
    _classname in NWG_OBCL_BuildingsCatalogue
};

NWG_OBCL_GetBuildingCategory = {
    //private _objectOrClassname = _this;
    GET_CLASSNAME(_this);
    //return
    (NWG_OBCL_BuildingsCatalogue getOrDefault [_classname,[]]) param [CATEGORY,""]
};

NWG_OBCL_GetSameBuildings = {
    //private _objectOrClassname = _this;
    GET_CLASSNAME(_this);
    //return
    (NWG_OBCL_BuildingsCatalogue getOrDefault [_classname,[]]) param [SAME,[]]
};

NWG_OBCL_IsFurniture = {
    //private _objectOrClassname = _this;
    GET_CLASSNAME(_this);
    //return
    _classname in NWG_OBCL_FurnitureCatalogue
};

NWG_OBCL_GetFurnitureCategory = {
    //private _objectOrClassname = _this;
    GET_CLASSNAME(_this);
    //return
    (NWG_OBCL_FurnitureCatalogue getOrDefault [_classname,[]]) param [CATEGORY,""]
};

NWG_OBCL_GetSameFurniture = {
    //private _objectOrClassname = _this;
    GET_CLASSNAME(_this);
    //return
    (NWG_OBCL_FurnitureCatalogue getOrDefault [_classname,[]]) param [SAME,[]]
};

//================================================================================================================
//Object methods
NWG_OBCL_IsUnit = {
    // private _object = _this;
    _this isKindOf "Man"
};

NWG_OBCL_IsVehicle = {
    // private _object = _this;
    (_this isKindOf "Car"        ||
    {_this isKindOf "Tank"       ||
    {_this isKindOf "Helicopter" ||
    {_this isKindOf "Plane"      ||
    {_this isKindOf "Ship"}}}})
};

NWG_OBCL_IsTurret = {
    // private _object = _this;
    _this isKindOf "StaticWeapon"
};

NWG_OBCL_IsMine = {
    // private _object = _this;
    _this isKindOf "TimeBombCore"
};

//================================================================================================================
//Hub method
NWG_OBCL_GetObjectType = {
    // private _object = _this;
    if (!(_this isEqualType objNull)) exitWith {
        (format ["NWG_OBCL_GetObjectType: Unexpected argument '%1'",_this]) call NWG_fnc_logError;
        ""
    };

    //Order is defined on probability of occurence and execution speed
    switch (true) do {
        case (_this call NWG_OBCL_IsUnit):     {OBJ_TYPE_UNIT};
        case (_this call NWG_OBCL_IsTurret):   {OBJ_TYPE_TRRT};
        case (_this call NWG_OBCL_IsMine):     {OBJ_TYPE_MINE};
        case (_this call NWG_OBCL_IsVehicle):  {OBJ_TYPE_VEHC};
        case (_this call NWG_OBCL_IsBuilding): {OBJ_TYPE_BLDG};
        case (_this call NWG_OBCL_IsFurniture):{OBJ_TYPE_FURN};
        default {OBJ_TYPE_DECO};
    }
};

//================================================================================================================
//Post-Init
call _Init;