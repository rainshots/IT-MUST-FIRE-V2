// Enemy territory outlines remain visible outside construction mode.
draw_set_alpha(1);
draw_set_color(COLOR_ENEMY_ZONE);
var _zone_count = array_length(enemy_zones);
for (var _zone_index = 0; _zone_index < _zone_count; ++_zone_index)
{
	var _zone = enemy_zones[_zone_index];
	draw_rectangle(_zone.left, _zone.top, _zone.right, _zone.bottom, true);
}
draw_set_color(c_white);
draw_set_alpha(1);

// Show the construction overlay only during a purchase or building relocation.
if (!instance_exists(o_game_controller) || !instance_exists(o_game_controller.shop_preview)) exit;
var _grid = building_grid_bounds_get();

// Tint occupied footprints, including the Heart and trash, but not the placement preview.
draw_set_color(COLOR_BUILDING_GRID_OCCUPIED);
draw_set_alpha(BALANCE_BUILDING_GRID_OCCUPIED_ALPHA);
with (o_worker_building_parent)
{
	if (placement_preview || id == o_game_controller.shop_preview) continue;
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
for (var _column = 0; _column <= BALANCE_BUILDING_GRID_COLUMNS; ++_column)
{
	var _x = _grid.left + _column * BALANCE_BUILDING_GRID_CELL_SIZE;
	draw_line(_x, _grid.top, _x, _grid.bottom);
}
for (var _row = 0; _row <= BALANCE_BUILDING_GRID_ROWS; ++_row)
{
	var _y = _grid.top + _row * BALANCE_BUILDING_GRID_CELL_SIZE;
	draw_line(_grid.left, _y, _grid.right, _y);
}
draw_set_color(c_white);
draw_set_alpha(1);
