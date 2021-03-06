/*
   call as [] call blck_fnc_cleanEmptyGroups;
   Deletes any empty groups and thereby prevents errors resulting from createGroup returning nullGroup.

	By Ghostrider [GRG]
	Copyright 2016	
	--------------------------
	License
	--------------------------
	All the code and information provided here is provided under an Attribution Non-Commercial ShareAlike 4.0 Commons License.

	http://creativecommons.org/licenses/by-nc-sa/4.0/
*/
#include "\q\addons\custom_server\Configs\blck_defines.hpp";

private _grp = +allGroups;
{
	if ((count units _x) isEqualTo 0) then {deleteGroup _x};
}forEach _grp;

