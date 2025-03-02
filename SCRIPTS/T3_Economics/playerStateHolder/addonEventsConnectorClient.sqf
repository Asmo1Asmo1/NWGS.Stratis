#include "..\..\globalDefines.h"
/*
    Addon-Connector between playerStateHolder and other client modules
*/

//Subscribe to client events and trigger client module to request state update on server side
[EVENT_ON_LOADOUT_CHANGED,  {"LoadoutChanged"  call NWG_fnc_pshOnClientStateChange}] call NWG_fnc_subscribeToClientEvent;
[EVENT_ON_LOOT_CHANGED,     {"LootChanged"     call NWG_fnc_pshOnClientStateChange}] call NWG_fnc_subscribeToClientEvent;
[EVENT_ON_MONEY_CHANGED,    {"MoneyChanged"    call NWG_fnc_pshOnClientStateChange}] call NWG_fnc_subscribeToClientEvent;
[EVENT_ON_PROGRESS_CHANGED, {"ProgressChanged" call NWG_fnc_pshOnClientStateChange}] call NWG_fnc_subscribeToClientEvent;
[EVENT_ON_GARAGE_CHANGED,   {"GarageChanged"   call NWG_fnc_pshOnClientStateChange}] call NWG_fnc_subscribeToClientEvent;
