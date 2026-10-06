/// @description Ends a battle only when a faction has neither buildings nor marching reinforcements.
function conquest_result_update(_controller)
{
	if (!instance_exists(_controller)) return;
	if (_controller.phase != BATTLE_PHASE.BATTLE) return;
	var _alive = [false, false, false];
	var _node_count = array_length(_controller.nodes);
	for (var _index = 0; _index < _node_count; ++_index)
	{
		_alive[_controller.nodes[_index].owner] = true;
	}
	var _army_count = array_length(_controller.armies);
	for (var _index = 0; _index < _army_count; ++_index)
	{
		var _army = _controller.armies[_index];
		if (_army.count > 0) _alive[_army.owner] = true;
	}
	if (!_alive[CONQUEST_OWNER.PLAYER]) _controller.phase = BATTLE_PHASE.DEFEAT;
	else if (!_alive[CONQUEST_OWNER.ENEMY])
	{
		_controller.phase = BATTLE_PHASE.VICTORY;
		var _map = _controller.campaign_map;
		if (instance_exists(_map)) world_map_level_capture(_map, _map.active_level);
	}
}
