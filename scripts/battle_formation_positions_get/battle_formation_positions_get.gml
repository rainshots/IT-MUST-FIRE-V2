/// @description Returns centered formation positions without changing any squad or instance.
function battle_formation_positions_get(_squad, _center_x, _center_y)
{
	var _count = array_length(_squad.unit_objects);
	var _columns = ceil(sqrt(_count));
	var _rows = ceil(_count / max(1, _columns));
	var _spacing = BALANCE_BATTLE_FORMATION_SPACING;
	var _positions = [];
	for (var _index = 0; _index < _count; ++_index)
	{
		var _column = _index mod _columns;
		var _row = floor(_index / _columns);
		array_push(_positions, {
			x: _center_x + ((_column - ((_columns - 1) * 0.5)) * _spacing),
			y: _center_y + ((_row - ((_rows - 1) * 0.5)) * _spacing)
		});
	}
	return _positions;
}
