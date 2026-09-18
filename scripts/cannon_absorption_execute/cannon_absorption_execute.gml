/// @description Absorbs enemy ground corpses inside the current Gaze, then grows it and starts cooldown.
/// @param {Id.Instance} _cannon Owning Cannon.
/// @param {Id.Instance} _controller Controller holding corpse snapshots.
function cannon_absorption_execute(_cannon, _controller)
{
	if (!instance_exists(_cannon) || !instance_exists(_controller)
		|| !_cannon.gaze_enabled || _cannon.cannon_type != CANNON.CANNON_2
		|| global.day_phase != DAY_PHASE.NIGHT || !_cannon.cannon_reload_is_ready())
	{
		return false;
	}

	// Snapshot the radius before growth so a single use cannot chain into newly reached corpses.
	var _radius = _cannon.gaze_radius;
	var _corpse_count = array_length(_controller.corpse_draw_data);
	var _absorbed_count = 0;
	var _write_index = 0;
	for (var _corpse_index = 0; _corpse_index < _corpse_count; ++_corpse_index)
	{
		var _corpse = _controller.corpse_draw_data[_corpse_index];
		var _is_enemy = variable_struct_exists(_corpse, "unit_faction")
			&& _corpse.unit_faction == UNIT_FACTION.ENEMY;
		if (_is_enemy && point_distance(_cannon.gaze_x, _cannon.gaze_y, _corpse.x, _corpse.y) <= _radius)
		{
			// Release any hauler reservation before removing the inert snapshot.
			if (variable_struct_exists(_corpse, "reserved_by") && instance_exists(_corpse.reserved_by)
				&& variable_instance_exists(_corpse.reserved_by, "reserved_corpse_id")
				&& _corpse.reserved_by.reserved_corpse_id == _corpse.corpse_id)
			{
				_corpse.reserved_by.reserved_corpse_id = noone;
			}
			_absorbed_count++;
			continue;
		}
		_controller.corpse_draw_data[_write_index] = _corpse;
		_write_index++;
	}
	array_resize(_controller.corpse_draw_data, _write_index);
	if (_absorbed_count <= 0)
	{
		return false;
	}

	// Base-relative growth is permanent and additive, never compounded from the current radius.
	_cannon.gaze_radius += _absorbed_count * _cannon.gaze_base_radius * BALANCE_ABSORPTION_RADIUS_GROWTH_SHARE;
	if (_cannon.absorption_upgrade == ABSORPTION_UPGRADE.HEALING)
	{
		_cannon.hp = min(_cannon.max_hp, _cannon.hp
			+ _absorbed_count * _cannon.max_hp * BALANCE_ABSORPTION_HEAL_SHARE);
	}
	_cannon.absorption_last_corpse_count = _absorbed_count;
	_cannon.absorption_total_corpse_count += _absorbed_count;
	_cannon.cannon_reload_start(PROJECTILE_TYPE.ABSORPTION);
	return true;
}
