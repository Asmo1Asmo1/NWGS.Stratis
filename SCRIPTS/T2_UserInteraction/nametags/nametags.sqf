//======================================================================================================
//======================================================================================================
//Defines
#define MAX_DISTANCE 15
#define TEXT_SIZE 0.04

//======================================================================================================
//======================================================================================================
//Settings
NWG_NMTGS_Settings = createHashMapFromArray [
	["TEXT_SIZE",0.04],
	["TEXT_COLOR",((getArray (configFile/'CfgInGameUI'/'SideColors'/'colorFriendly')))],
	["TEXT_FONT","EtelkaMonospacePro"],

	["FUNC_GET_NPC_NAME",   {if !(call NWG_fnc_dlgIsOpen) then {_this call NWG_fnc_dlgGetNpcNameLocalized} else {""}}],
	["FUNC_GET_PLAYER_NAME",{format ["[lvl.%1] %2",(_this call NWG_fnc_pGetPlayerLevel),(name _this)]}],

	["",0]
];

//======================================================================================================
//======================================================================================================
//Init
private _Init = {
	addMissionEventHandler ["Draw3D",{call NWG_NMTGS_TryDraw}];
};

//======================================================================================================
//======================================================================================================
//Try draw nametags each frame
NWG_NMTGS_TryDraw = {
	//Aquire target
    if (isNull (call NWG_fnc_radarGetUnitInFront)) exitWith {};
	private _target = call NWG_fnc_radarGetUnitInFront;

	//Get target name
	private _targetName = if (isPlayer _target)
		then {_target call (NWG_NMTGS_Settings get "FUNC_GET_PLAYER_NAME")}
		else {_target call (NWG_NMTGS_Settings get "FUNC_GET_NPC_NAME")};
	if (_targetName isEqualTo "") exitWith {};

    //Draw the text
    drawIcon3D [
    /*texture*/     "",
    /*color*/       (NWG_NMTGS_Settings get "TEXT_COLOR"),
    /*position*/    (_target modelToWorldVisual ((_target selectionPosition "head") vectorAdd [0,0,(((cameraOn distance2D _target) ^ (1/3)) / 3)])),//Unexplainable magic formula
    /*icon width*/  0,//We don't need that since we're displaying text only
    /*icon height*/ 0,
    /*icon angle*/  0,
    /*text*/        _targetName,
    /*shadow*/      2,//With outline
    /*textSize*/    (NWG_NMTGS_Settings get "TEXT_SIZE"),
    /*text font*/   (NWG_NMTGS_Settings get "TEXT_FONT")
    ];
};

//======================================================================================================
//======================================================================================================
call _Init;