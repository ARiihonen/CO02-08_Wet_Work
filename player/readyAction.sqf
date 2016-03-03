_bool = _this select 3;

if (_bool) then {
	
	if (!surfaceIsWater getPos player) then {
		player setVariable ["wetwork_ready", true, true];
		player removeAction ready_action;
		
		sleep 2;
		unready_action = player addAction ["<t color='#CD0000'>Not Ready</t>", "player\readyAction.sqf", false, 1, false, true];
	} else {
		hint "Can't wait on water.";
	};
	
} else {
	player setVariable ["wetwork_ready", false, true];
	player removeAction unready_action;
	
	sleep 2;
	ready_action = player addAction ["<t color='#228B22'>Ready to wait</t>", "player\readyAction.sqf", true, 1, false, true];
};