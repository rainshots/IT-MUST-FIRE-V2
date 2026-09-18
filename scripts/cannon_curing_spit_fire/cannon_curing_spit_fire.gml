/// @description Launches one reusable Curing Spit shell at the Gaze center without aiming.
function cannon_curing_spit_fire(_cannon)
{
	if (!instance_exists(_cannon) || !_cannon.gaze_enabled
		|| !cannon_shot_is_available(PROJECTILE_TYPE.CURING_SPIT)
		|| global.day_phase != DAY_PHASE.NIGHT || !_cannon.cannon_reload_is_ready())
	{
		return false;
	}
	var _projectile = _cannon.cannon_agony_projectile_create(
		_cannon.gaze_x, _cannon.gaze_y, PROJECTILE_TYPE.CURING_SPIT, 0);
	if (!instance_exists(_projectile))
	{
		return false;
	}
	_projectile.effect_radius = _cannon.gaze_radius;
	_projectile.curing_spit_upgrade = _cannon.curing_spit_upgrade;
	_projectile.damage_amount = 0;
	_projectile.image_blend = COLOR_CURING_SPIT;
	_cannon.cannon_reload_start(PROJECTILE_TYPE.CURING_SPIT);
	global.cannon_fire_version++;
	global.sound_play_random(global.cannon_shot_sounds);
	return true;
}
