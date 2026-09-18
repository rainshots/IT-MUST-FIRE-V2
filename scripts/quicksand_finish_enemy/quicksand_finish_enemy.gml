/// @description Resolves a Quicksand upgrade against a living enemy at the end of the field.
function quicksand_finish_enemy(_enemy, _center_x, _center_y, _radius, _upgrade)
{
	if (!instance_exists(_enemy) || _enemy.hp <= 0 || _enemy.unit_faction != UNIT_FACTION.ENEMY)
	{
		return;
	}
	var _distance = point_distance(_center_x, _center_y, _enemy.x, _enemy.y);
	if (_distance > _radius)
	{
		return;
	}
	if (_upgrade == QUICKSAND_UPGRADE.DEVOUR
		&& _distance <= _radius * BALANCE_QUICKSAND_EXECUTION_RADIUS_SHARE)
	{
		// Normal death cleanup and rewards still run, but no corpse snapshot may be created.
		var _particle = instance_create_layer(_enemy.x, _enemy.y, "Instances", o_particle_explosion);
		_particle.start_radius = 20;
		_particle.end_radius = 2;
		_particle.inner_color = COLOR_QUICKSAND;
		_particle.outer_color = COLOR_QUICKSAND;
		_enemy.corpse_visual_created = true;
		_enemy.hp = 0;
		_enemy.unit_death_process();
	}
	else if (_upgrade == QUICKSAND_UPGRADE.CONFUSION)
	{
		var _proximity = 1 - clamp(_distance / max(1, _radius), 0, 1);
		var _duration = lerp(BALANCE_QUICKSAND_CONFUSION_MIN_TIME, BALANCE_QUICKSAND_CONFUSION_MAX_TIME, _proximity);
		_enemy.status_effect_apply(STATUS_EFFECT.CONFUSION, _duration);
	}
}
