/// @description Builds one of three battlefield layouts, scaled to the selected campaign point.
function conquest_level_prepare(_controller)
{
	if (!instance_exists(_controller)) return;
	var _map = _controller.campaign_map;
	if (instance_exists(_map))
	{
		_controller.level_title = _map.active_level_title;
		var _rooms = [Battle_room, r_battle_02, r_battle_03, r_battle_04, r_battle_05, r_battle_06,
			r_battle_07, r_battle_08, r_battle_09, r_battle_10, r_battle_11];
		var _room_count = array_length(_rooms);
		for (var _index = 0; _index < _room_count; ++_index)
		{
			if (_rooms[_index] == _map.active_battle_room) _controller.level_index = _index;
		}
	}

	// Start the campaign with the experimental road mission; retain later battles for comparison.
	_controller.tactical_mode = _controller.level_index == 0;
	_controller.roads = [];
	_controller.march_speed = BALANCE_CONQUEST_MARCH_SPEED;
	if (_controller.tactical_mode)
	{
		conquest_road_level_prepare(_controller);
		return;
	}

	// Hollow Fields has a gentler opening; later missions retain their existing pressure.
	var _is_second_mission = _controller.level_index == 1;
	_controller.ai_timer = _is_second_mission
		? BALANCE_CONQUEST_SECOND_MISSION_AI_OPENING_SECONDS : BALANCE_CONQUEST_AI_OPENING_SECONDS;
	_controller.ai_interval_seconds = _is_second_mission
		? BALANCE_CONQUEST_SECOND_MISSION_AI_INTERVAL : BALANCE_CONQUEST_AI_INTERVAL;
	var _player_starting_garrison = _is_second_mission ? BALANCE_CONQUEST_SECOND_MISSION_PLAYER_GARRISON : 48;
	var _enemy_bonus = _controller.level_index * 3;
	var _enemy_starting_garrison = _is_second_mission ? BALANCE_CONQUEST_SECOND_MISSION_ENEMY_GARRISON : 40 + _enemy_bonus;

	// Paired flanks, a contested centre, and distinct routes keep every building reachable.
	var _layouts = [
		[[240, 490], [490, 280], [490, 710], [770, 475], [960, 235], [960, 745],
			[1150, 475], [1430, 280], [1430, 710], [1680, 490]],
		[[225, 490], [470, 240], [470, 745], [760, 325], [760, 650], [960, 490],
			[1160, 325], [1160, 650], [1450, 240], [1450, 745], [1695, 490]],
		[[230, 520], [450, 300], [475, 755], [750, 535], [890, 245], [1020, 760],
			[1170, 470], [1410, 260], [1460, 715], [1690, 480]]
	];
	var _points = _layouts[_controller.level_index mod array_length(_layouts)];
	var _count = array_length(_points);
	for (var _index = 0; _index < _count; ++_index)
	{
		var _point = _points[_index];
		var _kind = CONQUEST_BUILDING.SETTLEMENT;
		if (_index == 3 || _index == _count - 4) _kind = CONQUEST_BUILDING.TOWER;
		// On the second mission, match the enemy's extra settlement and keep one central forge.
		if (_index == 5 || (_index == 4 && !_is_second_mission)) _kind = CONQUEST_BUILDING.FORGE;
		var _owner = CONQUEST_OWNER.NEUTRAL;
		var _garrison = _kind == CONQUEST_BUILDING.SETTLEMENT ? 10 : 14;
		var _level = 1;
		if (_index == 0 || _index == _count - 1)
		{
			_owner = _index == 0 ? CONQUEST_OWNER.PLAYER : CONQUEST_OWNER.ENEMY;
			_garrison = _index == 0 ? _player_starting_garrison : _enemy_starting_garrison;
			_level = 2;
		}
		array_push(_controller.nodes, new conquest_node_constructor(_point[0], _point[1],
			_kind, _owner, _garrison, _level));
	}
	_controller.selected_nodes = [0];

	// Reuse existing foliage around the margins; no collision or hidden obstacles.
	var _tree_count = 26;
	for (var _index = 0; _index < _tree_count; ++_index)
	{
		var _x = 65 + ((_index * 173 + _controller.level_index * 29) mod 1780);
		var _y = _index mod 2 == 0 ? 130 + (_index mod 3) * 14 : 855 - (_index mod 3) * 11;
		array_push(_controller.scenery, { x: _x, y: _y, sprite: _index mod 2 == 0 ? s_tree_yellow_01 : s_tree_yellow_02 });
	}
}
