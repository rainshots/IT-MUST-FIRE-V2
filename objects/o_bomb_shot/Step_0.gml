// Pause freezes the fuse; fast-forward and aiming use the shared simulation scale.
if (global.pause)
{
	exit;
}

fuse_timer = max(0, fuse_timer - global.gameplay_time_scale);

if (fuse_timer > 0)
{
	exit;
}

// Damage only living enemies inside the blast, using their normal damage handling.
with (o_enemy_units)
{
	if (hp > 0 && unit_faction == UNIT_FACTION.ENEMY)
	{
		var _distance_x = x - other.x;
		var _distance_y = y - other.y;
		var _radius_squared = other.effect_radius * other.effect_radius;

		if ((_distance_x * _distance_x) + (_distance_y * _distance_y) <= _radius_squared)
		{
			unit_damage_receive(other.damage_amount, UNIT_FACTION.FRIENDLY, false, true, other.source_instance, DAMAGE_CATEGORY.EXPLOSION);
		}
	}
}

// The blast flash, smoke, and sound happen when the fuse expires, not on landing.
var _explosion = instance_create_layer(x, y, "Instances", o_particle_explosion);

if (instance_exists(_explosion))
{
	_explosion.end_radius = effect_radius;
}

for (var _smoke_index = 0; _smoke_index < smoke_count; ++_smoke_index)
{
	var _direction = random(360);
	var _distance = sqrt(random(1)) * effect_radius;
	instance_create_layer(x + lengthdir_x(_distance, _direction), y + lengthdir_y(_distance, _direction), "Instances", o_particle_smoke);
}

global.sound_play_random(global.explosion_sounds);
instance_destroy();