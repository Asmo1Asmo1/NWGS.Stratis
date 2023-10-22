//================================================================================================================
//================================================================================================================
//Dots generation - Core for other functions

NWG_SPWB_GenerateDotsCircle = {
    params ["_pos","_rad","_count"];

    private _sector = 360/_count;
    private _randShift = (random (_sector*2)) - _sector;
    private _result = [];
    private "_dot";

    for "_i" from 0 to (_count-1) do {
        _dot = _pos getPos [_rad,((_sector * _i) + _randShift)];
        _dot set [2,0];
        _result pushBack _dot;
    };

    //return
    _result
};

NWG_SPWB_GenerateDotsCloud = {
    params ["_pos","_rad","_count"];

    private _result = [];
    private "_dot";

    for "_i" from 0 to (_count-1) do {
        _dot = _pos getPos [((sqrt random 1) * _rad),(random 360)];
        _dot set [2,0];
        _result pushBack _dot;
    };

    //return
    _result
};

NWG_SPWB_GenerateDottedArea = {
    params ["_pos","_minRad","_maxRad","_step"];

    private _result = [];
    private _curRad = _minRad;
    private ["_count","_sector","_randShift","_dot"];

    while { _curRad <= _maxRad } do {
        _count = (round ((6.28*_curRad)/_step)) max 1;
        _sector = 360/_count;
        _randShift = (random (_sector*2)) - _sector;

        for "_i" from 0 to (_count-1) do {
            _dot = _pos getPos [_curRad,((_sector * _i) + _randShift)];
            _dot set [2,0];
            _result pushBack _dot;
        };

        _curRad = _curRad + _step;
    };

    //return
    _result
};