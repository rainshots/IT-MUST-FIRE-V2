x = BALANCE_BUILDING_GRID_CENTER_X;
y = BALANCE_BUILDING_GRID_CENTER_Y;
depth = BALANCE_BUILDING_GRID_DEPTH;
is_attackable = false;
// Compatibility fields let the fog system reveal the construction area.
hp = 1;
faction = global.player_faction;
vision_radius = BALANCE_FACTION_BASE_REVEAL_RADIUS;

// Static world-space bounds also remain available for future enemy placement.
var _zone_one_x = BALANCE_BUILDING_GRID_CENTER_X + BALANCE_ENEMY_ZONE_1_OFFSET_X;
var _zone_two_x = _zone_one_x + BALANCE_ENEMY_ZONE_2_OFFSET_X;
var _zone_three_x = _zone_two_x + BALANCE_ENEMY_ZONE_3_OFFSET_X;
var _centers = [_zone_one_x, _zone_two_x, _zone_three_x];
var _widths = [BALANCE_ENEMY_ZONE_1_WIDTH, BALANCE_ENEMY_ZONE_2_WIDTH, BALANCE_ENEMY_ZONE_3_WIDTH];
var _heights = [BALANCE_ENEMY_ZONE_HEIGHT, BALANCE_ENEMY_ZONE_2_HEIGHT, BALANCE_ENEMY_ZONE_3_HEIGHT];
building_grids = [building_grid_bounds_get()];
enemy_zones = [];
enemy_zone_corrupted = [false, false, false];
for (var _i = 0; _i < array_length(_centers); ++_i)
{
	enemy_zones[_i] = {
		left: _centers[_i] - _widths[_i] * 0.5,
		right: _centers[_i] + _widths[_i] * 0.5,
		top: BALANCE_BUILDING_GRID_CENTER_Y - _heights[_i] * 0.5,
		bottom: BALANCE_BUILDING_GRID_CENTER_Y + _heights[_i] * 0.5
	};
}
