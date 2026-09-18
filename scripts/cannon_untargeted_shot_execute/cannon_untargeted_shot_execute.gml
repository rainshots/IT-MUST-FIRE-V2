/// @description Executes a reusable instant action directly from its shot slot without aiming.
/// @param {PROJECTILE_TYPE} _shot_type Action identity.
/// @param {Real} _queue_index Selected reusable shot entry.
function cannon_untargeted_shot_execute(_shot_type, _queue_index)
{
	if (!instance_exists(o_cannon) || !instance_exists(o_game_controller)
		|| !cannon_shot_is_available(_shot_type)
		|| (cannon_shot_category_get(_shot_type) != CANNON_SHOT_CATEGORY.INSTANT_UNTARGETED
			&& cannon_shot_category_get(_shot_type) != CANNON_SHOT_CATEGORY.PROJECTILE_UNTARGETED)
		|| _queue_index < 0 || _queue_index >= array_length(global.cannon_projectile_queue)
		|| global.cannon_projectile_queue[_queue_index] != _shot_type)
	{
		return false;
	}
	var _controller = instance_find(o_game_controller, 0);
	var _cannon = instance_find(o_cannon, 0);
	if (!_controller.cannon_projectile_type_can_fire_in_current_phase(_shot_type)
		|| !_cannon.cannon_reload_is_ready() || _cannon.hp <= 0)
	{
		return false;
	}
	switch (_shot_type)
	{
		case PROJECTILE_TYPE.CURING_SPIT:
			return cannon_curing_spit_fire(_cannon);
		case PROJECTILE_TYPE.DARK_GARDEN:
			return cannon_dark_garden_fire(_cannon);
		case PROJECTILE_TYPE.QUICKSAND:
			return cannon_quicksand_fire(_cannon);
		case PROJECTILE_TYPE.ABSORPTION:
			return cannon_absorption_execute(_cannon, _controller);
	}
	return false;
}
