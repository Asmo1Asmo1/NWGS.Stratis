//Check if object is building
// _objectOrClassname: Object OR string (class name)
// Returns: Boolean
NWG_fnc_ocIsBuilding = {
    // private _objectOrClassname = _this;
    _this call NWG_OBCL_IsBuilding
};

//Gets 'same' buildings from catalogue (classnames that represent a retexture of the same model)
// _objectOrClassname: Object OR string (class name)
// Returns:
// 1) Array of calssnames including the object itself if there are several models of the same building
// 2) Array with only argument classname itself if building is unique
// 3) Empty array if arg is not a building
NWG_fnc_ocGetSameBuildings = {
    // private _objectOrClassname = _this;
    _this call NWG_OBCL_GetSameBuildings
};

//Check if object is furniture
// _objectOrClassname: Object OR string (class name)
// Returns: Boolean
NWG_fnc_ocIsFurniture = {
    // private _objectOrClassname = _this;
    _this call NWG_OBCL_IsFurniture
};

//Gets 'same' furniture from catalogue (classnames that represent a retexture of the same model)
// _objectOrClassname: Object OR string (class name)
// Returns:
// 1) Array of calssnames including the object itself if there are several models of the same furniture
// 2) Array with only argument classname itself if furniture is unique
// 3) Empty array if arg is not a furniture
NWG_fnc_ocGetSameFurniture = {
    // private _objectOrClassname = _this;
    _this call NWG_OBCL_GetSameFurniture
};

//Check if object is vehicle
// _object: Object
// Returns: Boolean
NWG_fnc_ocIsVehicle = {
    // private _object = _this;
    _this call NWG_OBCL_IsVehicle
};