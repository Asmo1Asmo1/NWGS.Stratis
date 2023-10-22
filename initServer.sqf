//Setup dynamic groups - sever side
["Initialize"] call BIS_fnc_dynamicGroups;

//Server side initialization
switch (true) do
{
    //Servermod - scripts already compiled
    case (!isNil "NWG_SER_IsServermod"): {/*Do nothing*/};
    //Standalone - compile scripts
    case (fileExists "initScriptsCompilation.sqf"): {[""] call (compileFinal preprocessFileLineNumbers "initScriptsCompilation.sqf")};
    //Nothing - report warning
    default {diag_log formatText ["%1(%2) [WARNING] %3", __FILE__, __LINE__, "#### STARTUP WITHOUT SERVER SIDE"]};
};

//Report server ready
[] spawn {
    waitUntil { (!isNil "NWG_SER_CompilationDone") };
    diag_log formatText ["%1(%2) [REPORT] %3", __FILE__, __LINE__, "#### SCRIPTS COMPILATION COMPLETE"];

    NWG_SER_ServerReady = true;
    publicVariable "NWG_SER_ServerReady";
};