//================================================================================================================
//================================================================================================================
//Prepare variables and collections
params ["_flag"];

NWG_SER_IsServermod = _flag isNotEqualTo "";
private _isDevBuild = (is3DENPreview || {is3DENMultiplayer});

private _commonFunctions = [];//Functions to be run on server and client both
private _serverFunctions = [];//Functions to be run on server only
private _clientFunctions = [];//Functions to be run on client only

private _serverModules = [];//Modules to be run on server only
private _clientModules = [];//Modules to be run on client only

//================================================================================================================
//================================================================================================================
//Prepare compilation script
NWG_fnc_compile = {
    // private _fileAddress = _this;
    private _fileAddress = (if (NWG_SER_IsServermod) then {(format ["NWG\%1",_this])} else {_this});

    //return
    (if (fileExists _fileAddress) then {
        (compileFinal preprocessFileLineNumbers _fileAddress)
    } else {
        diag_log formatText ["  [ERROR] #### File not found: %1", _fileAddress];
        {}//Return empty code block
    })
};

//================================================================================================================
//================================================================================================================
//Compile functions and modules

//T0_Core
//commonFunctions
_commonFunctions pushBack ("SCRIPTS\T0_Core\commonFunctions.sqf" call NWG_fnc_compile);
if (_isDevBuild) then {_commonFunctions pushBack ("SCRIPTS\T0_Core\commonTestFunctions.sqf" call NWG_fnc_compile)};
//eventSystem
_serverModules pushBack ("SCRIPTS\T0_Core\eventSystem\eventSystem.sqf" call NWG_fnc_compile);
_clientModules pushBack ("SCRIPTS\T0_Core\eventSystem\eventSystem.sqf" call NWG_fnc_compile);
_commonFunctions pushBack ("SCRIPTS\T0_Core\eventSystem\eventSystemFunctions.sqf" call NWG_fnc_compile);

//T1_Battlefield
//advancedCombat
_serverModules pushBack ("SCRIPTS\T1_Battlefield\advancedCombat\advancedCombatActive.sqf" call NWG_fnc_compile);
_serverModules pushBack ("SCRIPTS\T1_Battlefield\advancedCombat\advancedCombatPassive.sqf" call NWG_fnc_compile);
_serverFunctions pushBack ("SCRIPTS\T1_Battlefield\advancedCombat\advancedCombatFunctions.sqf" call NWG_fnc_compile);
//dots
_serverModules pushBack ("SCRIPTS\T1_Battlefield\dots\dots.sqf" call NWG_fnc_compile);
_serverFunctions pushBack ("SCRIPTS\T1_Battlefield\dots\dotsFunctions.sqf" call NWG_fnc_compile);
if (_isDevBuild) then {_serverModules pushBack ("SCRIPTS\T1_Battlefield\dots\dotsTests.sqf" call NWG_fnc_compile)};
//dspawn
_serverModules pushBack ("SCRIPTS\T1_Battlefield\dspawn\dspawn.sqf" call NWG_fnc_compile);
_serverFunctions pushBack ("SCRIPTS\T1_Battlefield\dspawn\dspawnFunctions.sqf" call NWG_fnc_compile);
if (_isDevBuild) then {_serverModules pushBack ("SCRIPTS\T1_Battlefield\dspawn\dspawnTests.sqf" call NWG_fnc_compile)};
if (_isDevBuild) then {_serverModules pushBack ("SCRIPTS\T1_Battlefield\dspawn\dspawnDev.sqf" call NWG_fnc_compile)};
//garbageCollector
_serverModules pushBack ("SCRIPTS\T1_Battlefield\garbageCollector\GCServerSide.sqf" call NWG_fnc_compile);
_clientModules pushBack ("SCRIPTS\T1_Battlefield\garbageCollector\GCClientSide.sqf" call NWG_fnc_compile);
_commonFunctions pushBack ("SCRIPTS\T1_Battlefield\garbageCollector\GCFunctions.sqf" call NWG_fnc_compile);
//objectClassificator
_serverModules pushBack ("SCRIPTS\T1_Battlefield\objectClassificator\objectClassificator.sqf" call NWG_fnc_compile);
_serverFunctions pushBack ("SCRIPTS\T1_Battlefield\objectClassificator\objectClassificatorFunctions.sqf" call NWG_fnc_compile);
if (_isDevBuild) then {_serverModules pushBack ("SCRIPTS\T1_Battlefield\objectClassificator\objectClassificatorTests.sqf" call NWG_fnc_compile)};
//spawner
_serverModules pushBack ("SCRIPTS\T1_Battlefield\spawner\spawner.sqf" call NWG_fnc_compile);
_serverFunctions pushBack ("SCRIPTS\T1_Battlefield\spawner\spawnerFunctions.sqf" call NWG_fnc_compile);
if (_isDevBuild) then {_serverModules pushBack ("SCRIPTS\T1_Battlefield\spawner\spawnerTests.sqf" call NWG_fnc_compile)};
//stateHolder
_serverModules pushBack ("SCRIPTS\T1_Battlefield\stateHolder\stateHolder.sqf" call NWG_fnc_compile);
_serverFunctions pushBack ("SCRIPTS\T1_Battlefield\stateHolder\stateHolderFunctions.sqf" call NWG_fnc_compile);
//ukrep
_serverModules pushBack ("SCRIPTS\T1_Battlefield\ukrep\ukrepPlacement.sqf" call NWG_fnc_compile);
_serverFunctions pushBack ("SCRIPTS\T1_Battlefield\ukrep\ukrepFunctionsServer.sqf" call NWG_fnc_compile);
_clientFunctions pushBack ("SCRIPTS\T1_Battlefield\ukrep\ukrepFunctionsClient.sqf" call NWG_fnc_compile);
if (_isDevBuild) then {_serverModules pushBack ("SCRIPTS\T1_Battlefield\ukrep\ukrepGathering.sqf" call NWG_fnc_compile)};
if (_isDevBuild) then {_serverModules pushBack ("SCRIPTS\T1_Battlefield\ukrep\ukrepTests.sqf" call NWG_fnc_compile)};
//undertaker
_serverModules pushBack ("SCRIPTS\T1_Battlefield\undertaker\undertaker.sqf" call NWG_fnc_compile);
//yellowKing
_serverModules pushBack ("SCRIPTS\T1_Battlefield\yellowKing\yellowKing.sqf" call NWG_fnc_compile);

