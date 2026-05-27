// Run shared movement and combat first.
event_inherited();

if (global.pause || hp <= 0 || ability_cooldown <= 0)
{
	exit;
}

if (is_being_dragged)
{
	exit;
}

// Warlock active abilities run on cooldown.
ability_timer--;

if (ability_timer <= 0)
{
	if (demon_ability == DEMON_ABILITY.WARLOCK_CURSE)
	{
		ability_popup_create(x, y, demon_ability);

		var _enemy_list = ds_list_create();
		var _enemy_count = collision_circle_list(x, y, ability_radius, o_enemy_units, false, true, _enemy_list, false);

		for (var _enemy_index = 0; _enemy_index < _enemy_count; ++_enemy_index)
		{
			var _enemy = _enemy_list[| _enemy_index];

			if (instance_exists(_enemy))
			{
				_enemy.armor_debuff_multiplier = BALANCE_ABILITY_WARLOCK_CURSE_ARMOR_MULTIPLIER;
				_enemy.armor_debuff_timer = BALANCE_ABILITY_WARLOCK_CURSE_DURATION * room_speed;
			}
		}

		ds_list_destroy(_enemy_list);
	}
	else if (demon_ability == DEMON_ABILITY.WARLOCK_SUMMON_SKELETON)
	{
		ability_popup_create(x, y, demon_ability);

		var _spawn_distance = BALANCE_ABILITY_WARLOCK_SKELETON_SPAWN_DISTANCE;
		var _spawn_direction = random(360);
		var _skeleton = instance_create_layer(
			x + lengthdir_x(_spawn_distance, _spawn_direction),
			y + lengthdir_y(_spawn_distance, _spawn_direction),
			"Instances",
			o_skeleton
		);

		_skeleton.max_hp = BALANCE_ABILITY_WARLOCK_SKELETON_HP;
		_skeleton.hp = _skeleton.max_hp;
		_skeleton.damage = BALANCE_ABILITY_WARLOCK_SKELETON_DAMAGE;
		_skeleton.life_timer = BALANCE_ABILITY_WARLOCK_SKELETON_LIFE_TIME * room_speed;
	}

	ability_timer = max(ability_cooldown / abilities_cd_spd, 1);
}
