//Runs on both server and clients after initServer.sqf is finished
waitUntil {!isNil "serverInit"};
waitUntil {serverInit};

#include "logic\activeMods.sqf"

//initialise mods if active
if ( "task_force_radio" call caran_checkMod ) then {
	_load = [] execVM "mods\tfar.sqf";
};

if ( "asr_ai3_main" call caran_checkMod ) then {
	_load = [] execVM "mods\asr.sqf";
};

//Player init: this will only run on players. Use it to add the briefing and any player-specific stuff like action-menu items.
if (!isServer || (isServer && !isDedicated) ) then {
	//put in briefings
	briefing = [] execVM "briefing\briefing.sqf";
	
	//Shot event handler
	_handleShooting = [] spawn {
		waitUntil { dayTime > 4.75 };
		
		player addEventHandler ["Fired", "
			if (!(missionNamespace getVariable ['shit_fan', false])) then {
				
				_weapon = _this select 1;
				
				if (_weapon != 'Put' ) then {
					_silenced = false;
					
					if (_weapon == primaryWeapon player && 'muzzle_snds_H' in primaryWeaponItems player) then {
						_silenced = true;
					} else {
						if (_weapon == handgunWeapon player && 'muzzle_snds_L' in handgunItems player) then {
							_silenced = true;
						};
					};
					
					if (!_silenced) then {
						missionNamespace setVariable ['shit_fan', true, true];
					};
				} else {
					hint 'put';
				};
			};
			
			if (missionNamespace getVariable ['shit_fan', false]) then {
				player removeEventHandler ['Fired', 0];
			};
		"];
	};
};

execVM "logic\hcHandle.sqf";