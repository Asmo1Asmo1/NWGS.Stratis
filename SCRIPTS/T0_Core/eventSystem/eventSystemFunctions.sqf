//Subscribes to the event on server side
//params:
//  _event - the event to subscribe to
//  _code - the code to execute when the event is raised
//  _setFirst - (optional) if true, the code will be set first in the event's code list
NWG_fnc_evSubscribeToServerEvent = {
    //params ["_event","_code",["_setFirst",false]];
    ([NWG_EVENTS_ServerEvents]+_this) call NWG_EVENTS_SubscribeToEvent;
};

//Subscribes to the event on client side
//params:
//  _event - the event to subscribe to
//  _code - the code to execute when the event is raised
//  _setFirst - (optional) if true, the code will be set first in the event's code list
NWG_fnc_evSubscribeToClientEvent = {
    //params ["_event","_code",["_setFirst",false]];
    ([NWG_EVENTS_ClientEvents]+_this) call NWG_EVENTS_SubscribeToEvent;
};

//Raises the event on server side
//params:
//  _event - the event to raise
//  _args - (optional) the arguments to pass to the event's code
NWG_fnc_evRaiseServerEvent = {
    //params ["_event",["_args",[]]];
    ([NWG_EVENTS_ServerEvents]+_this) call NWG_EVENTS_RaiseEvent;
};

//Raises the event on client side
//params:
//  _event - the event to raise
//  _args - (optional) the arguments to pass to the event's code
NWG_fnc_evRaiseClientEvent = {
    //params ["_event",["_args",[]]];
    ([NWG_EVENTS_ClientEvents]+_this) call NWG_EVENTS_RaiseEvent;
};