/// @description Spawns a berry or seed uniformly inside a mature tree's local spread radius.
/// @param {Id.Instance} _tree Tree providing the position and Cannon ownership.
/// @param {Asset.GMObject} _object Garden entity to spawn.
function dark_garden_spawn_near(_tree, _object)
{
	if (!instance_exists(_tree) || global.day_phase != DAY_PHASE.NIGHT)
	{
		return noone;
	}
	var _direction = random(360);
	var _distance = sqrt(random(1)) * BALANCE_DARK_GARDEN_SPREAD_RADIUS;
	var _spawn = instance_create_layer(_tree.x + lengthdir_x(_distance, _direction),
		_tree.y + lengthdir_y(_distance, _direction), "Instances", _object);
	_spawn.source_cannon = _tree.source_cannon;
	return _spawn;
}
