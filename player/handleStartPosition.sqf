
//Handle starting position
_position = [0,0,0];
_groupID = groupID (group player);

//build list of markers within applicable zone with "infil" present:
_infil_markers = [];
{
	if ( ["infil", markerText _x] call BIS_fnc_inString ) then {
		if ( ["marker_shore_1", (getMarkerPos _x)] call BIS_fnc_inTrigger || ["marker_shore_2", (getMarkerPos _x)] call BIS_fnc_inTrigger ) then {
			_infil_markers set [count _infil_markers, _x];
		};
	};
} forEach allMapMarkers;

//If group name present in some infil marker, choose it:
_group_markers = [];
{
	if ( [_groupID, markerText _x] call BIS_fnc_inString ) then {
		_group_markers set [count _group_markers, _x];
	};
} forEach _infil_markers;

//If there are infil markers and group markers, select group marker. If no group markers, select infil marker. If neither, select default position.
_text = "";
if (count _infil_markers > 0) then {
	
	if ( count _group_markers > 0) then {
		_position = getMarkerPos (_group_markers select 0);
		(_group_markers select 0) setMarkerTypeLocal "mil_start";
		(_group_markers select 0) setMarkerColorLocal "ColorWEST";
		(_group_markers select 0) setMarkerDirLocal 315;
		
		if (count _group_markers > 1) then {
			_text = "Multiple markers with group ID and 'infil' found. Selecting first.";
		};
		
	} else {
		_position = getMarkerPos (_infil_markers select 0);
		(_infil_markers select 0) setMarkerTypeLocal "mil_start";
		(_infil_markers select 0) setMarkerColorLocal "ColorWEST";
		(_infil_markers select 0) setMarkerDirLocal 315;
		
		if (count _infil_markers > 1) then {
			_text = "Multiple markers with 'infil' found. Selecting first.";
		};
	};
	
} else {
	_text = "No applicable markers found. Selecting default starting position.";
	_position = getMarkerPos "alternate_start";
	
	"alternate_start" setMarkerTypeLocal "mil_start";
	"alternate_start" setMarkerColor "ColorWEST";
	"alternate_start" setMarkerText "Default start position";
};

//Move starting position until it is on water.
while {!surfaceIsWater _position} do {
	_position = ( [ (_position select 0) + 5, (_position select 1) - 5, 0] );
};
_position = ( [ (_position select 0) + 10, (_position select 1) - 10, 0] );

//Offset position if group red
if (_groupID == "Red") then {
	_position = ( [ (_position select 0) + 10, (_position select 1) + 2.5, 0] );
};

//Offset position by group number
_num = 0;
{
	if (player == _x) then {
		_num = _forEachIndex;
	};
} forEach (units group player);
_position = ( [ (_position select 0) + (2.5*_num), _position select 1, 0] );

//Place player on position
player setPos _position;
player setDir 315;

//Fade back
titleText ["", "BLACK IN", 5];
if (_text != "") then {
	hint _text;
};