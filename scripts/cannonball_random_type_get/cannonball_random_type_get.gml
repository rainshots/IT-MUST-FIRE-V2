/// @description Selects uniformly from unlocked cannonballs for Forge production.
function cannonball_random_type_get()
{
	var _types = [CANNONBALL_TYPE.NORMAL, CANNONBALL_TYPE.POISON, CANNONBALL_TYPE.FIRE];
	if (instance_exists(o_game_controller) && o_game_controller.cannon_necro_unlocked) array_push(_types, CANNONBALL_TYPE.NECRO);
	return _types[irandom(array_length(_types) - 1)];
}
