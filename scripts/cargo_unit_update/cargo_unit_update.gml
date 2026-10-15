/// @description Updates individual player guarding and post-launch assault; unit context.
function cargo_unit_update()
{
	if (!instance_exists(o_cannon)) return;
	gameplay_time_scale = global.gameplay_time_scale;
	is_walking = false;
	is_attacking_target = false;
	if (cannon_loaded || is_being_dragged) return;
	// Once deployed, the objective takes priority over nearby units, houses and damage alerts.
	target_instance = noone;
	if (cargo_launched && instance_exists(o_base_tower))
	{
		var _tower = instance_nearest(x, y, o_base_tower);
		if (target_can_be_attacked(_tower)) target_instance = _tower;
	}
	if (!instance_exists(target_instance))
	{
		var _enemy = noone;
		var _nearest = infinity;
		var _count = instance_number(o_enemy_units);
		for (var _i = 0; _i < _count; ++_i)
		{
			var _candidate = instance_find(o_enemy_units, _i);
			if (!target_can_be_attacked(_candidate)) continue;
			var _distance = point_distance(x, y, _candidate.x, _candidate.y);
			var _eligible = cargo_launched ? _distance <= vision_radius
				: point_distance(o_cannon.x, o_cannon.y, _candidate.x, _candidate.y) <= BALANCE_CARGO_DEFENSE_RADIUS;
			if (_eligible && _distance < _nearest) { _enemy = _candidate; _nearest = _distance; }
		}
		// Damage alerts override the Cannon perimeter so ranged attackers can be pursued.
		if (target_can_be_attacked(alert_target)
			&& variable_instance_exists(alert_target, "unit_faction")
			&& alert_target.unit_faction == UNIT_FACTION.ENEMY)
		{
			_enemy = alert_target;
		}
		else
		{
			alert_target = noone;
			alert_target_timer = 0;
		}
		// Launched units attack nearby reward buildings on their way to the objective.
		if (!instance_exists(_enemy) && cargo_launched)
		{
			_nearest = vision_radius;
			with (o_living_house)
			{
				if (!other.target_can_be_attacked(id)) continue;
				var _distance = point_distance(other.x, other.y, x, y);
				if (_distance < _nearest) { _enemy = id; _nearest = _distance; }
			}
		}
		target_instance = _enemy;
		if (!instance_exists(target_instance) && cargo_launched && instance_exists(o_base_tower)) target_instance = instance_nearest(x, y, o_base_tower);
	}
	if (instance_exists(target_instance))
	{
		if (point_distance(x, y, target_instance.x, target_instance.y) <= attack_radius)
		{
			is_attacking_target = true;
			attack_target(target_instance);
		}
		else move_towards_target(target_instance);
	}
	else if (!cargo_launched)
	{
		var _x = o_cannon.x + cargo_idle_offset_x;
		var _y = o_cannon.y + cargo_idle_offset_y;
		if (point_distance(x, y, _x, _y) > 15) move_towards_world_point(_x, _y);
	}
	update_walk_sway();
}
