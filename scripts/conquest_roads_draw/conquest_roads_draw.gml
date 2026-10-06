/// @description Draws real road links and the player's standing reinforcement routes using the established palette.
function conquest_roads_draw(_controller)
{
	if (!instance_exists(_controller)) return;
	var _nodes = _controller.nodes;
	var _road_count = array_length(_controller.roads);
	draw_set_alpha(1);
	for (var _index = 0; _index < _road_count; ++_index)
	{
		var _road = _controller.roads[_index];
		var _from = _nodes[_road[0]];
		var _to = _nodes[_road[1]];
		draw_set_color(COLOR_CONQUEST_SHADOW);
		draw_line_width(_from.x, _from.y, _to.x, _to.y, 23);
		draw_set_color(COLOR_CONQUEST_ROAD);
		draw_line_width(_from.x, _from.y, _to.x, _to.y, 17);
	}

	// Persistent arrows explain the actual logistics plan; a cut route keeps its last path visible.
	var _node_count = array_length(_nodes);
	for (var _index = 0; _index < _node_count; ++_index)
	{
		var _node = _nodes[_index];
		if (_node.owner != CONQUEST_OWNER.PLAYER || _node.route_target < 0) continue;
		var _path = _node.route_path;
		var _path_count = array_length(_path);
		var _selected = array_contains(_controller.selected_nodes, _index);
		draw_set_alpha(_selected ? 1 : 0.6);
		draw_set_color(_node.route_blocked ? COLOR_CONQUEST_PLAYER : COLOR_CULTIST_COUNTER_TEXT);
		for (var _step = 1; _step < _path_count; ++_step)
		{
			var _from = _nodes[_path[_step - 1]];
			var _to = _nodes[_path[_step]];
			var _angle = point_direction(_from.x, _from.y, _to.x, _to.y);
			var _middle_x = (_from.x + _to.x) * 0.5;
			var _middle_y = (_from.y + _to.y) * 0.5;
			var _arrow_size = 13;
			draw_line_width(_from.x, _from.y, _to.x, _to.y, _selected ? 3 : 2);
			draw_triangle(_middle_x + lengthdir_x(_arrow_size, _angle), _middle_y + lengthdir_y(_arrow_size, _angle),
				_middle_x + lengthdir_x(_arrow_size, _angle + 140), _middle_y + lengthdir_y(_arrow_size, _angle + 140),
				_middle_x + lengthdir_x(_arrow_size, _angle - 140), _middle_y + lengthdir_y(_arrow_size, _angle - 140), false);
		}
	}
	draw_set_alpha(1);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_color(c_white);
}
