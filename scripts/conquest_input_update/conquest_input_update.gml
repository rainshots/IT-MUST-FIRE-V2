/// @description Handles click, drag, box selection, group orders, upgrades, pause and campaign navigation.
function conquest_input_update(_controller)
{
	if (!instance_exists(_controller)) return;
	var _mouse_x = device_mouse_x_to_gui(0);
	var _mouse_y = device_mouse_y_to_gui(0);
	var _pressed = mouse_check_button_pressed(mb_left);
	var _released = mouse_check_button_released(mb_left);
	var _finished = _controller.phase != BATTLE_PHASE.BATTLE;
	_controller.hovered_node = conquest_node_at_position(_controller, _mouse_x, _mouse_y);

	// Result and pause controls use the same positions in input and drawing.
	if (!_finished && (keyboard_check_pressed(vk_space) || keyboard_check_pressed(vk_escape)))
	{
		_controller.paused = !_controller.paused;
		_controller.pointer_down = false;
		_controller.box_selecting = false;
	}
	if (_controller.paused || _finished)
	{
		if (_pressed && point_in_rectangle(_mouse_x, _mouse_y, 710, 650, 950, 710))
		{
			room_goto(r_world_map);
			return;
		}
		if (keyboard_check_pressed(ord("R")) || (_pressed && point_in_rectangle(_mouse_x, _mouse_y, 970, 650, 1210, 710)))
		{
			room_restart();
			return;
		}
		if (!_finished && _pressed && point_in_rectangle(_mouse_x, _mouse_y, 810, 560, 1110, 620)) _controller.paused = false;
		return;
	}
	if (_pressed && point_in_rectangle(_mouse_x, _mouse_y, 1710, 19, 1885, 66))
	{
		_controller.paused = true;
		_controller.pointer_down = false;
		return;
	}

	// Remove captured sources before applying any new group order.
	for (var _index = array_length(_controller.selected_nodes) - 1; _index >= 0; --_index)
	{
		if (_controller.nodes[_controller.selected_nodes[_index]].owner != CONQUEST_OWNER.PLAYER)
		{
			array_delete(_controller.selected_nodes, _index, 1);
		}
	}
	var _fractions = [0.25, 0.5, 0.75, 1];
	if (conquest_route_input_update(_controller)) return;
	var _fraction_count = _controller.tactical_mode && _controller.auto_orders ? 0 : array_length(_fractions);
	for (var _index = 0; _index < _fraction_count; ++_index)
	{
		var _button_x = 700 + _index * 105;
		if (keyboard_check_pressed(ord("1") + _index)
			|| (_pressed && point_in_rectangle(_mouse_x, _mouse_y, _button_x, 960, _button_x + 92, 1012)))
		{
			_controller.send_fraction = _fractions[_index];
		}
	}
	if (keyboard_check_pressed(ord("A")))
	{
		_controller.selected_nodes = [];
		var _node_count = array_length(_controller.nodes);
		for (var _index = 0; _index < _node_count; ++_index)
		{
			if (_controller.nodes[_index].owner == CONQUEST_OWNER.PLAYER) array_push(_controller.selected_nodes, _index);
		}
	}
	var _selection_count = array_length(_controller.selected_nodes);
	if (keyboard_check_pressed(ord("U"))
		|| (_pressed && point_in_rectangle(_mouse_x, _mouse_y, 1440, 949, 1855, 1014)))
	{
		var _upgraded = false;
		if (_selection_count == 1) _upgraded = conquest_upgrade_start(_controller, _controller.selected_nodes[0], CONQUEST_OWNER.PLAYER);
		_controller.feedback = _upgraded ? "Upgrade started. Recruitment pauses for 3 seconds."
			: "Select one building. Upgrade costs 20 / 40 troops and leaves at least one defender.";
		_controller.feedback_timer = 4;
		return;
	}
	var _hovered = _controller.hovered_node;
	if (mouse_check_button_pressed(mb_right))
	{
		if (_hovered >= 0) conquest_selection_send(_controller, _hovered);
		else _controller.selected_nodes = [];
		_controller.pointer_down = false;
		return;
	}

	// Clicking an ally selects it; dragging it onto any other building sends troops.
	if (_pressed && _mouse_y >= _controller.field_top && _mouse_y < _controller.field_bottom)
	{
		_controller.pointer_down = true;
		_controller.pressed_node = _hovered;
		_controller.pointer_start_x = _mouse_x;
		_controller.pointer_start_y = _mouse_y;
		_controller.box_selecting = _hovered < 0;
		if (_hovered >= 0 && _controller.nodes[_hovered].owner == CONQUEST_OWNER.PLAYER)
		{
			if (keyboard_check(vk_shift))
			{
				if (!array_contains(_controller.selected_nodes, _hovered)) array_push(_controller.selected_nodes, _hovered);
			}
			else if (!array_contains(_controller.selected_nodes, _hovered)) _controller.selected_nodes = [_hovered];
		}
	}
	if (_released && _controller.pointer_down)
	{
		_controller.pointer_down = false;
		var _distance = point_distance(_controller.pointer_start_x, _controller.pointer_start_y, _mouse_x, _mouse_y);
		var _drag_threshold = 12;
		if (_controller.box_selecting)
		{
			if (!keyboard_check(vk_shift)) _controller.selected_nodes = [];
			if (_distance > _drag_threshold)
			{
				var _node_count = array_length(_controller.nodes);
				for (var _index = 0; _index < _node_count; ++_index)
				{
					var _node = _controller.nodes[_index];
					if (_node.owner == CONQUEST_OWNER.PLAYER
						&& point_in_rectangle(_node.x, _node.y - 25, min(_mouse_x, _controller.pointer_start_x),
							min(_mouse_y, _controller.pointer_start_y), max(_mouse_x, _controller.pointer_start_x),
							max(_mouse_y, _controller.pointer_start_y)) && !array_contains(_controller.selected_nodes, _index))
					{
						array_push(_controller.selected_nodes, _index);
					}
				}
			}
		}
		else if (_hovered >= 0)
		{
			var _target = _controller.nodes[_hovered];
			if (_hovered != _controller.pressed_node || _target.owner != CONQUEST_OWNER.PLAYER)
			{
				conquest_selection_send(_controller, _hovered);
			}
			else if (!keyboard_check(vk_shift)) _controller.selected_nodes = [_hovered];
		}
		_controller.box_selecting = false;
	}
}
