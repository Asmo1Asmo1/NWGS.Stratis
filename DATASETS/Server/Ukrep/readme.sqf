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
100 call NWG_UKREP_GatherUkrepABS

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
    This is a problem. Modules usually get created, do the job and get deleted at the first frame of the mission. So the workaround is following:
    1. Create a module, place it in the editor and configure
    2. Place VR_3DSelector_01_default_F object at the exact same position
    3. Add following to VR selector init:
private _this = this;
_this setVariable ["HELP_RealClassname",""];
    4. Paste actual module classname to code above
    5. Save the mission
    6. Export -> SQF -> Copy to clipboard
    7. Find your module in sqf code and copy setVariable lines, e.g.:
        _this setVariable ["objectArea",[10,10,0,false,-1]];
        _this setVariable ["#filter",4];
        _this setVariable ["#hideLocally",false];
    8. Paste to VR selector init, so that entire init looks like this:
        private _this = this;
        _this setVariable ["HELP_RealClassname","ModuleHideTerrainObjects_F"];
        _this setVariable ["objectArea",[10,10,0,false,-1]];
        _this setVariable ["#filter",4];
        _this setVariable ["#hideLocally",false];
    9. Now you can gather the composition and see that HELPER record is created along with other objects
*/

//Get vehicles appearance:
/*Get current appearance with current values:*/
cursorObject call NWG_fnc_spwnGetVehicleAppearance;

/*Get all the appearance and color variants:*/
cursorObject call NWG_fnc_spwnGetVehicleAppearanceAll;