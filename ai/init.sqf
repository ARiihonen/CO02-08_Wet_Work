//this bit is for all AI scripts you want to run at mission start. Maybe you want to spawn in dudes or something.

/*
{
	if (!isPlayer _x) then {
		_x execVM "ai\gear.sqf";
	};
} forEach allUnits;
*/

//Loop to keep main groups from moving too far beyond their own zones, while still being dismissed
_mainGroups = [] spawn {
	
	_groups = [group_main, group_aa, group_fwd];
	{
		_x setVariable ["wetwork_base", (getPos leader _x), false];
		_x setVariable ["dismiss_group", units _x, false];
	} forEach _groups;
	
	while { !(missionNamespace getVariable ["shitFan", false]) } do {
		sleep 1;
		{
			_grp = _x;
			
			_callback = false;
			{
				if (_x distance (_grp getVariable "wetwork_base") > 100 ) then {
					_callback = true;
				};
			} forEach units _grp;
			
			if (_callback) then {
				_newGroup = createGroup east;
				_newGroup setVariable ["wetwork_base", _grp getVariable "wetwork_base", false];
				
				(_grp getVariable "dismiss_group") joinSilent _newGroup;
				_newGroup setVariable ["dismiss_group", units _x, false];
					
				_wp = _newGroup addWaypoint [_newGroup getVariable "wetwork_base", 0, 1];
				_wp setWaypointType "MOVE";
				_wp setWaypointBehaviour "SAFE";
				_wp setWaypointSpeed "LIMITED";
				_wp setWaypointCombatMode "RED";
				_newGroup setCurrentWaypoint _wp;
				
				_wp2 = _newGroup addWaypoint [_newGroup getVariable "wetwork_base", 0, 2];
				_wp2 setWaypointType "DISMISS";
				
				_groups = _groups - [_grp];
				_groups set [count _groups, _newGroup];
			};
			
		} forEach _groups;
	};
};

_visitWaypoints = [] spawn {
	waitUntil { (missionNamespace getVariable ["meeting_over", false]) };
	
	if (!(missionNamespace getVariable ["shit_fan", false])) then {
		(units group target) joinSilent (group local_leader);
		
		_markers_road = ["marker_road_1"];
		for "_i" from 2 to (5 - main_spot) do {
			_markers_road set [count _markers_road, format ["marker_road_%1", _i]];
		};
		
		{
			_wp = (group target) addWaypoint [markerPos _x, 0];
		} forEach _markers_road;
		
		_marker_base = format ["marker_main_%1", main_spot];
		for "_i" from 1 to 5 do {
			_wp = (group target) addWaypoint [markerPos _marker_base, 50];
		};
		
		_wpFinal = (group target) addWaypoint [markerPos "marker_finalwp", 0];
		_wpFinal setWaypointStatements ["true", "
			leaderGrp = createGroup east;
			[local_leader] joinSilent leaderGrp;
			
			_returnWp = (group leader) addWaypoint [getPos target_vehicle, 0];
			_returnWp setWaypointType 'GETIN';
			_returnWp waypointAttachVehicle target_vehicle;
		"];
	
	};
};
	
_escapeWaypoints = [] spawn {
	waitUntil { (missionNamespace getVariable ["shit_fan", false]) };
	
	_newGrp = createGroup east;
	[target] joinSilent _newGrp;
	
	if (vehicle target != target_vehicle) then {
		_escapeWP = _newGrp addWaypoint [getPos target_vehicle, 0];
		_escapeWP setWaypointType 'GETIN';
		_escapeWP setWaypointSpeed 'FULL';
		_escapeWP setWaypointBehaviour 'AWARE';
		_escapeWP waypointAttachVehicle target_vehicle;
		_newGrp setCurrentWaypoint _escapeWP;
	
		waitUntil { vehicle target == target_vehicle };
	};
	
	(crew target_vehicle) joinSilent _newGrp;

	_escapeWP = _newGrp addWaypoint [markerPos 'marker_escape', 0];
	_escapeWP setWaypointType 'MOVE';
	_escapeWP setWaypointSpeed 'FULL';
	_escapeWP setWaypointBehaviour 'AWARE';
	_newGrp setCurrentWaypoint _escapeWP;
};