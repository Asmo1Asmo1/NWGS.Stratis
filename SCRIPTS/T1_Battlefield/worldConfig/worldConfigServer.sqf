//================================================================================================================
//================================================================================================================
//Settings
NWG_WCONF_SER_Settings = createHashMapFromArray [
    /*Dynamic simulation settings*/
    ["DYNASIM_CONFIGURE_ON_START",true],//Configure dynamic simulation on mission start
    ["DYNASIM_ENABLED",true],//Is dynamic simulation system enabled
    ["DYNASIM_DIST_CHAR",5000],//Dynasim distance for units/groups
    ["DYNASIM_DIST_MVEH",5000],//Dynasim distance for manned (occupied) vehicles
    ["DYNASIM_DIST_EVEH",500],//Dynasim distance for empty vehicles
    ["DYNASIM_DIST_PROP",50],//Dynasim distance for objects and buildings
    ["DYNASIM_DIST_MOVING_MULT",1],//Multiply distance by N if the object is moving
    // ["DYNASIM_DIST_LIMIT_BY_VIEW",true],//Limit by viewdistance (there is no such script command and behaviour in MP is undefined anyway)

    ["",0]
];

//================================================================================================================
//================================================================================================================
//Init
private _Init = {
    //dynamic simulation
    if (NWG_WCONF_SER_Settings get "DYNASIM_CONFIGURE_ON_START") then {call NWG_WCONF_ConfigureDynamicSimulation};
};

//================================================================================================================
//================================================================================================================
//Dynamic simulation config
NWG_WCONF_ConfigureDynamicSimulation = {
    //Entire system enable/disable
    enableDynamicSimulationSystem (NWG_WCONF_SER_Settings get "DYNASIM_ENABLED");
    if !(NWG_WCONF_SER_Settings get "DYNASIM_ENABLED") exitWith {};//Exit if dynamic simulation is disabled

    //Set distances
    "Group"        setDynamicSimulationDistance (NWG_WCONF_SER_Settings get "DYNASIM_DIST_CHAR");
    "Vehicle"      setDynamicSimulationDistance (NWG_WCONF_SER_Settings get "DYNASIM_DIST_MVEH");
    "EmptyVehicle" setDynamicSimulationDistance (NWG_WCONF_SER_Settings get "DYNASIM_DIST_EVEH");
    "Prop"         setDynamicSimulationDistance (NWG_WCONF_SER_Settings get "DYNASIM_DIST_PROP");

    //Set moving multiplier
    "IsMoving" setDynamicSimulationDistanceCoef (NWG_WCONF_SER_Settings get "DYNASIM_DIST_MOVING_MULT");
};

//================================================================================================================
//================================================================================================================
call _Init;