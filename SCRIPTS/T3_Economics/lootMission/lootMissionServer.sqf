#include "..\..\globalDefines.h"

//================================================================================================================
//================================================================================================================
//Defines
#define TAG_ANYFAC "ANYFAC"
#define TAG_ANYVEH "ANYVEH"
#define TAG_ANYBOX "ANYBOX"

#define TAG_CAR "CAR"
#define TAG_AIR "AIR"
#define TAG_ARM "ARM"
#define TAG_BOAT "BOAT"

#define TAG_LOOT "LOOT"
#define TAG_WEAP "WEAP"
#define TAG_RUG "RUG"
#define TAG_MED "MED"

#define SET_TAGS 0
#define SET_TIER 1
#define SET_ITEMS 2

//================================================================================================================
//================================================================================================================
//Settings
NWG_LM_SER_Settings = createHashMapFromArray [
    ["CATALOGUE_PATH_VANILLA","DATASETS\Server\LootMission\_Vanilla.sqf"],//Path to vanilla loot catalogue
    ["CATALOGUE_COMPILE_ON_INIT",false],//If true, catalogue will be compiled on init, otherwise you should call NWG_fnc_lmCompileCatalogue
    ["CATALOGUE_MAX_TIER",4],//If max rarity in catalogue is 3, then this value should be 4

/*
    Set types and their filling rules
    Monosets
    Clth only	1-2-3 items (1-1-2 each)
    Weap only	2-2-3 items (1 each)
    Items only	2-2-3-4 items (1-1-2-3 each)
    Ammo only	2-3-4-5 items (5-6-8-10 each)
    Mixed sets
    Clth w items	1-2 clth (1-1-2 each), 1 item (1-1-2 each) [Scuba Diver set]
    Items w ammo	1-2 items (1-1-2 each), 1 ammo (5-6-8-10 each) [Laser designators and batteries]
    Weap w items	1-1-2 weap (1 each), 1-1-2 items (1 each) [Drones with terminals]
    Weap w ammo	1-1-2 weap (1 each), 1-2-3 ammo (5-6-8-10 each)
    Weap full	1-1-2 weap (1 each), 1-2-3 items (1-1-2 each), 1-2-3 ammo (5-6-8-10 each)
*/
    ["LOOT_MONO_CLTH", [/*CLTH*/[[1,2,3],[1,1,2]], [], [], []      ]],
    ["LOOT_MONO_WEAP", [[], /*WEAP*/[[2,2,3],[1]], [], []          ]],
    ["LOOT_MONO_ITEM", [[], [], /*ITEMS*/[[2,2,3,4],[1,1,2,3]], [] ]],
    ["LOOT_MONO_AMMO", [[], [], [], /*AMMO*/[[2,3,4,5],[5,6,8,10]] ]],

    ["LOOT_MIX_CLTH_W_ITEMS", [
        [[1,2],[1,1,2]],    // clothes
        [],                 // weapons
        [[1],[1,1,2]],      // items
        []                  // ammo
    ]],
    ["LOOT_MIX_ITEMS_W_AMMO", [
        [],                 // clothes
        [],                 // weapons
        [[1,1,2],[1]],      // items
        [[1,2],[1,2,4,5]]   // ammo
    ]],
    ["LOOT_MIX_WEAP_W_ITEMS", [
        [],                 // clothes
        [[1,1,2],[1]],      // weapons
        [[1,1,2],[1]],      // items
        []                  // ammo
    ]],
    ["LOOT_MIX_WEAP_W_AMMO", [
        [],                 // clothes
        [[1,1,2],[1]],      // weapons
        [],                 // items
        [[1,2,3],[5,6,8,10]]// ammo
    ]],
    ["LOOT_MIX_WEAP_W_ITEMS_AND_AMMO", [
        [],                 // clothes
        [[1,1,2],[1]],      // weapons
        [[1,2,3],[1,1,2]],  // items
        [[1,2,3],[5,6,8,10]]// ammo
    ]],

    ["LOOT_DEFAULT", [
        [[1,2,3],[1,2,3]],  // clothes
        [[1,2,3],[1,2,3]],  // weapons
        [[1,2,3],[1,2,3]],  // items
        [[1,2,3],[2,4,6]]   // ammo
    ]],

/*
    Vehicles and containers set probabilities
    Vehicles
    CAR	2-3-4 sets	Cars, trucks, etc.
    AIR	1-2-2-3 sets	Planes and helicopters
    ARM	2-3-4 sets	Tanks and APCs
    BOAT	1-2-2-3 sets	Boats
    Containers
    LOOT	1-2-3 sets	Loot box
    WEAP	1-2-3 sets	Weapon box
    RUG	0-1-1-2 sets	Rug. container
    MED	1-1-2 sets	Med. container
*/
    /*Vehicle containers*/
    ["VEH_CAR_SETS_COUNTS",  [2,3,4]],  // Cars
    ["VEH_TRK_SETS_COUNTS",  [3,3,4]],  // Trucks
    ["VEH_AIR_SETS_COUNTS",  [1,2,2,3]],// Planes and helicopters
    ["VEH_ARM_SETS_COUNTS",  [2,3,4]],  // Tanks and APCs
    ["VEH_BOAT_SETS_COUNTS", [1,2,2,3]],// Boats

    /*Static containers*/
    ["CONT_LOOT_SETS_COUNTS", [1,2,3]],  // Loot box
    ["CONT_WEAP_SETS_COUNTS", [1,2,3]],  // Weapon box
    ["CONT_RUG_SETS_COUNTS",  [0,1,1,2]],// Rugged container
    ["CONT_MED_SETS_COUNTS",  [1,1,2]],  // Medical container

/*
    Container object types
*/
    ["CONT_LOOT_TYPES",[
        "Box_IND_Ammo_F",
        "Box_T_East_Ammo_F",
        "Box_East_Ammo_F",
        "Box_EAF_Ammo_F",
        "Box_NATO_Ammo_F",
        "Box_IND_AmmoOrd_F",
        "Box_East_AmmoOrd_F",
        "Box_IDAP_AmmoOrd_F",
        "Box_EAF_AmmoOrd_F",
        "Box_NATO_AmmoOrd_F",
        "Box_IND_Grenades_F",
        "Box_East_Grenades_F",
        "Box_EAF_Grenades_F",
        "Box_NATO_Grenades_F",
        "Box_IND_Support_F",
        "Box_East_Support_F",
        "Box_EAF_Support_F",
        "Box_NATO_Support_F"
    ]],
    ["CONT_WEAP_TYPES",[
        "Box_IND_Wps_F",
        "Box_T_East_Wps_F",
        "Box_East_Wps_F",
        "Box_EAF_Wps_F",
        "Box_T_NATO_Wps_F",
        "Box_NATO_Wps_F"
    ]],
    ["CONT_RUG_TYPES",[
        "Land_PortableCabinet_01_4drawers_black_F",
        "Land_PortableCabinet_01_7drawers_black_F",
        "Land_PortableCabinet_01_4drawers_olive_F",
        "Land_PortableCabinet_01_7drawers_olive_F",
        "Land_PortableCabinet_01_4drawers_sand_F",
        "Land_PortableCabinet_01_7drawers_sand_F"
    ]],
    ["CONT_MED_TYPES",[
        "Land_PortableCabinet_01_medical_F"
    ]],

    ["",0]
];

