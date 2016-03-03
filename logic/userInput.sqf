_bool = _this;

disableUserInput _bool;

if (!_bool) then {
	disableUserInput true;
	disableUserInput false;
	
	hint "Time to move";
} else {
	hint "You settle down to wait...";
};