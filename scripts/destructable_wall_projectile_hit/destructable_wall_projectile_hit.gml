/// @description Applies cannon blast damage to wall masks once per impact, in projectile context.
function destructable_wall_projectile_hit()
{
	if (damage_amount <= 0 || !instance_exists(source_instance)
		|| source_instance.object_index != o_cannon || !instance_exists(o_destructable_wall))
	{
		return;
	}

	// Mask overlap allows hitting a large wall's edge even when its origin is outside the blast.
	var _walls = ds_list_create();
	var _wall_count = collision_circle_list(target_x, target_y, effect_radius,
		o_destructable_wall, false, true, _walls, false);
	for (var _wall_index = 0; _wall_index < _wall_count; ++_wall_index)
	{
		var _wall = _walls[| _wall_index];
		if (instance_exists(_wall))
		{
			// The artillery branch already handles its explicitly selected structure.
			if (projectile_type == PROJECTILE_TYPE.ARTILLERY && _wall == artillery_direct_target)
			{
				continue;
			}
			_wall.unit_damage_receive(damage_amount, damage_faction, damage_is_critical_hit, true, source_instance);
		}
	}
	ds_list_destroy(_walls);
}
