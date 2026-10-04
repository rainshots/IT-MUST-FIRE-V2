// Tomb state and linked graves are owned by this instance.
is_infected = false;
linked_graves = [];
grave_count = BALANCE_TOMB_A_GRAVE_COUNT;
grave_radius = BALANCE_TOMB_A_GRAVE_RADIUS;
activation_interval_seconds = BALANCE_TOMB_A_ACTIVATION_INTERVAL_SECONDS;
activation_timer_seconds = 0;
image_speed = 0;
y_sort_enabled = true;
// Keep the original room layer: Y sorting changes the built-in layer to -1.
spawn_layer_id = layer;

// Place an evenly spaced ring of inactive graves on the tomb's instance layer.
var _full_circle = 360;
for (var _grave_index = 0; _grave_index < grave_count; ++_grave_index)
{
	var _angle = _full_circle * _grave_index / grave_count;
	var _grave = instance_create_layer(
		x + lengthdir_x(grave_radius, _angle),
		y + lengthdir_y(grave_radius, _angle),
		spawn_layer_id,
		o_grave2
	);
	_grave.owner_tomb = id;
	array_push(linked_graves, _grave);
}

// Only the first corruption impact infects the tomb and deploys its initial archers.
on_projectile_hit = function(_projectile_type)
{
	if (is_infected || _projectile_type != PROJECTILE_TYPE.CORRUPTION)
	{
		return;
	}

	is_infected = true;
	sprite_index = s_tomb_a_active;
	activation_timer_seconds = 0;
	var _linked_count = array_length(linked_graves);
	for (var _grave_index = 0; _grave_index < _linked_count; ++_grave_index)
	{
		var _grave = linked_graves[_grave_index];
		if (instance_exists(_grave))
		{
			_grave.is_active = false;
			_grave.sprite_index = s_grave_a;
		}
	}

	var _spawn_count = BALANCE_TOMB_A_INITIAL_ARCHER_COUNT;
	var _full_circle = 360;
	for (var _unit_index = 0; _unit_index < _spawn_count; ++_unit_index)
	{
		var _angle = _full_circle * _unit_index / _spawn_count;
		instance_create_layer(
			x + lengthdir_x(BALANCE_TOMB_A_ARCHER_SPAWN_RADIUS, _angle),
			y + lengthdir_y(BALANCE_TOMB_A_ARCHER_SPAWN_RADIUS, _angle),
			spawn_layer_id,
			o_skeleton_archer2
		);
	}
};
