// Base unit combat stats.
unit_faction = UNIT_FACTION.NOONE;
max_hp = 20;
hp = max_hp;
damage = 1;
magic_damage = 0;
reload_time = room_speed;
reload_timer = 0;
attack_radius = 32;
cannon_attack_radius = 200;
y_sort_enabled = true;

// Base unit movement and target search settings.
move_speed = 1.2;
target_detection_radius = BALANCE_UNIT_VISION_RADIUS;
vision_radius = BALANCE_UNIT_VISION_RADIUS;
cannon_guard_radius = 460;
target_instance = noone;
alert_target = noone;
alert_target_timer = 0;
alert_target_time = BALANCE_UNIT_ALERT_TARGET_TIME * room_speed;

// Rally command state is assigned by rally projectiles.
rally_group_id = 0;
rally_target_x = x;
rally_target_y = y;
rally_home_x = x;
rally_home_y = y;
rally_arrive_radius = BALANCE_PROJECTILE_RALLY_ARRIVE_RADIUS;
rally_is_active = false;
rally_is_returning = false;
rally_has_arrived = false;

// Optional guard behavior is used by spawned defenders.
owner_garnizon = noone;
guard_target = noone;
guard_radius = 220;
unit_can_attack_cannon = true;
is_night_attack_unit = false;

// Unit separation keeps units from stacking into one point.
separation_radius = 26;
separation_strength = 0.55;
separation_update_interval = 5;
separation_update_timer = irandom(separation_update_interval - 1);
separation_max_neighbors = 6;
separation_push_x = 0;
separation_push_y = 0;
combat_separation_multiplier = 0.45;
is_attacking_target = false;

// Attack feedback shows who hit whom for a short moment.
attack_feedback_time = 0.16 * room_speed;
attack_feedback_timer = 0;
attack_feedback_target = noone;
attack_feedback_target_x = x;
attack_feedback_target_y = y;
attack_feedback_line_width = 2;
attack_lunge_distance = 6;
attack_lunge_return_time_multiplier = 0.65;
visual_attack_offset_x = 0;
visual_attack_offset_y = 0;

// Optional combat modifiers used by cultist demon forms and debuffs.
armor = 100;
armor_debuff_multiplier = 1;
armor_debuff_timer = 0;
crit_chance = 0;
aoe_radius = 0;
next_attack_damage_multiplier = 1;
next_attack_radius_multiplier = 1;
is_being_dragged = false;
drag_drop_x = x;
drag_drop_y = y;

// Health bar visual settings.
bar_width = 34;
bar_height = 4;
bar_offset_y = 28;

// Walking sway tilts the sprite a little while the unit is moving.
is_walking = false;
walk_sway_angle = 4;
walk_sway_half_time = 0.16;
walk_sway_timer = random(walk_sway_half_time);
walk_sway_direction = choose(-1, 1);

face_world_x = function(_target_x)
{
	var _facing_dead_zone = 1;
	var _sprite_scale = abs(image_xscale);

	if (abs(_target_x - x) <= _facing_dead_zone)
	{
		return;
	}

	// Unit sprites need a mirrored xscale to face left in-game.
	if (_target_x < x)
	{
		image_xscale = -_sprite_scale;
	}
	else
	{
		image_xscale = _sprite_scale;
	}
};

find_nearest_target = function(_object_index, _max_distance)
{
	var _nearest_target = instance_nearest(x, y, _object_index);

	if (instance_exists(_nearest_target))
	{
		var _target_distance = point_distance(x, y, _nearest_target.x, _nearest_target.y);

		if (_target_distance <= _max_distance)
		{
			return _nearest_target;
		}
	}

	return noone;
};

