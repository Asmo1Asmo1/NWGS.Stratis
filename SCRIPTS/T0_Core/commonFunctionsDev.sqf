//===============================================================
//Object attach

//Gets the attachTo offset and setVectorDirAndUp values between two objects
//note: both objects will be temporarily attached to one another for this to work
//params: _parentObject - object to attach to
//params: _attachedObject - object to attach
//returns: array [attachTo offset, setVectorDirAndUp values]
NWG_fnc_devGetAttachToValues = {
    params ["_parentObject","_attachedObject"];

    _attachedObject disableCollisionWith _parentObject;
    _attachedObject attachTo [_parentObject];

    private _result = [
        //Offset
        (_parentObject getRelPos _attachedObject),
        //Dir and Up
        [
            (_attachedObject vectorWorldToModelVisual vectorDirVisual _parentObject),
            (_attachedObject vectorWorldToModelVisual vectorUpVisual _parentObject)
        ]
    ];

    detach _attachedObject;
    _attachedObject enableCollisionWith _parentObject;

    //Copy to clipboard
    copyToClipboard str _result;

    //return
    _result
};