//================================================================================================================
//================================================================================================================
//Fields
NWG_LM_SER_lootCatalogue = [];
NWG_LM_SER_setsEnrichment = 0;
NWG_LM_SER_itemEnrichment = 0;
NWG_LM_SER_maxTier = 4;

//================================================================================================================
//================================================================================================================
//Init
private _Init = {
    if (NWG_LM_SER_Settings get "CATALOGUE_COMPILE_ON_INIT") then {
        call NWG_LM_SER_CompileCatalogue;
    };
};

//================================================================================================================
//================================================================================================================
//Catalogue compilation
NWG_LM_SER_CompileCatalogue = {
    //Check if already compiled
    if !(NWG_LM_SER_lootCatalogue isEqualTo []) exitWith {
        "NWG_LM_SER_CompileCatalogue: Catalogue already compiled" call NWG_fnc_logError;
        false
    };

    //Compile raw data
    private _filePath = NWG_LM_SER_Settings get "CATALOGUE_PATH_VANILLA";
    private _catalogueRaw = call (_filePath call NWG_fnc_compile);
    if (isNil "_catalogueRaw" || {!(_catalogueRaw isEqualType [])}) exitWith {
        (format ["NWG_LM_SER_CompileCatalogue: Failed to compile catalogue: '%1'",_filePath]) call NWG_fnc_logError;
        false
    };

    //Repack according to tier
    private _catalogue = [];
    private _maxCount = (NWG_LM_SER_Settings get "CATALOGUE_MAX_TIER") + 1;
    {
        for "_i" from 1 to ((_maxCount - (_x#SET_TIER)) max 1) do {_catalogue pushBack _x};
    } forEach _catalogueRaw;

    //Shuffle catalogue
    _catalogue = _catalogue call NWG_fnc_arrayShuffle;

    //Save and return
    NWG_LM_SER_lootCatalogue = _catalogue;
    true
};

//================================================================================================================
//================================================================================================================
//Configure future loot filling
NWG_LM_SER_Configure = {
	params [["_setEnrichment",0],["_itemEnrichment",0],["_maxTier",10]];
    NWG_LM_SER_setsEnrichment = _setEnrichment;
    NWG_LM_SER_itemEnrichment = _itemEnrichment;
    NWG_LM_SER_maxTier = _maxTier;
    true
};

//================================================================================================================
//================================================================================================================
//Generate loot set(s)
NWG_LM_SER_GenerateLootSet = {
    params [["_faction",""],["_containerTag",""],["_setsCount",1],["_enrichment",NWG_LM_SER_itemEnrichment],["_maxTier",NWG_LM_SER_maxTier]];

    //Get catalogue to select from
    if (NWG_LM_SER_lootCatalogue isEqualTo [] && {(call NWG_LM_SER_CompileCatalogue) isEqualTo false}) exitWith {
        (format ["NWG_LM_SER_GenerateLootSet: Failed to compile catalogue"]) call NWG_fnc_logError;
        false
    };
    private _catalogue = NWG_LM_SER_lootCatalogue;
    private _factionFilter = switch (true) do {
        case (_faction isEqualTo ""): {{true}};
        case (_faction isEqualTo TAG_ANYFAC): {{true}};
        default {{
            if (TAG_ANYFAC in (_this#SET_TAGS) && {!(("-"+_faction) in (_this#SET_TAGS))}) exitWith {true};
            if (_faction in (_this#SET_TAGS)) exitWith {true};
            false
        }};
    };
    private _containerFilter = switch (true) do {
        case (_containerTag isEqualTo ""): {{true}};
        case (_containerTag in [TAG_CAR,TAG_AIR,TAG_ARM,TAG_BOAT]) : {{TAG_ANYVEH in (_this#SET_TAGS) || {_containerTag in (_this#SET_TAGS)}}};
        case (_containerTag in [TAG_LOOT,TAG_WEAP,TAG_RUG,TAG_MED]): {{TAG_ANYBOX in (_this#SET_TAGS) || {_containerTag in (_this#SET_TAGS)}}};
        default {{_containerTag in (_this#SET_TAGS)}};
    };
    private _tierFilter = {(_this#SET_TIER) <= _maxTier};
    _catalogue = _catalogue select {(_x call _factionFilter) && {(_x call _containerFilter) && {(_x call _tierFilter)}}};

    //Iterate and fill sets
    private _result = LOOT_ITEM_DEFAULT_CHART;
    private ["_setType","_setRules","_itemsProb","_countProb"];
    for "_i" from 1 to _setsCount do {
        //Select random set and define its type
        (selectRandom _catalogue) params ["_setTags","","_setItems"];
        _setType = 0;
        {if ((count _x) > 0) then {_setType = _setType + (2 ^ _forEachIndex)}} forEach _setItems;//Binary flags encoding

        //Select rules
        _setRules = switch (_setType) do {
            /*Monosets*/
            case 1:  {NWG_LM_SER_Settings get "LOOT_MONO_CLTH"};
            case 2:  {NWG_LM_SER_Settings get "LOOT_MONO_WEAP"};
            case 4:  {NWG_LM_SER_Settings get "LOOT_MONO_ITEM"};
            case 8:  {NWG_LM_SER_Settings get "LOOT_MONO_AMMO"};
            /*Mixed sets*/
            case 5:  {NWG_LM_SER_Settings get "LOOT_MIX_CLTH_W_ITEMS"};
            case 12: {NWG_LM_SER_Settings get "LOOT_MIX_ITEMS_W_AMMO"};
            case 6:  {NWG_LM_SER_Settings get "LOOT_MIX_WEAP_W_ITEMS"};
            case 10: {NWG_LM_SER_Settings get "LOOT_MIX_WEAP_W_AMMO"};
            case 14: {NWG_LM_SER_Settings get "LOOT_MIX_WEAP_W_ITEMS_AND_AMMO"};
            /*Unexpected set type*/
            default {
                (format ["NWG_LM_SER_GenerateLootSet: Unexpected set type: %1, set tags to find it: %2",_setType,_setTags]) call NWG_fnc_logError;
                NWG_LM_SER_Settings get "LOOT_DEFAULT"
            };
        };

        //Fill by rules
        {
            if ((count (_setRules#_x)) == 0) then {continue};
            if ((count (_setItems#_x)) == 0) then {continue};

            _itemsProb = (_setRules#_x)#0;
            _countProb = (_setRules#_x)#1;

            if (_enrichment != 0) then {
                _itemsProb = [_itemsProb,_enrichment] call NWG_LM_SER_ApplyEnrichment;
            };

            //I've tested and seems like 'to (selectRandom ...)' is evaluated only once, so it is safe to use it that way
            for "_j" from 1 to (selectRandom _itemsProb) do {
                (_result#_x) pushBack (selectRandom _countProb);
                (_result#_x) pushBack (selectRandom (_setItems#_x));
            };
        } forEach [
            LOOT_ITEM_CAT_CLTH,
            LOOT_ITEM_CAT_WEAP,
            LOOT_ITEM_CAT_ITEM,
            LOOT_ITEM_CAT_AMMO
        ];
    };

    //Repack result in case there were duplicates or zero counts or something
    {(_x call NWG_fnc_unCompactStringArray) call NWG_fnc_compactStringArray} forEach _result;

    //return
    _result
};

//[[2,3,4,5],-1] -> [1,2,3,4]
//[[1,1,2,3],-1] -> [1,1,1,2]
NWG_LM_SER_ApplyEnrichment = {
    params ["_probabilities","_enrichment"];
    private _result = _probabilities + [];//Shallow copy
    private _min = if ((_result param [0,0]) > 0) then {1} else {0};

    {
        _result set [_forEachIndex,((_x + _enrichment) max _min)];
        _min = _x;
    } forEach _result;

    //return
    _result
};

//================================================================================================================
//================================================================================================================
//Objects filling
NWG_LM_SER_FillObject = {
    params ["_object","_lootSet"];
    _object call NWG_fnc_clearContainerCargoGlobal;//Clear object
    [_object,(flatten _lootSet)] call NWG_fnc_fillContainerCargoGlobal;//Fill object
};

NWG_LM_SER_FillContainers = {
    params [["_faction",""],["_containers",[]],["_setsEnrichment",NWG_LM_SER_setsEnrichment],["_itemEnrichment",NWG_LM_SER_itemEnrichment],["_maxTier",NWG_LM_SER_maxTier]];

    private _result = [];
    private ["_type","_tag","_counts","_count","_lootSet"];
    //foreach container
    {
        //Define container type, tags and counts
        _type = typeOf _x;
        switch (true) do {
            case (_type in (NWG_LM_SER_Settings get "CONT_LOOT_TYPES")): {_tag = TAG_LOOT; _counts = NWG_LM_SER_Settings get "CONT_LOOT_SETS_COUNTS"};
            case (_type in (NWG_LM_SER_Settings get "CONT_WEAP_TYPES")): {_tag = TAG_WEAP; _counts = NWG_LM_SER_Settings get "CONT_WEAP_SETS_COUNTS"};
            case (_type in (NWG_LM_SER_Settings get "CONT_RUG_TYPES")) : {_tag = TAG_RUG;  _counts = NWG_LM_SER_Settings get "CONT_RUG_SETS_COUNTS"};
            case (_type in (NWG_LM_SER_Settings get "CONT_MED_TYPES")) : {_tag = TAG_MED;  _counts = NWG_LM_SER_Settings get "CONT_MED_SETS_COUNTS"};
            default {continue};//<== Safely ignore unexpected objects
        };

        //Apply enrichment if needed
        if (_setsEnrichment != 0) then {
            _counts = [_counts,_setsEnrichment] call NWG_LM_SER_ApplyEnrichment;
        };

        //Select random count
        _count = selectRandom _counts;
        if (_count == 0) then {
            _x call NWG_fnc_clearContainerCargoGlobal;
            continue;//<== Bad luck, clear and skip this container
        };

        //Generate loot set
        _lootSet = [_faction,_tag,_count,_itemEnrichment,_maxTier] call NWG_LM_SER_GenerateLootSet;
        if (_lootSet isEqualTo false) then {
            (format ["NWG_LM_SER_FillContainers: Failed to generate loot set for: %1",[_faction,_tag,_count,_itemEnrichment]]) call NWG_fnc_logError;
            _x call NWG_fnc_clearContainerCargoGlobal;
            continue;//<== Error, clear and skip this container
        };

        //Fill container
        [_x,_lootSet] call NWG_LM_SER_FillObject;
        _result pushBack _x;
    } forEach _containers;

    //return
    _result
};

NWG_LM_SER_FillVehicles = {
    params [["_faction",""],["_vehicles",[]],["_setsEnrichment",NWG_LM_SER_setsEnrichment],["_itemEnrichment",NWG_LM_SER_itemEnrichment],["_maxTier",NWG_LM_SER_maxTier]];

    private ["_tag","_counts","_count","_lootSet"];
    //foreach vehicle
    {
        //Define vehicle tag and counts
        switch true do {
            case (_x isKindOf "Tank"):          {_tag = TAG_ARM;  _counts = NWG_LM_SER_Settings get "VEH_ARM_SETS_COUNTS"};
            case (_x isKindOf "Wheeled_APC_F"): {_tag = TAG_ARM;  _counts = NWG_LM_SER_Settings get "VEH_ARM_SETS_COUNTS"};//Just count it as armoured vehicle here
            case (_x isKindOf "Air"):           {_tag = TAG_AIR;  _counts = NWG_LM_SER_Settings get "VEH_AIR_SETS_COUNTS"};
            case (_x isKindOf "Ship"):          {_tag = TAG_BOAT; _counts = NWG_LM_SER_Settings get "VEH_BOAT_SETS_COUNTS"};
            case ((getMass _x) > 10000):        {_tag = TAG_CAR;  _counts = NWG_LM_SER_Settings get "VEH_TRK_SETS_COUNTS"};//Trucks
            default                             {_tag = TAG_CAR;  _counts = NWG_LM_SER_Settings get "VEH_CAR_SETS_COUNTS"};//Fallback to car
        };

        //Apply enrichment if needed
        if (_setsEnrichment != 0) then {
            _counts = [_counts,_setsEnrichment] call NWG_LM_SER_ApplyEnrichment;
        };

        //Select random count
        _count = selectRandom _counts;
        if (_count == 0) then {
            _x call NWG_fnc_clearContainerCargoGlobal;
            continue;//<== Bad luck, clear and skip this vehicle
        };

        //Generate loot set
        _lootSet = [_faction,_tag,_count,_itemEnrichment,_maxTier] call NWG_LM_SER_GenerateLootSet;
        if (_lootSet isEqualTo false) then {
            (format ["NWG_LM_SER_FillVehicles: Failed to generate loot set for: %1",[_faction,_tag,_count,_itemEnrichment]]) call NWG_fnc_logError;
            _x call NWG_fnc_clearContainerCargoGlobal;
            continue;//<== Error, clear and skip this vehicle
        };

        //Fill vehicle
        [_x,_lootSet] call NWG_LM_SER_FillObject;
    } forEach _vehicles;
};

//================================================================================================================
//================================================================================================================
call _Init;