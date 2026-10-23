// Worker placement tint is drawn below buildings and units.
if (instance_exists(o_game_controller) && instance_exists(o_game_controller.worker_dragged)
	&& o_game_controller.worker_dragged.hp > 0)
{
	draw_set_color(COLOR_BUILDING_GRID_MERGE);
	draw_set_alpha(BALANCE_BUILDING_GRID_OCCUPIED_ALPHA);
	with (o_worker_building_parent)
	{
		if (!building_accepts_workers || !building_grid_work_enabled(id) || placement_preview || is_being_dragged
			|| array_length(worker_cultists) >= worker_max) continue;
		var _bounds = building_bounds_get(id, x, y);
		draw_rectangle(_bounds.left, _bounds.top, _bounds.right, _bounds.bottom, false);
	}
	draw_set_color(c_white);
	draw_set_alpha(1);
}

// Show the construction overlay only during a purchase or building relocation.
if (!instance_exists(o_game_controller) || !instance_exists(o_game_controller.shop_preview)) exit;
for (var _grid_index = 0; _grid_index < array_length(building_grids); ++_grid_index)
{
	var _grid = building_grids[_grid_index];

	// Tint occupied footprints, including the Heart and trash, but not the placement preview.
	draw_set_color(COLOR_BUILDING_GRID_OCCUPIED);
	draw_set_alpha(BALANCE_BUILDING_GRID_OCCUPIED_ALPHA);
	with (o_worker_building_parent)
	{
		if (placement_preview || id == o_game_controller.shop_preview) continue;
		// Matching upgradable buildings are purchase merge targets.
		var _preview = o_game_controller.shop_preview;
		var _can_merge = o_game_controller.shop_cost > 0 && !is_being_dragged
			&& object_index == _preview.object_index && _preview.upgrade_object != noone;
		draw_set_color(_can_merge ? COLOR_BUILDING_GRID_MERGE : COLOR_BUILDING_GRID_OCCUPIED);
		var _bounds = building_bounds_get(id, x, y);
		var _left = max(_grid.left, _bounds.left);
		var _right = min(_grid.right, _bounds.right);
		var _top = max(_grid.top, _bounds.top);
		var _bottom = min(_grid.bottom, _bounds.bottom);
		if (_left < _right && _top < _bottom)
		{
			draw_rectangle(_left, _top, _right, _bottom, false);
		}
	}

	// Keep grid lines visible over the occupied-slot fill.
	draw_set_color(COLOR_BUILDING_GRID);
	draw_set_alpha(BALANCE_BUILDING_GRID_ALPHA);
	for (var _column = 0; _column <= round((_grid.right - _grid.left) / BALANCE_BUILDING_GRID_CELL_SIZE); ++_column)
	{
		var _x = _grid.left + _column * BALANCE_BUILDING_GRID_CELL_SIZE;
		draw_line(_x, _grid.top, _x, _grid.bottom);
	}
	for (var _row = 0; _row <= round((_grid.bottom - _grid.top) / BALANCE_BUILDING_GRID_CELL_SIZE); ++_row)
	{
		var _y = _grid.top + _row * BALANCE_BUILDING_GRID_CELL_SIZE;
		draw_line(_grid.left, _y, _grid.right, _y);
	}
	draw_set_color(c_white);
	draw_set_alpha(1);
}
