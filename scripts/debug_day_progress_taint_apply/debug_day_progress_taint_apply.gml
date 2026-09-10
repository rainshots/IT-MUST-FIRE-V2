/// @description Applies one connected Taint circle toward an attack-lane point and builds it if newly captured.
function debug_day_progress_taint_apply(_controller)
{
	if (!instance_exists(_controller)
		|| !instance_exists(o_cannon)
		|| !instance_exists(o_corruption_grid))
	{
		return "skipped (no cannon or grid)";
	}
	var _directions = _controller.night_attack_directions;
	if (array_length(_directions) <= 0)
	{
		return "skipped (no incoming direction)";
	}
	var _direction = _directions[irandom(array_length(_directions) - 1)].direction;
	var _cannon = instance_find(o_cannon, 0);
	var _target = debug_day_progress_taint_target_get(_cannon, _direction);
	if (!instance_exists(_target))
	{
		return "skipped (no unclaimed point)";
	}

	// Find the nearest visibly tainted cell to the target, excluding Saint-protected ground.
	var _grid = instance_find(o_corruption_grid, 0);
	var _cell_size = _grid.cell_size;
	var _grid_width = _grid.grid_width;
	var _grid_height = _grid.grid_height;
	var _minimum_taint = _grid.minimum_draw_corruption;
	var _nearest_distance = infinity;
	var _anchor_x = 0;
	var _anchor_y = 0;
	for (var _cell_x = 0; _cell_x < _grid_width; ++_cell_x)
	{
		for (var _cell_y = 0; _cell_y < _grid_height; ++_cell_y)
		{
			if (ds_grid_get(_grid.corruption_grid, _cell_x, _cell_y) < _minimum_taint
				|| ds_grid_get(_grid.saint_grid, _cell_x, _cell_y) >= _minimum_taint)
			{
				continue;
			}
			var _world_x = (_cell_x + 0.5) * _cell_size;
			var _world_y = (_cell_y + 0.5) * _cell_size;
			var _distance = point_distance(_world_x, _world_y, _target.x, _target.y);
			if (_distance < _nearest_distance)
			{
				_nearest_distance = _distance;
				_anchor_x = _world_x;
				_anchor_y = _world_y;
			}
		}
	}
	if (_nearest_distance == infinity)
	{
		return "skipped (no existing Taint)";
	}

	// Advance the impact center by at most one current shell radius, preserving contact with Taint.
	var _radius = _cannon.cannon_taint_compost_radius_get();
	var _advance_distance = min(_radius, _nearest_distance);
	var _advance_direction = point_direction(_anchor_x, _anchor_y, _target.x, _target.y);
	var _impact_x = _anchor_x + lengthdir_x(_advance_distance, _advance_direction);
	var _impact_y = _anchor_y + lengthdir_y(_advance_distance, _advance_direction);
	if (!_grid.circle_touches_corruption(_impact_x, _impact_y, _radius))
	{
		return "skipped (Taint would be disconnected)";
	}
	corrupt_circle(_impact_x, _impact_y, _radius, BALANCE_PROJECTILE_GROUND_CORRUPTION_AMOUNT);
	array_push(global.day_event_executed_log_lines,
		"[Auto] Taint at " + string(round(_impact_x)) + ", " + string(round(_impact_y)));

	// Resolve the normal ground-capture check now, before this same keypress starts the night.
	_target.capture_check_timer = _target.capture_check_interval;
	_target.tower_capture_update();
	if (!_target.is_captured)
	{
		return "expanded toward " + object_get_name(_target.object_index);
	}
	if (!_target.structure_choice_options_rolled)
	{
		_target.cursed_point_structure_options_roll();
	}
	var _choices = [];
	var _choice_count = array_length(_target.structure_choice_options);
	for (var _choice_index = 0; _choice_index < _choice_count; ++_choice_index)
	{
		var _choice = _target.structure_choice_options[_choice_index];
		if (_target.cursed_point_structure_choice_can_construct(_choice))
		{
			array_push(_choices, _choice);
		}
	}
	if (array_length(_choices) <= 0)
	{
		return "captured (no available structure)";
	}
	var _selected_choice = _choices[irandom(array_length(_choices) - 1)];
	return debug_day_progress_construction_execute(_target, _selected_choice, true)
		? "captured + " + _selected_choice.building_name
		: "captured (construction failed)";
}
