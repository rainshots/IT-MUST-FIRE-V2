// Initialize shared enemy detection and countdown behavior.
event_inherited();

image_xscale = 0.7;
image_yscale = image_xscale;

// Steel Trap gameplay settings.
trap_radius = BALANCE_STEEL_TRAP_EFFECT_RADIUS;
trap_stun_time = BALANCE_STEEL_TRAP_STUN_TIME;
warning_color = COLOR_STEEL_TRAP_RADIUS;
particle_layer_name = "Instances";

trap_activate = function()
{
	// Stun every living enemy inside the radius at the moment of activation.
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
			&& variable_instance_exists(_enemy, "stun_apply"))
		{
			_enemy.stun_apply(trap_stun_time);
		}
	}

	ds_list_destroy(_enemy_list);

	// Show a short expanding pulse across the activated area.
	var _activation_effect = instance_create_layer(x, y, particle_layer_name, o_particle_explosion);

	if (instance_exists(_activation_effect))
	{
		_activation_effect.end_radius = trap_radius;
		_activation_effect.inner_color = warning_color;
		_activation_effect.outer_color = warning_color;
	}

	instance_destroy();
};
