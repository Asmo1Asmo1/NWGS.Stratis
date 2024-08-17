#define DIALOGUE_NAME "vehicleCustomization"
#define LEFT_BOX_IDD 1500
#define RIGHT_BOX_IDD 1501
#define TITLE_TEMPLATE "[ %1 ]"

NWG_VCUI_CreateCustomizationUI = {
    disableSerialization;
    params ["_vehicle","_leftTitle","_rightTitle"];

    //Check argument
    if (isNull _vehicle || {!alive _vehicle}) exitWith {
        (format ["NWG_VCUI_CreateCustomizationUI: Invalid arg '%1'",_vehicle]) call NWG_fnc_logError;
        false
    };

    //Create GUI
    private _gui = createDialog [DIALOGUE_NAME,true];
    if (isNull _gui) exitWith {
        "NWG_VCUI_CustomizePylons: Failed to create GUI" call NWG_fnc_logError;
        false
    };

    //Get GUI panels
    private _leftPanel = _gui displayCtrl LEFT_BOX_IDD;
    private _rightPanel = _gui displayCtrl RIGHT_BOX_IDD;
    if (isNull _leftPanel || {isNull _rightPanel}) exitWith {
        "NWG_VCUI_CreateCustomizationUI: Failed to get UI panels" call NWG_fnc_logError;
        false
    };

    //Create camera
    /*Fix camera sliding away in 3rd person view by enforcing 1st person*/
    private _origView = toUpper cameraView;
    if (_origView isNotEqualTo "INTERNAL") then {
        player switchCamera "INTERNAL";
    };
    _gui setVariable ["NWG_VCUI_origView",_origView];

    private _camera = _vehicle call {
        private _vehicle = _this;
        //Calculate future camera position
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
    _gui setVariable ["NWG_VCUI_camera",_camera];
    _gui displayAddEventHandler ["Unload", {
        // params ["_display","_exitCode"];
        private _gui = _this select 0;
        switchCamera player;

        /*Fix 1st|3rd person view incosistency after camera slide fix*/
        private _origView = _gui getVariable "NWG_VCUI_origView";
        player switchCamera _origView;

        private _camera = _gui getVariable "NWG_VCUI_camera";
        _camera cameraEffect ["terminate","back"];
        camDestroy _camera;
    }];

    //Add titles
    _leftPanel  lbAdd (format [TITLE_TEMPLATE,(_leftTitle call NWG_fnc_localize)]);
    _rightPanel lbAdd (format [TITLE_TEMPLATE,(_rightTitle call NWG_fnc_localize)]);

    //Return
    [_gui,_leftPanel,_rightPanel]
};