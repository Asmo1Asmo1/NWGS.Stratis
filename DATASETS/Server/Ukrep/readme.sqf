/*
    Every REL blueprint requires a root object - object in the center of the composition.
    Ways to mark root object:
    1. Init code: this setVariable ["UKREP_IsRoot",true];
    2. Name it 'NWG_UKREP_Root' (case sensitive)
    3. Look at it as player - the object under the crosshair will be marked as root.
*/

// Console commands to gather data:

//Increase speed to run around and check things faster:
setAccTime 2;

//Gather REL composition (first number is a radius):
19 call NWG_UKREP_GatherUkrepREL

//Gather ABS composition (first number is a radius):
250 call NWG_UKREP_GatherUkrepABS

//Test zaselenie:
[300,"NATO"] call NWG_UKREP_ZASELENIE_Test


//Placeholders
/*Building*/
    "Land_VR_Block_04_F"//Big VR block (buildings)
/*Loot boxes*/
    "Land_VR_Shape_01_cube_1m_F"//VR cube (boxes)
/*Units*/
    "B_Soldier_VR_F",//Blue VR unit (common units)
    "I_Soldier_VR_F",//Green VR unit (high ground units)
    "C_Soldier_VR_F",//Purple VR unit (officers)
    "O_Soldier_VR_F"//Red VR unit (not used yet)
/*Vehicles*/
    "Land_VR_Target_MRAP_01_F",//Small VR vehicle
    "Land_VR_Target_APC_Wheeled_01_F",//Medium VR vehicle
    "Land_VR_Target_MBT_01_cannon_F"//Large VR vehicle
/*Helpers*/
    "VR_3DSelector_01_default_F"//VR selector (used for modules, see below)

//Gather modules:
/*
There are following problems with that:
    A. Some modules (e.g.:HideTerrainObjects) usually get created, do the job and get deleted at the first frame of the mission. Thus making it impossible to gather as we do it in runtime.
    B. Others complicate things by spawning additional objects at the mission start (e.g.: SiteAmbient spawns animals).
    C. All modules carry a lot of variables, some are important for us, others - not, it is hard to distinguish between the two.
For these reasons it is not advised to gather modules automatically - it is unreliable.
Instead, better use a placeholder object (blue VR selector arrow) and gather data using it as a property bag:
    1. Create a module, place it in the editor and configure, check that everything works
    2. Place 'VR Selector' (VR_3DSelector_01_default_F) object at the exact same position as the module
    3. Add following to VR selector's init:
private _this = this;
_this setVariable ["HELP_RealClassname",""];
    4. Copy-paste an actual module classname to the "" above
    5. Save the mission
    6. Export -> SQF (if too big: -> Copy to clipboard -> paste to file)
    7. Find your module in sqf code (in _logics part) and copy all the 'setVariable' lines (except for the bis_fnc_initmodules_disableautoactivation)
    8. Paste these lines into VR selector init, so that entire init looks like this:
private _this = this;
_this setVariable ["HELP_RealClassname","ModuleHideTerrainObjects_F"];
_this setVariable ["objectArea",[10,10,0,false,-1]];
_this setVariable ["#filter",4];
_this setVariable ["#hideLocally",false];
    9. Delete the module from the editor
    Now you can gather the composition and see that HELPER record is created at the end of the blueprint
*/
/*
To easy copy the already gathered module:
private _this = this;
_this setVariable ["HELP_RealClassname",""];
{_this setVariable [(_x#0),(_x#1)]} forEach []
*/

//Get vehicles appearance:
/*Get current appearance with current values:*/
cursorObject call NWG_fnc_spwnGetVehicleAppearance;

/*Get all the appearance and color variants:*/
cursorObject call NWG_fnc_spwnGetVehicleAppearanceAll;