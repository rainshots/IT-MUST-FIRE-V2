/// @description Plans safe unit displacement, applying only when every affected unit has a destination.
function building_units_displace(_building, _x, _y, _ignore_a = noone, _ignore_b = noone)
{
	var _placed = building_bounds_get(_building, _x, _y);
	var _obstacles = [_placed];
	with (o_worker_building_parent)
	{
		if (id == _building || id == _ignore_a || id == _ignore_b || placement_preview || is_being_dragged) continue;
		array_push(_obstacles, building_bounds_get(id, x, y));
	}
	var _units = [];
	with (o_units_parent) if (hp > 0) array_push(_units, id);
	with (o_cultist) if (hp > 0) array_push(_units, id);
	var _moves = [];
	for (var _i = 0; _i < array_length(_units); ++_i)
	{
		var _unit = _units[_i];
		if (variable_instance_exists(_unit, "cannon_loaded") && _unit.cannon_loaded) continue;
		if (_unit.bbox_right < _placed.left || _unit.bbox_left > _placed.right || _unit.bbox_bottom < _placed.top || _unit.bbox_top > _placed.bottom) continue;
		// Preserve the collision footprint rather than assuming a centered sprite origin.
		var _left = _unit.bbox_left - _unit.x;
		var _right = _unit.bbox_right - _unit.x;
		var _top = _unit.bbox_top - _unit.y;
		var _bottom = _unit.bbox_bottom - _unit.y;
		var _best = undefined;
		var _best_distance = infinity;
		for (var _j = 0; _j < array_length(_obstacles); ++_j)
		{
			var _r = _obstacles[_j];
			var _margin = BALANCE_BUILDING_PUSH_MARGIN;
			var _lx = _r.left - _right - _margin;
			var _rx = _r.right - _left + _margin;
			var _ty = _r.top - _bottom - _margin;
			var _by = _r.bottom - _top + _margin;
			var _candidates = [[_lx, _unit.y], [_rx, _unit.y], [_unit.x, _ty], [_unit.x, _by],
				[_lx, _ty], [_rx, _ty], [_lx, _by], [_rx, _by]];
			for (var _k = 0; _k < array_length(_candidates); ++_k)
			{
				var _cx = _candidates[_k][0];
				var _cy = _candidates[_k][1];
				if (_cx + _left < 0 || _cx + _right > room_width || _cy + _top < 0 || _cy + _bottom > room_height) continue;
				var _free = true;
				for (var _obstacle = 0; _obstacle < array_length(_obstacles); ++_obstacle)
				{
					var _bounds = _obstacles[_obstacle];
					if (_cx + _left < _bounds.right && _cx + _right > _bounds.left && _cy + _top < _bounds.bottom && _cy + _bottom > _bounds.top) { _free = false; break; }
				}
				var _distance = point_distance(_unit.x, _unit.y, _cx, _cy);
				if (_free && _distance < _best_distance) { _best = {unit: _unit, x: _cx, y: _cy}; _best_distance = _distance; }
			}
		}
		if (is_undefined(_best)) return false;
		array_push(_moves, _best);
	}
	// Nothing is moved if any unit cannot be displaced safely.
	for (var _i = 0; _i < array_length(_moves); ++_i)
	{
		var _move = _moves[_i];
		_move.unit.x = _move.x;
		_move.unit.y = _move.y;
		if (variable_instance_exists(_move.unit, "idle_wander_target_x"))
		{
			_move.unit.idle_wander_target_x = _move.x;
			_move.unit.idle_wander_target_y = _move.y;
		}
	}
	return true;
}
