//================================================================================================================
//================================================================================================================
//Settings
NWG_ESCB_CLI_Settings = createHashMapFromArray [
	/*Texture settings*/
	["TEXTURE_TEMPLATE","#(rgb,1024,1024,3)text(0,0,""Caveat"",0.1,""#000000"",""#ffffff"",""%1\n%2"")"],

	/*Localization*/
	["LOC_TITLE","#ESCB_TITLE#"],
	["LOC_NO_WINNERS","#ESCB_NO_WINNERS#"],

	/*Chart settings*/
	["CHART_ITEM_LENGTH",20],//Lenght of one item in characters
	["CHART_COLUMNS",2],//Number of columns

    ["",0]
];

//================================================================================================================
//================================================================================================================
//Init
private _Init = {
	//Send request to server
	remoteExec ["NWG_fnc_escbRequestValues",2];
};

//================================================================================================================
//================================================================================================================
//Set billboard with names
NWG_ESCB_CLI_OnValuesResponse = {
	params ["_billboardObject","_winners"];

	private _title = (NWG_ESCB_CLI_Settings get "LOC_TITLE") call NWG_fnc_localize;
	private _body = if ((count _winners) > 0)
		then {_winners call NWG_ESCB_CLI_FormatWinners}
		else {(NWG_ESCB_CLI_Settings get "LOC_NO_WINNERS") call NWG_fnc_localize};
	private _texture = format [(NWG_ESCB_CLI_Settings get "TEXTURE_TEMPLATE"),_title,_body];

	//Set texture
	_billboardObject setObjectTexture [0,_texture];
};

NWG_ESCB_CLI_FormatWinners = {
	private _winners = _this;
	private _itemLength = NWG_ESCB_CLI_Settings get "CHART_ITEM_LENGTH";
	private _columns = NWG_ESCB_CLI_Settings get "CHART_COLUMNS";

	//Form winners into chart - single string separated by newlines
	//Where each row is: "winnerName" maxed to _itemLength (either shortend or padded with spaces) * _columns
	private _rowCount = ceil ((count _winners) / _columns);
	private _rowResult = [];
	private _result = [];
	private ["_index","_name","_temp"];
	for "_row" from 0 to (_rowCount - 1) do {
		_rowResult = [];

		for "_col" from 0 to (_columns - 1) do {
			_index = _row + (_col * _rowCount);
			if (_index >= (count _winners)) exitWith {};
			// Ensure name is exactly _itemLength characters (truncate or pad with spaces)
			_name = _winners select _index;
			_name = switch (true) do {
				case ((count _name) == _itemLength): {_name};
				case (count _name > _itemLength): {_name select [0, _itemLength]};
				default {
					_temp = _name;
					private _attempts = 100;
					while {_attempts > 0} do {
						if ((count _temp) >= _itemLength) exitWith {};
						_temp = _temp + " ";
						_attempts = _attempts - 1;
					};
					_temp
				};
			};
			_rowResult pushBack _name;
		};

		if ((count _rowResult) > 0) then {
			_result pushBack (_rowResult joinString "");
		};
	};

	_result joinString "\n"
};

//================================================================================================================
//================================================================================================================
call _Init;