find_nearest_cannon_attacker = function()
{
	if (!instance_exists(o_cannon))
	{
		return noone;
	}

	var _cannon = instance_find(o_cannon, 0);
	var _nearby_enemies = ds_list_create();
	var _enemy_count = collision_circle_list(_cannon.x, _cannon.y, cannon_attack_radius, o_enemy_units, false, true, _nearby_enemies, false);
	var _nearest_attacker = noone;
	var _nearest_distance = infinity;

	// Pick the closest enemy that is close enough to attack the cannon.
	for (var _enemy_index = 0; _enemy_index < _enemy_count; ++_enemy_index)
	{
		var _enemy = _nearby_enemies[| _enemy_index];

		if (instance_exists(_enemy) && _enemy.hp > 0)
		{
			var _enemy_distance = point_distance(x, y, _enemy.x, _enemy.y);

			if (_enemy_distance < _nearest_distance)
			{
				_nearest_attacker = _enemy;
				_nearest_distance = _enemy_distance;
			}
		}
	}

	ds_list_destroy(_nearby_enemies);

	return _nearest_attacker;
};

find_nearest_enemy_object = function(_max_distance)
{
	var _nearest_target = noone;
	var _nearest_distance = _max_distance;

	// Holy towers are hostile structures for friendly units.
	if (instance_exists(o_holy_tower))
	{
		var _holy_tower_count = instance_number(o_holy_tower);

		for (var _tower_index = 0; _tower_index < _holy_tower_count; ++_tower_index)
		{
			var _tower = instance_find(o_holy_tower, _tower_index);

			if (instance_exists(_tower) && _tower.hp > 0)
			{
				var _tower_distance = point_distance(x, y, _tower.x, _tower.y);

				if (_tower_distance <= _nearest_distance)
				{
					_nearest_distance = _tower_distance;
					_nearest_target = _tower;
				}
			}
		}
	}

	// Garnizons are hostile structures for friendly units.
	if (instance_exists(o_garnizon))
	{
		var _garnizon_count = instance_number(o_garnizon);

		for (var _garnizon_index = 0; _garnizon_index < _garnizon_count; ++_garnizon_index)
		{
			var _garnizon = instance_find(o_garnizon, _garnizon_index);

			if (instance_exists(_garnizon) && _garnizon.hp > 0)
			{
				var _garnizon_distance = point_distance(x, y, _garnizon.x, _garnizon.y);

				if (_garnizon_distance <= _nearest_distance)
				{
					_nearest_distance = _garnizon_distance;
					_nearest_target = _garnizon;
				}
			}
		}
	}

	return _nearest_target;
};

move_towards_target = function(_target)
{
	if (instance_exists(_target))
	{
		var _target_direction = point_direction(x, y, _target.x, _target.y);

		is_walking = true;
		face_world_x(_target.x);
		x += lengthdir_x(move_speed, _target_direction);
		y += lengthdir_y(move_speed, _target_direction);
	}
};

move_towards_world_point = function(_target_x, _target_y)
{
	var _target_direction = point_direction(x, y, _target_x, _target_y);

	is_walking = true;
	face_world_x(_target_x);
	x += lengthdir_x(move_speed, _target_direction);
	y += lengthdir_y(move_speed, _target_direction);
};

update_walk_sway = function()
{
	if (!is_walking)
	{
		walk_sway_timer = 0;
		walk_sway_direction = 1;
		image_angle = 0;
		return;
	}

	walk_sway_timer += 1 / max(1, room_speed);

	if (walk_sway_timer >= walk_sway_half_time)
	{
		walk_sway_timer -= walk_sway_half_time;
		walk_sway_direction *= -1;
	}

	image_angle = walk_sway_angle * walk_sway_direction;
};

start_attack_lunge = function(_target)
{
	if (!instance_exists(_target))
	{
		return;
	}

	var _lunge_direction = point_direction(x, y, _target.x, _target.y);

	visual_attack_offset_x = lengthdir_x(attack_lunge_distance, _lunge_direction);
	visual_attack_offset_y = lengthdir_y(attack_lunge_distance, _lunge_direction);
};

