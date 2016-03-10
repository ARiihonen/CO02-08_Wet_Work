mortar addEventHandler ['Fired',"
	diag_log format ['mortar fired, %1', _this];
	_projectile = _this select 6;
	diag_log format ['projectile: %1', _projectile];
	
	_light = '#lightpoint' createVehicleLocal (getPos _projectile);
	_light lightAttachObject [_projectile, [0,0,0]];
	
	_light setLightBrightness 0;
	_light setLightAmbient [0,0,0];
	_light setLightColor[0,0,0];
	_light setLightAttenuation  [0, 0, 0, 0, 0, 0];

	_light setLightUseFlare false;
	_light setLightFlareSize 0;
	_light setLightFlareMaxDistance 0;
	
	_lightBoom = _light spawn {
		_light = _this;
		sleep (mortar getArtilleryETA [markerPos 'marker_?', '8Rnd_82mm_Mo_Flare_white']);
		
		_light setLightAmbient [1,1,1];
		_light setLightColor[1,1,1];
		_light setLightAttenuation  [0, 0, 0, 5, 1500, 1500];

		_light setLightUseFlare true;
		_light setLightFlareMaxDistance 1000;
		
		_brightness = 0;
		_flare = 0;
		for '_i' from 1 to 100 do {
			_brightness = 0.2*_i;
			_flare = 0.1*_i;
			
			_light setLightBrightness _brightness;
			_light setLightFlareSize _flare;
			
			sleep 0.01;
		};
		
		sleep 25;
		
		while { _brightness > 0 && _flare > 0 } do {
			_brightness = _brightness - 0.2;
			_flare = _flare - 0.1;
			
			_light setLightBrightness _brightness;
			_light setLightFlareSize _flare;
			
			sleep 0.01;
		};
		
		deleteVehicle _light;
	};
"];