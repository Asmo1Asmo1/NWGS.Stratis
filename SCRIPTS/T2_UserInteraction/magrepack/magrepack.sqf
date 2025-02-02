/*Original is made by Outlawled, R3vo and GiPPO back in 2015-2017*/
/*https://steamcommunity.com/sharedfiles/filedetails/?id=1593431569*/
/*Reworked by Asmo*/

//======================================================================================================
//======================================================================================================
//Defines

/*Settings*/
#define SETUP_HOTKEY false
#define HOTKEY_KEYCODE 19//R
#define HOTKEY_MODIFIER "ctrl"//'none','shift','ctrl','alt'

#define IMAGE_PATH "GUI\magrepack\images\%1"

#define REPACK_CYCLE_RATE 0.05
#define TIME_PER_BULLET 0.8
#define TIME_PER_MG_BELT 6
#define TIME_TEXT_UPDATE 0.25
#define ADD_EMPTIED_MAGS_BACK false

/*Macro*/
#define DIALOG_WINDOW (uiNamespace getVariable ["MRO_Dialog_Main",displayNull])
#define AMMO_TYPE_SELECTION 22170
#define AMMO_TYPE_ALL "all"
#define SOURCE_AREA 2215
#define TARGET_AREA 2216
#define SOURCE_PIC 1201
#define SOURCE_INFO 1100
#define SOURCE_BOX 1501
#define TARGET_PIC 1203
#define TARGET_INFO 1101
#define TARGET_BOX 1502
#define MAGS_LIST 1500
#define MAGS_LIST_TITLE 1000
#define MAGS_LIST_BOX_AREA 2217
#define REPACKING_TEXT 1008
#define AMMO_SOURCE 22180
#define AMMO_TARGET 22190
#define REPACK_PROGRESS 10002

/*Macro commands*/
#define IS_EMPTY(array) ((count array)  == 0)

/*Enums*/
#define TYPE 0
#define CUR_AMMO 1
#define MAX_AMMO 2
#define MAG_COUNT 3
#define CALIBER 4
#define IS_MG_BELT 5
#define DISPLAY_NAME 6

#define DRAG_NONE -1
#define DRAG_SOURCE -2
#define DRAG_TARGET -3

#define FLAG_UNDEFINED "undefined"
#define FLAG_LIST "list"
#define FLAG_SOURCE "source"
#define FLAG_TARGET "target"

#define MOVE_NONE 0
#define MOVE_LIST 1
#define MOVE_SOURCE 2
#define MOVE_TARGET 3

#define TEXT_MAIN_TITLE 0
#define TEXT_SOURCE_LABEL 1
#define TEXT_TARGET_LABEL 2
#define TEXT_BUTTON_FULL_MAGS 3
#define TEXT_ALL_AMMO_TYPES 4
#define TEXT_TITLE_ALL_MAGS 5
#define TEXT_TITLE_COMPATIBLE_MAGS 6
#define TEXT_SOURCE_OCCUPIED 7
#define TEXT_SOURCE_EMPTY 8
#define TEXT_TARGET_OCCUPIED 9
#define TEXT_TARGET_FULL 10
#define TEXT_REPACKING 11
#define TEXT_HOTKEY 12

//======================================================================================================
//======================================================================================================
//Fields
MRO_text = [
	"Mag Repack",//TEXT_MAIN_TITLE
	" Source",//TEXT_SOURCE_LABEL
	"Target ",//TEXT_TARGET_LABEL
	"FULL MAGS",//TEXT_BUTTON_FULL_MAGS
	"All Ammo Types",//TEXT_ALL_AMMO_TYPES
	"All Magazines",//TEXT_TITLE_ALL_MAGS
	"Compatible Magazines",//TEXT_TITLE_COMPATIBLE_MAGS
	"Source is already defined!",//TEXT_SOURCE_OCCUPIED
	"Source cannot be empty!",//TEXT_SOURCE_EMPTY
	"Target is already defined!",//TEXT_TARGET_OCCUPIED
	"Target magazine cannot be full!",//TEXT_TARGET_FULL
	"Repacking",//TEXT_REPACKING
	"Hotkey set, Ctrl+R by default"//TEXT_HOTKEY
];
MRO_isTextLocalized = false;

MRO_DefaultFields = {
	MRO_currentMagsList = [];
	MRO_source = [];
	MRO_target = [];
	MRO_dragging = DRAG_NONE;
	MRO_currentFilter = AMMO_TYPE_ALL;
};
call MRO_DefaultFields;

MRO_isIgnoreEvents = false;
MRO_isShowFullMags = false;
MRO_checkCycle = scriptNull;

//======================================================================================================
//======================================================================================================
//Init & OnDestroy

