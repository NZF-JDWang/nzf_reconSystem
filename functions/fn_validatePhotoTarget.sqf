params ["_target"];

if (isNull _target) exitWith { false };
if !(_target getVariable ["nzf_reconSystem_isTarget", false]) exitWith { false };

// Determine target type
private _isHuman = _target isKindOf "CAManBase";
private _isVehicle = _target isKindOf "LandVehicle" || 
                     _target isKindOf "Air" || 
                     _target isKindOf "Ship";

// Get the module's custom strictness setting (1-4)
private _strictness = _target getVariable ["nzf_reconSystem_customStrictness", 2];

// Calculate base threshold based on target type
private _baseThreshold = switch (true) do {
    case _isHuman: { 1000 };     // Keep human threshold
    case _isVehicle: { 8000 };   // Increased from 5000 to 8000 for vehicles
    default { 1000 };            // Keep other objects threshold
};

// Adjust threshold based on strictness (1-4)
private _multiplier = switch (_strictness) do {
    case 1: { 1.0 };    // Easy - 100% of base threshold
    case 2: { 2.0 };    // Medium - 200% of base threshold
    case 3: { 5.0 };    // Hard - 500% of base threshold
    case 4: { 15.0 };   // Extra Hard - 1500% of base threshold
    default { 2.0 };    // Fallback to Medium
};

private _threshold = _baseThreshold * _multiplier;

// Special check for human targets - verify head is visible
if (_isHuman) then {
    private _headPos = _target selectionPosition "head";
    if (_headPos isEqualTo [0,0,0]) exitWith { false };
    
    private _worldHeadPos = _target modelToWorld _headPos;
    private _screenHeadPos = worldToScreen _worldHeadPos;
    
    // Check if head is in view and not blocked
    if (isNil "_screenHeadPos" || {count _screenHeadPos == 0}) exitWith { false };
    
    // Check if there's a line of sight to the head
    private _playerEyePos = eyePos player;
    private _intersections = lineIntersectsSurfaces [_playerEyePos, _worldHeadPos, player, _target, true, 1];
    
    if (count _intersections > 0) exitWith {
        if (missionNamespace getVariable ["nzf_reconSystem_debug", false]) then {
            systemChat "Target head is not visible";
        };
        false
    };
};

// Get the target's bounding box in model space
private _bb = boundingBoxReal _target;

// Convert bounding box corners to world space points
private _bbPoints = [
    _target modelToWorld (_bb#0),                    // Bottom left back corner
    _target modelToWorld (_bb#1),                    // Top right front corner
    _target modelToWorld [(_bb#0#0), (_bb#0#1), (_bb#1#2)],  // Top left back corner
    _target modelToWorld [(_bb#1#0), (_bb#1#1), (_bb#0#2)]   // Bottom right front corner
];

// Convert world positions to screen coordinates (returns [x,y] for each point)
private _screenPoints = _bbPoints apply { worldToScreen _x };
private _validPoints = _screenPoints select { !isNil "_x" && {count _x == 2} };

// Find the extremes of the screen coordinates
private _minX = selectMin (_validPoints apply {_x#0});  // Leftmost point
private _maxX = selectMax (_validPoints apply {_x#0});  // Rightmost point
private _minY = selectMin (_validPoints apply {_x#1});  // Bottommost point
private _maxY = selectMax (_validPoints apply {_x#1});  // Topmost point

// Get screen aspect ratio and calculate coverage
private _aspectRatio = safeZoneW / safeZoneH;
private _screenWidth = (_maxX - _minX) * _aspectRatio;
private _screenHeight = _maxY - _minY;

// Calculate screen coverage as total area rather than just largest dimension
private _screenCoverage = _screenWidth * _screenHeight;

// Get angle between player's view direction and target's direction
private _targetDir = vectorDir _target;
private _playerDir = getCameraViewDirection player;
private _angleToTarget = acos (_targetDir vectorDotProduct _playerDir);

// Apply angle factor (front view is best, but don't penalize as heavily)
private _angleFactor = 0.5 + (cos _angleToTarget * 0.5); // Results in value between 0.5 and 1.0

// Add vehicle-specific screen coverage requirements
if (_isVehicle) then {
    private _minCoverage = switch (_strictness) do {
        case 1: { 0.4 };  // Easy: 40% screen coverage
        case 2: { 0.6 };  // Medium: 60% screen coverage
        case 3: { 0.8 };  // Hard: 80% screen coverage
        case 4: { 0.95 }; // Extra Hard: 95% screen coverage
        default { 0.6 };
    };
    
    if (_screenCoverage < _minCoverage) exitWith {
        if (missionNamespace getVariable ["nzf_reconSystem_debug", false]) then {
            systemChat format ["Vehicle must fill at least %1% of screen area", _minCoverage * 100];
        };
        false
    };
};

// For Extra Hard mode, require more significant screen coverage (applies to all targets)
if (_strictness == 4) then {
    private _requiredCoverage = if (_isAir) then { 0.95 } else { 0.9 };
    if (_screenCoverage < _requiredCoverage) exitWith {
        if (missionNamespace getVariable ["nzf_reconSystem_debug", false]) then {
            systemChat format ["Extra Hard mode: Target must fill at least %1% of screen area", _requiredCoverage * 100];
        };
        false
    };
};

// Calculate apparent size with adjusted base multiplier
private _apparentSize = (_screenWidth * _screenHeight * _angleFactor) * 200000;

// Debug info to help understand the values
if (missionNamespace getVariable ["nzf_reconSystem_debug", false]) then {
    systemChat format ["Screen Coverage: Width: %1%, Height: %2%, Size: %3%, Required: %4%", 
        round (_screenWidth * 100),
        round (_screenHeight * 100),
        round _apparentSize,
        round _threshold
    ];
};

if (_apparentSize < _threshold) exitWith { false };

true 