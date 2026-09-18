/// @description Launches one reusable Quicksand shell at the Gaze center without aiming.
function cannon_quicksand_fire(_cannon)
{
	if (!instance_exists(_cannon) || !_cannon.gaze_enabled
		|| !cannon_shot_is_available(PROJECTILE_TYPE.QUICKSAND)
		|| global.day_phase != DAY_PHASE.NIGHT || !_cannon.cannon_reload_is_ready())
	{
		return false;
	}
	var _projectile = _cannon.cannon_agony_projectile_create(
		_cannon.gaze_x, _cannon.gaze_y, PROJECTILE_TYPE.QUICKSAND, 0);
	if (!instance_exists(_projectile))
	{
		return false;
	}
	_projectile.effect_radius = _cannon.gaze_radius;
	_projectile.quicksand_upgrade = _cannon.quicksand_upgrade;
	_projectile.damage_amount = 0;
	_projectile.image_blend = COLOR_QUICKSAND;
	_cannon.cannon_reload_start(PROJECTILE_TYPE.QUICKSAND);
	global.cannon_fire_version++;
	global.sound_play_random(global.cannon_shot_sounds);
	return true;
}
