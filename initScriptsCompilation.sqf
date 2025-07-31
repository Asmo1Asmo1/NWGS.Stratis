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
    private _fileAddress = if (NWG_SER_IsServermod) then {format ["NWGS\%1",_this]} else {_this};
    if !(fileExists _fileAddress) exitWith {
        diag_log formatText ["  [ERROR] #### File not found: %1", _fileAddress];
        {}//Return empty code block
    };

    //else - return compiled code
    compileFinal (preprocessFileLineNumbers _fileAddress)
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
//remoteQueue
_serverModules pushBack ("SCRIPTS\T0_Core\remoteQueue\remoteQueueServer.sqf" call NWG_fnc_compile);
// _clientModules pushBack ("SCRIPTS\T0_Core\remoteQueue\remoteQueueClient.sqf" call NWG_fnc_compile);//Moved to the end of compilation sequence (must be executed last)
_commonFunctions pushBack ("SCRIPTS\T0_Core\remoteQueue\remoteQueueFunctions.sqf" call NWG_fnc_compile);

//T1_Battlefield
//advancedCombat
_serverModules pushBack ("SCRIPTS\T1_Battlefield\advancedCombat\advancedCombatActive.sqf" call NWG_fnc_compile);
_serverModules pushBack ("SCRIPTS\T1_Battlefield\advancedCombat\advancedCombatPassive.sqf" call NWG_fnc_compile);
_serverModules pushBack ("SCRIPTS\T1_Battlefield\advancedCombat\advancedCombatUtils.sqf" call NWG_fnc_compile);
_serverModules pushBack ("SCRIPTS\T1_Battlefield\advancedCombat\missionMachineConnector.sqf" call NWG_fnc_compile);
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
//kostyli
_serverModules pushBack ("SCRIPTS\T1_Battlefield\kostyli\kostyliServer.sqf" call NWG_fnc_compile);
//missionMachine
_serverModules pushBack ("SCRIPTS\T1_Battlefield\missionMachine\missionMachineSettings.sqf" call NWG_fnc_compile);
_serverModules pushBack ("SCRIPTS\T1_Battlefield\missionMachine\missionMachineServerSide.sqf" call NWG_fnc_compile);
_serverModules pushBack ("SCRIPTS\T1_Battlefield\missionMachine\databaseConnector.sqf" call NWG_fnc_compile);
_serverModules pushBack ("SCRIPTS\T1_Battlefield\missionMachine\baseNpcPositionFix.sqf" call NWG_fnc_compile);
_clientModules pushBack ("SCRIPTS\T1_Battlefield\missionMachine\missionMachineClientSide.sqf" call NWG_fnc_compile);
_commonFunctions pushBack ("SCRIPTS\T1_Battlefield\missionMachine\missionMachineFunctions.sqf" call NWG_fnc_compile);
if (_isDevBuild) then {_serverModules pushBack ("SCRIPTS\T1_Battlefield\missionMachine\missionMachineTests.sqf" call NWG_fnc_compile)};
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
//worldConfig
_serverModules pushBack ("SCRIPTS\T1_Battlefield\worldConfig\worldConfigCommon.sqf" call NWG_fnc_compile);
_clientModules pushBack ("SCRIPTS\T1_Battlefield\worldConfig\worldConfigCommon.sqf" call NWG_fnc_compile);
_serverModules pushBack ("SCRIPTS\T1_Battlefield\worldConfig\worldConfigServer.sqf" call NWG_fnc_compile);
_commonFunctions pushBack ("SCRIPTS\T1_Battlefield\worldConfig\worldConfigFunctions.sqf" call NWG_fnc_compile);
//yellowKing
_serverModules pushBack ("SCRIPTS\T1_Battlefield\yellowKing\yellowKing.sqf" call NWG_fnc_compile);
_serverModules pushBack ("SCRIPTS\T1_Battlefield\yellowKing\missionMachineConnector.sqf" call NWG_fnc_compile);
_serverFunctions pushBack ("SCRIPTS\T1_Battlefield\yellowKing\yellowKingFunctions.sqf" call NWG_fnc_compile);

