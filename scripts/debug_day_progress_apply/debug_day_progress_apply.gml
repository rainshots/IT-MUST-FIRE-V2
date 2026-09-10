/// @description Applies one day of cheat progress before the controller skips to night.
function debug_day_progress_apply(_controller)
{
	if (!instance_exists(_controller)
		|| !global.cheats_enabled
		|| global.day_phase != DAY_PHASE.DAY)
	{
		return false;
	}

	// Apply permanent additions before selecting today's eligible Rite recipients.
	var _building_name = debug_day_progress_building_create(_controller);
	var _squad_name = debug_day_progress_squad_create();
	var _taint_result = debug_day_progress_taint_apply(_controller);
	var _rite_count = debug_day_progress_rites_execute();
	show_debug_message("[Day progress] Day " + string(day_event_current_day_get())
		+ " | Building: " + _building_name
		+ " | Squad: " + _squad_name
		+ " | Taint: " + _taint_result
		+ " | Rites: " + string(_rite_count));
	return true;
}
