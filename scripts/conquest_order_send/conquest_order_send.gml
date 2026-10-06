/// @description Sends an integer share of a source garrison; returns how many troops departed.
function conquest_order_send(_controller, _source_index, _target_index, _fraction, _owner)
{
	if (!instance_exists(_controller)) return 0;
	var _count = array_length(_controller.nodes);
	if (_source_index < 0 || _target_index < 0 || _source_index >= _count || _target_index >= _count
		|| _source_index == _target_index || _controller.phase != BATTLE_PHASE.BATTLE) return 0;
	var _source = _controller.nodes[_source_index];
	var _target = _controller.nodes[_target_index];
	if (_source.owner != _owner || _owner == CONQUEST_OWNER.NEUTRAL || _source.upgrade_remaining > 0) return 0;
	var _troops = floor(floor(_source.garrison) * clamp(_fraction, 0, 1));
	if (_troops <= 0) return 0;
	_source.garrison -= _troops;
	array_push(_controller.armies, {
		owner: _owner, count: _troops, source: _source_index, target: _target_index,
		x: _source.x, y: _source.y, start_x: _source.x, start_y: _source.y,
		distance: max(1, point_distance(_source.x, _source.y, _target.x, _target.y)),
		progress: 0
	});
	return _troops;
}
