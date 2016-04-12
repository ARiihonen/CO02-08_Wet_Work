/*
This runs on the server machine after objects have initialised in the map. Anything the server needs to set up before the mission is started is set up here.
*/

//set respawn tickets to 0
[missionNamespace, 1] call BIS_fnc_respawnTickets;
[missionNamespace, -1] call BIS_fnc_respawnTickets;

//Task setting: ['TaskName', locality, ['Description', 'Title', 'Marker'], target, 'STATE', priority, showNotification, true] call BIS_fnc_setTask;
['captureTask', true, ['Capture the russian officer as proof of their involvement in the rebellion.', 'Capture HVT', ''], nil, 'ASSIGNED', 0, false, true] call BIS_fnc_setTask;

//end mission
missionEnding = {
	_end = '';
	if (! ('captureTask' call BIS_fnc_taskCompleted) ) then {
		if (alive target) then {
			if ([trigger_extraction, (getPos vehicle target)] call BIS_fnc_inTrigger) then {
				['captureTask', 'SUCCEEDED', false] call BIS_fnc_taskSetState;
				_end = 'Win';
			} else {
				['captureTask', 'FAILED', false] call BIS_fnc_taskSetState;
				['killTask', true, ['Kill the target if capturing is not successful.', 'Kill HVT', ''], nil, 'FAILED', 0, false, true] call BIS_fnc_setTask;
				_end = 'Lose';
			};
		} else {
			['captureTask', 'FAILED', false] call BIS_fnc_taskSetState;
			['killTask', true, ['Kill the target if capturing is not successful.', 'Kill HVT', ''], nil, 'SUCCEEDED', 0, false, true] call BIS_fnc_setTask;
			_end = 'Salvaged';
		};
	};
	
	//Runs end.sqf on everyone. For varying mission end states, calculate the correct one here and send it as an argument for end.sqf
	[_end,'end.sqf'] remoteExec ['BIS_fnc_execVM',west,false];
};

//Create trigger to handle ending when all living players are in extraction area
trigger_ending = createTrigger ['EmptyDetector', [0,0,0], false];
trigger_ending setTriggerActivation ['NONE', 'PRESENT', false];
trigger_ending setTriggerStatements [
	"{ !( [trigger_extraction, (getPos (vehicle _x)) ] call BIS_fnc_inTrigger ) } count playableUnits == 0",
	"call missionEnding;",
	""
];

//Sets different stages of shit hitting fan
missionNamespace setVariable ['kills_shit', 2 + (floor random 3), false];
missionNamespace setVariable ['kills_extra_shit', (missionNamespace getVariable 'kills_shit') + (floor random 6), false];

//trigger for shit hitting fan
trigger_shitfan = createTrigger ['EmptyDetector', [0,0,0], false];
trigger_shitfan setTriggerActivation ['NONE', 'PRESENT', false];
trigger_shitfan setTriggerStatements [
	"!(missionNamespace getVariable ['shit_extra_fan', false]) && !(missionNamespace getVariable ['shit_fan', false]) && (missionNamespace getVariable ['enemies_killed', 0] > missionNamespace getVariable ['kills_shit', 2])",
	"missionNamespace setVariable ['shit_fan', true, true]; hint 'shit fan!';",
	""
];

//trigger for shit hitting extra fan
trigger_shitfan_extra = createTrigger ['EmptyDetector', [0,0,0], false];
trigger_shitfan_extra setTriggerActivation ['NONE', 'PRESENT', false];
trigger_shitfan_extra setTriggerStatements [
	"!(missionNamespace getVariable ['shit_extra_fan', false]) && ( (missionNamespace getVariable ['enemies_killed', 0] > missionNamespace getVariable ['kills_extra_shit', 2]) || !canMove boat_1 || !canMove boat_2 || !canMove boat_3 )",
	"missionNamespace setVariable ['shit_extra_fan', true, true]; missionNamespace setVariable ['shit_fan', true, true]; hint 'shit extra fan!'",
	""
];

//time skip to mission start
phaseSwitch = {
	if ( dayTime < 4.75 ) then {
		missionNamespace setVariable ['phase_switching', true, true];
		
		[[],'player\phaseSwitch.sqf'] remoteExec ['BIS_fnc_execVM',west,false];
		
		setTimeMultiplier 120;
		waitUntil { dayTime >= 4.75 };
		setTimeMultiplier 1;
		
		missionNamespace setVariable ['phase_switching', false, true];
	};
};

//trigger to detect when time skip should happen
trigger_timeskip = createTrigger ['EmptyDetector', [0,0,0], false];
trigger_timeskip setTriggerActivation ['NONE', 'PRESENT', false];
trigger_timeskip setTriggerStatements [
	"{ _x getVariable ['wetwork_ready', false] } count playableUnits == count playableUnits",
	"_timeskip = [] spawn phaseSwitch;",
	""
];

//play generator sounds from generator until morning
_generator_sounds = [] spawn {
	while { dayTime < 4.5 } do {
		_generator = generator_main;
		_position = generator_main modelToWorld [0,0,0];
		_filePath = [(str missionConfigFile), 0, -15] call BIS_fnc_trimString;
		_filePath = _filePath + 'sounds\generator.wav';
		
		playSound3D [_filePath, _generator, false, _position, 1, 1, 0];
		sleep 2.3;
	};
};

//client inits wait for serverInit to be true before starting, to make sure all variables the server sets up are set up before clients try to refer to them (which would cause errors)
serverInit = true;
publicVariable 'serverInit';