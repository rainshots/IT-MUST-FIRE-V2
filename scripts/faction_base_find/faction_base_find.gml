/// @description Finds the living map base belonging to a faction.
function faction_base_find(_faction)
{
	var _base_count = instance_number(o_faction_base_parent);
	for (var _index = 0; _index < _base_count; ++_index)
	{
		var _base = instance_find(o_faction_base_parent, _index);
		if (instance_exists(_base) && _base.faction == _faction && _base.hp > 0)
		{
			return _base;
		}
	}
	return noone;
}
