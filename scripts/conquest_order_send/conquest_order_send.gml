/// @description Sends an integer share of a source garrison; returns how many troops departed.
function conquest_order_send(_controller, _source_index, _target_index, _fraction, _owner)
{
	if (!instance_exists(_controller)) return 0;
	var _count = array_length(_controller.nodes);
	if (_source_index < 0 || _target_index < 0 || _source_index >= _count || _target_index >= _count
		|| _source_index == _target_index || _controller.phase != BATTLE_PHASE.BATTLE) return 0;
	var _source = _controller.nodes[_source_index];
	if (_source.owner != _owner || _owner == CONQUEST_OWNER.NEUTRAL || _source.upgrade_remaining > 0) return 0;
	if (_controller.tactical_mode && (_source.dispatch_remaining > 0 || _source.under_siege)) return 0;
	var _path = conquest_path_get(_controller, _source_index, _target_index, _owner);
	if (array_length(_path) < 2) return 0;
	var _next = _controller.nodes[_path[1]];
	var _troops = floor(floor(_source.garrison) * clamp(_fraction, 0, 1));
	if (_troops <= 0) return 0;
	_source.garrison -= _troops;
	if (_controller.tactical_mode) _source.dispatch_remaining = BALANCE_CONQUEST_ROUTE_INTERVAL;
	array_push(_controller.armies, {
		owner: _owner, count: _troops, source: _source_index, target: _target_index,
		x: _source.x, y: _source.y, start_x: _source.x, start_y: _source.y,
		distance: max(1, point_distance(_source.x, _source.y, _next.x, _next.y)),
		progress: 0, previous_progress: 0, path: _path, path_step: 1,
		segment_source: _source_index, segment_target: _path[1],
		besieging: false, engaged: false, pending_damage: 0, engaged_enemy_count: 0
	});
	return _troops;
}
