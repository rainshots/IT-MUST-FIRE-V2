// A removed point releases its squad so another free point can be selected.
if (is_struct(assigned_squad)
	&& variable_struct_exists(assigned_squad, "properties")
	&& variable_struct_exists(assigned_squad.properties, "day_point")
	&& assigned_squad.properties.day_point == id)
{
	assigned_squad.properties.day_point = noone;
}

// A removed point cannot keep a shared squad slot reserved.
if (is_struct(pending_squad_event)
	&& variable_struct_exists(pending_squad_event, "reserves_squad_slot"))
{
	pending_squad_event.reserves_squad_slot = false;
}

if (variable_global_exists("squad_point_selection_source")
	&& global.squad_point_selection_source == id)
{
	global.squad_point_selection_source = noone;

	if (global.focus_window == FOCUS_WINDOW.SQUAD_POINT_SELECTION)
	{
		global.focus_window = FOCUS_WINDOW.NOONE;
		global.pause = squad_point_selection_previous_pause_state;
	}
}
