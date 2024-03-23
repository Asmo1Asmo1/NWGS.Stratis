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