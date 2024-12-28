#include "script_component.hpp"

[
    "nzf_reconSystem_debug",
    "CHECKBOX",
    ["Debug Mode", "Enable debug logging and visual markers for the recon system"],
    ["[NZF] Recon System", "Debug"],
    false,
    1,
    {}
] call CBA_Settings_fnc_init;

[
    "nzf_reconSystem_cameraClass",
    "EDITBOX",
    ["Recon Camera Class", "Classname of the camera item to use for recon"],
    ["[NZF] Recon System", "Equipment"],
    "Camera_lxWS",  // Western Sahara Digital Camera
    1,
    {}
] call CBA_Settings_fnc_init;