//T2_UserInteraction
//actionsInVehicle
_clientModules pushBack ("SCRIPTS\T2_UserInteraction\actionsInVehicle\actionsInVehicle.sqf" call NWG_fnc_compile);
_clientFunctions pushBack ("SCRIPTS\T2_UserInteraction\actionsInVehicle\actionsInVehicleFunctions.sqf" call NWG_fnc_compile);
_serverFunctions pushBack ("SCRIPTS\T2_UserInteraction\actionsInVehicle\actionsInVehicleFunctionsServer.sqf" call NWG_fnc_compile);
//actionsItems
_serverModules pushBack ("SCRIPTS\T2_UserInteraction\actionsItems\actionsItemsServer.sqf" call NWG_fnc_compile);
_serverModules pushBack ("SCRIPTS\T2_UserInteraction\actionsItems\missionMachineConnector.sqf" call NWG_fnc_compile);
_serverModules pushBack ("SCRIPTS\T2_UserInteraction\actionsItems\ukrepConnector.sqf" call NWG_fnc_compile);
_serverModules pushBack ("SCRIPTS\T2_UserInteraction\actionsItems\taxiConnector.sqf" call NWG_fnc_compile);
_clientModules pushBack ("SCRIPTS\T2_UserInteraction\actionsItems\actionsItemsClient.sqf" call NWG_fnc_compile);
if (_isDevBuild) then {_clientModules pushBack ("SCRIPTS\T2_UserInteraction\actionsItems\actionsItemsClientTest.sqf" call NWG_fnc_compile)};
_clientModules pushBack ("SCRIPTS\T2_UserInteraction\actionsItems\taxiConnector.sqf" call NWG_fnc_compile);//Both client and server
_commonFunctions pushBack ("SCRIPTS\T2_UserInteraction\actionsItems\actionsItemsFunctions.sqf" call NWG_fnc_compile);
//actionsKeybind
_clientModules pushBack ("SCRIPTS\T2_UserInteraction\actionsKeybind\actionsKeybind.sqf" call NWG_fnc_compile);
_clientFunctions pushBack ("SCRIPTS\T2_UserInteraction\actionsKeybind\actionsKeybindFunctions.sqf" call NWG_fnc_compile);
//additionalWeapon
_clientModules pushBack ("SCRIPTS\T2_UserInteraction\additionalWeapon\additionalWeapon.sqf" call NWG_fnc_compile);
_clientModules pushBack ("SCRIPTS\T2_UserInteraction\additionalWeapon\additionalWeaponCommon.sqf" call NWG_fnc_compile);
_serverModules pushBack ("SCRIPTS\T2_UserInteraction\additionalWeapon\additionalWeaponCommon.sqf" call NWG_fnc_compile);
_commonFunctions pushBack ("SCRIPTS\T2_UserInteraction\additionalWeapon\additionalWeaponFunctions.sqf" call NWG_fnc_compile);
//adminTools
_serverModules pushBack ("SCRIPTS\T2_UserInteraction\adminTools\adminToolsServer.sqf" call NWG_fnc_compile);
_serverFunctions pushBack ("SCRIPTS\T2_UserInteraction\adminTools\adminToolsFunctions.sqf" call NWG_fnc_compile);
//antiAbuse
_clientModules pushBack ("SCRIPTS\T2_UserInteraction\antiAbuse\antiAbuse.sqf" call NWG_fnc_compile);
//groupNames
_serverModules pushBack ("SCRIPTS\T2_UserInteraction\groupNames\groupNamesServer.sqf" call NWG_fnc_compile);
//inventoryManager
_clientModules pushBack ("SCRIPTS\T2_UserInteraction\inventoryManager\inventoryManager.sqf" call NWG_fnc_compile);
_clientFunctions pushBack ("SCRIPTS\T2_UserInteraction\inventoryManager\inventoryManagerFunctions.sqf" call NWG_fnc_compile);
if (_isDevBuild) then {_clientModules pushBack ("SCRIPTS\T2_UserInteraction\inventoryManager\inventoryManagerTests.sqf" call NWG_fnc_compile)};
//inventoryUI
_clientModules pushBack ("SCRIPTS\T2_UserInteraction\inventoryUI\inventoryUI.sqf" call NWG_fnc_compile);
if (_isDevBuild) then {_clientModules pushBack ("SCRIPTS\T2_UserInteraction\inventoryUI\inventoryUITests.sqf" call NWG_fnc_compile)};
//keybindings
_clientModules pushBack ("SCRIPTS\T2_UserInteraction\keybindings\keybindings.sqf" call NWG_fnc_compile);
_clientFunctions pushBack ("SCRIPTS\T2_UserInteraction\keybindings\keybindingsFunctions.sqf" call NWG_fnc_compile);
if (_isDevBuild) then {_clientModules pushBack ("SCRIPTS\T2_UserInteraction\keybindings\keybindingsTests.sqf" call NWG_fnc_compile)};
//magrepack
_clientModules pushBack ("SCRIPTS\T2_UserInteraction\magrepack\magrepack.sqf" call NWG_fnc_compile);
_clientFunctions pushBack ("SCRIPTS\T2_UserInteraction\magrepack\magrepackFunctions.sqf" call NWG_fnc_compile);
//mapOpen
_clientModules pushBack ("SCRIPTS\T2_UserInteraction\mapOpen\mapOpen.sqf" call NWG_fnc_compile);
_clientFunctions pushBack ("SCRIPTS\T2_UserInteraction\mapOpen\mapOpenFunctions.sqf" call NWG_fnc_compile);
//maprules
_clientModules pushBack ("SCRIPTS\T2_UserInteraction\maprules\maprules.sqf" call NWG_fnc_compile);
//markers
_serverModules pushBack ("SCRIPTS\T2_UserInteraction\markers\markersServerSide.sqf" call NWG_fnc_compile);
_clientModules pushBack ("SCRIPTS\T2_UserInteraction\markers\markersClientSide.sqf" call NWG_fnc_compile);
_commonFunctions pushBack ("SCRIPTS\T2_UserInteraction\markers\markersFunctions.sqf" call NWG_fnc_compile);
if (_isDevBuild) then {_serverModules pushBack ("SCRIPTS\T2_UserInteraction\markers\markersTests.sqf" call NWG_fnc_compile)};
//medicine
#define MEDICINE_TESTS_ON_DEDICATED true
_clientModules pushBack ("SCRIPTS\T2_UserInteraction\medicine\medicineCommon.sqf" call NWG_fnc_compile);
_clientModules pushBack ("SCRIPTS\T2_UserInteraction\medicine\medicineClientSide.sqf" call NWG_fnc_compile);
_serverModules pushBack ("SCRIPTS\T2_UserInteraction\medicine\medicineCommon.sqf" call NWG_fnc_compile);
_serverModules pushBack ("SCRIPTS\T2_UserInteraction\medicine\medicineServerSide.sqf" call NWG_fnc_compile);
_commonFunctions pushBack ("SCRIPTS\T2_UserInteraction\medicine\medicineFunctions.sqf" call NWG_fnc_compile);
if (_isDevBuild || MEDICINE_TESTS_ON_DEDICATED) then {_clientModules pushBack ("SCRIPTS\T2_UserInteraction\medicine\medicineDummy.sqf" call NWG_fnc_compile)};
//nametags
_clientModules pushBack ("SCRIPTS\T2_UserInteraction\nametags\nametags.sqf" call NWG_fnc_compile);
//playerRadar
_clientModules pushBack ("SCRIPTS\T2_UserInteraction\playerRadar\playerRadar.sqf" call NWG_fnc_compile);
_clientFunctions pushBack ("SCRIPTS\T2_UserInteraction\playerRadar\playerRadarFunctions.sqf" call NWG_fnc_compile);
if (_isDevBuild) then {_clientModules pushBack ("SCRIPTS\T2_UserInteraction\playerRadar\playerRadarTests.sqf" call NWG_fnc_compile)};
//playerShutUp
_clientModules pushBack ("SCRIPTS\T2_UserInteraction\playerShutUp\playerShutUpClient.sqf" call NWG_fnc_compile);
_commonFunctions pushBack ("SCRIPTS\T2_UserInteraction\playerShutUp\playerShutUpFunctions.sqf" call NWG_fnc_compile);
//playerTraits
_clientModules pushBack ("SCRIPTS\T2_UserInteraction\playerTraits\playerTraits.sqf" call NWG_fnc_compile);
//radioChatter
_clientModules pushBack ("SCRIPTS\T2_UserInteraction\radioChatter\radioChatter.sqf" call NWG_fnc_compile);
_commonFunctions pushBack ("SCRIPTS\T2_UserInteraction\radioChatter\radioChatterFunctions.sqf" call NWG_fnc_compile);
if (_isDevBuild) then {_clientModules pushBack ("SCRIPTS\T2_UserInteraction\radioChatter\radioChatterTests.sqf" call NWG_fnc_compile)};
//stickyBombs
_clientModules pushBack ("SCRIPTS\T2_UserInteraction\stickyBombs\stickyBombs.sqf" call NWG_fnc_compile);
//unformEquip
_clientModules pushBack ("SCRIPTS\T2_UserInteraction\unformEquip\unformEquip.sqf" call NWG_fnc_compile);
_clientFunctions pushBack ("SCRIPTS\T2_UserInteraction\unformEquip\unformEquipFunctions.sqf" call NWG_fnc_compile);
//userPlanshet
_clientModules pushBack ("SCRIPTS\T2_UserInteraction\userPlanshet\userPlanshet.sqf" call NWG_fnc_compile);
_clientFunctions pushBack ("SCRIPTS\T2_UserInteraction\userPlanshet\userPlanshetFunctions.sqf" call NWG_fnc_compile);
_clientModules pushBack ("SCRIPTS\T2_UserInteraction\userPlanshet\03Group.sqf" call NWG_fnc_compile);
_clientModules pushBack ("SCRIPTS\T2_UserInteraction\userPlanshet\05Info.sqf" call NWG_fnc_compile);
_clientModules pushBack ("SCRIPTS\T2_UserInteraction\userPlanshet\06Settings.sqf" call NWG_fnc_compile);
//viewDistance
_clientModules pushBack ("SCRIPTS\T2_UserInteraction\viewDistance\viewDistance.sqf" call NWG_fnc_compile);
_clientFunctions pushBack ("SCRIPTS\T2_UserInteraction\viewDistance\viewDistanceFunctions.sqf" call NWG_fnc_compile);
//voting
_serverModules pushBack ("SCRIPTS\T2_UserInteraction\voting\votingCommon.sqf" call NWG_fnc_compile);
_serverModules pushBack ("SCRIPTS\T2_UserInteraction\voting\votingServerSide.sqf" call NWG_fnc_compile);
_clientModules pushBack ("SCRIPTS\T2_UserInteraction\voting\votingCommon.sqf" call NWG_fnc_compile);
_clientModules pushBack ("SCRIPTS\T2_UserInteraction\voting\votingClientSide.sqf" call NWG_fnc_compile);
_commonFunctions pushBack ("SCRIPTS\T2_UserInteraction\voting\votingFunctions.sqf" call NWG_fnc_compile);
//votingBan
_serverModules pushBack ("SCRIPTS\T2_UserInteraction\votingBan\votingBanServerSide.sqf" call NWG_fnc_compile);
_clientModules pushBack ("SCRIPTS\T2_UserInteraction\votingBan\votingBanClientSide.sqf" call NWG_fnc_compile);
_commonFunctions pushBack ("SCRIPTS\T2_UserInteraction\votingBan\votingBanFunctions.sqf" call NWG_fnc_compile);

