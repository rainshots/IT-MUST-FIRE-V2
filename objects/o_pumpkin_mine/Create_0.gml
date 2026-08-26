// Initialize shared enemy detection and countdown behavior.
event_inherited();

image_xscale = 0.5;
image_yscale = image_xscale;
// Pumpkin Mine gameplay settings.
trap_radius = BALANCE_PUMPKIN_MINE_EXPLOSION_RADIUS;
trap_damage = BALANCE_PUMPKIN_MINE_DAMAGE;
smoke_particle_count = BALANCE_PUMPKIN_MINE_SMOKE_COUNT;
warning_color = COLOR_PUMPKIN_MINE_RADIUS;
particle_layer_name = "Instances";

trap_activate = function()
{
	// Damage every living enemy inside the radius at the moment of detonation.
	var _enemy_list = ds_list_create();
	var _enemy_count = collision_circle_list(
		x,
		y,
		trap_radius,
		o_enemy_units,
		false,
		true,
		_enemy_list,
		false
	);

	for (var _enemy_index = 0; _enemy_index < _enemy_count; ++_enemy_index)
	{
		var _enemy = _enemy_list[| _enemy_index];

		if (trap_enemy_is_valid(_enemy)
			&& variable_instance_exists(_enemy, "unit_damage_receive"))
		{
			_enemy.unit_damage_receive(
				trap_damage,
				UNIT_FACTION.FRIENDLY,
				false,
				false,
				noone
			);
		}
	}

	ds_list_destroy(_enemy_list);

	// The expanding flash reaches the exact gameplay radius.
	var _explosion = instance_create_layer(x, y, particle_layer_name, o_particle_explosion);

	if (instance_exists(_explosion))
	{
		_explosion.end_radius = trap_radius;
	}

	// Spread smoke uniformly over the complete explosion area.
	for (var _smoke_index = 0; _smoke_index < smoke_particle_count; ++_smoke_index)
	{
		var _smoke_direction = random(360);
		var _smoke_distance = sqrt(random(1)) * trap_radius;
		var _smoke_x = x + lengthdir_x(_smoke_distance, _smoke_direction);
		var _smoke_y = y + lengthdir_y(_smoke_distance, _smoke_direction);

		instance_create_layer(_smoke_x, _smoke_y, particle_layer_name, o_particle_smoke);
	}

	// Reuse the project's randomized explosion sound set when it is available.
	if (variable_global_exists("explosion_sounds")
		&& variable_global_exists("sound_play_random"))
	{
		global.sound_play_random(global.explosion_sounds);
	}

	instance_destroy();
};