//T2_UserInteraction
//magrepack
_clientModules pushBack ("SCRIPTS\T2_UserInteraction\magrepack\magrepack.sqf" call NWG_fnc_compile);
//markers
_serverModules pushBack ("SCRIPTS\T2_UserInteraction\markers\markersServerSide.sqf" call NWG_fnc_compile);
_clientModules pushBack ("SCRIPTS\T2_UserInteraction\markers\markersClientSide.sqf" call NWG_fnc_compile);
_commonFunctions pushBack ("SCRIPTS\T2_UserInteraction\markers\markersFunctions.sqf" call NWG_fnc_compile);
if (_isDevBuild) then {_serverModules pushBack ("SCRIPTS\T2_UserInteraction\markers\markersTests.sqf" call NWG_fnc_compile)};
//playerRadar
_clientModules pushBack ("SCRIPTS\T2_UserInteraction\playerRadar\playerRadar.sqf" call NWG_fnc_compile);
_clientFunctions pushBack ("SCRIPTS\T2_UserInteraction\playerRadar\playerRadarFunctions.sqf" call NWG_fnc_compile);
if (_isDevBuild) then {_clientModules pushBack ("SCRIPTS\T2_UserInteraction\playerRadar\playerRadarTests.sqf" call NWG_fnc_compile)};
//viewDistance
_clientModules pushBack ("SCRIPTS\T2_UserInteraction\viewDistance\viewDistance.sqf" call NWG_fnc_compile);

//================================================================================================================
//================================================================================================================
//ServerSide
{call _x} forEach _commonFunctions;
{call _x} forEach _serverFunctions;
{call _x} forEach _serverModules;

//================================================================================================================
//================================================================================================================
//Send to Players
NWG_SER_toSendToPlayer = [];
NWG_SER_toSendToPlayer append _commonFunctions;
NWG_SER_toSendToPlayer append _clientFunctions;
NWG_SER_toSendToPlayer append _clientModules;

NWG_fnc_playerScriptsRequest = {
    params ["_playerObj","_language"];

    //Network check
    private _callerID = remoteExecutedOwner;
    if (isDedicated && {_callerID == 0 && {local _playerObj}}) exitWith {
        diag_log formatText ["%1(%2) [ERROR] %3", __FILE__, __LINE__,  "#### NWG_fnc_playerScriptsRequest: Caller can not be identified"];
    };
    private _recipient = if (_callerID != 0) then {_callerID} else {_playerObj};

    //Send
    NWG_SER_toSendToPlayer remoteExec ["NWG_fnc_clientScriptsReceive",_recipient];
};

//================================================================================================================
//================================================================================================================
//Finalize
NWG_SER_CompilationDone = true;