//T3_Economics
//categorizationItems
_serverModules pushBack ("SCRIPTS\T3_Economics\categorizationItems\categorizationItems.sqf" call NWG_fnc_compile);
_clientModules pushBack ("SCRIPTS\T3_Economics\categorizationItems\categorizationItems.sqf" call NWG_fnc_compile);
if (_isDevBuild) then {_clientModules pushBack ("SCRIPTS\T3_Economics\categorizationItems\categorizationItemsTests.sqf" call NWG_fnc_compile)};
_commonFunctions pushBack ("SCRIPTS\T3_Economics\categorizationItems\categorizationItemsFunctions.sqf" call NWG_fnc_compile);
//categorizationVehs
_serverModules pushBack ("SCRIPTS\T3_Economics\categorizationVehs\categorizationVehs.sqf" call NWG_fnc_compile);
_clientModules pushBack ("SCRIPTS\T3_Economics\categorizationVehs\categorizationVehs.sqf" call NWG_fnc_compile);
if (_isDevBuild) then {_clientModules pushBack ("SCRIPTS\T3_Economics\categorizationVehs\categorizationVehsTests.sqf" call NWG_fnc_compile)};
_commonFunctions pushBack ("SCRIPTS\T3_Economics\categorizationVehs\categorizationVehsFunctions.sqf" call NWG_fnc_compile);
//database
_serverModules pushBack ("SCRIPTS\T3_Economics\database\databaseCommon.sqf" call NWG_fnc_compile);
_serverModules pushBack ("SCRIPTS\T3_Economics\database\databasePlayers.sqf" call NWG_fnc_compile);
_serverModules pushBack ("SCRIPTS\T3_Economics\database\databasePrices.sqf" call NWG_fnc_compile);
_serverModules pushBack ("SCRIPTS\T3_Economics\database\databaseEscapeBillboard.sqf" call NWG_fnc_compile);
_serverModules pushBack ("SCRIPTS\T3_Economics\database\databaseUnlockedLevels.sqf" call NWG_fnc_compile);
_serverFunctions pushBack ("SCRIPTS\T3_Economics\database\databaseFunctions.sqf" call NWG_fnc_compile);
//economicsTest
if (_isDevBuild) then {_serverModules pushBack ("SCRIPTS\T3_Economics\economicsTest\economicsTest.sqf" call NWG_fnc_compile)};
//escapeBillboard
_serverModules pushBack ("SCRIPTS\T3_Economics\escapeBillboard\escapeBillboardServerSide.sqf" call NWG_fnc_compile);
_serverModules pushBack ("SCRIPTS\T3_Economics\escapeBillboard\missionMachineConnector.sqf" call NWG_fnc_compile);
_clientModules pushBack ("SCRIPTS\T3_Economics\escapeBillboard\escapeBillboardClientSide.sqf" call NWG_fnc_compile);
_commonFunctions pushBack ("SCRIPTS\T3_Economics\escapeBillboard\escapeBillboardFunctions.sqf" call NWG_fnc_compile);
//garage
_serverModules pushBack ("SCRIPTS\T3_Economics\garage\garageServerSide.sqf" call NWG_fnc_compile);
_serverModules pushBack ("SCRIPTS\T3_Economics\garage\garageCommon.sqf" call NWG_fnc_compile);
_serverModules pushBack ("SCRIPTS\T3_Economics\garage\missionMachineConnector.sqf" call NWG_fnc_compile);
_clientModules pushBack ("SCRIPTS\T3_Economics\garage\garageClientSide.sqf" call NWG_fnc_compile);
_clientModules pushBack ("SCRIPTS\T3_Economics\garage\garageCommon.sqf" call NWG_fnc_compile);
_commonFunctions pushBack ("SCRIPTS\T3_Economics\garage\garageFunctions.sqf" call NWG_fnc_compile);
_clientModules pushBack ("SCRIPTS\T3_Economics\garage\addonReturnToGarageClient.sqf" call NWG_fnc_compile);
_serverModules pushBack ("SCRIPTS\T3_Economics\garage\addonReturnToGarageServer.sqf" call NWG_fnc_compile);
//hunting
_clientModules pushBack ("SCRIPTS\T3_Economics\hunting\huntingClient.sqf" call NWG_fnc_compile);
//lootMission
_serverModules pushBack ("SCRIPTS\T3_Economics\lootMission\lootMissionServer.sqf" call NWG_fnc_compile);
_serverModules pushBack ("SCRIPTS\T3_Economics\lootMission\missionMachineConnector.sqf" call NWG_fnc_compile);
_serverModules pushBack ("SCRIPTS\T3_Economics\lootMission\dspawnConnector.sqf" call NWG_fnc_compile);
_commonFunctions pushBack ("SCRIPTS\T3_Economics\lootMission\lootMissionFunctions.sqf" call NWG_fnc_compile);
if (_isDevBuild) then {_serverModules pushBack ("SCRIPTS\T3_Economics\lootMission\lootMissionDev.sqf" call NWG_fnc_compile)};
//lootStorage
_serverModules pushBack ("SCRIPTS\T3_Economics\lootStorage\lootStorageCommon.sqf" call NWG_fnc_compile);
_serverModules pushBack ("SCRIPTS\T3_Economics\lootStorage\lootStorageServer.sqf" call NWG_fnc_compile);
_serverModules pushBack ("SCRIPTS\T3_Economics\lootStorage\missionMachineConnector.sqf" call NWG_fnc_compile);
_clientModules pushBack ("SCRIPTS\T3_Economics\lootStorage\lootStorageCommon.sqf" call NWG_fnc_compile);
_clientModules pushBack ("SCRIPTS\T3_Economics\lootStorage\lootStorageClient.sqf" call NWG_fnc_compile);
_clientModules pushBack ("SCRIPTS\T3_Economics\lootStorage\addonStorageAtVehicle.sqf" call NWG_fnc_compile);
_commonFunctions pushBack ("SCRIPTS\T3_Economics\lootStorage\lootStorageFunctions.sqf" call NWG_fnc_compile);
if (_isDevBuild) then {_clientModules pushBack ("SCRIPTS\T3_Economics\lootStorage\lootStorageTests.sqf" call NWG_fnc_compile)};
//moneyTransfer
_clientModules pushBack ("SCRIPTS\T3_Economics\moneyTransfer\moneyTransfer.sqf" call NWG_fnc_compile);
_clientFunctions pushBack ("SCRIPTS\T3_Economics\moneyTransfer\moneyTransferFunctions.sqf" call NWG_fnc_compile);
//playerStateHolder
_clientModules pushBack ("SCRIPTS\T3_Economics\playerStateHolder\playerStateHolderClient.sqf" call NWG_fnc_compile);
_serverModules pushBack ("SCRIPTS\T3_Economics\playerStateHolder\playerStateHolderServer.sqf" call NWG_fnc_compile);
_commonFunctions pushBack ("SCRIPTS\T3_Economics\playerStateHolder\playerStateHolderFunctions.sqf" call NWG_fnc_compile);
_serverModules pushBack ("SCRIPTS\T3_Economics\playerStateHolder\addonDepleterServer.sqf" call NWG_fnc_compile);
_clientModules pushBack ("SCRIPTS\T3_Economics\playerStateHolder\addonEventsConnectorClient.sqf" call NWG_fnc_compile);
_serverModules pushBack ("SCRIPTS\T3_Economics\playerStateHolder\addonLoadoutHelperServer.sqf" call NWG_fnc_compile);
_clientModules pushBack ("SCRIPTS\T3_Economics\playerStateHolder\addonLoadoutHelperClient.sqf" call NWG_fnc_compile);
_serverModules pushBack ("SCRIPTS\T3_Economics\playerStateHolder\addonMissionMachineConnectorServer.sqf" call NWG_fnc_compile);
//progress
_serverModules pushBack ("SCRIPTS\T3_Economics\progress\progressCommon.sqf" call NWG_fnc_compile);
_clientModules pushBack ("SCRIPTS\T3_Economics\progress\progressCommon.sqf" call NWG_fnc_compile);
_clientModules pushBack ("SCRIPTS\T3_Economics\progress\progressClient.sqf" call NWG_fnc_compile);
_commonFunctions pushBack ("SCRIPTS\T3_Economics\progress\progressFunctions.sqf" call NWG_fnc_compile);
_serverModules pushBack ("SCRIPTS\T3_Economics\progress\missionMachineConnector.sqf" call NWG_fnc_compile);
//shopItems
_serverModules pushBack ("SCRIPTS\T3_Economics\shopItems\shopItemsServerSide.sqf" call NWG_fnc_compile);
_serverModules pushBack ("SCRIPTS\T3_Economics\shopItems\missionMachineConnector.sqf" call NWG_fnc_compile);
_clientModules pushBack ("SCRIPTS\T3_Economics\shopItems\shopItemsClientSide.sqf" call NWG_fnc_compile);
_commonFunctions pushBack ("SCRIPTS\T3_Economics\shopItems\shopItemsFunctions.sqf" call NWG_fnc_compile);
if (_isDevBuild) then {_clientModules pushBack ("SCRIPTS\T3_Economics\shopItems\shopItemsTests.sqf" call NWG_fnc_compile)};
//shopMobile
_serverModules pushBack ("SCRIPTS\T3_Economics\shopMobile\shopMobileServerSide.sqf" call NWG_fnc_compile);
_serverModules pushBack ("SCRIPTS\T3_Economics\shopMobile\missionMachineConnector.sqf" call NWG_fnc_compile);
_serverModules pushBack ("SCRIPTS\T3_Economics\shopMobile\dspawnConnectorServer.sqf" call NWG_fnc_compile);
_clientModules pushBack ("SCRIPTS\T3_Economics\shopMobile\shopMobileClientSide.sqf" call NWG_fnc_compile);
_commonFunctions pushBack ("SCRIPTS\T3_Economics\shopMobile\shopMobileFunctions.sqf" call NWG_fnc_compile);
//shopVehicles
_serverModules pushBack ("SCRIPTS\T3_Economics\shopVehicles\shopVehiclesServerSide.sqf" call NWG_fnc_compile);
_serverModules pushBack ("SCRIPTS\T3_Economics\shopVehicles\missionMachineConnector.sqf" call NWG_fnc_compile);
_clientModules pushBack ("SCRIPTS\T3_Economics\shopVehicles\shopVehiclesClientSide.sqf" call NWG_fnc_compile);
_commonFunctions pushBack ("SCRIPTS\T3_Economics\shopVehicles\shopVehiclesFunctions.sqf" call NWG_fnc_compile);
if (_isDevBuild) then {_clientModules pushBack ("SCRIPTS\T3_Economics\shopVehicles\shopVehiclesTests.sqf" call NWG_fnc_compile)};
//uiHelper
_clientModules pushBack ("SCRIPTS\T3_Economics\uiHelper\uiHelper.sqf" call NWG_fnc_compile);
_clientFunctions pushBack ("SCRIPTS\T3_Economics\uiHelper\uiHelperFunctions.sqf" call NWG_fnc_compile);
//vehCustomizationAppearance
_serverModules pushBack ("SCRIPTS\T3_Economics\vehCustomizationAppearance\vehCustomizationAppearanceCore.sqf" call NWG_fnc_compile);
_clientModules pushBack ("SCRIPTS\T3_Economics\vehCustomizationAppearance\vehCustomizationAppearanceCore.sqf" call NWG_fnc_compile);
_clientModules pushBack ("SCRIPTS\T3_Economics\vehCustomizationAppearance\vehCustomizationAppearance.sqf" call NWG_fnc_compile);
_commonFunctions pushBack ("SCRIPTS\T3_Economics\vehCustomizationAppearance\vehCustomizationAppearanceFunctions.sqf" call NWG_fnc_compile);
//vehCustomizationPylons
_serverModules pushBack ("SCRIPTS\T3_Economics\vehCustomizationPylons\vehCustomizationPylonsCore.sqf" call NWG_fnc_compile);
_clientModules pushBack ("SCRIPTS\T3_Economics\vehCustomizationPylons\vehCustomizationPylonsCore.sqf" call NWG_fnc_compile);
_clientModules pushBack ("SCRIPTS\T3_Economics\vehCustomizationPylons\vehCustomizationPylons.sqf" call NWG_fnc_compile);
_commonFunctions pushBack ("SCRIPTS\T3_Economics\vehCustomizationPylons\vehCustomizationPylonsFunctions.sqf" call NWG_fnc_compile);
//vehCustomizationUI
_clientModules pushBack ("SCRIPTS\T3_Economics\vehCustomizationUI\vehCustomizationUI.sqf" call NWG_fnc_compile);
_clientFunctions pushBack ("SCRIPTS\T3_Economics\vehCustomizationUI\vehCustomizationUIFunctions.sqf" call NWG_fnc_compile);
//vehOwnership
_serverModules pushBack ("SCRIPTS\T3_Economics\vehOwnership\vehOwnershipCommon.sqf" call NWG_fnc_compile);
_clientModules pushBack ("SCRIPTS\T3_Economics\vehOwnership\vehOwnershipCommon.sqf" call NWG_fnc_compile);
_clientModules pushBack ("SCRIPTS\T3_Economics\vehOwnership\vehOwnershipClient.sqf" call NWG_fnc_compile);
_commonFunctions pushBack ("SCRIPTS\T3_Economics\vehOwnership\vehOwnershipFunctions.sqf" call NWG_fnc_compile);
//wallet
_serverModules pushBack ("SCRIPTS\T3_Economics\wallet\walletCommon.sqf" call NWG_fnc_compile);
_serverModules pushBack ("SCRIPTS\T3_Economics\wallet\missionMachineConnector.sqf" call NWG_fnc_compile);
_clientModules pushBack ("SCRIPTS\T3_Economics\wallet\walletCommon.sqf" call NWG_fnc_compile);
_clientModules pushBack ("SCRIPTS\T3_Economics\wallet\walletClient.sqf" call NWG_fnc_compile);
_commonFunctions pushBack ("SCRIPTS\T3_Economics\wallet\walletFunctions.sqf" call NWG_fnc_compile);
if (_isDevBuild) then {_clientModules pushBack ("SCRIPTS\T3_Economics\wallet\walletTests.sqf" call NWG_fnc_compile)};

