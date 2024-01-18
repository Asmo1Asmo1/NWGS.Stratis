#include "..\..\globalDefines.h"

//================================================================================================================
//Settings
#define BUILDINGS_CATALOGUE_ADDRESS "DATASETS\Server\ObjectClassificator\Buildings.sqf"
#define FURNITURE_CATALOGUE_ADDRESS "DATASETS\Server\ObjectClassificator\Furniture.sqf"

//Defines
#define CATEGORY 0
#define FLATTENED 1
#define STRUCTURED 2

//================================================================================================================
//Fields
NWG_OBCL_BuildingsCatalogue = [];
NWG_OBCL_FurnitureCatalogue = [];

//================================================================================================================
//Init
private _Init = {

    private _initCatalogue = {
        params ["_catalogueAddress","_resultCatalogue"];

        //Compile and check validity
        private _rawCatalogue = call (_catalogueAddress call NWG_fnc_compile);
        if (isNil "_rawCatalogue" || {!(_rawCatalogue isEqualType [])}) exitWith {
            (format ["NWG_OBCL_Init: Catalogue '%1' is invalid",_catalogueAddress]) call NWG_fnc_logError;
        };

        //Rearrange catalogue
        for "_i" from 0 to ((count _rawCatalogue)-2) step 2 do {
            private _category = _rawCatalogue param [_i,-1];
            private _entries = _rawCatalogue param [(_i+1),-1];

            //Check validity
            if (isNil "_category" || {!(_category isEqualType "")}) then {
                (format ["NWG_OBCL_Init: Category '%1' of catalogue '%2' at index %3 is invalid",_catalogueAddress,_category,_i]) call NWG_fnc_logError;
                continue;
            };
            if (isNil "_entries" || {!(_entries isEqualType [])}) then {
                (format ["NWG_OBCL_Init: Entries '%1' of catalogue '%2' at index %3 are invalid",_catalogueAddress,_entries,(_i+1)]) call NWG_fnc_logError;
                continue;
            };

            _resultCatalogue pushBack [_category,(flatten _entries),_entries];
        };
    };

    //Init buildings catalogue
    [BUILDINGS_CATALOGUE_ADDRESS,NWG_OBCL_BuildingsCatalogue] call _initCatalogue;
    //Init furniture catalogue
    [FURNITURE_CATALOGUE_ADDRESS,NWG_OBCL_FurnitureCatalogue] call _initCatalogue;
};

//================================================================================================================
//Buldings and Furniture methods

/*
    Annotation:
    As a trade-off between correct DRY+functions approach and intention to eliminate the overhead of creating and unpacking arrays of arguments,
    this time we will use macro 'functions' instead of actual functions. Consider this a manual inlining.
    During the compilation each macro will be replaced with the actual code for each method.
    Note that for macro we had to replace # operator with a 'select' command
*/

#define GET_INDEX_IN_CATALOGUE(ARG,CATALOGUE)\
    private _arg = switch (true) do {\
        case (ARG isEqualType objNull): {typeOf ARG};\
        case (ARG isEqualType ""): {ARG};\
        default {(format ["NWG_OBCL: Unexpected argument '%1'",ARG]) call NWG_fnc_logError; ""};\
    };\
    private _i = CATALOGUE findIf {_arg in (_x select FLATTENED)}\

#define RETURN_CATEGORY(ARG,CATALOGUE)\
    GET_INDEX_IN_CATALOGUE(ARG,CATALOGUE);\
    if (_i == -1) exitWith {""};\
    ((CATALOGUE select _i) select CATEGORY)\

#define RETURN_SAME(ARG,CATALOGUE)\
    GET_INDEX_IN_CATALOGUE(ARG,CATALOGUE);\
    if (_i == -1) exitWith {[]};\
    private _result = {\
        if (_x isEqualType "" && {_arg isEqualTo _x}) exitWith {[_x]};\
        if (_x isEqualType [] && {_arg in _x}) exitWith {_x};\
    } forEach ((CATALOGUE select _i) select STRUCTURED);\
    _result\

NWG_OBCL_IsBuilding = {
    //private _objectOrClassname = _this;
    ((_this call NWG_OBCL_GetBuildingCategory) isNotEqualTo "")
};

NWG_OBCL_GetBuildingCategory = {
    //private _objectOrClassname = _this;
    RETURN_CATEGORY(_this,NWG_OBCL_BuildingsCatalogue)
};

NWG_OBCL_GetSameBuildings = {
    //private _objectOrClassname = _this;
    RETURN_SAME(_this,NWG_OBCL_BuildingsCatalogue)
};

NWG_OBCL_IsFurniture = {
    //private _objectOrClassname = _this;
    ((_this call NWG_OBCL_GetFurnitureCategory) isNotEqualTo "")
};

NWG_OBCL_GetFurnitureCategory = {
    //private _objectOrClassname = _this;
    RETURN_CATEGORY(_this,NWG_OBCL_FurnitureCatalogue)
};

NWG_OBCL_GetSameFurniture = {
    //private _objectOrClassname = _this;
    RETURN_SAME(_this,NWG_OBCL_FurnitureCatalogue)
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