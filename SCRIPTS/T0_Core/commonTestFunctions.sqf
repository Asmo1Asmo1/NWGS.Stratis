NWG_fnc_testClearMap = {
    {deleteMarker _x} forEach allMapMarkers;
};

NWG_fnc_testPlaceMarker = {
    params ["_pos","_name",["_color","ColorRed"],["_text",""]];

    private _marker = createMarkerLocal [_name,_pos];
    _marker setMarkerShapeLocal "icon";
    _marker setMarkerTypeLocal "mil_dot";
    _marker setMarkerColorLocal _color;
    _marker setMarkerTextLocal _text;
};

NWG_fnc_testDumpToRptAndClipboard = {
    private _array = _this + [];//Shallow copy

    //Convert to strings
    {
        if !(_x isEqualType "")
            then {_array set [_forEachIndex,(str _x)]};
    } forEach _array;

    //Dump to RPT
    diag_log text "==========[       START       ]===========";
    {diag_log (text _x)} forEach _array;
    diag_log text "==========[        END        ]===========";

    //Dump to clipboard
    copyToClipboard (_array joinString (toString [13,10]));//Copy with 'new line' separator

    //Return the array
    _array
};

NWG_fnc_testFullProgress = {
    [player,10000000] call NWG_fnc_wltAddPlayerMoney;
    [player,[100,100,10,10,10]] call NWG_fnc_pSetPlayerProgress;
    NWG_MIS_UnlockedLevels = NWG_MIS_UnlockedLevels apply {true};
};

NWG_fnc_testRaiseLvlAndMoney = {
    params ["_addLvl",["_addMoney",0]];

    [player,0,_addLvl] call NWG_fnc_pAddPlayerProgress;
    [player,1,_addLvl] call NWG_fnc_pAddPlayerProgress;
    if (_addMoney > 0) then {
        [player,_addMoney] call NWG_fnc_wltAddPlayerMoney;
    };
};

NWG_fnc_testAssignDebugLoadout = {
    private _loadout = [["arifle_SPAR_01_snd_F","muzzle_snds_M","acc_pointer_IR","optic_Hamr",["30Rnd_556x45_Stanag_Sand",30],[],""],["launch_MRAWS_olive_rail_F","","","",["MRAWS_HEAT_F",1],[],""],[],["U_B_CombatUniform_mcam_tshirt",[["FirstAidKit",5]]],["V_PlateCarrier1_rgr",[["30Rnd_556x45_Stanag_Sand",10,30]]],["B_Kitbag_mcamo",[["ToolKit",1],["MRAWS_HEAT_F",1,1]]],"H_MilCap_grn","",["Rangefinder","","","",[],[],""],["ItemMap","O_UavTerminal","ItemRadio","ItemCompass","ItemWatch","NVGoggles_OPFOR"]];
    _loadout call NWG_fnc_invSetPlayerLoadout;

    private _holder = ["arifle_SPAR_01_snd_F","muzzle_snds_M","acc_pointer_IR","optic_Hamr",["30Rnd_556x45_Stanag_Sand",30],[],""];
    [player,_holder] call NWG_AW_SetHolderData;
    [player,_holder] call NWG_AW_CreateHolderObject;
};
