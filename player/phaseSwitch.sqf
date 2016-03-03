_playerPos = getPos player;

_goggles = false;
if (goggles player == "G_Diving") then {
	player unassignItem (goggles player);
};

_cam = "camera" camcreate _playerPos;
_cam cameraeffect ["internal", "back"];
showcinemaBorder false;

_cam camPrepareTarget _playerPos;
_cam camPreparePos [(_playerPos select 0), (_playerPos select 1) - 75, 50];
_cam camPrepareFOV 0.75;
_cam camCommitPrepared 10;
waitUntil { camCommitted _cam };

_cam camPrepareTarget (markerPos "cam_target");
_cam camCommitPrepared 5;
waitUntil { camCommitted _cam };

waitUntil { dayTime > 4.75 };

_cam camPrepareTarget _playerPos;
_cam camCommitPrepared 2;
waitUntil { camCommitted _cam };

_cam camPreparePos _playerPos;
_cam camCommitPrepared 5;
waitUntil { camCommitted _cam };

_cam cameraeffect ["terminate", "back"];
camDestroy _cam;

if (_goggles) then {
	_player assignItem "G_Diving";
};