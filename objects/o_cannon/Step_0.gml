// Receive a freshly selected target from the game controller.
if (global.cannon_target_exists && target_version != global.cannon_target_version)
{
	target_exists = true;
	target_x = global.cannon_target_x;
	target_y = global.cannon_target_y;
	target_projectile_type = global.cannon_target_projectile_type;
	target_version = global.cannon_target_version;
	shot_timer = 0;
}

// Cannons do not fire while the game is paused or while no target exists.
if (global.pause || !target_exists)
{
	exit;
}

// Fire at the selected target once the reload timer is ready.
shot_timer--;

if (shot_timer <= 0)
{
	var _projectile_x = x;
	var _projectile_y = y + projectile_spawn_offset_y;
	var _projectile = instance_create_layer(_projectile_x, _projectile_y, projectile_layer_name, o_projectile);

	_projectile.start_x = _projectile_x;
	_projectile.start_y = _projectile_y;
	_projectile.target_x = target_x;
	_projectile.target_y = target_y;
	_projectile.projectile_type = target_projectile_type;
	_projectile.effect_radius = projectile_effect_radius;

	shot_timer = shot_interval;
}
