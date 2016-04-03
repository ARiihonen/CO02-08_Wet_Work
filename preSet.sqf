/*
This script is defined as a pre-init function in description.ext, meaning it runs before the map initialises.
*/
#include "logic\preInit.sqf"
#include "logic\activeMods.sqf"

if (isServer) then {
	//Randomizing unit presence variables
	main_spot = 1+ (floor(random 3));
	
	//Define strings to search for in active addons
	_checkList = [
		"asr_ai3_main",
		"task_force_radio"
	];
	
	//Check mod checklist against active addons
	_checkList call caran_initModList;
	
	if ( 'asr_ai3_main' call caran_checkMod ) then {
		call compile preprocessfile 'mods\asr.sqf';
	};
};