/*
	Author: Ghostrider-DbD-
	Inspiration: blckeagls / A3EAI / VEMF / IgiLoad / SDROP
	License: Attribution-NonCommercial-ShareAlike 4.0 International
	1/23/17
*/

params["_supplyHeli","_missionPos","_numAI","_skillAI","_weapons","_uniforms","_headGear"];

// create a group for our paratroops
private["_paraGroup"];
_paraGroup = createGroup blck_AI_Side;  // ;  Group changed for Exile for which player is RESISTANCE.	
_supplyHeli setVariable["paraGroup",_paraGroup];
_paraGroup setcombatmode blck_combatMode;
_paraGroup allowfleeing 0;
_paraGroup setspeedmode "FULL";
_paraGroup setFormation blck_groupFormation; 
_paraGroup setVariable ["blck_group",true,true];

diag_log format["_fnc_spawnParaUnits:: paratrooper group created; spawning %1 units",_numAI];

//https://forums.bistudio.com/topic/127341-how-to-get-cargo-capacity-and-costweight-of-stuff-into-sqf/
//_veh = TypeOf (_supplyHeli); //for example
//_maxpeople = getNumber (configFile >> "CfgVehicles" >> _veh >> "transportSoldier");
//if ( (_maxpeople - 1) < _numAI) then {_numAI = _maxpeople - 1;};  // calculate the max troops carried by the chopper minus 1 for the pilot who is already on board and adjust the number of AI to spawn as needed.

	_launcherType = "none";
_sniperExists = false;

/*
for "_i" from 1 to _numAI do
{
	//Spawns the AI unit
	diag_log format["spawnGroup:: spawning unit #%1",_i];
	_unit = [[getPos _supplyHeli select 0, getPos _supplyHeli select 1,(getPos _supplyHeli select 2) - 10],_weapons,_paraGroup,_skillAI,_launcherType,_uniforms,_headGear] call blck_fnc_spawnAI;
		
	if !(_sniperExists) then
	{
		if ((random(1) < 0.2)) then
		{	
			_sniperExists = true;
			_unit setBehaviour "STEALTH";
		};
	};
	
	_unit assignAsCargo _supplyHeli;
	[_unit] orderGetIn true;
	diag_log format["reinforcements:: spawned unit %1, at location %2",_unit,getPos _unit];
	uiSleep 0.5;	
};
*/
/*	
diag_log "reinforcements:: eject paratroops";	
{
	unassignvehicle _x;
	_x action ["EJECT", _supplyHeli];
	sleep 0.5;
} foreach units _paraGroup;
*/

private["_dir","_offset"];
_dir = getDir _supplyHeli;
_dir = if (_dir < 180) then {_dir + 150} else {_dir - 150};

for "_i" from 1 to _numAI do
{
	_offset =  _supplyHeli getPos [10, _dir];
	_chute = createVehicle ["Steerable_Parachute_F", [100, 100, 200], [], 0, "FLY"];
	[_chute] call blck_fnc_protectVehicle;
	/*
	private["_modType"];
	_modType = call blck_fnc_getModType;
	if (_modType isEqualTo "Epoch") then
	{
		[_chute] call EPOCH_server_setVToken;;
	};
	*/
	_unit = [[_offset select 0, _offset select 1, 180],_weapons,_paraGroup,_skillAI,_launcherType,_uniforms,_headGear] call blck_fnc_spawnAI;
	_unit setDir (getDir _supplyHeli) - 90;
	_chute setPos [_offset select 0, _offset select 1, 250];  //(_offset select 2) - 10];
	_unit disableCollisionWith _supplyHeli;
	_chute disableCollisionWith _supplyHeli;
	_unit assignAsDriver _chute;
	_unit moveInDriver _chute;
	_unit allowDamage true;
	uiSleep 1;

	diag_log format["_fnc_spawnParaUnits:: spawned unit %1, at location %2 and vehicle _unit %1",_unit,getPos _unit, vehicle _unit];
};

_paraGroup selectLeader ((units _paraGroup) select 0);
	
diag_log "_fnc_spawnParaUnits:: paratroops created, setting wayponts";
_paraGroup setVariable["missionPos",_missionPos];
[_paraGroup, 0] setWPPos _missionPos;
[_paraGroup, 0]  setWaypointCombatMode "RED";
[_paraGroup, 0]  setWaypointType "MOVE";
[_paraGroup, 0]  setWaypointSpeed "NORMAL";
[_paraGroup, 0]  setWaypointBehaviour "COMBAT";
[_paraGroup, 0]  setWaypointCompletionRadius 20;
[_paraGroup, 0]  setWaypointStatements ["true","[this getVariable[""missionPos""], 30, 45, this] call blck_fnc_setupWaypoints;"];

_fn_cleanupTroops = {		
	private["_troopsOnGround"];
	params["_group"];
	_troopsOnGround = false;	
	while {!_troopsOnGround} do
	{
		_troopsOnGround = true;
		{
			//diag_log format["reinforments:: Tracking Paratroops unit %1 position %4  altitue %2 velocity %3 attachedTo %4",_x, (getPos _x select 2), (velocity _x select 2), getPosATL _x, attachedTo _x];
			if ( (getPosATL _x select 2) < 0.1) then {
				if (surfaceIsWater (position _x)) then {
					diag_log format["_fnc_spawnParaUnits:: unit %1 at %2 deleted",_x, getPos _x];
					[_x] call blck_fnc_deleteAI;
				};
			} 
			else 
			{_troopsOnGround = false;};
		}forEach units _group;
		uiSleep 1;	
	};
};

diag_log "_fnc_spawnParaUnits:: waiting for paratroops to land";
[_paraGroup] spawn _fn_cleanupTroops;

diag_log "spawnParatroops:: All Units on the Ground";

// Return the group spawned for book keeping purposes
diag_log format["_fnc_spawnParaUnits::  typeName _paraGroup = %1", (typeName _paraGroup)];
_paraGroup;
