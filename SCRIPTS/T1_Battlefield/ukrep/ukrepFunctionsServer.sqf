/*======== GROUPS ==========*/
//Checks if the given group is spawned by 'ukrep' subsystem
//params:
// _group - group to check
//returns:
// boolean
NWG_fnc_ukrpIsUkrepGroup = {
    // private _group = _this;
    _this getVariable ["NWG_UKREP_ownership",false]
};

/*======== BLUEPRINTS ==========*/
//Returns array of all ABS blueprints from the given page
//params:
// _pageName - name of the catalogue page to read
// _blueprintName - (optional) name filter of the blueprint(s) to be selected from the page
// _blueprintPos - (optional) position filter of the blueprint(s) to be selected from the page
//returns:
// array of blueprint containers (empty array if none found)
// each container has following structure: ["ABS","UkrepName",[ABSPos],0,Radius,0,[Payload],[Blueprint]]
NWG_fnc_ukrpGetBlueprintsABS = {
    // params ["_pageName",["_blueprintName",""],["_blueprintPos",[]]];
    _this call NWG_UKREP_GetBlueprintsABS
};

//Returns array of all REL blueprints from the given page
//params:
// _pageName - name of the catalogue page to read
// _blueprintName - (optional) name filter of the blueprint(s) to be selected from the page
// _blueprintRoot - (optional) root filter of the blueprint(s) to be selected from the page
//returns:
// array of blueprint containers (empty array if none found)
// each container has following structure: ["REL","UkrepName",0,0,Radius,0,[Payload],[Blueprint]]
NWG_fnc_ukrpGetBlueprintsREL = {
    // params ["_pageName",["_blueprintName",""],["_blueprintRoot",[]]];
    _this call NWG_UKREP_GetBlueprintsREL
};

/*======== BUILDING ==========*/
//Builds FRACTAL ABS composition
//params:
// _fractalSteps - array of fractal steps describing each step of the building process
//      0: root - root layer of the fractal: [["_pageName",""],["_blueprintName",""],["_chances",[]],["_blueprintPos",[]]]
//      1: bldg - each building:             [["_pageName",""],["_blueprintName",""],["_chances",[]]];
//      2: furn - each furniture:            [["_pageName",""],["_blueprintName",""],["_chances",[]]];
// _faction - (optional) faction replacement to be applied (e.g.: "NATO") (default: "")
// _groupRules - (optional) array of group rules to be applied to the composition
//      rules are:
//          - 0: GRP_RULES_MEMBERSHIP - side/group/"AGENT" (default: west) (use "AGENT" to create units as agents instead of actual units)
//          - 1: GRP_RULES_DYNASIM - apply dynamic simulation to the group (default: true)
// _mapObjectsLimit - (optional) limit of pre-existing map objects (buildings and furniture) to include in the composition (default: 10)
//returns:
// [_bldgs,_furns,_decos,_units,_vehcs,_trrts,_mines] - array of spawned objects OR false if failed
NWG_fnc_ukrpBuildFractalABS = {
    // params ["_fractalSteps",["_faction",""],["_groupRules",[]],["_mapObjectsLimit",10]];
    _this call NWG_UKREP_FRACTAL_PlaceFractalABS
};

//Builds composition around given object
//params:
// _pageName - name of the catalogue page to be used
// _object - object to build composition around
// _objectType - (optional) type of the object if known (will slightly speed up the process) (type: string from globalDefines: "BLDG","FURN","DECO","UNIT","VEHC","TRRT","MINE")
// _blueprintName - (optional) name filter of the blueprint(s) to be selected from the page
// _chances - (optional) array of chances for each object type to be spawned (default: [1.0,1.0,1.0,1.0,1.0,1.0,1.0])
//      each chance can be:
//          - number (0.0-1.0) - raw percentage (0.5 = 50% of objects of this type)
//          - array [number, number] - min-max range of percentage ([0.1,0.5] = 10-50% of objects of this type)
//          - hashMap - set of rules:  "IgnoreList":[], "MinPercentage":0.0, "MaxPercentage":1.0, "MinCount":0, "MaxCount":0
// _faction - (optional) faction replacement to be applied (e.g.: "NATO") (default: "")
// _groupRules - (optional) array of group rules to be applied to the composition
//      rules are:
//          - 0: GRP_RULES_MEMBERSHIP - side/group/"AGENT" (default: west) (use "AGENT" to create units as agents instead of actual units)
//          - 1: GRP_RULES_DYNASIM - apply dynamic simulation to the group (default: true)
// _adaptToGround - (optional) boolean, if true, composition will be adapted to the ground
//returns:
// [_bldgs,_furns,_decos,_units,_vehcs,_trrts,_mines] - array of spawned objects OR false if failed
NWG_fnc_ukrpBuildAroundObject = {
    // params ["_pageName","_object",["_objectType",""],["_blueprintName",""],["_chances",[]],["_faction",""],["_groupRules",[]],["_adaptToGround",true]];
    _this call NWG_UKREP_PUBLIC_PlaceREL_Object
};