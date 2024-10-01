#include "..\..\globalDefines.h"

//================================================================================================================
//================================================================================================================
//Item type getter
// call NWG_ICAT_GetItemType_Test_PlayerLoadout
NWG_ICAT_GetItemType_Test_PlayerLoadout = {
    private _loadout = getUnitLoadout player;//Get raw
    _loadout = (flatten _loadout) select {_x isEqualType "" && {_x isNotEqualTo ""}};//Flatten and filter
    _loadout = _loadout arrayIntersect _loadout;//Remove duplicates

    _loadout = _loadout apply {
        [(_x call NWG_ICAT_GetItemType),_x]
    };
    _loadout = _loadout call NWG_ICAT_Sort;
    _loadout call NWG_fnc_testDumpToRptAndClipboard;
    _loadout
};

// call NWG_ICAT_GetItemType_Test_VanillaCatalogue
NWG_ICAT_GetItemType_Test_VanillaCatalogue = {
    private _filePath = "DATASETS\Server\ItemsCategorization\_Vanilla.sqf";
    private _catalogue = call (_filePath call NWG_fnc_compile);
    if (isNil "_catalogue" || {!(_catalogue isEqualType [])}) exitWith {"Failed to load catalogue"};

    private _itemCategories = [LOOT_ITEM_TYPE_CLTH,LOOT_ITEM_TYPE_WEAP,LOOT_ITEM_TYPE_ITEM,LOOT_ITEM_TYPE_AMMO];
    private ["_category","_entries","_xCat"];
    private _errors = [];
    {
        _category = _x param [0,""];
        _entries  = _x param [1,[]];
        if (!(_category isEqualType "") || {!(_entries isEqualType [])})
            then {_errors pushBack (format ["NWG_ICAT_GetItemType_Test_VanillaCatalogue: Defective record in %1:%2 cat:%3 ent:%4",_filePath,_forEachIndex,_category,_entries]); continue};

        if !(_category in _itemCategories)
            then {_errors pushBack (format ["NWG_ICAT_GetItemType_Test_VanillaCatalogue: Invalid category '%1' in %2:%3",_category,_filePath,_forEachIndex]); continue};

        {
            _xCat = _x call NWG_ICAT_GetItemType;
            if (_category isNotEqualTo _xCat)
                then {_errors pushBack (format ["NWG_ICAT_GetItemType_Test_VanillaCatalogue: For '%1' expected '%2' got '%3'",_x,_category,_xCat])};
        } forEach _entries;

    } forEach _catalogue;

    if ((count _errors) > 0) then {
        _errors call NWG_fnc_testDumpToRptAndClipboard;
        "Some errors occured, see RPT for details"
    } else {
        "All tests passed successfully"
    }
};

//================================================================================================================
//================================================================================================================
//Test utils
NWG_ICAT_sortOrder = [LOOT_ITEM_TYPE_CLTH,LOOT_ITEM_TYPE_WEAP,LOOT_ITEM_TYPE_ITEM,LOOT_ITEM_TYPE_AMMO,false];//Order of sorting
NWG_ICAT_Sort = {
    // private _array = _this;
    private _sorted = _this apply {[(NWG_ICAT_sortOrder find (_x#0)),_x]};//Repack for sorting
    _sorted sort true;//Sort
    _this resize 0;
    _this append (_sorted apply {_x#1});//Repack back
    //return
    _this
};