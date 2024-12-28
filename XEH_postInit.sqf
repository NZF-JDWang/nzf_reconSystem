#include "script_component.hpp"

// Server-side initialization
if (isServer) then {
    [] call nzf_reconSystem_fnc_initReconSystem;
};