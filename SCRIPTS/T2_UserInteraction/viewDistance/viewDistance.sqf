/*
	Author: Bryan "Tonic" Boardwine
	Reworked by: Asmo
*/

//======================================================================================================
//======================================================================================================
//Defines

//==============================================
//Settings
/*Standalone module option*/
#define SETUP_HOTKEY true
#define HOTKEY 62 //F4

/*Limits*/
#define MIN_VIEWDISTANCE 100
#define MAX_VIEWDISTANCE 5000

/* Default values */
#define DEFAULT_VIEWDISTANCE 1600
#define DEFAULT_GRASS "norm"
#define DEFAULT_TARGET_FPS 30

/* Target FPS values */
#define TARGET_FPS_REFRESH 0.05
#define TARGET_FPS_OK_DELTA 1
#define TARGET_FPS_DISTANCE_STEP 10

//==============================================
//IDs and Macro
/* Main display IDD & IDC's */
#define MENU_IDD 2900
#define INFANTRY_SLIDER 2901
#define INFANTRY_EDIT 2902
#define GROUND_SLIDER 2911
#define GROUND_EDIT 2912
#define AIR_SLIDER 2921
#define AIR_EDIT 2922
#define OBJECT_CHKBOX 2931
#define OBJECT_SLIDER 2941
#define OBJECT_EDIT 2942
#define DRONE_SLIDER 2951
#define DRONE_EDIT 2952
#define TERRAIN_NONE 2950
#define TARFPS_CHKBOX 2932
#define TARFPS_EDIT_MINDIST 2963
#define TARFPS_EDIT_MAXDIST 2964
#define TARFPS_EDIT 2962


/* Save / Load Manager */
#define MANAGER_GROUP 2999
#define SAVELOAD_GROUP 3000
#define SAVES_LIST 3001
#define SLOT_NAME 3002

/* Display Macros */
#define CONTROL(disp,ctrl) ((findDisplay ##disp) displayCtrl ##ctrl)

/* Update UI values helper */
#define UPDATE_ALL_UI true
#define UPDATE_NUMBERS_ONLY false


