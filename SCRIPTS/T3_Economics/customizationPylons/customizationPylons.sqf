/*
    Reference used: SetupPylons by Artemoz
    This is NOT the same script, but a cut-down and reworked version of it because I wanted to:
    a) Allow it to be put in public (never got such permission from Artemoz)
    b) Make it consistent with appearanceCustomization and use the same UI

    Differences are:
    - Uses custom camera view instead of no changes to camera
    - Uses the same UI as appearanceCustomization instead of custom UI by Artemoz
    - Does not support precise pylon customization, only presets (about 3/4 of functionality is removed)
    - Rearranged and refactored code

    @Asmo
*/

//================================================================================================================
//================================================================================================================
//Defines
#define DIALOGUE_NAME "vehicleCustomization"
#define LEFT_BOX_IDD 1500
#define RIGHT_BOX_IDD 1501
#define TITLE_TEMPLATE "[ %1 ]"

//================================================================================================================
//================================================================================================================
//Methods
NWG_CPYL_CanCustomizePylons = {
    // private _vehicle = _this;
    "true" configClasses (configOf _this >> "Components" >> "TransportPylonsComponent") isNotEqualTo []
};

NWG_CPYL_CustomizePylons = {
    disableSerialization;
    private _vehicle = _this;

    //Check argument
    if !(_vehicle call NWG_CPYL_CanCustomizePylons) exitWith {
        (format ["NWG_CPYL_CustomizePylons: %1 cannot be customized",(typeOf _vehicle)]) call NWG_fnc_logError;
    };

    //Create GUI
    private _gui = createDialog [DIALOGUE_NAME,true];
    if (isNull _gui) exitWith {
        "NWG_CPYL_CustomizePylons: Failed to create GUI" call NWG_fnc_logError;
    };
    _gui setVariable ["NWG_CPYL_vehicle",_vehicle];

    //Init the left panel (pylon presets)
    private _leftPanel = _gui displayCtrl LEFT_BOX_IDD;
    _leftPanel lbAdd (format [TITLE_TEMPLATE,("#CPYL_LEFT_TITLE#" call NWG_fnc_localize)]);
    private _presets = "true" configClasses (configOf _vehicle >> "Components" >> "TransportPylonsComponent" >> "Presets");
    private _picture = getText (configOf _vehicle >> "icon");
	{
		private _i = _leftPanel lbAdd (getText (_x >> "displayName"));
		_leftPanel lbSetData [_i, (configName _x)];
        _leftPanel lbSetPicture [_i, _picture];
	} forEach _presets;

    //Init the right panel (pylon owner)
    private _rightPanel = _gui displayCtrl RIGHT_BOX_IDD;
    _rightPanel lbAdd (format [TITLE_TEMPLATE,("#CPYL_RIGHT_TITLE#" call NWG_fnc_localize)]);
    _rightPanel lbAdd ("#CPYL_OWNER_PILOT#" call NWG_fnc_localize);
    _rightPanel lbAdd ("#CPYL_OWNER_GUNNER#" call NWG_fnc_localize);

    //Create camera
    /*<Fix camera sliding away in 3rd person view>*/
    private _origView = toUpper cameraView;
    if (_origView isNotEqualTo "INTERNAL") then {
        player switchCamera "INTERNAL";
    };
    _gui setVariable ["NWG_CPYL_origView",_origView];
    /*</Fix camera sliding away in 3rd person view>*/

    private _camera = _vehicle call {
        private _vehicle = _this;
        //Calculate camera position
        private _bb = boundingBoxReal _vehicle;//[[bbMin],[bbMax],radius]
        private _bbRadius = _bb#2;
        private _bbHeight = ((_bb#1)#2) * 2;//*2 to make it higher
        private _dirToCamera = (getDir _vehicle) - 45;//45 degrees to the left
        if (_dirToCamera < 0) then {_dirToCamera = _dirToCamera + 360};//Normalize
        private _cameraPos = _vehicle getPos [_bbRadius,_dirToCamera];
        _cameraPos set [2,(_cameraPos#2) + _bbHeight];//Height
        //Create and place camera
        private _camera = "camera" camCreate _cameraPos;
        _camera setPosASL (getPosASL _camera);
        //Make camera look at the vehicle
        private _dirVectorNormalized = vectorNormalized ((getPosASL _vehicle) vectorDiff (getPosASL _camera));
        _camera setVectorDirAndUp [_dirVectorNormalized,[0,0,1]];
        //return
        _camera
    };
    switchCamera _camera;
    _gui setVariable ["NWG_CPYL_camera",_camera];
    _gui displayAddEventHandler ["Unload", {
        // params ["_display","_exitCode"];
        private _gui = _this select 0;
        switchCamera player;

        /*<Fix camera sliding away in 3rd person view>*/
        private _origView = _gui getVariable "NWG_CPYL_origView";
        player switchCamera _origView;
        /*</Fix camera sliding away in 3rd person view>*/

        private _camera = _gui getVariable "NWG_CPYL_camera";
        _camera cameraEffect ["terminate","back"];
        camDestroy _camera;
	}];
};