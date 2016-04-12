//Killed event handler for all AI
{
	if (side _x == east) then {
		_x addEventHandler ['Killed', "
			_dead = missionNamespace getVariable ['enemies_killed', 0]; 
			missionNamespace setVariable ['enemies_killed', _dead + 1];
		"];
	};
} forEach allUnits;

//regular AI reaction if shit hits the fan:
aiReaction = {
	_groups = [group_main, group_aa, group_fwd];
	diag_log format ['noticed: %1, shit_fan: %2, shit_extra_fan: %3', (missionNamespace getVariable ['players_noticed', false]), (missionNamespace getVariable ['shit_fan', false]), (missionNamespace getVariable ['shit_extra_fan', false]) ];
	
	{
		_grp = _x;

		if ( _grp == group_fwd ) then {
			_wp = _grp addWaypoint [getPos mortar, 0, 1];
			_wp setWaypointType 'GETIN';
			_wp setWaypointBehaviour 'AWARE';
			_wp setWaypointSpeed 'FULL';
			_wp setWaypointCombatMode 'RED';
			_wp waypointAttachVehicle mortar;
			_grp setCurrentWaypoint _wp;
			
			(leader _grp) assignAsGunner mortar;
		} else {
			_wp = _grp addWaypoint [(getPos leader _grp), 0, 1];
			_wp setWaypointType 'SAD';
			_wp setWaypointBehaviour 'AWARE';
			_wp setWaypointSpeed 'LIMITED';
			_wp setWaypointCombatMode 'RED';
			_grp setCurrentWaypoint _wp;
			
			_wp = _grp addWaypoint [(getpos leader _grp), 0];
			_wp setWaypointType 'CYCLE';
		};
	} forEach _groups;
	
	{
		if (side _x == east && !(target in units _x || vehicle leader _x == target_vehicle) ) then {
			_x setBehaviour 'AWARE';
		};
	} forEach allGroups;
	
	if (dayTime < 4.5 && !(missionNamespace getVariable ['phase_switching', false])) then {
		_mortarBarrage = [] spawn {
			[[],'effects\mortarLight.sqf'] remoteExec ['BIS_fnc_execVM', 0, true];
			waitUntil { count crew mortar > 0 };
			
			sleep 2;
			mortar doArtilleryFire [markerPos 'marker_?', '8Rnd_82mm_Mo_Flare_white', 1];
			for "_i" from 1 to 3 do {
				if (!(missionNamespace getVariable ['phase_switching', false])) then {
					mortar doArtilleryFire [markerPos 'marker_?', '8Rnd_82mm_Mo_Flare_white', 1];
					sleep 60;
				};
			};
		};
	};
};

//detect shit in fan for AI reaction
trigger_reaction = createTrigger ['EmptyDetector', [0,0,0], false];
trigger_reaction setTriggerActivation ['NONE', 'PRESENT', true];
trigger_reaction setTriggerStatements [
	"missionNamespace getVariable ['shit_fan', false] || missionNamespace getVariable ['shit_extra_fan', false] || missionNamespace getVariable ['players_noticed', false]",
	"call aiReaction; diag_log 'reaction'; hint 'reaction';",
	""
];

breakMeeting = {
	_newGrp = createGroup east;
	((units group target) - [local_leader]) joinSilent _newGrp;
	[local_leader] joinSilent (createGroup east);
	
	_behaviour = 'SAFE';
	_speed = 'NORMAL';
	if ( missionNamespace getVariable ['shit_fan', false] || missionNamespace getVariable ['shit_extra_fan', false] ) then {
		_behaviour = 'AWARE';
		_speed = 'FULL';
	};
	
	//missionNamespace setVariable ['fuck_off_vehicles', false];
	if (vehicle target != target_vehicle) then {
		_escapeWP = _newGrp addWaypoint [getPos target_vehicle, 0];
		_escapeWP setWaypointType 'GETIN';
		_escapeWP setWaypointSpeed _speed;
		_escapeWP setWaypointBehaviour _behaviour;
		_escapeWP waypointAttachVehicle target_vehicle;
		
		{
			_x assignAsCargo target_vehicle;
		} forEach (units group target);
		
		_newGrp setCurrentWaypoint _escapeWP;
	};
	
	_getOut = [_behaviour, _speed] spawn {
		_behaviour = _this select 0;
		_speed = _this select 1;
		
		waitUntil { vehicle target == target_vehicle };
		
		(crew target_vehicle) joinSilent (group target);
		_escapeWP = (group target) addWaypoint [markerPos 'marker_escape', 0];
		_escapeWP setWaypointType 'MOVE';
		_escapeWP setWaypointSpeed _speed;
		_escapeWP setWaypointBehaviour _behaviour;
		(group target) setCurrentWaypoint _escapeWP;
	};
	
	true
};

_visitWaypoints = [] spawn {
	waitUntil { missionNamespace getVariable ['target_contacted', false] };
	if ( missionNamespace getVariable ['shit_extra_fan', false] ) then {
		diag_log 'shit extra fan, not meeting';
		
		_escape = [] call breakMeeting;
	};
	
	waitUntil { (missionNamespace getVariable ['meeting_started', false]) };
	diag_log 'meeting started';
	
	_shitFanHandle = [] spawn {
		waitUntil { missionNamespace getVariable ['shit_fan', false] || missionNamespace getVariable ['shit_extra_fan', false] };
		diag_log 'shit in fan, calling off meeting';
		
		_escape = [] call breakMeeting;
	};
	
	waitUntil { (missionNamespace getVariable ['meeting_over', false]) };
	diag_log 'meeting over';
	
	if (!(missionNamespace getVariable ['shit_fan', false]) && !(missionNamespace getVariable ['shit_extra_fan', false]) ) then {
		{
			diag_log format ['%1 vehicle: %2', _x, assignedVehicle _x];
			unassignVehicle _x;
		} forEach ( (units group target) + [local_leader] );
		
		_behaviour = behaviour local_leader;
		[local_leader] joinSilent (group target);
		if (_behaviour != 'SAFE') then {
			(group target) setBehaviour _behaviour;
			(group target) setFormation 'DIAMOND';
		};
		
		_startWp = (group target) addWaypoint [markerPos 'marker_route_1', 0];
		(group target) setCurrentWaypoint _startWp;

		_markers_road = [];
		for '_i' from 2 to (5 - main_spot) do {
			_markers_road set [count _markers_road, format ['marker_route_%1', _i]];
		};
		diag_log format ['Main spot: %1, markers road: %2', main_spot, _markers_road];
		
		{
			_wp = (group target) addWaypoint [markerPos _x, 0];
		} forEach _markers_road;
		
		_marker_base = format ['marker_main_%1', main_spot];
		for '_i' from 1 to 5 do {
			_wp = (group target) addWaypoint [markerPos _marker_base, 50];
		};
		
		_wpFinal = (group target) addWaypoint [markerPos 'marker_finalwp', 0];
		_wpFinal setWaypointStatements ['true', ' _away = [] call breakMeeting; '];
	};
};