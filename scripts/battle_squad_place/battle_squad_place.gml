/// @description Creates or moves squad members at reserved formation positions, including after combat starts.
function battle_squad_place(_squad, _positions)
{
	// First arrivals create members; repositioning keeps the same instances and stats.
	var _unit_count = array_length(_positions);
	var _existing_count = array_length(_squad.units);
	for (var _index = 0; _index < _unit_count; ++_index)
	{
		var _unit = _index < _existing_count ? _squad.units[_index] : noone;
		var _position = _positions[_index];
		if (!instance_exists(_unit))
		{
			_unit = instance_create_layer(_position.x, _position.y, "Instances", _squad.unit_objects[_index]);
			_unit.squad = _squad;
			_unit.squad_unit_index = _index;
			squad_unit_permanent_bonuses_apply(_squad, _unit);
			foundry_unit_permanent_bonuses_apply(_unit);
			_unit.foundry_permanent_bonuses_pending = false;
			_unit.hp = _unit.max_hp;
			_squad.units[_index] = _unit;
			_squad.total_max_hp += _unit.max_hp;
		}
		_unit.x = _position.x;
		_unit.y = _position.y;
		_unit.drag_drop_x = _position.x;
		_unit.drag_drop_y = _position.y;
		_unit.navigation_path_state_clear();
		_unit.depth = -floor(_unit.y);
	}
	squad_marker_position_update(_squad);
	return true;
}
