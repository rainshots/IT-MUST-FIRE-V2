if (!instance_exists(o_game_controller)) exit;
var _placing = instance_exists(o_game_controller.shop_preview);
var _dragging_worker = instance_exists(o_game_controller.worker_dragged);
// Interaction overlays take priority over the persistent grid view.
var _persistent = o_game_controller.show_building_grid && !_placing && !_dragging_worker;

// Worker placement tint is drawn below buildings and units.
if (instance_exists(o_game_controller) && instance_exists(o_game_controller.worker_dragged)
	&& o_game_controller.worker_dragged.hp > 0)
{
	draw_set_color(COLOR_BUILDING_GRID_MERGE);
	draw_set_alpha(_persistent ? BALANCE_BUILDING_GRID_PERSISTENT_ALPHA : BALANCE_BUILDING_GRID_OCCUPIED_ALPHA);
	with (o_worker_building_parent)
	{
		if (!building_accepts_workers || !building_grid_work_enabled(id) || placement_preview || is_being_dragged
			|| array_length(worker_cultists) >= worker_max) continue;
		var _bounds = building_bounds_get(id, x, y);
		draw_rectangle(_bounds.left, _bounds.top, _bounds.right, _bounds.bottom, false);
		// Emphasize the valid workplace currently under the carried Cultist.
		if (id == o_game_controller.worker_drop_building)
		{
			draw_set_color(COLOR_BUILDING_GRID);
			draw_set_alpha(1);
			draw_rectangle(_bounds.left, _bounds.top, _bounds.right, _bounds.bottom, true);
			draw_set_color(COLOR_BUILDING_GRID_MERGE);
			draw_set_alpha(BALANCE_BUILDING_GRID_OCCUPIED_ALPHA);
		}
	}
	draw_set_color(c_white);
	draw_set_alpha(1);
}

// Draw every unlocked grid for construction or the persistent view.
if (!_placing && !_persistent) exit;
for (var _grid_index = 0; _grid_index < array_length(building_grids); ++_grid_index)
{
	var _grid = building_grids[_grid_index];

	// Tint occupied footprints, including the Heart and trash, but not the placement preview.
	draw_set_color(COLOR_BUILDING_GRID_OCCUPIED);
	draw_set_alpha(_persistent ? BALANCE_BUILDING_GRID_PERSISTENT_ALPHA : BALANCE_BUILDING_GRID_OCCUPIED_ALPHA);
	with (o_worker_building_parent)
	{
		if (placement_preview || id == o_game_controller.shop_preview) continue;
		// Matching upgradable buildings are purchase merge targets.
		var _preview = o_game_controller.shop_preview;
		var _can_merge = _placing && o_game_controller.shop_cost > 0 && !is_being_dragged
			&& object_index == _preview.object_index && _preview.upgrade_object != noone;
		draw_set_color(_persistent ? COLOR_BUILDING_GRID : (_can_merge ? COLOR_BUILDING_GRID_MERGE : COLOR_BUILDING_GRID_OCCUPIED));
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

	// Color each hovered grid slot by occupancy, excluding the carried building itself.
	if (_placing)
	{
		var _carried = o_game_controller.shop_preview;
		var _footprint = building_bounds_get(_carried, _carried.x, _carried.y);
		var _cell_size = BALANCE_BUILDING_GRID_CELL_SIZE;
		var _column_start = max(0, floor((_footprint.left - _grid.left) / _cell_size));
		var _column_end = min(round((_grid.right - _grid.left) / _cell_size), ceil((_footprint.right - _grid.left) / _cell_size));
		var _row_start = max(0, floor((_footprint.top - _grid.top) / _cell_size));
		var _row_end = min(round((_grid.bottom - _grid.top) / _cell_size), ceil((_footprint.bottom - _grid.top) / _cell_size));
		draw_set_alpha(BALANCE_BUILDING_PLACEMENT_FILL_ALPHA);
		for (var _column = _column_start; _column < _column_end; ++_column)
		{
			for (var _row = _row_start; _row < _row_end; ++_row)
			{
				var _cell_left = _grid.left + _column * _cell_size;
				var _cell_top = _grid.top + _row * _cell_size;
				var _blocked = false;
				with (o_worker_building_parent)
				{
					if (id == _carried || placement_preview || is_being_dragged) continue;
					var _occupied = building_bounds_get(id, x, y);
					if (_cell_left < _occupied.right && _cell_left + _cell_size > _occupied.left
						&& _cell_top < _occupied.bottom && _cell_top + _cell_size > _occupied.top)
					{
						_blocked = true;
						break;
					}
				}
				draw_set_color(_blocked ? COLOR_BUILDING_PLACEMENT_BLOCKED : COLOR_BUILDING_PLACEMENT_OPEN);
				draw_rectangle(_cell_left, _cell_top, _cell_left + _cell_size, _cell_top + _cell_size, false);
			}
		}
	}

	// Keep grid lines visible over the occupied-slot fill.
	draw_set_color(COLOR_BUILDING_GRID);
	draw_set_alpha(_persistent ? BALANCE_BUILDING_GRID_PERSISTENT_ALPHA : BALANCE_BUILDING_GRID_ALPHA);
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
