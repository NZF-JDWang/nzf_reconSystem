params [["_logic", objNull, [objNull]], ["_units", [], [[]]], ["_activated", true, [true]]];

if (!_activated || !isServer) exitWith {};

private _syncedObjects = synchronizedObjects _logic;

// Filter out triggers
private _triggers = _syncedObjects select { _x isKindOf "EmptyDetector" };
private _targets = _syncedObjects select { !(_x isKindOf "EmptyDetector") };

// Debug output
if (nzf_reconSystem_debug) then {
    systemChat format ["Found %1 triggers and %2 targets", count _triggers, count _targets];
};

// Enforce single target rule
if (count _targets != 1) exitWith {
    private _msg = format ["[NZF Recon System] Error: Module must be synced with exactly one target object (found %1)", count _targets];
    if (nzf_reconSystem_debug) then {
        _msg remoteExec ["systemChat", 0];
    };
    [_msg] call BIS_fnc_error;
};

private _target = _targets select 0;

// Check if target is already a recon target
if (_target getVariable ["nzf_reconSystem_isTarget", false]) exitWith {
    private _msg = format ["[NZF Recon System] Error: Object %1 is already a recon target", typeOf _target];
    if (nzf_reconSystem_debug) then {
        _msg remoteExec ["systemChat", 0];
    };
    [_msg] call BIS_fnc_error;
};

// Get module settings
private _strictness = _logic getVariable ["PhotoStrictness", 2];

private _preventCleanup = _logic getVariable ["PreventCleanup", true];

// Mark the object as a recon target and store settings
_target setVariable ["nzf_reconSystem_isTarget", true, true];
_target setVariable ["nzf_reconSystem_triggers", _triggers, true];
_target setVariable ["nzf_reconSystem_customStrictness", _strictness, true];

// Set cleanup prevention if enabled
if (_preventCleanup) then {
    removeFromRemainsCollector [_target];
    _target setVariable ["acex_headless_blacklist", true, true];
};

// Debug: Verify triggers are stored
if (nzf_reconSystem_debug) then {
    private _storedTriggers = _target getVariable ["nzf_reconSystem_triggers", []];
    systemChat format ["Stored %1 triggers for target %2", count _storedTriggers, typeOf _target];
};

// Clean up the module
deleteVehicle _logic; 