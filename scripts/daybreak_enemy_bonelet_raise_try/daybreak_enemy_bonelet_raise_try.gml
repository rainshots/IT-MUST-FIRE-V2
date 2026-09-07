/// @description Gives a dead enemy the Rise Again chance to create a temporary allied Bonelet.
/// @param {Id.Instance} dead_unit Enemy whose death is currently being processed.
function daybreak_enemy_bonelet_raise_try(_dead_unit)
{
	if (!instance_exists(_dead_unit) || !instance_exists(o_game_controller)
		|| _dead_unit.unit_faction != UNIT_FACTION.ENEMY)
	{
		return noone;
	}

	var _game_controller = instance_find(o_game_controller, 0);
	if (!_game_controller.rise_again_active || random(1) >= BALANCE_RISE_AGAIN_CHANCE)
	{
		return noone;
	}

	// Raised enemies are independent allies and never occupy a player squad slot.
	var _bonelet = instance_create_layer(_dead_unit.x, _dead_unit.y, "Instances", o_skeleton_bonelet);
	if (instance_exists(_bonelet))
	{
		_bonelet.projectile_skeleton_dies_at_morning = true;
		_bonelet.regroup_is_active = false;
		_bonelet.rally_is_active = false;
	}

	return _bonelet;
}
