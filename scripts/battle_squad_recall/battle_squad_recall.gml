/// @description Returns a deployed squad to its reserve card during preparation.
function battle_squad_recall(_controller, _squad)
{
	if (!instance_exists(_controller) || !is_struct(_squad)
		|| _controller.battle_phase != BATTLE_PHASE.PREPARATION
		|| !_squad.properties.battle_deployed) return false;

	// Recalling an airborne squad cancels its shell before it can create any units.
	var _projectile = _squad.properties.battle_deployment_projectile;
	if (instance_exists(_projectile)) instance_destroy(_projectile);
	_squad.properties.battle_deployment_projectile = noone;

	var _count = array_length(_squad.units);
	for (var _index = 0; _index < _count; ++_index)
	{
		var _unit = _squad.units[_index];
		if (instance_exists(_unit)) instance_destroy(_unit);
	}
	_squad.units = [];
	_squad.total_max_hp = 0;
	_squad.properties.battle_deployed = false;
	_controller.battle_deployed_count--;
	return true;
}
