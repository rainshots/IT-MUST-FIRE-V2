/// @description Starts destination selection without charging Mana; controller context.
function faction_summon_select(_index)
{
	if (!faction_summon_can_purchase(global.player_faction, _index)) return false;
	faction_summon_selected = _index;
	squad_control_selection_clear();
	global.focus_window = FOCUS_WINDOW.SUMMON;
	return true;
}
