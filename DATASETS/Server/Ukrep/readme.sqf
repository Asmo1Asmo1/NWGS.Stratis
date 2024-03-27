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