update_attack_lunge = function()
{
	var _return_time = max(1, reload_time * attack_lunge_return_time_multiplier);
	var _return_amount = attack_lunge_distance / _return_time;
	var _offset_distance = point_distance(0, 0, visual_attack_offset_x, visual_attack_offset_y);

	if (_offset_distance <= 0)
	{
		visual_attack_offset_x = 0;
		visual_attack_offset_y = 0;
		return;
	}

	if (_offset_distance <= _return_amount)
	{
		visual_attack_offset_x = 0;
		visual_attack_offset_y = 0;
		return;
	}

	var _return_direction = point_direction(visual_attack_offset_x, visual_attack_offset_y, 0, 0);

	visual_attack_offset_x += lengthdir_x(_return_amount, _return_direction);
	visual_attack_offset_y += lengthdir_y(_return_amount, _return_direction);
};

rally_group_ready_to_return = function()
{
	var _friendly_count = instance_number(o_friendly_units);

	for (var _friendly_index = 0; _friendly_index < _friendly_count; ++_friendly_index)
	{
		var _friendly_unit = instance_find(o_friendly_units, _friendly_index);

		if (instance_exists(_friendly_unit)
			&& _friendly_unit.rally_is_active
			&& !_friendly_unit.rally_is_returning
			&& _friendly_unit.rally_group_id == rally_group_id)
		{
			if (!_friendly_unit.rally_has_arrived
				|| _friendly_unit.is_attacking_target
				|| instance_exists(_friendly_unit.target_instance))
			{
				return false;
			}
		}
	}

	return true;
};

rally_group_start_returning = function()
{
	var _friendly_count = instance_number(o_friendly_units);

	for (var _friendly_index = 0; _friendly_index < _friendly_count; ++_friendly_index)
	{
		var _friendly_unit = instance_find(o_friendly_units, _friendly_index);

		if (instance_exists(_friendly_unit)
			&& _friendly_unit.rally_is_active
			&& _friendly_unit.rally_group_id == rally_group_id)
		{
			_friendly_unit.rally_is_returning = true;
			_friendly_unit.rally_has_arrived = false;
		}
	}
};

update_separation_push = function()
{
	separation_update_timer++;

	if (separation_update_timer mod separation_update_interval != 0)
	{
		return;
	}

	var _separation_object = o_units_parent;

	if (unit_faction == UNIT_FACTION.ENEMY)
	{
		_separation_object = o_enemy_units;
	}
	else if (unit_faction == UNIT_FACTION.FRIENDLY)
	{
		_separation_object = o_friendly_units;
	}

	var _nearby_units = ds_list_create();
	var _nearby_unit_count = collision_circle_list(x, y, separation_radius, _separation_object, false, true, _nearby_units, false);
	var _checked_unit_count = min(_nearby_unit_count, separation_max_neighbors);
	var _push_x = 0;
	var _push_y = 0;

	// Push away from a few nearby units. This avoids expensive full crowd checks.
	for (var _unit_index = 0; _unit_index < _checked_unit_count; ++_unit_index)
	{
		var _nearby_unit = _nearby_units[| _unit_index];

		if (instance_exists(_nearby_unit) && _nearby_unit != id)
		{
			var _distance_to_unit = point_distance(x, y, _nearby_unit.x, _nearby_unit.y);
			var _push_direction = point_direction(_nearby_unit.x, _nearby_unit.y, x, y);

			if (_distance_to_unit <= 0)
			{
				_distance_to_unit = 1;
				_push_direction = (_unit_index * 47) mod 360;
			}

			var _push_amount = 1 - clamp(_distance_to_unit / separation_radius, 0, 1);

			_push_x += lengthdir_x(_push_amount, _push_direction);
			_push_y += lengthdir_y(_push_amount, _push_direction);
		}
	}

	ds_list_destroy(_nearby_units);

	separation_push_x = clamp(_push_x, -1, 1) * separation_strength;
	separation_push_y = clamp(_push_y, -1, 1) * separation_strength;
};

apply_separation_push = function()
{
	var _separation_multiplier = 1;

	if (is_attacking_target)
	{
		_separation_multiplier = combat_separation_multiplier;
	}

	x += separation_push_x * _separation_multiplier;
	y += separation_push_y * _separation_multiplier;
};

