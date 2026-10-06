/// @description Draws the battlefield with original terrain, scenery and animated troop columns.
function conquest_world_draw(_controller)
{
	if (!instance_exists(_controller)) return;
	draw_set_alpha(1);
	draw_set_color(c_white);
	draw_sprite_stretched(s_background, 0, 0, 0, _controller.gui_width, _controller.gui_height);
	var _nodes = _controller.nodes;
	var _node_count = array_length(_nodes);

	// The experimental mission displays only traversable roads and persistent order arrows.
	if (_controller.tactical_mode) conquest_roads_draw(_controller);
	// Classic missions retain their decorative paths for comparison.
	draw_set_color(COLOR_CONQUEST_ROAD);
	draw_set_alpha(0.3);
	var _road_distance = 530;
	var _classic_node_count = _controller.tactical_mode ? 0 : _node_count;
	for (var _index = 0; _index < _classic_node_count; ++_index)
	{
		for (var _other = _index + 1; _other < _node_count; ++_other)
		{
			var _source = _nodes[_index];
			var _target = _nodes[_other];
			if (point_distance(_source.x, _source.y, _target.x, _target.y) < _road_distance)
			{
				draw_line_width(_source.x, _source.y, _target.x, _target.y, 13);
			}
		}
	}
	draw_set_alpha(1);
	var _scenery_count = array_length(_controller.scenery);
	for (var _index = 0; _index < _scenery_count; ++_index)
	{
		var _item = _controller.scenery[_index];
		conquest_sprite_draw(_item.sprite, _item.x, _item.y, 70, 85);
	}

	// Tower range is shown only while inspecting that tower.
	if (_controller.hovered_node >= 0)
	{
		var _hovered = _nodes[_controller.hovered_node];
		if (_hovered.kind == CONQUEST_BUILDING.TOWER)
		{
			draw_set_color(conquest_owner_color_get(_hovered.owner));
			draw_set_alpha(0.45);
			draw_circle(_hovered.x, _hovered.y, BALANCE_CONQUEST_TOWER_RANGE, true);
			draw_set_alpha(1);
		}
	}

	// Sort only lightweight draw entries; individual soldiers never become instances.
	var _draw_entries = [];
	for (var _index = 0; _index < _node_count; ++_index) array_push(_draw_entries, { y: _nodes[_index].y, index: _index, building: true });
	var _army_count = array_length(_controller.armies);
	for (var _index = 0; _index < _army_count; ++_index) array_push(_draw_entries, { y: _controller.armies[_index].y, index: _index, building: false });
	array_sort(_draw_entries, function(_first, _second) { return _first.y - _second.y; });
	var _entry_count = array_length(_draw_entries);
	for (var _index = 0; _index < _entry_count; ++_index)
	{
		var _entry = _draw_entries[_index];
		if (_entry.building)
		{
			conquest_building_draw(_controller, _entry.index);
			continue;
		}
		var _army = _controller.armies[_entry.index];
		var _target = _nodes[_controller.tactical_mode ? _army.segment_target : _army.target];
		var _angle = point_direction(_army.start_x, _army.start_y, _target.x, _target.y);
		var _draw_x = _army.x;
		var _draw_y = _army.y;
		if (_controller.tactical_mode)
		{
			// Separate opposing counters and keep besiegers outside the building's own counter plate.
			if (_army.besieging)
			{
				var _siege_offset = 100;
				_draw_x -= lengthdir_x(_siege_offset, _angle);
				_draw_y -= lengthdir_y(_siege_offset, _angle);
			}
			else if (_army.engaged) _draw_x += _army.owner == CONQUEST_OWNER.PLAYER ? -30 : 30;
		}
		var _visible_troops = min(12, ceil(_army.count));
		var _sprite = _army.owner == CONQUEST_OWNER.PLAYER ? s_skeleton : s_peasant;
		for (var _troop = 0; _troop < _visible_troops; ++_troop)
		{
			var _row = floor(_troop / 3);
			var _side = (_troop mod 3 - 1) * 14;
			var _trail = min(_row * 16, _army.progress * _army.distance);
			var _x = _draw_x - lengthdir_x(_trail, _angle) + lengthdir_x(_side, _angle + 90);
			var _y = _draw_y - lengthdir_y(_trail, _angle) + lengthdir_y(_side, _angle + 90);
			var _bob = abs(sin(_controller.elapsed_seconds * 11 + _troop)) * 3;
			conquest_sprite_draw(_sprite, _x, _y - _bob, 27, 33, _target.x < _army.start_x);
		}
		draw_set_halign(fa_center);
		draw_set_valign(fa_middle);
		draw_set_font(_controller.ui_font);
		draw_set_color(COLOR_WORLD_MAP_PANEL);
		draw_rectangle(_draw_x - 21, _draw_y + 6, _draw_x + 21, _draw_y + 29, false);
		draw_set_color(conquest_owner_color_get(_army.owner));
		draw_rectangle(_draw_x - 21, _draw_y + 6, _draw_x + 21, _draw_y + 29, true);
		draw_set_color(COLOR_CULTIST_COUNTER_TEXT);
		draw_text(_draw_x, _draw_y + 17, string(ceil(_army.count)));
		if (_controller.tactical_mode && _army.engaged)
		{
			draw_set_color(COLOR_CULTIST_COUNTER_TEXT);
			draw_text(_army.x, _army.y - 37, "X");
		}
	}
	var _shot_count = array_length(_controller.shots);
	for (var _index = 0; _index < _shot_count; ++_index)
	{
		var _shot = _controller.shots[_index];
		draw_set_color(conquest_owner_color_get(_shot.owner));
		draw_set_alpha(min(1, _shot.remaining * 8));
		draw_line_width(_shot.x, _shot.y, _shot.target_x, _shot.target_y, 3);
	}

	// Live orders remain previews until release; box selection uses the same screen coordinates.
	draw_set_alpha(1);
	draw_set_color(COLOR_CULTIST_COUNTER_TEXT);
	if (_controller.pointer_down)
	{
		var _mouse_x = device_mouse_x_to_gui(0);
		var _mouse_y = device_mouse_y_to_gui(0);
		if (_controller.box_selecting)
		{
			draw_rectangle(_controller.pointer_start_x, _controller.pointer_start_y, _mouse_x, _mouse_y, true);
		}
		else if (_controller.pressed_node >= 0 && _nodes[_controller.pressed_node].owner == CONQUEST_OWNER.PLAYER)
		{
			var _selected_count = array_length(_controller.selected_nodes);
			for (var _index = 0; _index < _selected_count; ++_index)
			{
				var _node = _nodes[_controller.selected_nodes[_index]];
				if (!_controller.tactical_mode) draw_line_width(_node.x, _node.y, _mouse_x, _mouse_y, 2);
				else if (_controller.hovered_node >= 0)
				{
					var _path = conquest_path_get(_controller, _controller.selected_nodes[_index], _controller.hovered_node, CONQUEST_OWNER.PLAYER);
					var _path_count = array_length(_path);
					for (var _step = 1; _step < _path_count; ++_step)
					{
						var _from = _nodes[_path[_step - 1]];
						var _to = _nodes[_path[_step]];
						draw_line_width(_from.x, _from.y, _to.x, _to.y, 4);
					}
				}
			}
			draw_circle(_mouse_x, _mouse_y, 10, true);
		}
	}
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_color(c_white);
	draw_set_alpha(1);
}
