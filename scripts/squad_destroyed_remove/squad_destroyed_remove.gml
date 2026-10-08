/// @description Removes wiped squads and releases their roster slots and control references.
function squad_destroyed_remove()
{
	for (var _index = array_length(global.squads) - 1; _index >= 0; --_index)
	{
		var _squad = global.squads[_index];
		if (squad_living_unit_count_get(_squad) > 0 || (_squad.is_hero && _squad.hero_respawn_enabled)) continue;
		var _point = squad_day_point_get(_squad);
		if (instance_exists(_point)) _point.assigned_squad = noone;
		if (global.dragged_squad == _squad) global.dragged_squad = noone;
		if (instance_exists(o_game_controller))
		{
			var _controller = instance_find(o_game_controller, 0);
			if (_controller.selected_squad == _squad) _controller.squad_control_selection_clear();
		}
		if (instance_exists(o_hud))
		{
			var _hud = instance_find(o_hud, 0);
			if (_hud.squad_info_squad == _squad)
			{
				_hud.squad_info_squad = noone;
				_hud.squad_info_is_pinned = false;
				global.squad_info_window_open = false;
			}
		}
		array_delete(global.squads, _index, 1);
	}
	// Dead commanders must not occupy persistent selection or army slots.
	for (var _index = array_length(global.archdemons) - 1; _index >= 0; --_index)
	{
		if (!instance_exists(global.archdemons[_index])) array_delete(global.archdemons, _index, 1);
	}
}
