//This runs on every respawning player AND players spawning in for the first time EVEN IF description.ext has set respawnOnStart to 0. Yeah, I don't get it either.
#include "logic\activeMods.sqf";

//Make screen black to disguise start teleporting
titleText ["", "BLACK FADED", 60];

//Make sure player has no more tickets so can't respawn
_tickets = [player, nil] call BIS_fnc_respawnTickets;
[player, (_tickets*-1)] call BIS_fnc_respawnTickets;

//_gear = player execVM "player\gear.sqf"; //running the gear script

//Disable various channels to disallow cheaty communication
{ _x enableChannel false } forEach [0,1,2];

//Put on NVGs
player action ["nvGoggles", player];

//Handle starting position
execVM "player\handleStartPosition.sqf";

//Add ready action
ready_action = player addAction ["<t color='#228B22'>Ready to wait</t>", "player\readyAction.sqf", true, 1, false, true];

waitUntil { missionNamespace getVariable ["phase_2", false] };
if (!isNil 'ready_action') then {
	player removeAction ready_action;
};
if (!isNil 'unready_action') then {
	player removeAction unready_action;
};