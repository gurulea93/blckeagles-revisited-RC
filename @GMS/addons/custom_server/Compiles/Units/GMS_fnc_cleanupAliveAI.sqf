/*
  Delete alive AI.
  Now called from the main thread which tracks the time elapsed so that we no longer spawn a wait timer for each completed mission.
  by Ghostrider
  Last updated 4/11/17
	
	--------------------------
	License
	--------------------------
	All the code and information provided here is provided under an Attribution Non-Commercial ShareAlike 4.0 Commons License.

	http://creativecommons.org/licenses/by-nc-sa/4.0/
*/
#include "\q\addons\custom_server\Configs\blck_defines.hpp";

for "_i" from 1 to (count blck_liveMissionAI) do {
	if ((_i) <= count blck_liveMissionAI) then {
		_units = blck_liveMissionAI deleteat 0;
		_units params ["_unitsarr","_timer"];
		if (diag_tickTime > _timer) then {
			{
				if ((alive _x) && !(isNull objectParent _x)) then {
					[objectParent _x] call blck_fnc_deleteAIvehicle;
				};
				[_x] call blck_fnc_deleteAI;
			} forEach _unitsarr;
			uiSleep 0.1;
			#ifdef blck_debugMode
			if (blck_debugLevel > 1) then {diag_log format["_fnc_mainTread:: blck_liveMissionAI updated to %1",blck_liveMissionAI];};
			#endif
		}
		else {
			blck_liveMissionAI pushback _units;
		};
	};
};