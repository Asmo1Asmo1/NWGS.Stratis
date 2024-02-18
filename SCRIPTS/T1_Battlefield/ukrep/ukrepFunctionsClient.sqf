//Private function internally used by ukrep system
//Rotates and adapts mines to the terrain
//params:
//_mines - array of mines
//_dirs - array of directions
NWG_fnc_ukrpMinesRotateAndAdapt = {
    params ["_mines","_dirs"];
    {
        _x setDir (_dirs#_forEachIndex);
        if (((getPosATL _x)#2) < 0.2) then {_x setVectorUp (surfaceNormal (getPosWorld _x))};
    } forEach _mines;
};