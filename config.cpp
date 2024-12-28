////////////////////////////////////////////////////////////////////
//DeRap: config.bin
//Produced from mikero's Dos Tools Dll version 9.10
//https://mikero.bytex.digital/Downloads
//'now' is Fri Dec 27 17:13:29 2024 : 'file' last modified on Tue Dec 24 11:34:52 2024
////////////////////////////////////////////////////////////////////

#define _ARMA_

class CfgPatches
{
	class nzf_reconSystem_main
	{
		name = "NZF Recon System";
		units[] = {"nzf_reconSystem_moduleSetTarget"};
		weapons[] = {};
		requiredVersion = 2.02;
		requiredAddons[] = {"CBA_main","ace_common","cba_settings","A3_Modules_F"};
		author = "New Zealand Forces";
		version = "0.1";
	};
};
class CfgFactionClasses
{
	class NO_CATEGORY;
	class NZF_Systems: NO_CATEGORY
	{
		displayName = "NZF Systems";
	};
};
class CfgFunctions
{
	class nzf_reconSystem
	{
		tag = "nzf_reconSystem";
		class functions
		{
			file = "nzf_reconSystem\functions";
			class initReconSystem
			{
				postInit = 1;
			};
			class moduleSetTarget{};
			class validatePhotoTarget{};
		};
	};
};
class Extended_PreInit_EventHandlers
{
	class nzf_reconSystem
	{
		init = "call compile preprocessFileLineNumbers 'nzf_reconSystem\XEH_preInit.sqf'";
	};
};
class Extended_PostInit_EventHandlers
{
	class nzf_reconSystem
	{
		init = "call compile preprocessFileLineNumbers 'nzf_reconSystem\XEH_postInit.sqf'";
	};
};
class CfgVehicles
{
	class Logic;
	class Module_F: Logic
	{
		class AttributesBase
		{
			class Default;
			class Edit;
			class Combo;
			class Checkbox;
			class CheckboxNumber;
			class ModuleDescription;
			class Slider;
		};
		class ModuleDescription
		{
			class AnyBrain;
		};
	};
	class nzf_reconSystem_moduleSetTarget: Module_F
	{
		scope = 2;
		displayName = "Set Recon Target";
		icon = "\A3\ui_f\data\igui\cfg\simpleTasks\types\target_ca.paa";
		category = "NZF_Systems";
		function = "nzf_reconSystem_fnc_moduleSetTarget";
		functionPriority = 1;
		isGlobal = 2;
		isTriggerActivated = 0;
		isDisposable = 1;
		is3DEN = 0;
		class Attributes: AttributesBase
		{
			class PhotoStrictness
			{
				displayName = "Photo Requirements";
				tooltip = "How difficult it should be to get a valid photo of this target";
				property = "nzf_reconSystem_moduleSetTarget_Strictness";
				control = "Combo";
				typeName = "NUMBER";
				defaultValue = "2";
				class Values
				{
					class Easy
					{
						name = "Easy";
						value = 1;
						tooltip = "Target just needs to be visible in frame";
					};
					class Medium
					{
						name = "Medium";
						value = 2;
						tooltip = "Target needs to be clearly visible";
					};
					class Hard
					{
						name = "Hard";
						value = 3;
						tooltip = "Target needs to be clearly visible and well-framed";
					};
					class ExtraHard
					{
						name = "Extra Hard";
						value = 4;
						tooltip = "For documents and items requiring extreme detail - requires perfect framing and very close range";
					};
				};
			};
			
			class PreventCleanup: Checkbox
			{
				displayName = "Prevent Cleanup";
				tooltip = "If enabled, this object will not be removed by cleanup scripts";
				property = "nzf_reconSystem_moduleSetTarget_PreventCleanup";
				defaultValue = "true";
			};
		};
		class ModuleDescription: ModuleDescription
		{
			description = "Designate an object as a recon target";
			sync[] = {"AnyBrain"};
			class AnyBrain
			{
				description = "Single object to become a recon target";
				position = 0;
				direction = 0;
				optional = 0;
				duplicate = 0;
				syncRequired = 1;
			};
		};
	};
};
class CfgSounds
{
	sounds[] = {"nzf_cameraShutter"};
	class nzf_cameraShutter
	{
		name = "Camera Shutter";
		sound[] = {"nzf_reconSystem\sounds\camera_click.ogg",20,1};
		titles[] = {};
	};
};
class cfgMods
{
	author = "[NZF]JD Wang";
	timepacked = "1735040092";
};
