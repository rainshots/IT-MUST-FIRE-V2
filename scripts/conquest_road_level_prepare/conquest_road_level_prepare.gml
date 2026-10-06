/// @description Builds Ashen Crossing with a fortified shortcut and a longer economic flank.
function conquest_road_level_prepare(_controller)
{
	if (!instance_exists(_controller)) return;
	_controller.nodes = [
		new conquest_node_constructor(210, 440, CONQUEST_BUILDING.SETTLEMENT, CONQUEST_OWNER.PLAYER, 50, 2),
		new conquest_node_constructor(550, 400, CONQUEST_BUILDING.SETTLEMENT, CONQUEST_OWNER.PLAYER, 18),
		new conquest_node_constructor(960, 400, CONQUEST_BUILDING.TOWER, CONQUEST_OWNER.NEUTRAL, 24, 2),
		new conquest_node_constructor(1370, 400, CONQUEST_BUILDING.SETTLEMENT, CONQUEST_OWNER.ENEMY, 16),
		new conquest_node_constructor(1710, 440, CONQUEST_BUILDING.SETTLEMENT, CONQUEST_OWNER.ENEMY, 40, 2),
		new conquest_node_constructor(660, 725, CONQUEST_BUILDING.SETTLEMENT, CONQUEST_OWNER.NEUTRAL, 8),
		new conquest_node_constructor(1200, 725, CONQUEST_BUILDING.FORGE, CONQUEST_OWNER.NEUTRAL, 12)
	];
	var _labels = ["Cult refuge", "West outpost", "The crossing", "East outpost", "Enemy refuge", "Old hamlet", "Roadside forge"];
	var _count = array_length(_controller.nodes);
	for (var _index = 0; _index < _count; ++_index) _controller.nodes[_index].label = _labels[_index];
	_controller.roads = [[0, 1], [1, 2], [2, 3], [3, 4], [1, 5], [5, 6], [6, 3]];
	_controller.march_speed = BALANCE_CONQUEST_ROAD_SPEED;
	_controller.ai_timer = BALANCE_CONQUEST_ROAD_AI_OPENING_SECONDS;
	_controller.ai_interval_seconds = BALANCE_CONQUEST_ROAD_AI_INTERVAL;
	_controller.selected_nodes = [0];
	_controller.feedback = "Drag from the refuge to your outpost to establish automatic reinforcements.";
	_controller.feedback_timer = 18;
	_controller.route_refresh_remaining = 0;
	_controller.scenery = [];

	// Frame the two roads with the project's existing foliage, keeping the road junctions clear.
	var _tree_count = 24;
	for (var _index = 0; _index < _tree_count; ++_index)
	{
		var _x = 90 + (_index * 173) mod 1750;
		var _y = _index mod 2 == 0 ? 190 + (_index mod 3) * 18 : 850 - (_index mod 3) * 8;
		array_push(_controller.scenery, { x: _x, y: _y, sprite: _index mod 2 == 0 ? s_tree_yellow_01 : s_tree_yellow_02 });
	}
}
