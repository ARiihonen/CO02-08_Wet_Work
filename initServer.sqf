/*
This runs on the server machine after objects have initialised in the map. Anything the server needs to set up before the mission is started is set up here.
*/

//set respawn tickets to 0
[missionNamespace, 1] call BIS_fnc_respawnTickets;
[missionNamespace, -1] call BIS_fnc_respawnTickets;

//Task setting: ["TaskName", locality, ["Description", "Title", "Marker"], target, "STATE", priority, showNotification, true] call BIS_fnc_setTask;
["captureTask", true, ["Capture the russian officer as proof of their involvement in the rebellion.", "Capture HVT", ""], nil, "ASSIGNED", 0, false, true] call BIS_fnc_setTask;
//Add killTask and fail captureTask if dead target ID'd (action)

//Spawns a thread that will run a loop to keep an eye on mission progress and to end it when appropriate, checking which ending should be displayed.
_progress = [] spawn {
	
	//Init all variables you need in this loop
	_ending = false;
	_players_away = false;
	_phase_switch = false;

	//Starts a loop to check mission status every second, update tasks, and end mission when appropriate
	while {!_ending} do {
		sleep 2;
		
		//Mission ending condition check
		if ( _players_away ) then {
			_ending = true;
			
			sleep 2;
			
			if (! ("captureTask" call BIS_fnc_taskCompleted) ) then {
				if (alive target) then {
					if (target in list trigger_extraction) then {
						["captureTask", "SUCCEEDED", false] call BIS_fnc_taskSetState;
					} else {
						["captureTask", "FAILED", false] call BIS_fnc_taskSetState;
						["killTask", true, ["Kill the target if capturing is not successful.", "Kill HVT", ""], nil, "FAILED", 0, false, true] call BIS_fnc_setTask;
					};
				} else {
					["captureTask", "FAILED", false] call BIS_fnc_taskSetState;
					["killTask", true, ["Kill the target if capturing is not successful.", "Kill HVT", ""], nil, "SUCCEEDED", 0, false, true] call BIS_fnc_setTask;
				};
			};
			
			sleep 8;
			
			_end = "";
			if ( toUpper (["captureTask"] call BIS_fnc_taskState) == "SUCCEEDED" ) then {
				_end = "Win";
				
				diag_log "Capturetask succeeded";
			} else {
				if ( toUpper (["killTask"] call BIS_fnc_taskState) == "SUCCEEDED" ) then {
					_end = "Salvaged";
					
					diag_log "Kill task succeeded";
				} else {
					_end = "Lose";
					
					diag_log "Nothing succeeded";
				};
			};
			
			//Runs end.sqf on everyone. For varying mission end states, calculate the correct one here and send it as an argument for end.sqf
			[[_end],"end.sqf"] remoteExec ["BIS_fnc_execVM",west,false];
		};
		
		//Sets shit hitting the fan if THINGS
		if (!(missionNamespace getVariable ["shit_fan", false]) && (!canMove boat_1 || !canMove boat_2 || !canMove boat_3) ) then {
			missionNamespace setVariable ["shit_fan", true];
		};
		
		//Sets _players_away as true if everyone alive is in extract area:
		_players_away = true;
		{
			if (alive _x && !(_x in list trigger_extraction)) then {
				_players_away = false;
			};
		} forEach playableUnits;
		
		//Advances to mission stage 2 if all players ready
		if (!_phase_switch) then {
			_phase_switch = true;
			{
				if (!(_x getVariable ["wetwork_ready", false])) then {
					_phase_switch = false;
				};
			} forEach playableUnits;
		};
		
		if ( dayTime < 4.75 ) then {
			if (_phase_switch) then {
				sleep 1;
				
				[[],"player\phaseSwitch.sqf"] remoteExec ["BIS_fnc_execVM",west,false];
				
				setTimeMultiplier 120;
				waitUntil { dayTime >= 4.75 };
				setTimeMultiplier 1;
				
				missionNamespace setVariable ["phase_2", true];
			};
		} else {
			if (missionNamespace getVariable ["phase_2", false]) then {
				missionNamespace setVariable ["phase_2", true];
			};
		};
	
	};
};

_generator_sounds = [] spawn {
	while { dayTime < 5 } do {
		_generator = generator_main;
		_position = generator_main modelToWorld [0,0,0];
		_filePath = [(str missionConfigFile), 0, -15] call BIS_fnc_trimString;
		_filePath = _filePath + "sounds\generator.wav";
		
		playSound3D [_filePath, _generator, false, _position, 1, 1, 0];
		sleep 2.3;
	};
};

//client inits wait for serverInit to be true before starting, to make sure all variables the server sets up are set up before clients try to refer to them (which would cause errors)
serverInit = true;
publicVariable "serverInit";