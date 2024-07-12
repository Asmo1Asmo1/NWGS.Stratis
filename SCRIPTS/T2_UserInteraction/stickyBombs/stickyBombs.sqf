/*
Original Author: ToxaBes
Total Rework: Asmo
Description: Attach explosive charges to objects
*/
TB_C4_Attach = {
    // params ["_unit","_weapon","_muzzle","_mode","_ammo","_magazine","_projectile","_gunner"];
    params ["_unit","","","","_ammo","","_explosive"];
    if (!alive _unit || {_ammo isNotEqualTo "DemoCharge_Remote_Ammo" || {isNull _explosive}}) exitWith {};//Check args

    //Get raycast from player's eyes to the object (works only in first person)
    private _intersections = lineIntersectsSurfaces [
        (AGLToASL (positionCameraToWorld [0,0,0])),
        (AGLToASL (positionCameraToWorld [0,0,3])),
        _unit
    ];
    if ((count _intersections) < 1) exitWith {};

    //Get object we hit with raycast
    (_intersections#0) params ["_intersectPosASL","_surfaceNormal","_intersectObject"];
    if (isNull _intersectObject || {!alive _intersectObject || {_intersectObject isKindOf "Man"}}) exitWith {};

    //Reposition explosive object (is under our feet by default)
    _explosive setPosASL _intersectPosASL;
    _explosive setVectorUp _surfaceNormal;

    //For vehicles - attach explosive to the vehicle (hence - the sticky bomb)
    if (_intersectObject call NWG_fnc_ocIsVehicle) then {
        private _dirAndUp = [
            (_intersectObject vectorWorldToModel vectorDir _explosive),
            (_intersectObject vectorWorldToModel vectorUp _explosive)
        ];
        _explosive attachTo [_intersectObject];
        _explosive setVectorDirAndUp _dirAndUp;
    };
};

player addEventHandler ["Fired",{_this call TB_C4_Attach}];