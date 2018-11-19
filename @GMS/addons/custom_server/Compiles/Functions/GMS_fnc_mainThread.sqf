/*
	By Ghostrider [GRG]

	--------------------------
	License
	--------------------------
	All the code and information provided here is provided under an Attribution Non-Commercial ShareAlike 4.0 Commons License.

	http://creativecommons.org/licenses/by-nc-sa/4.0/	
*/
#include "\q\addons\custom_server\Configs\blck_defines.hpp";

//diag_log format["starting _fnc_mainThread with time = %1",diag_tickTime];

private["_timer1sec","_timer5sec","_timer20sec","_timer5min","_timer5min"];
_timer1sec = diag_tickTime;
_timer5sec = diag_tickTime;
_timer20sec = diag_tickTime;
_timer1min = diag_tickTime;
_timer5min = diag_tickTime;

while {true} do
{
	uiSleep 1;
	if (diag_tickTime > _timer1sec) then 
	{
		[] call blck_fnc_vehicleMonitor;
		#ifdef GRGserver
		[] call blck_fnc_broadcastServerFPS;
		#endif
		_timer1sec = diag_tickTime + 1;
	};
	if (diag_tickTime > _timer5sec) then
	{
		_timer5sec = diag_tickTime + 5;
		[] call blck_fnc_missionGroupMonitor;
		[] call blck_fnc_sm_missionPatrolMonitor;
	};
	if (diag_tickTime > _timer20sec) then
	{
		[] call blck_fnc_cleanupAliveAI;
		[] call blck_fnc_cleanupObjects;
		[] call blck_fnc_cleanupDeadAI;
		[] call blck_fnc_scanForPlayersNearVehicles;		
		[] call blck_fnc_cleanEmptyGroups;
		_timer20sec = diag_tickTime + 20;
	};
	if ((diag_tickTime > _timer1min)) then
	{
		_timer1min = diag_tickTime + 60;
		[] call blck_fnc_spawnPendingMissions;
		if (blck_dynamicUMS_MissionsRuning < blck_numberUnderwaterDynamicMissions) then
		{
			[] spawn blck_fnc_addDyanamicUMS_Mission;
		};
		if (blck_useHC) then
		{
			[] call blck_fnc_HC_passToHCs;
		};
		if (blck_useTimeAcceleration) then
		{
			[] call blck_fnc_timeAcceleration;
		};
		#ifdef blck_debugMode
		//diag_log format["_fnc_mainThread: active SQFscripts include: %1",diag_activeSQFScripts];
		diag_log format["_fnc_mainThread: active scripts include: %1",diag_activeScripts];
		#endif
	};
	if (diag_tickTime > _timer5min) then 
	{
		diag_log format["[blckeagls] Timstamp %8 |Dynamic Missions Running %1 | UMS Running %2 | Vehicles %3 | Groups %4 | Server FPS %5 | Server Uptime %6 Min | Missions Run %7",blck_missionsRunning,blck_dynamicUMS_MissionsRuning,count blck_monitoredVehicles,count blck_monitoredMissionAIGroups,diag_FPS,floor(diag_tickTime/60),blck_missionsRun, diag_tickTime];
		_timer5min = diag_tickTime + 300;
	};
};