//T4_DialoguesAndQuests
//dialogueSystem
_serverModules pushBack ("SCRIPTS\T4_DialoguesAndQuests\dialogueSystem\missionMachineConnector.sqf" call NWG_fnc_compile);
_clientModules pushBack ("DATASETS\Client\Dialogues\Dialogues.sqf" call NWG_fnc_compile);//Compile dialogues data alongside modules
_clientModules pushBack ("SCRIPTS\T4_DialoguesAndQuests\dialogueSystem\dialogueSystemClientSide.sqf" call NWG_fnc_compile);
_clientModules pushBack ("SCRIPTS\T4_DialoguesAndQuests\dialogueSystem\00NpcCommon.sqf" call NWG_fnc_compile);
_clientModules pushBack ("SCRIPTS\T4_DialoguesAndQuests\dialogueSystem\01NpcTaxi.sqf" call NWG_fnc_compile);
_clientModules pushBack ("SCRIPTS\T4_DialoguesAndQuests\dialogueSystem\02NpcMech.sqf" call NWG_fnc_compile);
_serverModules pushBack ("SCRIPTS\T4_DialoguesAndQuests\dialogueSystem\02NpcMechServer.sqf" call NWG_fnc_compile);
_clientModules pushBack ("SCRIPTS\T4_DialoguesAndQuests\dialogueSystem\03NpcTrdr.sqf" call NWG_fnc_compile);
_clientModules pushBack ("SCRIPTS\T4_DialoguesAndQuests\dialogueSystem\04NpcMedc.sqf" call NWG_fnc_compile);
_clientModules pushBack ("SCRIPTS\T4_DialoguesAndQuests\dialogueSystem\05NpcComm.sqf" call NWG_fnc_compile);
_clientModules pushBack ("SCRIPTS\T4_DialoguesAndQuests\dialogueSystem\06NpcRoof.sqf" call NWG_fnc_compile);
_commonFunctions pushBack ("SCRIPTS\T4_DialoguesAndQuests\dialogueSystem\dialogueSystemFunctions.sqf" call NWG_fnc_compile);
if (_isDevBuild) then {_clientModules pushBack ("SCRIPTS\T4_DialoguesAndQuests\dialogueSystem\dialogueSystemTests.sqf" call NWG_fnc_compile)};
//quests
_serverModules pushBack ("SCRIPTS\T4_DialoguesAndQuests\quests\questsSettings.sqf" call NWG_fnc_compile);
_clientModules pushBack ("SCRIPTS\T4_DialoguesAndQuests\quests\questsSettings.sqf" call NWG_fnc_compile);
_serverModules pushBack ("SCRIPTS\T4_DialoguesAndQuests\quests\questsServerSide.sqf" call NWG_fnc_compile);
_serverModules pushBack ("SCRIPTS\T4_DialoguesAndQuests\quests\missionMachineConnector.sqf" call NWG_fnc_compile);
_serverModules pushBack ("SCRIPTS\T4_DialoguesAndQuests\quests\medicineConnector.sqf" call NWG_fnc_compile);
_clientModules pushBack ("SCRIPTS\T4_DialoguesAndQuests\quests\questsClientSide.sqf" call NWG_fnc_compile);
_commonFunctions pushBack ("SCRIPTS\T4_DialoguesAndQuests\quests\questsFunctions.sqf" call NWG_fnc_compile);
//tutorial
_clientModules pushBack ("SCRIPTS\T4_DialoguesAndQuests\tutorial\tutorialClientSide.sqf" call NWG_fnc_compile);
_clientModules pushBack ("SCRIPTS\T4_DialoguesAndQuests\tutorial\dialoguesHelper.sqf" call NWG_fnc_compile);
_serverModules pushBack ("SCRIPTS\T4_DialoguesAndQuests\tutorial\tutorialServerSide.sqf" call NWG_fnc_compile);
_serverModules pushBack ("SCRIPTS\T4_DialoguesAndQuests\tutorial\missionMachineConnector.sqf" call NWG_fnc_compile);
_commonFunctions pushBack ("SCRIPTS\T4_DialoguesAndQuests\tutorial\tutorialFunctions.sqf" call NWG_fnc_compile);

