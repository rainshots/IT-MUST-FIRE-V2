/// @description Fires a reusable seed volley at uniformly distributed points inside the current Gaze.
/// @param {Id.Instance} _cannon Cannon owning the Gaze and lifetime absorption total.
function cannon_dark_garden_fire(_cannon)
{
	if (!instance_exists(_cannon) || !_cannon.gaze_enabled || _cannon.hp <= 0
		|| !cannon_shot_is_available(PROJECTILE_TYPE.DARK_GARDEN)
		|| global.day_phase != DAY_PHASE.NIGHT || !_cannon.cannon_reload_is_ready())
	{
		return false;
	}
	var _seed_count = BALANCE_DARK_GARDEN_SEED_COUNT
		+ floor(_cannon.absorption_total_corpse_count / BALANCE_DARK_GARDEN_CORPSES_PER_SEED);
	for (var _seed_index = 0; _seed_index < _seed_count; ++_seed_index)
	{
		var _direction = random(360);
		var _distance = sqrt(random(1)) * _cannon.gaze_radius;
		var _projectile = _cannon.cannon_agony_projectile_create(
			_cannon.gaze_x + lengthdir_x(_distance, _direction),
			_cannon.gaze_y + lengthdir_y(_distance, _direction), PROJECTILE_TYPE.DARK_GARDEN, 0);
		if (instance_exists(_projectile))
		{
			_projectile.damage_amount = 0;
			_projectile.image_blend = COLOR_DARK_GARDEN;
		}
	}
	// A volley costs one shared reload, regardless of the number of seeds.
	_cannon.cannon_reload_start(PROJECTILE_TYPE.DARK_GARDEN);
	global.cannon_fire_version++;
	global.sound_play_random(global.cannon_shot_sounds);
	return true;
}