//Setup hotkey if defined
if (SETUP_HOTKEY) then
{
	[] spawn
	{
		waitUntil {sleep 0.1; !isNull (findDisplay 46)};//46 is a mission display, see https://community.bistudio.com/wiki/findDisplay
		(findDisplay 46) displayAddEventHandler ["KeyDown",
		{
			params ["","_keyCode","_shift","_ctrl","_alt"];

			//Check keycode
			if (_keyCode != HOTKEY_KEYCODE) exitWith {false};//bypass keydown

			//Check modifier
			private _modifier = switch (true) do {
				case (_shift):{"shift"};
				case (_ctrl):{"ctrl"};
				case (_alt):{"alt"};
				default {"none"};
			};
			if (_modifier isNotEqualTo HOTKEY_MODIFIER) exitWith {false};

			//Check if already opened
			if (!isNull DIALOG_WINDOW) exitWith {false};

			//Open
			call MRO_CreateDialog;
			//return true - intercept keydown
			true
		}];

		systemChat (MRO_text#TEXT_HOTKEY);
	};
};

MRO_CreateDialog =
{
	//Open dialog
	private _created = createDialog "MagRepack_Dialog_Main";
	if (!_created) exitWith {
		systemChat "Dialog failed to open";
	};

	//Create blur effect on background
	MRO_blur = ppEffectCreate ["DynamicBlur", 401];
	MRO_blur ppEffectEnable true;
	MRO_blur ppEffectAdjust [1.5];
	MRO_blur ppEffectCommit 0;

	//Play animation
	if ((vehicle player) isEqualTo player) then
	{
		private _stance = if ((stance player) isEqualTo "PRONE") then {"Ppne"} else {"Pknl"};
		private _raised = nil;
		private _weapon = nil;

		switch (currentWeapon player) do
		{
			case (""): 					  {_raised = "Snon"; _weapon = "Wnon"};
			case (primaryWeapon player):  {_raised = "Sras"; _weapon = "Wrfl"};
			case (secondaryWeapon player):{_raised = "Sras"; _weapon = "Wlnr"};
			default 					  {_raised = "Sras"; _weapon = "Wpst"};
		};

		player playMove (format ["Ainv%1Mstp%2%3Dnon",_stance,_raised,_weapon]);
	};

	//Localize
	if (!isNil "NWG_fnc_localize" && !MRO_isTextLocalized) then {
		{MRO_text set [_forEachIndex,(_x call NWG_fnc_localize)]} forEach MRO_text;
		MRO_isTextLocalized = true;
	};

	//Draw interface
	[] spawn
	{
		private _mainWindow = displayNull;
		waitUntil {
			_mainWindow = DIALOG_WINDOW;
			(!isNil "_mainWindow" && {!isNull _mainWindow})
		};

		//Setup background images
		(DIALOG_WINDOW displayCtrl 2210) ctrlSetText (format [IMAGE_PATH,"mr_sourcegradient.paa"]);
		(DIALOG_WINDOW displayCtrl 2211) ctrlSetText (format [IMAGE_PATH,"mr_targetgradient.paa"]);

		//Setup static text
		(DIALOG_WINDOW displayCtrl 1001) ctrlSetText (MRO_text#TEXT_MAIN_TITLE);
		(DIALOG_WINDOW displayCtrl 1002) ctrlSetText (MRO_text#TEXT_SOURCE_LABEL);
		(DIALOG_WINDOW displayCtrl 1004) ctrlSetText (MRO_text#TEXT_TARGET_LABEL);
		(DIALOG_WINDOW displayCtrl 2400) ctrlSetText (MRO_text#TEXT_BUTTON_FULL_MAGS);

		//Init
		call MRO_ResetUiAndLogic;

		//Setup auto-close
		if (!isNull MRO_checkCycle && {!scriptDone MRO_checkCycle}) then {
			terminate MRO_checkCycle;
		};
		MRO_checkCycle = [] spawn
		{
			waitUntil
			{
				uiSleep 0.25;

				//Check if window is closed or should be closed now
				if (isNull DIALOG_WINDOW) exitWith {true};
				if (isNull player || {!alive player}) exitWith {closeDialog 0;true};
				if (!isNil "NWG_fnc_medIsWounded" && {player call NWG_fnc_medIsWounded}) exitWith {closeDialog 0;true};

				//Always return
				false
			};
		};
	};
};

MRO_OnDialogDestroy =
{
	ppEffectDestroy MRO_blur;
	call MRO_DefaultFields;
};

//======================================================================================================
//======================================================================================================
//UI util
MRO_CtrlSetPos =
{
	params ["_control","_pos","_speed"];
	(DIALOG_WINDOW displayCtrl _control) ctrlSetPosition _pos;
	(DIALOG_WINDOW displayCtrl _control) ctrlCommit _speed;
};

//======================================================================================================
//======================================================================================================
//Code -> UI
MRO_ResetUiAndLogic =
{
	MRO_isIgnoreEvents = true;//Stop UI handling

	//Stop any activity and drop any values stored
	call MRO_StopRepack;
	call MRO_DefaultFields;

	//Generate new mags list
	MRO_currentMagsList = call MRO_GenerateMagsList;

	//Reset left window part
	call MRO_UpdateMagTypeSelection;
	call MRO_UpdateMagsList;

	//Reset right window part
	call MRO_UpdateSourceAndTarget;
	call MRO_ClearRepackUI;

	MRO_isIgnoreEvents = false;
};

MRO_UpdateListAndSelection =
{
	MRO_isIgnoreEvents = true;

	call MRO_UpdateMagTypeSelection;
	call MRO_UpdateMagsList;

	MRO_isIgnoreEvents = false;
};

MRO_ClearRepackUI =
{
	(DIALOG_WINDOW displayCtrl REPACKING_TEXT) ctrlSetText "";
	[REPACK_PROGRESS, [-0.325,0], 0] call MRO_CtrlSetPos;
};

MRO_UpdateMagTypeSelection =
{
	private _ammoTypeSelection = (DIALOG_WINDOW displayCtrl AMMO_TYPE_SELECTION);
	lbClear _ammoTypeSelection;

	private _ammoTypes = [];
	if (MRO_currentFilter isEqualTo AMMO_TYPE_ALL) then	{
		//Add 'All'
		_ammoTypeSelection lbAdd (MRO_text#TEXT_ALL_AMMO_TYPES);
		_ammoTypeSelection lbSetData [0,AMMO_TYPE_ALL];

		//Add every caliber
		{_ammoTypes pushBackUnique (_x#CALIBER)} forEach MRO_currentMagsList;
	} else {
		//Add only filter
		_ammoTypes pushBack MRO_currentFilter;
	};

	//do
	{
		private _newRow = _ammoTypeSelection lbAdd _x;
		_ammoTypeSelection lbSetData [_newRow,_x];
	} forEach _ammoTypes;

	_ammoTypeSelection lbSetCurSel 0;
};

MRO_UpdateMagsList =
{
	//Setup list title
	(DIALOG_WINDOW displayCtrl MAGS_LIST_TITLE) ctrlSetStructuredText parseText (if (MRO_currentFilter isEqualTo AMMO_TYPE_ALL)
		then {MRO_text#TEXT_TITLE_ALL_MAGS}
		else {MRO_text#TEXT_TITLE_COMPATIBLE_MAGS});

	//Prepare the UI
	private _magsList = (DIALOG_WINDOW displayCtrl MAGS_LIST);
	lnbClear _magsList;
	private _bgPos = ctrlPosition _magsList;
	//I have no idea what it does or why is it here but ok
	[MAGS_LIST, [(_bgPos#0), (_bgPos#1), 0.325, (_bgPos#3)], 0] call MRO_CtrlSetPos;
	[MAGS_LIST_BOX_AREA, [(_bgPos#0), (_bgPos#1), 0.325, (_bgPos#3) + 0.003], 0] call MRO_CtrlSetPos;
	_magsList lnbDeleteColumn 3;
	_magsList lnbAddColumn 0.89;

	//Fill the list
	//do
	{
		//Check filter by caliber
		if ((_x#CALIBER) isNotEqualTo MRO_currentFilter && {MRO_currentFilter isNotEqualTo AMMO_TYPE_ALL}) then {continue};

		//Check filter by full mag
		if (!MRO_isShowFullMags && {(_x#CUR_AMMO) >= (_x#MAX_AMMO)}) then {continue};

		//Fix text broken align if ammo count < 10
		private _template = if ((_x#MAG_COUNT) >= 10) then {"%1x  %2"} else {" %1x  %2"};
		private _text = format [_template,(_x#MAG_COUNT),(_x#DISPLAY_NAME)];
		private _picture = format ["bulletcount\%1.paa",(round ((_x#CUR_AMMO)/(_x#MAX_AMMO)*30))];
		_picture = format [IMAGE_PATH,_picture];

		private _newRow = _magsList lbadd _text;
		_magsList lbSetPicture [_newRow,_picture];
		_magsList lbSetPictureColor [_newRow,[1,1,1,1]];
		_magsList lbSetPictureColorSelected [_newRow,[1,1,1,1]];
		_magsList lbSetValue [_newRow,_forEachIndex];//Save mag index for later
	} forEach MRO_currentMagsList;
};

MRO_UpdateSourceAndTarget =
{
	private _updateScript = {
		params ["_item","_box","_pic","_ammoSlider","_infoBlock","_area"];

		private _isEmpty = IS_EMPTY(_item);
		lbClear (DIALOG_WINDOW displayCtrl _box);

		if (!_isEmpty) then {
			(DIALOG_WINDOW displayCtrl _box) lbAdd (_item#DISPLAY_NAME);
			(DIALOG_WINDOW displayCtrl _pic) ctrlSetText (getText (configFile >> "cfgMagazines" >> (_item#TYPE) >> "picture"));
			[_ammoSlider, [0,((0.12/(_item#MAX_AMMO)) * ((_item#MAX_AMMO) - (_item#CUR_AMMO)))], 0] call MRO_CtrlSetPos;

			(DIALOG_WINDOW displayCtrl _infoBlock) ctrlSetStructuredText parseText format [
				"<t size='0.65 * GUI_GRID_H' align='right'>%1<br/>%2</t>",
				(_item#DISPLAY_NAME),
				(getText (configFile >> "cfgMagazines" >> (_item#TYPE) >> "descriptionshort"))
			];
		} else {
			(DIALOG_WINDOW displayCtrl _pic) ctrlSetText "";
			[_ammoSlider, [0,0.12], 0] call MRO_CtrlSetPos;
			(DIALOG_WINDOW displayCtrl _infoBlock) ctrlSetStructuredText parseText "";
			(DIALOG_WINDOW displayCtrl _area) ctrlSetToolTip "";
		};

		(DIALOG_WINDOW displayCtrl _area) ctrlEnable _isEmpty;
	};

	[MRO_source,SOURCE_BOX,SOURCE_PIC,AMMO_SOURCE,SOURCE_INFO,SOURCE_AREA] call _updateScript;
	[MRO_target,TARGET_BOX,TARGET_PIC,AMMO_TARGET,TARGET_INFO,TARGET_AREA] call _updateScript;
};

//======================================================================================================
//======================================================================================================
//User -> UI

//Fired by 'FULL MAGS' button
MRO_OnToggleFullMags =
{
	if (MRO_isIgnoreEvents || {call MRO_IsRepacking}) exitWith {};
	MRO_isShowFullMags = !MRO_isShowFullMags;
	call MRO_ResetUiAndLogic;
};

//Fires when user starts to drag list/source/target
MRO_OnDrag =
{
	params ["_control","_listBoxInfo",["_flag",FLAG_UNDEFINED]];
	// (_listBoxInfo#0) params ["_text","_value","_data"];
	//(_listBoxInfo#0) Because it supports multi-selection but I'm not sure it is used anywhere at all

	//Check ignore
	if (MRO_isIgnoreEvents || {call MRO_IsRepacking}) exitWith {};

	MRO_dragging = switch (_flag) do
	{
		case FLAG_LIST:{(_listBoxInfo#0)#1};
		case FLAG_SOURCE:{DRAG_SOURCE};
		case FLAG_TARGET:{DRAG_TARGET};
		default {systemChat format ["MRO_OnDrag: unknown flag '%1'",_flag]; DRAG_NONE};
	};

	call MRO_BlockUiSelectively;
};

//Fires when user releases drop onto drop-handling UI item
MRO_OnDrop =
{
	// params ["_control","_xPos","_yPos","_listboxIDC","_listboxInfo","_flag"];
	private _flag = _this param [5,FLAG_UNDEFINED];

	//Check ignore
	if (MRO_isIgnoreEvents || {call MRO_IsRepacking}) exitWith {};

	//Define flags
	private _moveFrom = switch (MRO_dragging) do
	{
		case DRAG_NONE: {MOVE_NONE};
		case DRAG_SOURCE: {MOVE_SOURCE};
		case DRAG_TARGET: {MOVE_TARGET};
		default /*List item index*/ {MOVE_LIST};
	};

	private _moveTo = switch (_flag) do
	{
		case FLAG_LIST: {MOVE_LIST};
		case FLAG_SOURCE: {MOVE_SOURCE};
		case FLAG_TARGET: {MOVE_TARGET};
		default {systemChat format ["MRO_OnDrop: unknown flag '%1'",_flag];MOVE_NONE};
	};

	//Move item
	[_moveFrom,_moveTo] call MRO_MoveItem;

	//Check if need to start repack process
	if (!IS_EMPTY(MRO_source) && {!IS_EMPTY(MRO_target)}) then MRO_StartRepack;
};

//Fires when user releases mouse button
//!WARNING! Fires BEFORE OnDrop
MRO_OnMouseButtonUp =
{
	if (MRO_isIgnoreEvents || {MRO_dragging == DRAG_NONE}) exitWith {};
	call MRO_UnblockUI;
};

//Fires on right mouse button click on source/target
MRO_OnRmbClick =
{
	// private _flag = _this;
	if (MRO_isIgnoreEvents || {call MRO_IsRepacking}) exitWith {};

	switch (_this) do {
		case FLAG_SOURCE:{if (!IS_EMPTY(MRO_source)) then {[MOVE_SOURCE,MOVE_LIST] call MRO_MoveItem}};
		case FLAG_TARGET:{if (!IS_EMPTY(MRO_target)) then {[MOVE_TARGET,MOVE_LIST] call MRO_MoveItem}};
	};
};

//Fires when user changes selected ammo type
MRO_OnSelectionChange =
{
	params ["_control","_lbCurSel"/*,"_lbSelection"*/];

	//Check ignore
	if (MRO_isIgnoreEvents || {call MRO_IsRepacking}) exitWith {};
	if (!IS_EMPTY(MRO_source) || {!IS_EMPTY(MRO_target)}) exitWith {};

	//Change current filter and update the list
	MRO_currentFilter = _control lbData _lbCurSel;
	call MRO_UpdateMagsList;
};

//======================================================================================================
//======================================================================================================
//Drag util
MRO_PeekDraggedItem =
{
	private _draggedItem = switch (MRO_dragging) do
	{
		case DRAG_NONE: {[]};
		case DRAG_SOURCE: {MRO_source};
		case DRAG_TARGET: {MRO_target};
		default /*List item index*/ {MRO_currentMagsList select MRO_dragging};
	};

	//return
	_draggedItem
};

//======================================================================================================
//======================================================================================================
//Block UI logic
MRO_BlockUiSelectively =
{
	private _colorUnblocked = [1,1,1,0.3];
	private _colorBlocked = [1,0,0,0.3];

	private _draggedItem = call MRO_PeekDraggedItem;
	if (IS_EMPTY(_draggedItem)) exitWith {
		systemChat "MRO_BlockUiSelectively: dragging an empty item";
	};

	private _sourceDragging = _draggedItem isEqualTo MRO_source;
	private _targetDragging = _draggedItem isEqualTo MRO_target;

	//Define items list block
	if (_sourceDragging || _targetDragging) then {
		(DIALOG_WINDOW displayCtrl MAGS_LIST_BOX_AREA) ctrlEnable true;
	};

	//Define source block (along with UI state)
	private _sourceTooltip = "";
	private _sourceBcColor = _colorUnblocked;

	private _doBlockSource = switch (true) do
	{
		case (!IS_EMPTY(MRO_source)):
		{
			if (!_sourceDragging) then {_sourceTooltip = MRO_text#TEXT_SOURCE_OCCUPIED;_sourceBcColor = _colorBlocked};
			true
		};
		case ((_draggedItem#CUR_AMMO)<=0):
		{
			if (!_sourceDragging) then {_sourceTooltip = MRO_text#TEXT_SOURCE_EMPTY;_sourceBcColor = _colorBlocked};
			true
		};
		default {false};
	};

	(DIALOG_WINDOW displayCtrl SOURCE_AREA) ctrlSetToolTip _sourceTooltip;
	(DIALOG_WINDOW displayCtrl SOURCE_AREA) ctrlSetBackgroundColor _sourceBcColor;
	if (_doBlockSource) then {
		(DIALOG_WINDOW displayCtrl SOURCE_AREA) ctrlEnable (!_doBlockSource);
	};

	//Define target block (along with UI state)
	private _targetTooltip = "";
	private _targetBcColor = _colorUnblocked;

	private _doBlockTarget = switch (true) do
	{
		case (!IS_EMPTY(MRO_target)):
		{
			if (!_targetDragging) then {_targetTooltip = MRO_text#TEXT_TARGET_OCCUPIED;_targetBcColor = _colorBlocked};
			true
		};
		case (((_draggedItem)#CUR_AMMO) >= ((_draggedItem)#MAX_AMMO)):
		{
			if (!_targetDragging) then {_targetTooltip = MRO_text#TEXT_TARGET_FULL;_targetBcColor = _colorBlocked};
			true
		};
		default {false};
	};

	(DIALOG_WINDOW displayCtrl TARGET_AREA) ctrlSetToolTip _targetTooltip;
	(DIALOG_WINDOW displayCtrl TARGET_AREA) ctrlSetBackgroundColor _targetBcColor;
	if (_doBlockTarget) then {
		(DIALOG_WINDOW displayCtrl TARGET_AREA) ctrlEnable false;
	};

	(DIALOG_WINDOW displayCtrl MAGS_LIST_BOX_AREA) ctrlSetBackgroundColor _colorUnblocked;
};

MRO_UnblockUI =
{
	(DIALOG_WINDOW displayCtrl SOURCE_AREA) ctrlSetToolTip "";
	(DIALOG_WINDOW displayCtrl SOURCE_AREA) ctrlSetBackgroundColor [1,0,0,0];
	if (IS_EMPTY(MRO_source)) then {
		(DIALOG_WINDOW displayCtrl SOURCE_AREA) ctrlEnable true;
	};

	(DIALOG_WINDOW displayCtrl TARGET_AREA) ctrlSetToolTip "";
	(DIALOG_WINDOW displayCtrl TARGET_AREA) ctrlSetBackgroundColor [1,0,0,0];
	if (IS_EMPTY(MRO_target)) then {
		(DIALOG_WINDOW displayCtrl TARGET_AREA) ctrlEnable true;
	};

	(DIALOG_WINDOW displayCtrl MAGS_LIST_BOX_AREA) ctrlSetBackgroundColor [0,0,0,0];
	(DIALOG_WINDOW displayCtrl MAGS_LIST_BOX_AREA) ctrlEnable false;
};

//======================================================================================================
//======================================================================================================
//Move logic
MRO_MoveItem =
{
	params ["_moveFrom","_moveTo"];

	//Check move to the same location
	if (_moveFrom == _moveTo) exitWith {
		MRO_dragging = DRAG_NONE;
	};

	//Check incorrect move
	if (_moveFrom == MOVE_NONE || {_moveTo == MOVE_NONE}) exitWith {
		systemChat format["MRO_MoveItem: unknown move. From '%1' To '%2'",_moveFrom,_moveTo];
	};

	//At this point MOVE can only be one of
	// LIST => SOURCE/TARGET
	// SOURCE => LIST/TARGET
	// TARGET => LIST/SOURCE

	//Move from list to target/source
	if (_moveFrom == MOVE_LIST) exitWith {
		//Get underlying item
		private _draggedItem = call MRO_PeekDraggedItem;

		//Check valid
		if (IS_EMPTY(_draggedItem)) exitWith {
			systemChat "MRO_MoveItem: dragging an empty item";
		};
		if (MRO_dragging < 0) exitWith {
			systemChat "MRO_MoveItem: attempt to move from list while dragging something else";
		};

		private _isSource = _moveTo == MOVE_SOURCE;
		private _moveTarget = if (_isSource) then {MRO_source} else {MRO_target};
		private _companion =  if (_isSource) then {MRO_target} else {MRO_source};

		//Check
		if (!IS_EMPTY(_moveTarget)) exitWith {
			systemChat "MRO_MoveItem: attempt to move from list to NON-empty";
		};
		if (!IS_EMPTY(_companion) && {(_draggedItem#CALIBER) isNotEqualTo (_companion#CALIBER)}) exitWith {
			systemChat "MRO_MoveItem: _draggedItem caliber does not match existing companion caliber";
		};

		//Extract dragged item from mags list
		private _itemToMove = MRO_dragging call MRO_ExtractFromList;
		if (isNil "_itemToMove") exitWith {
			systemChat "MRO_MoveItem: _itemToMove from LIST is nil";
		};

		//Set new item
		if (_isSource) then {
			MRO_source = _itemToMove;
		} else {
			MRO_target = _itemToMove;
		};
		call MRO_UpdateSourceAndTarget;

		//Update filter and lists
		MRO_currentFilter = _itemToMove#CALIBER;
		call MRO_UpdateListAndSelection;

		//Drop drag
		MRO_dragging = DRAG_NONE;
	};

	if (_moveFrom == MOVE_SOURCE || {_moveFrom == MOVE_TARGET}) exitWith {
		//Define helpers
		private _isSource = _moveFrom == MOVE_SOURCE;
		private _itemToMove =  if (_isSource) then {MRO_source} else {MRO_target};
		private _companion =   if (_isSource) then {MRO_target} else {MRO_source};
		//Check valid
		if (IS_EMPTY(_itemToMove)) exitWith {
			systemChat "MRO_MoveItem: attempt to move from empty";
		};
		if (_moveTo != MOVE_LIST && {!IS_EMPTY(_companion)}) exitWith {
			systemChat "MRO_MoveItem: attempt to move to NON-empty";
		};

		//Clear move from
		if (_isSource) then {
			MRO_source = [];
		} else {
			MRO_target = [];
		};

		//Move item to new location
		if (_moveTo == MOVE_LIST) then {
			_itemToMove call MRO_AddToList;
		} else {
			_companion resize 0;
			_companion append _itemToMove;
		};

		//Update right panel
		call MRO_UpdateSourceAndTarget;

		//Update filter and lists
		MRO_currentFilter = switch (true) do {
			case (!IS_EMPTY(MRO_source)): {MRO_source#CALIBER};
			case (!IS_EMPTY(MRO_target)): {MRO_target#CALIBER};
			default {AMMO_TYPE_ALL};
		};
		call MRO_UpdateListAndSelection;

		//Drop drag
		MRO_dragging = DRAG_NONE;
	};

	//else
	systemChat (format["MRO_MoveItem: unexpected moveFrom '%1'",_moveFrom]);
};

MRO_ExtractFromList =
{
	// private _index = _this;
	if (_this >= (count MRO_currentMagsList) || {_this < 0}) exitWith {
		systemChat (format["MRO_ExtractFromList: incorrect index '%1'",_this]);
	};

	//Check if last mag of its kind
	if (((MRO_currentMagsList#_this)#MAG_COUNT) <= 1) exitWith {MRO_currentMagsList deleteAt _this};

	//Else - create copy and change mag counts
	private _listRecord = MRO_currentMagsList#_this;
	private _result = _listRecord + [];
	_listRecord set [MAG_COUNT,((_listRecord#MAG_COUNT)-1)];
	_result set [MAG_COUNT,1];

	//return
	_result
};

MRO_AddToList =
{
	// private _item = _this;
	private _i = MRO_currentMagsList findIf {(_this#TYPE) isEqualTo (_x#TYPE) && {(_this#CUR_AMMO) == (_x#CUR_AMMO)}};
	if (_i != -1) then {
		(MRO_currentMagsList#_i) set [MAG_COUNT,(((MRO_currentMagsList#_i)#MAG_COUNT)+1)];
	} else {
		MRO_currentMagsList pushBack _this;
		MRO_currentMagsList sort true;
	};
};

//======================================================================================================
//======================================================================================================
//Repack process
MRO_repackHandle = scriptNull;

MRO_IsRepacking =
{
	//return
	(!isNull MRO_repackHandle && {!scriptDone MRO_repackHandle})
};

MRO_StartRepack =
{
	if (IS_EMPTY(MRO_source)) exitWith {
		systemChat "MRO_StartRepack: source is empty";
	};
	if (IS_EMPTY(MRO_target)) exitWith {
		systemChat "MRO_StartRepack: target is empty";
	};

	call MRO_StopRepack;
	MRO_repackHandle = [] spawn MRO_RepackCore;
};

MRO_StopRepack =
{
	if (call MRO_IsRepacking) then {
		terminate MRO_repackHandle;
	};

	MRO_repackHandle = scriptNull;
};

MRO_RepackCore =
{
	private _oldSource = MRO_source + [];
	private _oldTarget = MRO_target + [];

	private _stopRepack = {
		isNull DIALOG_WINDOW ||
		{IS_EMPTY(MRO_source) ||
		{IS_EMPTY(MRO_target) ||
		{(MRO_source#CUR_AMMO) <= 0 ||
		{(MRO_target#CUR_AMMO) >= (MRO_target#MAX_AMMO)}
	}}}};

	private _sleepTime = nil;
	private _updateSteps = nil;
	private _repackCore = nil;

	//This is very hard to read but as long as it works, I kinda don't care, because I'm into it for almost a week now =_=
	if ((MRO_source#IS_MG_BELT) && (MRO_target#IS_MG_BELT)) then {
		_sleepTime = TIME_PER_MG_BELT;
		_updateSteps = TIME_PER_MG_BELT;
		_repackCore = {
			MRO_source set [CUR_AMMO,((MRO_source#CUR_AMMO) - ((MRO_target#MAX_AMMO) - (MRO_target#CUR_AMMO)))];
			MRO_target set [CUR_AMMO,((MRO_target#CUR_AMMO) + ((MRO_target#MAX_AMMO) - (MRO_target#CUR_AMMO)) + (MRO_source#CUR_AMMO))];
			if ((MRO_target#CUR_AMMO) > (MRO_target#MAX_AMMO)) then {MRO_target set [CUR_AMMO,(MRO_target#MAX_AMMO)]};
			if ((MRO_source#CUR_AMMO) < 0) then {MRO_source set [CUR_AMMO,0]};
		};
	} else {
		_sleepTime = TIME_PER_BULLET;
		_updateSteps = if ((MRO_source#CUR_AMMO) >= ((MRO_target#MAX_AMMO) - (MRO_target#CUR_AMMO)))
			then {((MRO_target#MAX_AMMO) - (MRO_target#CUR_AMMO)) * TIME_PER_BULLET}
			else {(MRO_source#CUR_AMMO) * TIME_PER_BULLET};
		_repackCore = {
			MRO_source set [CUR_AMMO,((MRO_source#CUR_AMMO) - 1)];
			MRO_target set [CUR_AMMO,((MRO_target#CUR_AMMO) + 1)];
		};
	};

	//Start slider animation
	[REPACK_PROGRESS, [0,0], _updateSteps] call MRO_CtrlSetPos;

	//Setup text indication
	private _text = MRO_text#TEXT_REPACKING;
	private _textArray = [
		(format ["%1.",_text]),
		(format ["%1..",_text]),
		(format ["%1...",_text]),
		(format ["%1....",_text])
	];
	private _textIndex = 2;

	//Repack cycle
	private _nextTextUpdate = time + TIME_TEXT_UPDATE;
	private _nextLogicIteration = time + _sleepTime;
	waitUntil
	{
		uiSleep REPACK_CYCLE_RATE;
		if (call _stopRepack) exitWith {true};//Pre-check

		private _curTime = time;

		//Update text
		if (_curTime >= _nextTextUpdate) then
		{
			_nextTextUpdate = _curTime + TIME_TEXT_UPDATE;
			(DIALOG_WINDOW displayCtrl REPACKING_TEXT) ctrlSetText (_textArray#_textIndex);
			_textIndex = _textIndex + 1;
			if (_textIndex >= (count _textArray)) then {_textIndex = 0};
		};

		//Run repack logic
		if (_curTime >= _nextLogicIteration) exitWith
		{
			_nextLogicIteration = _curTime + _sleepTime;
			call _repackCore;

			//Change ammo sliders to show repack process
			[AMMO_SOURCE, [0,((0.12/(MRO_source#MAX_AMMO)) * ((MRO_source#MAX_AMMO) - (MRO_source#CUR_AMMO)))], 0] call MRO_CtrlSetPos;
			[AMMO_TARGET, [0,((0.12/(MRO_target#MAX_AMMO)) * ((MRO_target#MAX_AMMO) - (MRO_target#CUR_AMMO)))], 0] call MRO_CtrlSetPos;

			//Post-check
			(call _stopRepack)
		};

		//else - always return
		false
	};

	//Post-check if window was closed - cancel everything
	if (isNull DIALOG_WINDOW) exitWith {};

	//Apply repack
	private _sourceDone = false;
	private _targetDone = false;
	{
		//Check if this container has source or target
		private _container = _x;
		private _allOldMags = magazinesAmmoCargo _container;
		private _sourceIndex = switch (true) do {
			case (_sourceDone): {-1};
			default {
				_allOldMags findIf {(_x#TYPE) isEqualTo (MRO_source#TYPE) && {(_x#CUR_AMMO) == (_oldSource#CUR_AMMO)}}
			};
		};
		private _targetIndex = switch (true) do {
			case (_targetDone): {-1};
			case (_sourceIndex == -1): {
				_allOldMags findIf {(_x#TYPE) isEqualTo (MRO_target#TYPE) && {(_x#CUR_AMMO) == (_oldTarget#CUR_AMMO)}}
			};
			default {
				private _index = -1;
				{
					if ((_x#TYPE) isEqualTo (MRO_target#TYPE) && {(_x#CUR_AMMO) == (_oldTarget#CUR_AMMO) && {_forEachIndex != _sourceIndex}}) exitWith {
						_index = _forEachIndex;
					};
				} forEach _allOldMags;
				_index
			};
		};

		//Check if any
		if (_sourceIndex == -1 && {_targetIndex == -1}) then {continue};

		//Delete all mags
		clearMagazineCargoGlobal _container;

		//Try modify source
		if (_sourceIndex != -1) then {
			if ((MRO_source#CUR_AMMO) <= 0 && {!ADD_EMPTIED_MAGS_BACK}) then {
				_allOldMags deleteAt _sourceIndex;
			} else {
				(_allOldMags#_sourceIndex) set [CUR_AMMO,(MRO_source#CUR_AMMO)];
			};
			_sourceDone = true;
		};

		//Try modify target
		if (_targetIndex != -1) then {
			(_allOldMags#_targetIndex) set [CUR_AMMO,(MRO_target#CUR_AMMO)];
			_targetDone = true;
		};

		//Repack mag array to add back format (has different structure [_type,_magCount,_ammoCount])
		private _allNewMags = [];
		while { (count _allOldMags) > 0 } do
		{
			private _cur = _allOldMags deleteAt ((count _allOldMags) - 1);
			private _newMagIndex = _allNewMags findIf {(_x#TYPE) isEqualTo (_cur#TYPE) && {(_x#2) == (_cur#CUR_AMMO)}};
			if (_newMagIndex != -1) then {
				//Increase mag count
				(_allNewMags#_newMagIndex) set [1,(((_allNewMags#_newMagIndex)#1)+1)];
			} else {
				//Add new record
				_allNewMags pushBack [(_cur#TYPE),1,(_cur#CUR_AMMO)];
			};
		};

		//Re-add mags
		{_container addMagazineAmmoCargo _x} forEach _allNewMags;
		if (_sourceDone && _targetDone) exitWith {};
	} forEach [(uniformContainer player),(vestContainer player),(backpackContainer player)];

	//Cache
	_oldSource = nil;
	_oldTarget = nil;
	_oldSource = MRO_source;
	_oldTarget = MRO_target;

	//Generate new mags list
	call MRO_DefaultFields;
	MRO_currentMagsList = call MRO_GenerateMagsList;

	//Reset left window part
	call MRO_UpdateListAndSelection;

	//Reset right window part
	call MRO_UpdateSourceAndTarget;
	call MRO_ClearRepackUI;

	//Try to re-add source and target by emulating user input
	if ((_oldSource#CUR_AMMO) > 0) then {
		private _m = MRO_currentMagsList findIf {(_x#TYPE) isEqualTo (_oldSource#TYPE) && {(_x#CUR_AMMO) == (_oldSource#CUR_AMMO)}};
		if (_m != -1) then {
			MRO_dragging = _m;
			[MOVE_LIST,MOVE_SOURCE] call MRO_MoveItem;
		};
	};

	if ((_oldTarget#CUR_AMMO) < (_oldTarget#MAX_AMMO)) then {
		private _n = MRO_currentMagsList findIf {(_x#TYPE) isEqualTo (_oldTarget#TYPE) && {(_x#CUR_AMMO) == (_oldTarget#CUR_AMMO)}};
		if (_n != -1) then {
			MRO_dragging = _n;
			[MOVE_LIST,MOVE_TARGET] call MRO_MoveItem;
		};
	};
};

//======================================================================================================
//======================================================================================================
//Get magazine info
MRO_magInfoCache = createHashMap;

MRO_GenerateMagsList =
{
	private _magsLocations = 	[
		(magazinesAmmoCargo uniformContainer player),
		(magazinesAmmoCargo vestContainer player),
		(magazinesAmmoCargo backpackContainer player)
	];

	private _result = [];

	//Process all mags and gather mags info
	//For every location
	for "_i" from 0 to ((count _magsLocations)-1) do
	{
		//For every mag in this location
		private _magsOfLocation = _magsLocations#_i;
		for "_j" from 0 to ((count _magsOfLocation)-1) do
		{
			//Extract values
			private _curType = (_magsOfLocation#_j)#0;//[=>"30Rnd_65x39_caseless_mag",30]
			private _curAmmo = (_magsOfLocation#_j)#1;//["30Rnd_65x39_caseless_mag",=>30]

			//Try get cached info
			private _cachedInfo = MRO_magInfoCache get _curType;

			//If there is no such record yet, create new cache entry
			if (isNil "_cachedInfo") then
			{
				//Get caliber and check if mag repack supported
				private _caliber = _curType call MRO_GetCaliber;
				if (_caliber isEqualTo "UNKNOWN") exitWith {
					_cachedInfo = false;
					MRO_magInfoCache set [_curType,false];
				};

				//Add new info record
				private _maxAmmo = getNumber (configfile >> "CfgMagazines" >> _curType >> "count");
				_cachedInfo = [
					/*NaN*/nil,
					/*NaN*/nil,
					/*MAX_AMMO*/_maxAmmo,
					/*NaN*/nil,
					/*CALIBER*/_caliber,
					/*IS_MG_BELT*/(_maxAmmo > 100 || {(getText (configFile >> "CfgMagazines" >> _curType >> "nameSound")) isEqualTo "mGun"}),
					/*DISPLAY_NAME*/(getText (configfile >> "CfgMagazines" >> _curType >> "displayName"))
				];
				MRO_magInfoCache set [_curType,_cachedInfo];
			};

			//If this mag is not supported - skip
			if (_cachedInfo isEqualTo false) then {continue};

			//If mag is full and full mags disabled - skip
			if (!MRO_isShowFullMags && {_curAmmo >= (_cachedInfo#MAX_AMMO)}) then {continue};

			//Check if already added (just need to increase mags count) (location we ignore on purpose - it doesn't matter for further logic)
			private _k = _result findIf {(_x#TYPE) isEqualTo _curType && {(_x#CUR_AMMO) == _curAmmo}};
			if (_k != -1) then {
				(_result#_k) set [MAG_COUNT,(((_result#_k)#MAG_COUNT) + 1)];
				continue;
			};

			//Add new result entry
			_result pushBack [
				/*TYPE*/_curType,
				/*CUR_AMMO*/_curAmmo,
				/*MAX_AMMO*/(_cachedInfo#MAX_AMMO),
				/*MAG_COUNT*/1,
				/*CALIBER*/(_cachedInfo#CALIBER),
				/*IS_MG_BELT*/(_cachedInfo#IS_MG_BELT),
				/*DISPLAY_NAME*/(_cachedInfo#DISPLAY_NAME)
			];
		};
	};

	//Sort
	_result sort true;

	//return
	_result
};

//======================================================================================================
//======================================================================================================
//Mag ammo caliber definition
MRO_typeToCaliberMap = [
	//Rifle 5
	["_545x39_","5.45x39"],
	["_556x45_","5.56x45"],
	["_570x28_","5.7x28"],
	["_580x42_","5.8x42"],
	//Rifle 6
	["_65x39_cased_","6.5x39 cased"],
	["_650x39_Cased_","6.5x39 cased"],
	["_65x39_caseless_","6.5x39 caseless"],
	["_680x43_","6.8x43"],
	["_68x43_","6.8x43"],
	//Rifle 7
	["_75x55_","7.5x55"],
	["_762x25_","7.62x25"],
	["_762x35_","7.62x35"],
	["_762x39_","7.62x39"],
	["_762x51_","7.62x51"],
	["_762x51mm_","7.62x51"],
	["_762_M80A1","7.62x51"],
	["_762x54_","7.62x54"],
	["_762x54R_","7.62x54"],
	["_762x67_","7.62x67"],
	["_792x57_","7.92x57"],
	//Rifle 9
	["_9x39_","9x39"],
	["_93x64_","9.3x64"],
	//12.7
	["_127x33_","12.7x33"],
	["_127x54_","12.7x54"],
	["_127x99_","12.7x99"],
	["_127x108_","12.7x108"],
	//Special
	["_22_LR_","22LR"],
	["_300BLK_","300BLK"],
	["_300WM_","300WM"],
	["_303_","303"],
	["_338_","338"],
	["_86x70_","338"],
	["_408_","408"],
	["_40SW_","40SW"],
	["_40sw_","40SW"],
	["_50BW_","50BW"],
	["_Sa58_","Sa58"],
	//Pistol & PDW
	["_45ACP_","45ACP"],
	["_357SIG_","9mm (9x22)"],
	["_9x21_","9mm (9x21)"],
	["_9x19_","9mm (9x19)"],
	["_9x19AP_","9mm (9x19)"],
	["_9x19mm_","9mm (9x19)"],
	["_9x18_","9mm (9x18)"],
	["_765x17_","32ACP"],
	["_50AE_","50AE"],
	["_46x30_","4.6x30"],
	["_460x30_","4.6x30"],
	["_10mm_","10mm"],
	["_3006_","30-06"],
	//12 Gauge
	["_Pellets","12 Gauge"],
	["_Slug","12 Gauge"],
	["_Buck","12 Gauge"],
	["AA40_HE","12 Gauge"],
	//HE
	["Rnd_HE","HE round"],
	["_25x40mm_","HE round"],
	//Signal pistol
	["_GreenSignal_","Green signal"],
	["_RedSignal_","Red signal"]
];

MRO_GetCaliber =
{
	// private _magType = _this;
	private _i = MRO_typeToCaliberMap findIf {(_x#0) in _this};
	//return
	if (_i != -1) then {((MRO_typeToCaliberMap#_i)#1)} else {"UNKNOWN"}
};