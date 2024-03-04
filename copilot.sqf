/*
    Annotation: this is a boilerplate with examples for GitHub Copilot
    The project is written in SQF language for Arma 3 and uses global variables of type 'code' as functions
    All the global variables are prefixed with 'NWG_' - tag of this project
*/

/* commonFunctions.sqf */
// Example of a global function - function that has its own logic and is used cross-module. Has descriptive name and comments explaining its purpose
//Concatenates parameters and returns the result
//params:
//  _param1 - first parameter
//  _param2 - second parameter
//  _optionalParam - (optional) third parameter, default value is 'defaultValue'
//returns:
//  _result - concatenation of parameters
NWG_fnc_concatenateParams = {
    params ["_param1","_param2",["_optionalParam","defaultValue"]];
    private _result = _param1 + _param2 + _optionalParam;
    //return
    _result
};
//Examples of usage
private _resultA = ["a","b"] call NWG_fnc_concatenateParams;
private _resultB = ["a","b","c"] call NWG_fnc_concatenateParams;

// Example of a function with a single argument
// Notice that instead of 'params' the 'private' and '_this' are used, and first line is commented out
//Returns the argument
//params:
//  _param - parameter
//returns:
//  _param - parameter
NWG_fnc_returnParam = {
    // private _param = _this;
    //return
    _this
};
//Examples of usage
private _resultA = "a" call NWG_fnc_returnParam;
private _resultB = "b" call NWG_fnc_returnParam;

/* boilerPlateFuctions.sqf */
// Example of a function tied to a module (naming includes shortened module name, 'bp' in this case - boilerplate module)
// Such functions are 'interfaces' between modules, so they are defined in a separate file and have comments explaining their purpose
// Notice that 'params' are commented out and '_this' is used instead
//Concatenates parameters and returns the result
//params:
//  _param1 - first parameter
//  _param2 - second parameter
//  _optionalParam - (optional) third parameter, default value is 'defaultValue'
//returns:
//  _result - concatenation of parameters
NWG_fnc_bpConcatenateParams = {
    // params ["_param1","_param2",["_optionalParam","defaultValue"]];
    _this call NWG_BP_ConcatenateParams
};
//Examples of usage
private _resultA = ["a","b"] call NWG_fnc_bpConcatenateParams;
private _resultB = ["a","b","c"] call NWG_fnc_bpConcatenateParams;

/* boilerPlate.sqf */
// Example of module content

// Example of module's field
NWG_BP_concatenateResults = [];

// Example of module init
private _Init = {
    NWG_BP_concatenateResults = [];
};

// Example of internal module function ('BP' in this case - boilerplate module)
// Such functions are defined inside the module file and are not available outside of it in other way than through the interface function
NWG_BP_ConcatenateParams = {
    params ["_param1","_param2",["_optionalParam","defaultValue"]];
    private _result = _param1 + _param2 + _optionalParam;
    NWG_BP_concatenateResults pushBack _result;
    _result
};

// Example of internal module function with a single argument
NWG_BP_ReturnParam = {
    // private _param = _this;
    NWG_BP_concatenateResults pushBack _this;
    _this
};

// Examples of usage and often used patterns and functions
NWG_BP_RunOftenUsed = {
    private _variable = 101;
    //Log error
    (format ["NWG_BP_RunOftenUsed: Error example '%1'",_variable]) call NWG_fnc_logError;
    //Common array-related functions
    private _array = ["a","b","b","c"];
    _array = _array call NWG_fnc_arrayShuffle;//Shuffle array
    _array = _array arrayIntersect _array;//Remove duplicates
    //Common logic and branching
    private _i = _array find "b";
    private _j = _array findIf {_x isEqualTo "b"};
    private _vowels = _array select {_x in ["a","e","i","o","u"]};

    if (_array isEqualTo ["a","b","c"]) then {
        systemChat "Array is equal to ['a','b','c']";
    } else {
        systemChat "Array is not equal to ['a','b','c']";
    };

    switch (true) do {
        case (_array isEqualTo ["a","b","c"]): {
            systemChat "Array is equal to ['a','b','c']";
        };
        case (_i isEqualTo 1): {
            systemChat "Array contains 'b' at index 1";
        };
        default {
            systemChat "Array is not equal to ['a','b','c']";
        };
    };
};