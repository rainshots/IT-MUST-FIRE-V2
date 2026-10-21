/// @description Returns real work progress and a readable status; worker-building context.
function building_work_progress_get()
{
	var _progress = 0;
	var _status = "Idle";
	if (is_grid_trash)
	{
		_progress = production_seconds / clear_seconds;
		_status = "Clearing: " + string(ceil(max(0, clear_seconds - production_seconds))) + "s";
	}
	else if (object_index == o_furnace && instance_exists(o_game_controller))
	{
		_progress = o_game_controller.fight_charge / BALANCE_FIGHT_CHARGE_MAX;
		_status = _progress >= 1 ? "Fully charged" : "Charging Cannon";
	}
	else if (is_defense_building)
	{
		_progress = production_seconds / production_interval;
		_status = "Reloading";
		if (object_index == o_pumpkin_patch)
		{
			_status = "Growing mine";
			if (array_length(mines) >= BALANCE_PUMPKIN_MAX_MINES) { _progress = 1; _status = "Patch full"; }
		}
		else if (_progress >= 1) _status = "Ready";
	}
	else if (variable_instance_exists(id, "production_kind"))
	{
		if (production_kind == 0)
		{
			var _health = 0;
			var _maximum = 0;
			with (o_friendly_units)
			{
				if (hp > 0 && !cannon_loaded && !is_being_dragged && !cargo_launched && !instance_exists(target_instance))
				{
					_health += hp;
					_maximum += max_hp;
				}
			}
			_progress = _maximum > 0 ? _health / _maximum : 0;
			_status = _maximum <= 0 ? "No idle units" : (_health >= _maximum ? "Units healed" : "Healing idle units");
		}
		else
		{
			_progress = production_seconds / max(0.000001, production_interval);
			_status = production_kind == 1 ? "Crafting shell" : "Summoning unit";
			if (production_kind == 1)
			{
				if (instance_exists(held_shell)) { _progress = 1; _status = "Shell ready - storage full"; }
				else if (production_seconds <= 0 && is_undefined(warehouse_free_get())) _status = "No storage space";
			}
			else if (player_unit_count_get() >= player_unit_cap_get()) _status = "Unit cap reached";
		}
	}
	if (array_length(worker_cultists) == 0) _status = "Needs Cultist";
	else if (global.pause) _status = "Paused";
	return {progress: clamp(_progress, 0, 1), status: _status};
}
