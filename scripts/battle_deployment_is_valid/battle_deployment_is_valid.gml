/// @description Checks the whole formation against Taint, room edges, obstacles, and other deployed squads.
function battle_deployment_is_valid(_controller, _squad, _positions)
{
	if (!instance_exists(_controller) || !is_struct(_squad)
		|| _controller.battle_phase != BATTLE_PHASE.PREPARATION
		|| (!_squad.properties.battle_deployed
			&& _controller.battle_deployed_count >= BALANCE_BATTLE_DEPLOYMENT_LIMIT))
	{
		return false;
	}

	var _margin = BALANCE_BATTLE_UNIT_MARGIN;
	var _count = array_length(_positions);
	for (var _index = 0; _index < _count; ++_index)
	{
		var _position = _positions[_index];
		if (_position.x < _margin || _position.y < _margin
			|| _position.x > room_width - _margin || _position.y > room_height - _margin
			|| !_controller.ground_cell_is_tainted_at_position(_position.x, _position.y)
			|| collision_rectangle(_position.x - _margin, _position.y - _margin,
				_position.x + _margin, _position.y + _margin, o_wall_parent, false, true) != noone
			|| collision_rectangle(_position.x - _margin, _position.y - _margin,
				_position.x + _margin, _position.y + _margin, o_mountain, false, true) != noone)
		{
			return false;
		}
		if (instance_exists(o_cannon))
		{
			var _cannon = instance_find(o_cannon, 0);
			if (point_distance(_position.x, _position.y, _cannon.x, _cannon.y) < _cannon.combat_radius + _margin)
			{
				return false;
			}
		}
	}

	// Reserve airborne formations as well as landed units so simultaneous shots cannot overlap.
	var _squads = global.squads;
	var _squad_count = array_length(_squads);
	for (var _squad_index = 0; _squad_index < _squad_count; ++_squad_index)
	{
		var _other_squad = _squads[_squad_index];
		if (_other_squad == _squad || !_other_squad.properties.battle_deployed) continue;
		var _projectile = _other_squad.properties.battle_deployment_projectile;
		var _other_positions = [];
		if (instance_exists(_projectile))
		{
			_other_positions = _projectile.battle_deployment_positions;
		}
		else
		{
			var _unit_count = array_length(_other_squad.units);
			for (var _unit_index = 0; _unit_index < _unit_count; ++_unit_index)
			{
				var _unit = _other_squad.units[_unit_index];
				if (instance_exists(_unit)) array_push(_other_positions, { x: _unit.x, y: _unit.y });
			}
		}
		var _other_position_count = array_length(_other_positions);
		for (var _other_index = 0; _other_index < _other_position_count; ++_other_index)
		{
			var _other_position = _other_positions[_other_index];
			for (var _position_index = 0; _position_index < _count; ++_position_index)
			{
				var _position = _positions[_position_index];
				if (point_distance(_other_position.x, _other_position.y, _position.x, _position.y) < _margin * 2)
				{
					return false;
				}
			}
		}
	}
	return _count > 0;
}
