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
    _loadout call NWG_ICAT_Dump;
    _loadout
};

//================================================================================================================
//================================================================================================================
//Test utils
NWG_ICAT_sortOrder = [ITEM_TYPE_CLTH,ITEM_TYPE_WEPN,ITEM_TYPE_ITEM,ITEM_TYPE_AMMO,false];//Order of sorting
NWG_ICAT_Sort = {
    // private _array = _this;
    private _sorted = _this apply {[(NWG_ICAT_sortOrder find (_x#0)),_x]};//Repack for sorting
    _sorted sort true;//Sort
    _this resize 0;
    _this append (_sorted apply {_x#1});//Repack back
    //return
    _this
};

NWG_ICAT_Dump = {
    private _array = _this;
    _array = _array apply {str _x};//Convert to strings

    //Dump to RPT
    diag_log text "==========[   NWG_ICAT_Dump   ]===========";
    {diag_log (text _x)} forEach _array;
    diag_log text "==========[        END        ]===========";

    //Dump to clipboard
    copyToClipboard (_array joinString (toString [13,10]));//Copy with 'new line' separator
};