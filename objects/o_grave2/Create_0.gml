// The spawning tomb assigns ownership; unattached graves remain inactive.
owner_tomb = noone;
is_active = false;
image_speed = 0;
y_sort_enabled = true;
// Keep the original room layer for reinforcements after Y sorting changes depth.
spawn_layer_id = layer;

// An active grave consumes one corruption impact and deploys one archer nearby.
on_projectile_hit = function(_projectile_type)
{
	if (!is_active || _projectile_type != PROJECTILE_TYPE.CORRUPTION
		|| !instance_exists(owner_tomb) || !owner_tomb.is_infected)
	{
		return;
	}

	is_active = false;
	sprite_index = s_grave_a;
	var _full_circle = 360;
	var _angle = random(_full_circle);
	instance_create_layer(
		x + lengthdir_x(BALANCE_GRAVE2_ARCHER_SPAWN_RADIUS, _angle),
		y + lengthdir_y(BALANCE_GRAVE2_ARCHER_SPAWN_RADIUS, _angle),
		spawn_layer_id,
		o_skeleton_archer2
	);
};
