/// @description F8 removes enemy troops and buildings without crediting artificial damage to squads.
function battle_enemies_clear()
{
	// Unregister hostile ground sources before removing buildings; skip converted structures.
	with (o_map_objects_parent)
	{
		var _enemy_building = battle_object_is_enemy(object_index);
		if (variable_instance_exists(id, "unit_faction")) _enemy_building = unit_faction == UNIT_FACTION.ENEMY;
		if (variable_instance_exists(id, "is_corrupted") && is_corrupted) _enemy_building = false;
		if (variable_instance_exists(id, "is_captured") && is_captured) _enemy_building = false;
		if (!_enemy_building) continue;
		if (variable_instance_exists(id, "holy_tower_saint_source_unregister")) holy_tower_saint_source_unregister();
		if (variable_instance_exists(id, "shrine_saint_source_unregister")) shrine_saint_source_unregister();
		if (variable_instance_exists(id, "shrine_saint_projectile_sources_unregister")) shrine_saint_projectile_sources_unregister();
		instance_destroy();
	}
	with (o_units_parent)
	{
		if (unit_faction == UNIT_FACTION.ENEMY)
		{
			hp = 0;
			instance_destroy();
		}
	}
	with (o_holy_cannon_strike) instance_destroy();
}
