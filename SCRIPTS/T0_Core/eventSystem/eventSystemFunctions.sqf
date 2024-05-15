//Subscribes to the event on server side
//params:
//  _event - the event to subscribe to
//  _code - the code to execute when the event is raised
//  _setFirst - (optional) if true, the code will be set first in the event's code list
NWG_fnc_subscribeToServerEvent = {
    //params ["_event","_code",["_setFirst",false]];
    ([NWG_EVENTS_ServerEvents,NWG_EVENTS_ServerEventsHistory]+_this) call NWG_EVENTS_SubscribeToEvent;
};

//Subscribes to the event on client side
//params:
//  _event - the event to subscribe to
//  _code - the code to execute when the event is raised
//  _setFirst - (optional) if true, the code will be set first in the event's code list
NWG_fnc_subscribeToClientEvent = {
    //params ["_event","_code",["_setFirst",false]];
    ([NWG_EVENTS_ClientEvents,NWG_EVENTS_ClientEventsHistory]+_this) call NWG_EVENTS_SubscribeToEvent;
};

//Raises the event on server side
//params:
//  _event - the event to raise
//  _args - (optional) the arguments to pass to the event's code
NWG_fnc_raiseServerEvent = {
    //params ["_event",["_args",[]]];
    ([NWG_EVENTS_ServerEvents,NWG_EVENTS_ServerEventsHistory]+_this) call NWG_EVENTS_RaiseEvent;
};

//Raises the event on client side
//params:
//  _event - the event to raise
//  _args - (optional) the arguments to pass to the event's code
NWG_fnc_raiseClientEvent = {
    //params ["_event",["_args",[]]];
    ([NWG_EVENTS_ClientEvents,NWG_EVENTS_ClientEventsHistory]+_this) call NWG_EVENTS_RaiseEvent;
};