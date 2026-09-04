// Initialize shared friendly unit state and squad behavior.
event_inherited();

// Provocateur is a durable melee unit whose main role is redirecting nearby enemies.
max_hp = BALANCE_PROVOCATEUR_HP;
hp = max_hp;
armor = BALANCE_PROVOCATEUR_ARMOR;
magic_resistance = BALANCE_PROVOCATEUR_MAGIC_RESISTANCE;
damage = BALANCE_PROVOCATEUR_DAMAGE;
magic_damage = BALANCE_PROVOCATEUR_MAGIC_DAMAGE;
reload_time = BALANCE_PROVOCATEUR_RELOAD_TIME * room_speed;
attack_radius = BALANCE_PROVOCATEUR_ATTACK_RADIUS;
move_speed = BALANCE_PROVOCATEUR_MOVE_SPEED;
bar_offset_y = -2;

provocateur_taunt_timer = BALANCE_PROVOCATEUR_TAUNT_INTERVAL * room_speed;

// Provocateur approaches combat targets but never performs an attack.
attack_target = function(_target)
{
	if (instance_exists(_target))
	{
		face_world_x(_target.x);
	}

	is_attacking_target = false;
	is_walking = false;
};

provocateur_taunt_apply = function()
{
	var _taunt_radius_squared = sqr(BALANCE_PROVOCATEUR_TAUNT_RADIUS);
	var _taunt_duration = BALANCE_PROVOCATEUR_TAUNT_DURATION * room_speed;
	var _enemy_count = instance_number(o_enemy_units);

	// Every valid enemy in range receives the Provocateur as its forced combat target.
	for (var _enemy_index = 0; _enemy_index < _enemy_count; ++_enemy_index)
	{
		var _enemy = instance_find(o_enemy_units, _enemy_index);

		if (!instance_exists(_enemy)
			|| !variable_instance_exists(_enemy, "hp")
			|| !variable_instance_exists(_enemy, "unit_faction")
			|| !variable_instance_exists(_enemy, "forced_attack_target")
			|| !variable_instance_exists(_enemy, "forced_attack_target_timer")
			|| _enemy.hp <= 0
			|| _enemy.unit_faction != UNIT_FACTION.ENEMY)
		{
			continue;
		}

		// Automated arenas are isolated, so never taunt enemies from another match.
		if (balance_test_match_id >= 0
			&& (!variable_instance_exists(_enemy, "balance_test_match_id")
				|| _enemy.balance_test_match_id != balance_test_match_id))
		{
			continue;
		}

		var _distance_x = _enemy.x - x;
		var _distance_y = _enemy.y - y;
		var _distance_squared = (_distance_x * _distance_x) + (_distance_y * _distance_y);

		if (_distance_squared > _taunt_radius_squared)
		{
			continue;
		}

		_enemy.forced_attack_target = id;
		_enemy.forced_attack_target_timer = _taunt_duration;
		_enemy.target_instance = id;
		_enemy.alert_target = id;
		_enemy.alert_target_timer = _taunt_duration;
		_enemy.target_search_update_timer = _enemy.target_search_update_interval;
	}
};