physical_damage_after_armor = function(_raw_damage, _target)
{
	if (!instance_exists(_target) || !variable_instance_exists(_target, "armor"))
	{
		return _raw_damage;
	}

	var _target_armor = _target.armor;

	if (variable_instance_exists(_target, "armor_debuff_multiplier"))
	{
		_target_armor *= _target.armor_debuff_multiplier;
	}

	var _armor_damage_multiplier = max(2 - (min(_target_armor, 190) * 0.01), 0.1);
	return _raw_damage * _armor_damage_multiplier;
};

attack_target = function(_target)
{
	if (!instance_exists(_target))
	{
		return;
	}

	face_world_x(_target.x);

	if (reload_timer > 0)
	{
		reload_timer--;
		return;
	}

	var _is_magic_damage = magic_damage > 0;
	var _base_attack_damage = damage;

	if (_is_magic_damage)
	{
		_base_attack_damage = magic_damage;
	}

	var _damage_amount = _base_attack_damage * next_attack_damage_multiplier;

	if (variable_instance_exists(id, "demon_ability")
		&& demon_ability == DEMON_ABILITY.IMP_BLOOD_RAGE
		&& hp < max_hp * BALANCE_ABILITY_IMP_BLOOD_RAGE_HP_THRESHOLD)
	{
		_damage_amount *= BALANCE_ABILITY_IMP_BLOOD_RAGE_DAMAGE_MULTIPLIER;
	}

	var _is_critical_hit = false;

	if (crit_chance > 0 && random(1) < crit_chance)
	{
		_damage_amount *= 2;
		_is_critical_hit = true;
	}

	var _raw_damage_amount = _damage_amount;

	if (!_is_magic_damage)
	{
		_damage_amount = physical_damage_after_armor(_raw_damage_amount, _target);
	}

	if (variable_instance_exists(_target, "hp"))
	{
		_target.hp = max(_target.hp - _damage_amount, 0);
		start_attack_lunge(_target);

		if (variable_instance_exists(_target, "unit_faction"))
		{
			damage_popup_create(_target.x, _target.y, _damage_amount, _target.unit_faction, _is_critical_hit);
		}
	}

	if (aoe_radius > 0)
	{
		var _aoe_object = o_enemy_units;

		if (unit_faction == UNIT_FACTION.ENEMY)
		{
			_aoe_object = o_friendly_units;
		}

		var _aoe_list = ds_list_create();
		var _aoe_range = aoe_radius * next_attack_radius_multiplier;
		var _aoe_count = collision_circle_list(_target.x, _target.y, _aoe_range, _aoe_object, false, true, _aoe_list, false);

		for (var _aoe_index = 0; _aoe_index < _aoe_count; ++_aoe_index)
		{
			var _aoe_target = _aoe_list[| _aoe_index];

			if (instance_exists(_aoe_target) && _aoe_target != _target && variable_instance_exists(_aoe_target, "hp"))
			{
				var _aoe_damage_amount = _raw_damage_amount;

				if (!_is_magic_damage)
				{
					_aoe_damage_amount = physical_damage_after_armor(_raw_damage_amount, _aoe_target);
				}

				_aoe_target.hp = max(_aoe_target.hp - _aoe_damage_amount, 0);

				if (variable_instance_exists(_aoe_target, "unit_faction"))
				{
					damage_popup_create(_aoe_target.x, _aoe_target.y, _aoe_damage_amount, _aoe_target.unit_faction);
				}
			}
		}

		ds_list_destroy(_aoe_list);
	}

	next_attack_damage_multiplier = 1;
	next_attack_radius_multiplier = 1;

	// Store attack feedback position even if the target dies immediately after hit.
	attack_feedback_target = _target;
	attack_feedback_target_x = _target.x;
	attack_feedback_target_y = _target.y;
	attack_feedback_timer = attack_feedback_time;

	reload_timer = reload_time;
};