//T0_Core
//remoteQueue
_clientModules pushBack ("SCRIPTS\T0_Core\remoteQueue\remoteQueueClient.sqf" call NWG_fnc_compile);//Must be executed last

//================================================================================================================
//================================================================================================================
//ServerSide
{call _x} forEach _commonFunctions;
{call _x} forEach _serverFunctions;
{call _x} forEach _serverModules;

//================================================================================================================
//================================================================================================================
//ClientSide
NWG_SER_toSendToPlayer = createHashMap;
private _clientSide = [];
_clientSide append _commonFunctions;
_clientSide append _clientFunctions;
_clientSide append _clientModules;

{
    private _localization = (format ["DATASETS\Client\Localization\%1.sqf",_x]) call NWG_fnc_compile;
    NWG_SER_toSendToPlayer set [_x,([_localization]+_clientSide)];
} forEach ["English","Russian"];

NWG_fnc_playerScriptsRequest = {
    params ["_playerObj","_language"];
    private _toSend = if (_language in NWG_SER_toSendToPlayer)
        then {NWG_SER_toSendToPlayer get _language}
        else {NWG_SER_toSendToPlayer get "English"};//Default language

    //Network check
    private _callerID = remoteExecutedOwner;
    if (isDedicated && {_callerID == 0 && {local _playerObj}}) exitWith {
        diag_log formatText ["%1(%2) [ERROR] %3", __FILE__, __LINE__,  "#### NWG_fnc_playerScriptsRequest: Caller can not be identified"];
    };
    private _recipient = if (_callerID != 0) then {_callerID} else {_playerObj};

    //Send
    _toSend remoteExec ["NWG_fnc_clientScriptsReceive",_recipient];
};

//================================================================================================================
//================================================================================================================
//Finalize
NWG_SER_CompilationDone = true;