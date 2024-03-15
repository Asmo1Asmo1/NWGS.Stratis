/*
    Annotation
    This is an event system specific for NWG logic
    This is where subsystems can subscribe to events that other subsystems can trigger
    Note: the events for server and client has been separated for clarity, especially during local testing
*/

if (!isNil "NWG_EVENTS_ServerEvents") exitWith {};//Fix double compile issue in local testing

NWG_EVENTS_ServerEvents = createHashMap;
NWG_EVENTS_ServerEventsHistory = createHashMap;

NWG_EVENTS_ClientEvents = createHashMap;
NWG_EVENTS_ClientEventsHistory = createHashMap;

NWG_EVENTS_SubscribeToEvent = {
    params ["_eventCollection","_history",["_event",""],["_code",{}],["_setFirst",false]];

    switch (true) do {
        case (!(_event in _eventCollection)): {_eventCollection set [_event,[_code]]; true};//Return true if the event is new ("fix" misleading 'false' return)
        case (_setFirst): {private _subs = _eventCollection get _event; _eventCollection set [_event,([_code]+_subs)]};
        default {(_eventCollection get _event) pushBack _code};
    };

    //Fire immediately if the event has already been raised before we subscribed
    if (_event in _history) then {(_history get _event) call _code};
};

NWG_EVENTS_RaiseEvent = {
    params ["_eventCollection","_history",["_event",""],["_args",[]]];
    {_args call _x} forEach (_eventCollection getOrDefault [_event,[]]);
    _history set [_event,_args];//Save the event for future subscribers
};