//======================================================================================================
//======================================================================================================
//Init
private _Init =
{
    //Load values
    private _save = profileNamespace getVariable ["NWG_tawvd_save",[]];
    NWG_tawvd_foot   = _save param [0,DEFAULT_VIEWDISTANCE];
    NWG_tawvd_car    = _save param [1,DEFAULT_VIEWDISTANCE];
    NWG_tawvd_air    = _save param [2,DEFAULT_VIEWDISTANCE];
    NWG_tawvd_drone  = _save param [3,DEFAULT_VIEWDISTANCE];
    NWG_tawvd_object = _save param [4,DEFAULT_VIEWDISTANCE];
    NWG_tawvd_grass  = _save param [5,DEFAULT_GRASS];
    NWG_tawvd_syncObject        = _save param [6,true];
    NWG_tawvd_targetFPSenabled  = _save param [7,false];
    NWG_tawvd_targetFPS         = _save param [8,DEFAULT_TARGET_FPS];
    NWG_tawvd_targetFPSminDist  = _save param [9,MIN_VIEWDISTANCE];
    NWG_tawvd_targetFPSmaxDist  = _save param [10,MAX_VIEWDISTANCE];

    //Prepare other variables
    NWG_VD_prevVeh = (vehicle player);
    NWG_VD_prevDrone = ((UAVControl (getConnectedUAV player))#1);

    //Apply loaded settings
    call NWG_VD_UpdateViewDistance;
    NWG_tawvd_grass call NWG_VD_OnTerrainChanged;

    //Start cycle
    addMissionEventHandler ["Draw3D",{call NWG_VD_OnEachFrame}];

    //Setup hotkey if defined
    if (SETUP_HOTKEY) then
    {
        [] spawn
        {
            waitUntil {!isNull (findDisplay 46)};//46 is a mission display, see https://community.bistudio.com/wiki/findDisplay
            (findDisplay 46) displayAddEventHandler ["KeyDown",
            {
                // params ["_eventName","_keyCode","_shift","_ctrl","_alt"];
                (if ((_this#1) == HOTKEY) then {
                    call NWG_VD_ToggleMenuOpenClose;
                    true//intercept keydown
                } else {
                    false//bypass keydown
                })
            }];
        };
    };
};

//======================================================================================================
//======================================================================================================
//Distance view check and change cycle
NWG_VD_prevVeh = objNull;
NWG_VD_prevDrone = objNull;
NWG_VD_nextAutoDistance = 0;

NWG_VD_OnEachFrame =
{
    switch (true) do {
        /*Invalid state check*/
        case (isNull player || {!alive player}): {};//Do nothing

        /*Target FPS scheme*/
        case (NWG_tawvd_targetFPSenabled): {
            if (visibleMap) exitWith {};
            if (time < NWG_VD_nextAutoDistance) exitWith {};
            NWG_VD_nextAutoDistance = time + TARGET_FPS_REFRESH;

            private _delta = NWG_tawvd_targetFPS - (round diag_fps);
            if ((abs _delta) <= TARGET_FPS_OK_DELTA) exitWith {};

            private _curDistance = switch (true) do {
                case (((UAVControl getConnectedUAV player)#1) isNotEqualTo ""): {NWG_tawvd_drone};
                case ((vehicle player) isKindOf "Man"): {NWG_tawvd_foot};
                case ((vehicle player) isKindOf "LandVehicle" || {(vehicle player) isKindOf "Ship"}): {NWG_tawvd_car};
                case ((vehicle player) isKindOf "Air"): {NWG_tawvd_air};
                default {NWG_tawvd_foot};
            };
            private _step = if (_delta > 0) then {-TARGET_FPS_DISTANCE_STEP} else {TARGET_FPS_DISTANCE_STEP};
            private _newDistance = (((_curDistance + _step) max NWG_tawvd_targetFPSminDist) min NWG_tawvd_targetFPSmaxDist);
            if (_newDistance == _curDistance) exitWith {};

            NWG_tawvd_foot   = _newDistance;
            NWG_tawvd_car    = _newDistance;
            NWG_tawvd_air    = _newDistance;
            NWG_tawvd_drone  = _newDistance;
            NWG_tawvd_object = _newDistance;

            _newDistance call NWG_VD_UpdateViewDistanceCore;
            if (!isNull (findDisplay MENU_IDD)) then {UPDATE_NUMBERS_ONLY call NWG_VD_UpdateMenu};
        };

        /*Standart scheme*/
        case ((vehicle player) isNotEqualTo NWG_VD_prevVeh): {
            NWG_VD_prevVeh = (vehicle player);
            call NWG_VD_UpdateViewDistance;
        };
        case (((UAVControl (getConnectedUAV player))#1) isNotEqualTo NWG_VD_prevDrone): {
            NWG_VD_prevDrone = ((UAVControl (getConnectedUAV player))#1);
            call NWG_VD_UpdateViewDistance;
        };
    };
};

NWG_VD_UpdateViewDistance =
{
    private _playerVeh = vehicle player;
    private _distance = switch (true) do
    {
        case (((UAVControl getConnectedUAV player)#1) isNotEqualTo ""): {NWG_tawvd_drone};
        case (_playerVeh isKindOf "Man"): {NWG_tawvd_foot};
        case (_playerVeh isKindOf "LandVehicle" || {_playerVeh isKindOf "Ship"}): {NWG_tawvd_car};
        case (_playerVeh isKindOf "Air"): {NWG_tawvd_air};
        default {nil};
    };

    if (!isNil "_distance") then {
        _distance call NWG_VD_UpdateViewDistanceCore;
    };
};

NWG_VD_UpdateViewDistanceCore =
{
    // private _distance = _this;

    setViewDistance _this;
    if (NWG_tawvd_syncObject) then {
        NWG_tawvd_object = _this;
        setObjectViewDistance [_this,100];
    };
};

//======================================================================================================
//======================================================================================================
//Grass settings change handler
NWG_VD_OnTerrainChanged =
{
    // private _type = _this;

    NWG_tawvd_grass = _this;

    switch (_this) do
    {
        case "low":   {setTerrainGrid 25};
        case "norm":  {setTerrainGrid 12.5};
        case "high":  {setTerrainGrid 6.25};
        case "ultra": {setTerrainGrid 3.125};
    };
};

//======================================================================================================
//======================================================================================================
//GUI interaction
NWG_VD_ToggleMenuOpenClose =
{
    if (isNull (findDisplay MENU_IDD)) then NWG_VD_OpenMenu else {closeDialog 0};
};

NWG_VD_OpenMenu =
{
    disableSerialization;

    private _display = findDisplay MENU_IDD;
    if (!isNull _display) exitWith {hint "Something went wrong, the menu already opened"};

    private _createDialogSuccess = createDialog "TAW_VDMenu";
    if(!_createDialogSuccess) exitWith {hint "Something went wrong, the menu won't open?"};

    if (!isNil "NWG_fnc_localizeDisplay") then {
        (findDisplay MENU_IDD) call NWG_fnc_localizeDisplay;
    };

    UPDATE_ALL_UI call NWG_VD_UpdateMenu;
};

NWG_VD_UpdateMenu =
{
    private _initSliders = _this;

    disableSerialization;
    private _display = findDisplay MENU_IDD;

    //Setup textboxes
    ctrlSetText[INFANTRY_EDIT, str(NWG_tawvd_foot)];
    ctrlSetText[GROUND_EDIT,   str(NWG_tawvd_car)];
    ctrlSetText[AIR_EDIT,      str(NWG_tawvd_air)];
    ctrlSetText[OBJECT_EDIT,   str(NWG_tawvd_object)];
    ctrlSetText[DRONE_EDIT,    str(NWG_tawvd_drone)];
    ctrlSetText[TARFPS_EDIT_MINDIST,   str(NWG_tawvd_targetFPSminDist)];
    ctrlSetText[TARFPS_EDIT_MAXDIST,   str(NWG_tawvd_targetFPSmaxDist)];
    ctrlSetText[TARFPS_EDIT,   str(NWG_tawvd_targetFPS)];

    //Setup sliders
    if (_initSliders) then
    {
        //do
        {
            slidersetRange [_x,MIN_VIEWDISTANCE,MAX_VIEWDISTANCE];
            (_display displayCtrl _x) sliderSetSpeed [100,100,100];
        } forEach [INFANTRY_SLIDER, GROUND_SLIDER, AIR_SLIDER, OBJECT_SLIDER, DRONE_SLIDER];
    };

    sliderSetPosition[INFANTRY_SLIDER,NWG_tawvd_foot];
    sliderSetPosition[GROUND_SLIDER,  NWG_tawvd_car];
    sliderSetPosition[AIR_SLIDER,     NWG_tawvd_air];
    sliderSetPosition[OBJECT_SLIDER,  NWG_tawvd_object];
    sliderSetPosition[DRONE_SLIDER,   NWG_tawvd_drone];

    //Get enable values
    private _enableUI    = !NWG_tawvd_targetFPSenabled;
    private _enableObjUI = !NWG_tawvd_syncObject;

    //Setup checkboxes
    (_display displayCtrl TARFPS_CHKBOX) cbSetChecked !_enableUI;
    (_display displayCtrl OBJECT_CHKBOX) cbSetChecked !_enableObjUI;

    //Enable or disable certain controls
    ctrlEnable [INFANTRY_SLIDER,_enableUI];
    ctrlEnable [INFANTRY_EDIT,  _enableUI];
    ctrlEnable [GROUND_SLIDER,  _enableUI];
    ctrlEnable [GROUND_EDIT,    _enableUI];
    ctrlEnable [AIR_SLIDER,     _enableUI];
    ctrlEnable [AIR_EDIT,       _enableUI];
    ctrlEnable [OBJECT_SLIDER,  (_enableUI && _enableObjUI)];
    ctrlEnable [OBJECT_EDIT,    (_enableUI && _enableObjUI)];
    ctrlEnable [DRONE_SLIDER,   _enableUI];
    ctrlEnable [DRONE_EDIT,     _enableUI];

    ctrlEnable [TARFPS_EDIT_MINDIST, _enableUI];
    ctrlEnable [TARFPS_EDIT_MAXDIST, _enableUI];
    ctrlEnable [TARFPS_EDIT, _enableUI];
};

NWG_VD_OpenSaveManager =
{
    disableSerialization;

    /* Store displays */
    private _controlGrp = CONTROL(MENU_IDD,MANAGER_GROUP);
    private _saveList = CONTROL(MENU_IDD,SAVES_LIST);
    lbClear _saveList; //Purge the list

    /* Make the Saves manager group visible */
    _controlGrp ctrlSetfade 0;
    _controlGrp ctrlCommit .3;

    /* Fill the listbox */
    for "_i" from 0 to 9 do {
        private _varData = profileNamespace getVariable format["tawvd_slot_%1",_i];
        if(!isNil "_varData") then
        {
            _saveList lbAdd (_varData#0);
            _saveList lbSetData [(lbSize _saveList)-1,"true"];
        }
        else
        {
            _saveList lbAdd format["Save Slot %1",_i];
            _saveList lbSetData [(lbSize _saveList)-1,"false"];
        };
    };
};

NWG_VD_OnSaveManagerSave =
{
    private _saveIndex = lbCurSel SAVES_LIST;
    private _saveName = ctrlText SLOT_NAME;

    hint format["saveIndex: %1", _saveIndex];
    profileNamespace setVariable [(format["tawvd_slot_%1",_saveIndex]),
        [
            _saveName,
            NWG_tawvd_foot,
            NWG_tawvd_car,
            NWG_tawvd_air,
            NWG_tawvd_drone,
            NWG_tawvd_object,
            NWG_tawvd_syncObject,
            NWG_tawvd_grass
        ]
    ];

    saveProfileNamespace;
    [] call NWG_VD_OpenSaveManager;
};

NWG_VD_OnSaveSelectionChanged =
{
    params [["_control",controlNull,[controlNull]],["_index",-1,[0]]];

    /* Error checks */
    if((_index == -1) || {isNull _control}) exitWith {};
    private _saveData = profileNamespace getVariable (format["tawvd_slot_%1",_index]);
    if(isNil "_saveData") exitWith {};

    /* Set variables to chosen slot data */
    CONTROL(MENU_IDD,SLOT_NAME) ctrlSetText (_saveData#0);
    NWG_tawvd_foot 		 = (_saveData#1);
    NWG_tawvd_car		 = (_saveData#2);
    NWG_tawvd_air		 = (_saveData#3);
    NWG_tawvd_drone		 = (_saveData#4);
    NWG_tawvd_object	 = (_saveData#5);
    NWG_tawvd_syncObject = (_saveData#6);
    NWG_tawvd_grass		 = (_saveData#7);

    /* Update Menu & View Distance */
    call NWG_VD_UpdateViewDistance;
    NWG_tawvd_grass call NWG_VD_OnTerrainChanged;
    UPDATE_NUMBERS_ONLY call NWG_VD_UpdateMenu;
};

NWG_VD_OnSliderChange =
{
    params [["_mode",-1,[0]],["_value",-1,[0]]];

    if(_mode == -1 || {_value == -1}) exitWith {};
    _value = round _value;

    disableSerialization;

    switch(_mode) do
    {
        case 0:
        {
            NWG_tawvd_foot = _value;
            ctrlSetText[INFANTRY_EDIT,str(_value)];
        };
        case 1:
        {
            NWG_tawvd_car = _value;
            ctrlSetText[GROUND_EDIT,str(_value)];
        };
        case 2:
        {
            NWG_tawvd_air = _value;
            ctrlSetText[AIR_EDIT,str(_value)];
        };
        case 3:
        {
            NWG_tawvd_object = _value;
            ctrlSetText[OBJECT_EDIT,str(_value)];
            setObjectViewDistance [NWG_tawvd_object,100];
        };
        case 4:
        {
            NWG_tawvd_drone = _value;
            ctrlSetText[DRONE_EDIT,str(_value)];
        };
    };

    call NWG_VD_UpdateViewDistance;

    if (NWG_tawvd_syncObject) then {
        sliderSetPosition[OBJECT_SLIDER, NWG_tawvd_object];
        ctrlSetText[OBJECT_EDIT,str(NWG_tawvd_object)];
    };
};

NWG_VD_OnFieldEdit =
{
    params ["_control","_linkedSlider"];

    disableSerialization;
    if(isNull _control) exitWith {}; //POOOOOP

    private _value = parseNumber (ctrlText _control);
    if (_value < MIN_VIEWDISTANCE || {_value > MAX_VIEWDISTANCE}) exitwith {};

    switch (_linkedSlider) do
    {
        case "ground":  {NWG_tawvd_foot = _value};
        case "vehicle": {NWG_tawvd_car = _value};
        case "air":     {NWG_tawvd_air = _value};
        case "object":  {NWG_tawvd_object = _value};
        case "drone":   {NWG_tawvd_drone = _value};
        default         {NWG_tawvd_foot = _value};
    };

    call NWG_VD_UpdateViewDistance;
    UPDATE_NUMBERS_ONLY call NWG_VD_UpdateMenu;
};

NWG_VD_OnObjectSyncChanged =
{
    private _nowEnabled = (_this#1) == 1;
    private _allowGeneralEdit = !NWG_tawvd_targetFPSenabled;
    if (!_allowGeneralEdit) exitWith {
        ((findDisplay MENU_IDD) displayCtrl OBJECT_CHKBOX) cbSetChecked !_nowEnabled;
    };

    NWG_tawvd_syncObject = _nowEnabled;
    call NWG_VD_UpdateViewDistance;
    UPDATE_NUMBERS_ONLY call NWG_VD_UpdateMenu;
};

NWG_VD_OnTargetFPSChkBoxChanged =
{
    private _nowEnabled = (_this#1) == 1;

    NWG_tawvd_targetFPSenabled = _nowEnabled;
    NWG_tawvd_syncObject = _nowEnabled;
    call NWG_VD_UpdateViewDistance;
    UPDATE_NUMBERS_ONLY call NWG_VD_UpdateMenu;
};

NWG_VD_OnTargetFPSMinDistFieldEdit =
{
    private _value = parseNumber (ctrlText _this);
    if (_value < MIN_VIEWDISTANCE || {_value > MAX_VIEWDISTANCE}) exitwith {};
    NWG_tawvd_targetFPSminDist  = _value;
};

NWG_VD_OnTargetFPSMaxDistFieldEdit =
{
    private _value = parseNumber (ctrlText _this);
    if (_value < MIN_VIEWDISTANCE || {_value > MAX_VIEWDISTANCE}) exitwith {};
    NWG_tawvd_targetFPSmaxDist  = _value;
};

NWG_VD_OnTargetFPSFieldEdit =
{
    private _value = parseNumber (ctrlText _this);
    if (_value < 0 || {_value > 999}) exitwith {};
    NWG_tawvd_targetFPS = _value;
};

NWG_VD_OnMenuClose =
{
    profileNamespace setVariable ["NWG_tawvd_save",[
        NWG_tawvd_foot,
        NWG_tawvd_car,
        NWG_tawvd_air,
        NWG_tawvd_drone,
        NWG_tawvd_object,
        NWG_tawvd_grass,
        NWG_tawvd_syncObject,
        NWG_tawvd_targetFPSenabled,
        NWG_tawvd_targetFPS,
        NWG_tawvd_targetFPSminDist,
        NWG_tawvd_targetFPSmaxDist
    ]];

    saveProfileNamespace;
};

//======================================================================================================
//======================================================================================================
//Init
call _Init;