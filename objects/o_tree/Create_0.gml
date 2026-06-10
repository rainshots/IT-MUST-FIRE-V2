// Tree visuals are randomized once, then only switch when corrupted ground reaches the trunk.
normal_sprite_index = choose(s_tree_yellow_01, s_tree_yellow_02);
corrupted_sprite_index = s_tree03;
is_corrupted = false;
corruption_check_interval = BALANCE_TREE_CORRUPTION_CHECK_INTERVAL;
corruption_check_timer = irandom(corruption_check_interval);
y_sort_enabled = true;

sprite_index = normal_sprite_index;
image_index = 0;
image_speed = 0;

var _tree_scale = random_range(BALANCE_TREE_SCALE_MIN, BALANCE_TREE_SCALE_MAX);
if random(1) < 0.1 {_tree_scale *= 2.5}
image_xscale = _tree_scale;
image_yscale = _tree_scale;

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

	if (_corruption >= _corruption_grid_object.full_corruption_value)
	{
		is_corrupted = true;
		sprite_index = corrupted_sprite_index;
	}
};
