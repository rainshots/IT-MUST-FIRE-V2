/// @description Updates automatic daytime avatar shots. Call only from o_cannon Step.
function cannon_day_shot_update()
{
	// Start a fresh interval next morning or when an avatar becomes available again.
	if (global.day_phase != DAY_PHASE.DAY || !instance_exists(o_player))
	{
		day_shot_remaining = BALANCE_CANNON_DAY_SHOT_INTERVAL_SECONDS;
		day_shot_warning_active = false;
		return;
	}

	// Preserve the exact remaining reload time until the avatar is fully reconstructed.
	var _avatar = instance_find(o_player, 0);
	if (global.pause || _avatar.is_disassembled)
	{
		return;
	}

	// Use simulation seconds, matching projectile flight and the game's pause behavior.
	var _step_seconds = global.gameplay_time_scale / max(1, room_speed);
	var _reload_multiplier = _avatar.player_taunt_is_active() ? BALANCE_PLAYER_TAUNT_RELOAD_MULTIPLIER : 1;
	var _reload_seconds = _step_seconds * _reload_multiplier;
	var _interval = max(_step_seconds, BALANCE_CANNON_DAY_SHOT_INTERVAL_SECONDS);
	var _warning_seconds = clamp(BALANCE_CANNON_DAY_SHOT_WARNING_SECONDS, 0, _interval);
	day_shot_remaining -= _reload_seconds;
	day_shot_warning_active = day_shot_remaining <= _warning_seconds;

	// Snapshot the radius when the warning begins, keeping the impact area identical.
	if (day_shot_warning_active && day_shot_remaining + _reload_seconds > _warning_seconds)
	{
		day_shot_radius = cannon_taint_compost_radius_get();
	}

	if (day_shot_remaining > 0)
	{
		return;
	}

	// Copy the current avatar position once; the shell never homes after launch.
	var _player = instance_find(o_player, 0);
	var _projectile = instance_create_layer(x, y + projectile_spawn_offset_y, projectile_layer_name, o_projectile);
	_projectile.target_x = _player.x;
	_projectile.target_y = _player.y;
	_projectile.projectile_type = PROJECTILE_TYPE.CORRUPTION;
	_projectile.projectile_sprite = s_taint_shell;
	_projectile.source_instance = id;
	_projectile.damage_faction = UNIT_FACTION.FRIENDLY;
	_projectile.effect_radius = day_shot_radius;
	_projectile.smoke_trail_enabled = true;
	_projectile.day_target_visible = true;
	_projectile.taint_compost_enchantment_x = _player.x;
	_projectile.taint_compost_enchantment_y = _player.y;
	var _distance = point_distance(_projectile.start_x, _projectile.start_y, _projectile.target_x, _projectile.target_y);
	var _flight_seconds = clamp(
		_distance / _projectile.projectile_speed,
		_projectile.minimum_flight_time,
		_projectile.maximum_flight_time
	);
	_projectile.flight_time = _flight_seconds * room_speed;

	// Restart at launch so successive shots remain one interval apart.
	day_shot_remaining += _interval;
	day_shot_warning_active = false;
	global.sound_play_random(global.cannon_shot_sounds);

	if (instance_exists(o_camera_controller))
	{
		var _camera_controller = instance_find(o_camera_controller, 0);
		_camera_controller.camera_shake_start(BALANCE_CANNON_SHOT_SHAKE_TIME, BALANCE_CANNON_SHOT_SHAKE_STRENGTH);
	}
}
