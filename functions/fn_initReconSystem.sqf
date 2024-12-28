if (!isServer) exitWith {};

// Initialize any server-side systems here
if (nzf_reconSystem_debug) then {
    diag_log "[NZF Recon System] Server initialization complete";
};

// Debug: Check for recon targets
if (nzf_reconSystem_debug) then {
    [{
        private _reconTargets = allMissionObjects "All" select {_x getVariable ["nzf_reconSystem_isTarget", false]};
        
        if (count _reconTargets > 0) then {
            {
                private _targetInfo = format ["[NZF Recon System] Debug: Recon Target Found - Type: %1, Position: %2", typeOf _x, getPos _x];
                if (nzf_reconSystem_debug) then {
                    _targetInfo remoteExec ["systemChat", 0];
                };
                diag_log _targetInfo;
            } forEach _reconTargets;
        } else {
            private _msg = "[NZF Recon System] Debug: No recon targets found";
            if (nzf_reconSystem_debug) then {
                _msg remoteExec ["systemChat", 0];
            };
            diag_log _msg;
        };
    }, [], 1] call CBA_fnc_waitAndExecute;
}; 

// Add camera handlers for player
if (hasInterface) then {
    private _lastSnapshot = -1;
    private _cooldown = 1;
    private _cameraClass = missionNamespace getVariable ["nzf_reconSystem_cameraClass", ""];
    private _pfhID = -1;
    
    // Exit if no valid camera class is set
    if (_cameraClass == "") exitWith {
        if (nzf_reconSystem_debug) then {
            systemChat "[NZF Recon System] Error: No camera class defined in CBA settings";
        };
    };
    
    // Exit if camera class doesn't exist
    if !(isClass (configFile >> "CfgWeapons" >> _cameraClass)) exitWith {
        if (nzf_reconSystem_debug) then {
            systemChat format ["[NZF Recon System] Error: Camera class '%1' not found", _cameraClass];
        };
    };

    player addEventHandler ["OpticsSwitch", {
        params ["_unit", "_isOptics"];
        private _cameraClass = missionNamespace getVariable ["nzf_reconSystem_cameraClass", ""];
        private _pfhID = _unit getVariable ["nzf_reconSystem_pfhID", -1];
        
        // Start monitoring when switching to optics with camera
        if (_isOptics && currentWeapon _unit == _cameraClass) then {
            // Only start if not already running
            if (_pfhID == -1) then {
                if (nzf_reconSystem_debug) then {
                    systemChat "[NZF Recon System] Debug: Starting camera monitoring";
                };
                
                _pfhID = [{
                    params ["_args"];
                    _args params ["_unit", "_cameraClass"];
                    
                    if (inputAction "defaultAction" > 0) then {
                        private _currentTime = CBA_missionTime;
                        private _lastSnapshot = _unit getVariable ["nzf_reconSystem_lastSnapshot", -1];
                        
                        if (_currentTime - _lastSnapshot >= 1) then {
                            // Always play camera effects when taking a photo
                            _unit say3D ["nzf_cameraShutter", 6];
                            cutText ["", "BLACK", 0.1];
                            [{cutText ["", "PLAIN", 0.1]}, [], 0.1] call CBA_fnc_waitAndExecute;
                            
                            private _target = cursorObject;
                            private _isValidPhoto = [_target] call nzf_reconSystem_fnc_validatePhotoTarget;
                            
                            if (_isValidPhoto) then {
                                // Activate any synced triggers
                                private _triggers = _target getVariable ["nzf_reconSystem_triggers", []];
                                
                                if (nzf_reconSystem_debug) then {
                                    systemChat format ["Found %1 triggers to activate", count _triggers];
                                };
                                
                                {
                                    if (!isNull _x) then {
                                        // Get the trigger's statement and execute it directly
                                        private _statement = triggerStatements _x select 1;
                                        if (_statement != "") then {
                                            call compile _statement;
                                        };
                                        
                                        if (nzf_reconSystem_debug) then {
                                            systemChat format ["Executing trigger statement: %1", _statement];
                                        };
                                    };
                                } forEach _triggers;
                                
                                if (nzf_reconSystem_debug) then {
                                    private _targetInfo = format ["[NZF Recon System] Valid photo taken of: %1 at position %2", typeOf _target, getPos _target];
                                    systemChat _targetInfo;
                                    diag_log _targetInfo;
                                    
                                    if (count _triggers > 0) then {
                                        systemChat format ["[NZF Recon System] Activated %1 trigger(s)", count _triggers];
                                    };
                                };
                            } else {
                                if (nzf_reconSystem_debug) then {
                                    private _reason = if (isNull _target) then {
                                        "No target in view"
                                    } else {
                                        if !(_target getVariable ["nzf_reconSystem_isTarget", false]) then {
                                            "Not a valid recon target"
                                        } else {
                                            "Target too small in frame"
                                        };
                                    };
                                    systemChat format ["[NZF Recon System] Invalid photo: %1", _reason];
                                };
                            };
                        };
                        
                        _unit setVariable ["nzf_reconSystem_lastSnapshot", _currentTime];
                    };
                }, 0.1, [_unit, _cameraClass]] call CBA_fnc_addPerFrameHandler;
                
                _unit setVariable ["nzf_reconSystem_pfhID", _pfhID];
            };
        } else {
            // Stop monitoring when leaving optics
            if (_pfhID != -1) then {
                if (nzf_reconSystem_debug) then {
                    systemChat "[NZF Recon System] Debug: Stopping camera monitoring";
                };
                
                [_pfhID] call CBA_fnc_removePerFrameHandler;
                _unit setVariable ["nzf_reconSystem_pfhID", -1];
            };
        };
    }];
}; 