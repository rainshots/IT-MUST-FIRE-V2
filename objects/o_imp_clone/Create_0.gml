// Initialize shared friendly combat state without Imp passive or active hooks.
event_inherited();

// Clone stats are overwritten by the original Imp right after creation.
sprite_index = s_imp;
image_xscale = 1;
image_yscale = 1;
image_alpha = 0.72;
image_speed = 0;
max_hp = 10;
hp = max_hp;
damage = 10;
magic_damage = 0;
armor = 100;
crit_chance = 0;
reload_time = room_speed;
attack_radius = BALANCE_IMP_ATTACK_RADIUS;
move_speed = BALANCE_IMP_MOVE_SPEED;
bar_offset_y = 28;
life_timer = BALANCE_IMP_BLOODY_CLONE_LIFE_TIME * room_speed;
clone_max_life_timer = life_timer;
clone_fade_start_share = 0.35;
explosion_enabled = false;
explosion_damage = 0;

clone_blood_explosion = function()
{
	if (!explosion_enabled)
	{
		return;
	}

	var _enemy_count = instance_number(o_enemy_units);

	for (var _enemy_index = 0; _enemy_index < _enemy_count; ++_enemy_index)
	{
		var _enemy = instance_find(o_enemy_units, _enemy_index);

		if (!target_can_be_attacked(_enemy)
			|| point_distance(x, y, _enemy.x, _enemy.y) > BALANCE_IMP_BLOODY_CLONE_EXPLOSION_RADIUS)
		{
			continue;
		}

		var _final_damage = physical_damage_after_armor(explosion_damage, _enemy);

		if (variable_instance_exists(_enemy, "unit_damage_receive"))
		{
			_enemy.unit_damage_receive(_final_damage, unit_faction, false);
		}
		else
		{
			_enemy.hp = max(_enemy.hp - _final_damage, 0);
			damage_popup_create(_enemy.x, _enemy.y, _final_damage, _enemy.unit_faction, false);
		}
	}
};
