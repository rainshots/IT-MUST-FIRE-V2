// Tree visuals are randomized once, then only switch when corrupted ground reaches the trunk.
normal_sprite_index = choose(s_tree_yellow_01, s_tree_yellow_02);
corrupted_sprite_index = s_tree03;
is_corrupted = false;
corruption_check_interval = BALANCE_TREE_CORRUPTION_CHECK_INTERVAL;
corruption_check_timer = irandom(corruption_check_interval);
corruption_spread_radius = BALANCE_TREE_CORRUPTION_SPREAD_RADIUS_IN_CELLS * BALANCE_GRID_CELL_SIZE;
y_sort_enabled = true;

// Unit occlusion fades the tree when units walk behind its upper sprite area.
unit_fade_check_interval = BALANCE_TREE_UNIT_FADE_CHECK_INTERVAL;
unit_fade_check_timer = irandom(unit_fade_check_interval);
unit_fade_target_alpha = 1;
unit_fade_alpha = 1;

sprite_index = normal_sprite_index;
image_index = 0;
image_speed = 0;

var _tree_scale = random_range(BALANCE_TREE_SCALE_MIN, BALANCE_TREE_SCALE_MAX);

if (random(1) < 0.1)
{
	_tree_scale *= 2.5;
}

image_xscale = _tree_scale;
image_yscale = _tree_scale;

tree_unit_occlusion_update = function()
{
	unit_fade_check_timer++;

	if (unit_fade_check_timer < unit_fade_check_interval)
	{
		return;
	}

	unit_fade_check_timer = 0;

	var _tree_width = bbox_right - bbox_left;
	var _tree_height = bbox_bottom - bbox_top;
	var _check_radius = _tree_width * BALANCE_TREE_UNIT_FADE_RADIUS_SCALE;
	var _check_height = _tree_height * BALANCE_TREE_UNIT_FADE_HEIGHT_SCALE;
	var _check_left = x - _check_radius;
	var _check_right = x + _check_radius;
	var _check_top = y - _check_height;
	var _check_bottom = y;
	var _has_unit_behind_tree = tree_unit_occlusion_object_check(
		o_friendly_units,
		_check_left,
		_check_top,
		_check_right,
		_check_bottom
	);

	if (!_has_unit_behind_tree)
	{
		_has_unit_behind_tree = tree_unit_occlusion_object_check(
			o_enemy_units,
			_check_left,
			_check_top,
			_check_right,
			_check_bottom
		);
	}

	if (!_has_unit_behind_tree)
	{
		_has_unit_behind_tree = tree_unit_occlusion_object_check(
			o_cultist,
			_check_left,
			_check_top,
			_check_right,
			_check_bottom
		);
	}

	if (_has_unit_behind_tree)
	{
		unit_fade_target_alpha = BALANCE_TREE_UNIT_FADE_ALPHA;
	}
	else
	{
		unit_fade_target_alpha = 1;
	}
};

tree_unit_occlusion_object_check = function(_object_index, _check_left, _check_top, _check_right, _check_bottom)
{
	var _unit_count = instance_number(_object_index);

	// Only live visible units above the tree origin should make the crown transparent.
	for (var _unit_index = 0; _unit_index < _unit_count; ++_unit_index)
	{
		var _unit = instance_find(_object_index, _unit_index);

		if (instance_exists(_unit)
			&& _unit.visible
			&& variable_instance_exists(_unit, "hp")
			&& _unit.hp > 0
			&& _unit.x >= _check_left
			&& _unit.x <= _check_right
			&& _unit.y >= _check_top
			&& _unit.y <= _check_bottom)
		{
			return true;
		}
	}

	return false;
};

tree_corruption_update = function()
{
	if (is_corrupted || !instance_exists(o_corruption_grid))
	{
		return;
	}

	var _corruption_grid_object = instance_find(o_corruption_grid, 0);
	var _cell_x = floor(x / _corruption_grid_object.cell_size);
	var _cell_y = floor(y / _corruption_grid_object.cell_size);
	var _is_inside_grid = _cell_x >= 0
		&& _cell_x < _corruption_grid_object.grid_width
		&& _cell_y >= 0
		&& _cell_y < _corruption_grid_object.grid_height;

	if (!_is_inside_grid)
	{
		return;
	}

	var _corruption = ds_grid_get(_corruption_grid_object.corruption_grid, _cell_x, _cell_y);

	if (_corruption > 0)
	{
		is_corrupted = true;
		sprite_index = corrupted_sprite_index;

		// A newly infected tree spreads Taint into nearby ground cells.
		corrupt_circle(x, y, corruption_spread_radius, _corruption_grid_object.full_corruption_value);
	}
};
