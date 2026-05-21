// Initialize shared map object state.
event_inherited();

// Forest corruption spread settings.
full_corruption_value = 1;
spread_corruption_per_second = 0.2;
is_fully_corrupted = false;

// Forest visual state settings.
//cursed_sprite_name = "s_wood_cursed";
cursed_sprite_index = s_wood_cursed//asset_get_index(cursed_sprite_name);

// Forest infects all neighbor cells around itself.
spread_offset_left_x = -1;
spread_offset_right_x = 1;
spread_offset_up_y = -1;
spread_offset_down_y = 1;

// Tooltip lines describe forest behavior.
tooltip_lines = [
	"Damage: No effect yet",
	"Corruption: Spreads from full corrupted ground",
	"Summon: No effect yet"
];

corrupt_neighbor_cell = function(_corruption_grid, _cell_x, _cell_y, _offset_x, _offset_y, _corruption)
{
	var _target_cell_x = _cell_x + _offset_x;
	var _target_cell_y = _cell_y + _offset_y;

	if (_target_cell_x < 0 || _target_cell_x >= _corruption_grid.grid_width)
	{
		return;
	}

	if (_target_cell_y < 0 || _target_cell_y >= _corruption_grid.grid_height)
	{
		return;
	}

	var _holy_count = ds_grid_get(_corruption_grid.holy_grid, _target_cell_x, _target_cell_y);

	if (_holy_count <= 0)
	{
		var _current_corruption = ds_grid_get(_corruption_grid.corruption_grid, _target_cell_x, _target_cell_y);
		ds_grid_set(_corruption_grid.corruption_grid, _target_cell_x, _target_cell_y, min(_current_corruption + _corruption, full_corruption_value));
	}
};
