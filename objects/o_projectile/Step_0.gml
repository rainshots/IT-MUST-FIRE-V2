// Move the projectile along a simple artillery arc.
if (global.pause)
{
	exit;
}

// Delay launch so volley projectiles land with slight timing differences.
if (launch_delay_timer > 0)
{
	launch_delay_timer--;
	exit;
}

flight_timer++;

var _flight_progress = clamp(flight_timer / flight_time, 0, 1);
var _arc_offset = -sin(_flight_progress * pi) * arc_height;

x = lerp(start_x, target_x, _flight_progress);
y = lerp(start_y, target_y, _flight_progress) + _arc_offset;

// Apply the projectile effect when it lands.
if (_flight_progress >= 1)
{
	// Spawn the main explosion flash at the impact point.
	instance_create_layer(target_x, target_y, particle_layer_name, o_particle_explosion);

	// Spawn smoke particles across the explosion radius.
	for (var _smoke_index = 0; _smoke_index < smoke_particle_count; ++_smoke_index)
	{
		var _smoke_direction = random(360);
		var _smoke_distance = sqrt(random(1)) * effect_radius;
		var _smoke_x = target_x + lengthdir_x(_smoke_distance, _smoke_direction);
		var _smoke_y = target_y + lengthdir_y(_smoke_distance, _smoke_direction);

		instance_create_layer(_smoke_x, _smoke_y, particle_layer_name, o_particle_smoke);
	}

	// Corruption projectiles infect ground cells in the explosion radius.
	if (projectile_type == PROJECTILE_TYPE.CORRUPTION)
	{
		corrupt_circle(target_x, target_y, effect_radius, ground_corruption_amount);
	}

	with (all)
	{
		var _is_valid_target = (
			id != other.id
			&& object_index != o_projectile
			&& object_index != o_particle_smoke
			&& object_index != o_particle_explosion
			&& object_index != o_camera_controller
			&& object_index != o_game_controller
		);

		if (_is_valid_target && point_distance(x, y, other.target_x, other.target_y) <= other.effect_radius)
		{
			if (variable_instance_exists(id, "on_projectile_hit"))
			{
				on_projectile_hit(other.projectile_type);
			}
			else if (other.projectile_type == PROJECTILE_TYPE.DAMAGE)
			{
				if (variable_instance_exists(id, "health"))
				{
					health -= other.damage_amount;
				}
				else if (variable_instance_exists(id, "hp"))
				{
					hp -= other.damage_amount;
				}
			}
			else if (other.projectile_type == PROJECTILE_TYPE.CORRUPTION)
			{
				if (!variable_instance_exists(id, "corruption"))
				{
					corruption = 0;
				}

				corruption += other.corruption_amount;
			}
			else if (other.projectile_type == PROJECTILE_TYPE.SUMMON)
			{
				// Summon contract will be added when the target object API is agreed.
			}
		}
	}

	instance_destroy();
}
